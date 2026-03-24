package dal;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.StockMovementHistoryItem;

public class StockMovementHistoryDAO {

    public int count(String keyword,
            String movementType,
            String referenceCode,
            String performedBy,
            Date from,
            Date to,
            Long productId) throws Exception {

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();

        sql.append("""
            SELECT COUNT(*)
            FROM (
                SELECT ir.import_id
                FROM import_receipts ir
                JOIN import_receipt_lines irl ON ir.import_id = irl.import_id
                JOIN products p ON p.product_id = irl.product_id
                LEFT JOIN users u ON u.user_id = ir.created_by
                WHERE ir.status = 'CONFIRMED'
            """);

        appendFilters(sql, params, keyword, "IMPORT", movementType, referenceCode, performedBy, from, to, productId);

        sql.append("""
                UNION ALL

                SELECT er.export_id
                FROM export_receipts er
                JOIN export_receipt_lines erl ON er.export_id = erl.export_id
                JOIN products p ON p.product_id = erl.product_id
                LEFT JOIN users u ON u.user_id = er.created_by
                WHERE er.status = 'CONFIRMED'
            """);

        appendFilters(sql, params, keyword, "EXPORT", movementType, referenceCode, performedBy, from, to, productId);

        sql.append("""
            ) x
        """);

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            setParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    public List<StockMovementHistoryItem> list(String keyword,
            String movementType,
            String referenceCode,
            String performedBy,
            Date from,
            Date to,
            Long productId,
            int page,
            int pageSize) throws Exception {

        if (page < 1) {
            page = 1;
        }
        if (pageSize <= 0) {
            pageSize = 10;
        }

        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();

        sql.append("""
            SELECT *
            FROM (
                SELECT
                    ir.receipt_date AS movement_time,
                    ir.import_id AS reference_id,
                    p.product_code,
                    p.product_name,
                    'IMPORT' AS movement_type,
                    irl.qty AS qty_change,
                    ir.import_code AS reference_code,
                    COALESCE(u.full_name, CONCAT('User #', ir.created_by)) AS performed_by,
                    ir.note AS header_note,
                    irl.item_note AS line_note
                FROM import_receipts ir
                JOIN import_receipt_lines irl ON ir.import_id = irl.import_id
                JOIN products p ON p.product_id = irl.product_id
                LEFT JOIN users u ON u.user_id = ir.created_by
                WHERE ir.status = 'CONFIRMED'
            """);

        appendFilters(sql, params, keyword, "IMPORT", movementType, referenceCode, performedBy, from, to, productId);

        sql.append("""
                UNION ALL

                SELECT
                    er.export_date AS movement_time,
                    er.export_id AS reference_id,
                    p.product_code,
                    p.product_name,
                    'EXPORT' AS movement_type,
                    (-erl.qty) AS qty_change,
                    er.export_code AS reference_code,
                    COALESCE(u.full_name, CONCAT('User #', er.created_by)) AS performed_by,
                    er.note AS header_note,
                    erl.item_note AS line_note
                FROM export_receipts er
                JOIN export_receipt_lines erl ON er.export_id = erl.export_id
                JOIN products p ON p.product_id = erl.product_id
                LEFT JOIN users u ON u.user_id = er.created_by
                WHERE er.status = 'CONFIRMED'
            """);

        appendFilters(sql, params, keyword, "EXPORT", movementType, referenceCode, performedBy, from, to, productId);

        sql.append("""
            ) x
            ORDER BY x.movement_time DESC, x.reference_code DESC, x.product_code ASC
            LIMIT ? OFFSET ?
        """);

        params.add(pageSize);
        params.add(offset);

        List<StockMovementHistoryItem> rows = new ArrayList<>();

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            setParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StockMovementHistoryItem item = new StockMovementHistoryItem();
                    item.setMovementTime(rs.getTimestamp("movement_time"));
                    item.setReferenceId(rs.getLong("reference_id"));
                    item.setProductCode(rs.getString("product_code"));
                    item.setProductName(rs.getString("product_name"));
                    item.setMovementType(rs.getString("movement_type"));
                    item.setQtyChange(rs.getInt("qty_change"));
                    item.setReferenceCode(rs.getString("reference_code"));
                    item.setPerformedBy(rs.getString("performed_by"));
                    item.setHeaderNote(rs.getString("header_note"));
                    item.setLineNote(rs.getString("line_note"));
                    rows.add(item);
                }
            }
        }

        return rows;
    }

    private void appendFilters(StringBuilder sql,
            List<Object> params,
            String keyword,
            String rowType,
            String selectedType,
            String referenceCode,
            String performedBy,
            Date from,
            Date to,
            Long productId) {

        if (selectedType != null && !selectedType.isBlank() && !"ALL".equalsIgnoreCase(selectedType)) {
            if (!rowType.equalsIgnoreCase(selectedType.trim())) {
                sql.append(" AND 1 = 0 ");
            }
        }

        if (productId != null) {
            sql.append(" AND p.product_id = ? ");
            params.add(productId);
        }

        if (keyword != null && !keyword.isBlank()) {
            sql.append("""
                AND (
                    p.product_code LIKE ?
                    OR p.product_name LIKE ?
                )
            """);
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (referenceCode != null && !referenceCode.isBlank()) {
            if ("IMPORT".equalsIgnoreCase(rowType)) {
                sql.append(" AND ir.import_code LIKE ? ");
            } else {
                sql.append(" AND er.export_code LIKE ? ");
            }
            params.add("%" + referenceCode.trim() + "%");
        }

        if (performedBy != null && !performedBy.isBlank()) {
            sql.append(" AND COALESCE(u.full_name, '') LIKE ? ");
            params.add("%" + performedBy.trim() + "%");
        }

        if (from != null) {
            if ("IMPORT".equalsIgnoreCase(rowType)) {
                sql.append(" AND DATE(ir.receipt_date) >= ? ");
            } else {
                sql.append(" AND DATE(er.export_date) >= ? ");
            }
            params.add(from);
        }

        if (to != null) {
            if ("IMPORT".equalsIgnoreCase(rowType)) {
                sql.append(" AND DATE(ir.receipt_date) <= ? ");
            } else {
                sql.append(" AND DATE(er.export_date) <= ? ");
            }
            params.add(to);
        }
    }

    private void setParams(PreparedStatement ps, List<Object> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }
}
