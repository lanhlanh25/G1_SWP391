package dal;

import model.ExportReceiptDetailHeader;
import model.ExportReceiptDetailLine;
import model.ExportReceiptListItem;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class ExportReceiptDAO {

    // =========================
    // DETAIL HEADER
    // =========================
    public ExportReceiptDetailHeader getDetailHeader(long exportId) {
        String sql = """
            SELECT er.export_id, er.export_code, er.export_date, er.note, er.status,
                   req.request_code,
                   u.full_name AS created_by_name
            FROM export_receipts er
            LEFT JOIN export_requests req ON req.request_id = er.request_id
            LEFT JOIN users u ON u.user_id = er.created_by
            WHERE er.export_id = ?
        """;

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, exportId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                ExportReceiptDetailHeader h = new ExportReceiptDetailHeader();
                h.setExportId(rs.getLong("export_id"));
                h.setExportCode(rs.getString("export_code"));
                h.setNote(rs.getString("note"));
                h.setStatus(rs.getString("status"));
                h.setRequestCode(rs.getString("request_code"));
                h.setCreatedByName(rs.getString("created_by_name"));

                Timestamp ts = rs.getTimestamp("export_date");
                if (ts != null) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
                    h.setExportDateUi(sdf.format(ts));
                } else {
                    h.setExportDateUi("");
                }
                return h;
            }

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // =========================
    // DETAIL LINES + IMEIs
    // =========================
    public List<ExportReceiptDetailLine> getDetailLines(long exportId) {
        String sql = """
    SELECT erl.line_id, erl.qty, erl.item_note,
           p.product_code,
           s.sku_code,
           u.full_name AS created_by_name
    FROM export_receipt_lines erl
    JOIN products p ON p.product_id = erl.product_id
    JOIN product_skus s ON s.sku_id = erl.sku_id
    JOIN export_receipts er ON er.export_id = erl.export_id
    JOIN users u ON u.user_id = er.created_by
    WHERE erl.export_id = ?
    ORDER BY erl.line_id ASC
""";

        String sqlImei = """
            SELECT imei
            FROM export_receipt_units
            WHERE line_id = ?
            ORDER BY eru_id ASC
        """;

        List<ExportReceiptDetailLine> out = new ArrayList<>();

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); PreparedStatement psImei = con.prepareStatement(sqlImei)) {

            ps.setLong(1, exportId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ExportReceiptDetailLine it = new ExportReceiptDetailLine();

                    long lineId = rs.getLong("line_id");
                    it.setLineId(lineId);
                    it.setQty(rs.getInt("qty"));
                    it.setProductCode(rs.getString("product_code"));
                    it.setSkuCode(rs.getString("sku_code"));
                    it.setCreatedByName(rs.getString("created_by_name"));
                    it.setItemNote(rs.getString("item_note"));

                    // IMEIs
                    List<String> imeis = new ArrayList<>();
                    psImei.setLong(1, lineId);
                    try (ResultSet r2 = psImei.executeQuery()) {
                        while (r2.next()) {
                            imeis.add(r2.getString("imei"));
                        }
                    }
                    it.setImeis(imeis);

                    out.add(it);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return out;
    }

    // =========================
    // LIST + FILTER + PAGING
    // =========================
    public int countList(String q, String status, java.sql.Date from, java.sql.Date to) {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(DISTINCT er.export_id)
            FROM export_receipts er
            LEFT JOIN export_requests req ON req.request_id = er.request_id
            LEFT JOIN users u ON u.user_id = er.created_by
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND er.export_code LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND er.status = ? ");
            params.add(status.trim());
        }
        if (from != null) {
            sql.append(" AND DATE(er.export_date) >= ? ");
            params.add(from);
        }
        if (to != null) {
            sql.append(" AND DATE(er.export_date) <= ? ");
            params.add(to);
        }

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public List<ExportReceiptListItem> list(String q, String status, java.sql.Date from, java.sql.Date to,
            int page, int pageSize) {

        StringBuilder sql = new StringBuilder("""
            SELECT er.export_id, er.export_code, er.export_date, er.status,
                   COALESCE(req.request_code, '-') AS request_code,
                   COALESCE(u.full_name, '-') AS created_by_name,
                   COALESCE(SUM(erl.qty), 0) AS total_qty
            FROM export_receipts er
            LEFT JOIN export_requests req ON req.request_id = er.request_id
            LEFT JOIN users u ON u.user_id = er.created_by
            LEFT JOIN export_receipt_lines erl ON erl.export_id = er.export_id
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND er.export_code LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND er.status = ? ");
            params.add(status.trim());
        }
        if (from != null) {
            sql.append(" AND DATE(er.export_date) >= ? ");
            params.add(from);
        }
        if (to != null) {
            sql.append(" AND DATE(er.export_date) <= ? ");
            params.add(to);
        }

        sql.append("""
            GROUP BY er.export_id, er.export_code, er.export_date, er.status, req.request_code, u.full_name
            ORDER BY er.export_id DESC
            LIMIT ? OFFSET ?
        """);

        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<ExportReceiptListItem> out = new ArrayList<>();

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

                while (rs.next()) {
                    ExportReceiptListItem it = new ExportReceiptListItem();
                    it.setExportId(rs.getLong("export_id"));
                    it.setExportCode(rs.getString("export_code"));
                    it.setRequestCode(rs.getString("request_code"));
                    it.setCreatedByName(rs.getString("created_by_name"));
                    it.setStatus(rs.getString("status"));
                    it.setTotalQty(rs.getInt("total_qty"));

                    Timestamp ts = rs.getTimestamp("export_date");
                    it.setExportDateUi(ts == null ? "" : sdf.format(ts));

                    out.add(it);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return out;
    }

    // =========================
    // CREATE EXPORT RECEIPT (manual)
    // =========================
public long createReceipt(Connection con,
        Long requestId,
        long createdBy,
        Timestamp exportDate,
        String note,
        String status) throws SQLException {

    String sql = """
        INSERT INTO export_receipts(request_id, export_code, created_by, export_date, note, status)
        VALUES (?, ?, ?, ?, ?, ?)
    """;

    String exportCode = generateExportCode(con, exportDate);

    try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

        if (requestId == null) ps.setNull(1, Types.BIGINT);
        else ps.setLong(1, requestId);

        ps.setString(2, exportCode);
        ps.setLong(3, createdBy);
        ps.setTimestamp(4, exportDate);

        ps.setString(5, note == null ? "" : note);
        ps.setString(6, (status == null || status.isBlank()) ? "DRAFT" : status);

        ps.executeUpdate();

        try (ResultSet rs = ps.getGeneratedKeys()) {
            if (rs.next()) return rs.getLong(1);
        }
    }
    throw new SQLException("Cannot create export receipt");
}

    public long createLine(Connection con,
            long exportId,
            long productId,
            long skuId,
            int qty,
            String itemNote) throws SQLException {

        String sql = """
    INSERT INTO export_receipt_lines(export_id, product_id, sku_id, qty, item_note)
    VALUES(?, ?, ?, ?, ?)
""";

        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, exportId);
            ps.setLong(2, productId);
            ps.setLong(3, skuId);
            ps.setInt(4, qty);
            ps.setString(5, itemNote);

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }

        throw new SQLException("Cannot create export receipt line");
    }

    public void insertUnitImeis(Connection con, long lineId, List<String> imeis) throws SQLException {
        if (imeis == null || imeis.isEmpty()) {
            return;
        }

        String sql = """
            INSERT INTO export_receipt_units(line_id, imei)
            VALUES(?, ?)
        """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (String imei : imeis) {
                if (imei == null) {
                    continue;
                }
                imei = imei.trim();
                if (imei.isBlank()) {
                    continue;
                }

                ps.setLong(1, lineId);
                ps.setString(2, imei);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

public String generateExportCode(Connection con, Timestamp exportDate) throws SQLException {
    if (exportDate == null) exportDate = new Timestamp(System.currentTimeMillis());

    String sql = """
        SELECT COUNT(*)
        FROM export_receipts
        WHERE DATE(export_date) = DATE(?)
    """;

    int count = 0;
    try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setTimestamp(1, exportDate);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) count = rs.getInt(1);
        }
    }

    java.time.LocalDate d = exportDate.toLocalDateTime().toLocalDate();
    String ymd = d.format(java.time.format.DateTimeFormatter.BASIC_ISO_DATE);
    String seq = String.format("%03d", count + 1);

    return "EX-" + ymd + "-" + seq;
}

    public Long findProductIdByCode(Connection con, String productCode) throws Exception {
        String sql = "SELECT product_id FROM products WHERE product_code = ?";
        try (var ps = con.prepareStatement(sql)) {
            ps.setString(1, productCode);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    public Long findSkuIdByCode(Connection con, String skuCode) throws Exception {
        String sql = "SELECT sku_id FROM product_skus WHERE sku_code = ?";
        try (var ps = con.prepareStatement(sql)) {
            ps.setString(1, skuCode);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

// Optional: verify SKU belongs to Product
    public boolean skuBelongsToProduct(Connection con, long skuId, long productId) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE sku_id=? AND product_id=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, skuId);
            ps.setLong(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
    
    // 1) List IMEIs available in stock for a SKU (ACTIVE only)
public List<String> listAvailableImeisBySku(Connection con, long skuId) throws SQLException {
    String sql = """
        SELECT imei
        FROM product_units
        WHERE sku_id = ?
          AND unit_status = 'ACTIVE'
        ORDER BY imei ASC
        LIMIT 500
    """;
    List<String> out = new ArrayList<>();
    try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setLong(1, skuId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getString(1));
        }
    }
    return out;
}

// 2) Mark an IMEI as exported (ACTIVE -> INACTIVE). Return true if success.
public boolean markUnitInactive(Connection con, long skuId, String imei) throws SQLException {
    String sql = """
        UPDATE product_units
        SET unit_status = 'INACTIVE', updated_at = CURRENT_TIMESTAMP
        WHERE sku_id = ?
          AND imei = ?
          AND unit_status = 'ACTIVE'
    """;
    try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setLong(1, skuId);
        ps.setString(2, imei);
        return ps.executeUpdate() == 1;
    }
}
}
