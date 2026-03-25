package dal;

import model.InventoryReportRow;
import model.IdName;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class InventoryReportDAO {

    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }

    public List<IdName> getActiveBrands() throws Exception {
        List<IdName> list = new ArrayList<>();
        String sql = "SELECT brand_id, brand_name FROM brands "
                + "WHERE is_active = 1 ORDER BY brand_name";
        try (Connection con = getConn();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new IdName(rs.getLong("brand_id"), rs.getString("brand_name")));
            }
        }
        return list;
    }

    /* ───── Summary KPI ───── */
    public Map<String, Integer> getSummary(Date from, Date to, Long brandId) throws Exception {

        Map<String, Integer> m = new HashMap<>();
        m.put("totalImport", 0);
        m.put("totalExport", 0);
        m.put("totalClosing", 0);
        m.put("totalOpening", 0);
        m.put("totalBelowRop", 0);
        m.put("totalOutOfStock", 0);

        // Subqueries to sum transactions. We consider 'CONFIRMED', 'COMPLETED', and
        // 'DONE' as inventory movements.
        String sql = "SELECT "
                + "  SUM(opening_qty) AS tot_opening, "
                + "  SUM(import_period) AS tot_import, "
                + "  SUM(export_period) AS tot_export, "
                + "  SUM(closing_qty) AS tot_closing, "
                + "  SUM(CASE WHEN closing_qty < threshold THEN 1 ELSE 0 END) AS below_rop, "
                + "  SUM(CASE WHEN closing_qty <= 0 THEN 1 ELSE 0 END) AS out_of_stock "
                + "FROM ( "
                + "  SELECT p.product_id, "
                + "    COALESCE(p.min_stock, 10) AS threshold, "
                + "    COALESCE(cur.total_qty, 0) AS cur_qty, "
                + "    COALESCE(ci.qty, 0) AS import_period, "
                + "    COALESCE(ce.qty, 0) AS export_period, "
                + "    COALESCE(fi.qty, 0) AS future_imp, "
                + "    COALESCE(fe.qty, 0) AS future_exp, "
                + "    (COALESCE(cur.total_qty, 0) - COALESCE(fi.qty, 0) + COALESCE(fe.qty, 0)) AS closing_qty, "
                + "    (COALESCE(cur.total_qty, 0) - COALESCE(fi.qty, 0) + COALESCE(fe.qty, 0) - COALESCE(ci.qty, 0) + COALESCE(ce.qty, 0)) AS opening_qty "
                + "  FROM products p "
                + "  /* Current real-time balance */ "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, COUNT(*) AS total_qty FROM product_units pu "
                + "    JOIN product_skus s ON s.sku_id = pu.sku_id "
                + "    WHERE pu.unit_status = 'ACTIVE' GROUP BY s.product_id "
                + "  ) cur ON cur.product_id = p.product_id "
                + "  /* Period Import */ "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, SUM(irl.qty) AS qty FROM import_receipt_lines irl "
                + "    JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "    JOIN product_skus s ON s.sku_id = irl.sku_id "
                + "    WHERE UPPER(ir.status) IN ('CONFIRMED','COMPLETED','DONE') AND DATE(ir.receipt_date) >= ? AND DATE(ir.receipt_date) <= ? GROUP BY s.product_id "
                + "  ) ci ON ci.product_id = p.product_id "
                + "  /* Period Export */ "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, SUM(erl.qty) AS qty FROM export_receipt_lines erl "
                + "    JOIN export_receipts er ON er.export_id = erl.export_id "
                + "    JOIN product_skus s ON s.sku_id = erl.sku_id "
                + "    WHERE UPPER(er.status) IN ('CONFIRMED','COMPLETED','DONE') AND DATE(er.export_date) >= ? AND DATE(er.export_date) <= ? GROUP BY s.product_id "
                + "  ) ce ON ce.product_id = p.product_id "
                + "  /* Future Import (after 'to' date) */ "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, SUM(irl.qty) AS qty FROM import_receipt_lines irl "
                + "    JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "    JOIN product_skus s ON s.sku_id = irl.sku_id "
                + "    WHERE UPPER(ir.status) IN ('CONFIRMED','COMPLETED','DONE') AND DATE(ir.receipt_date) > ? GROUP BY s.product_id "
                + "  ) fi ON fi.product_id = p.product_id "
                + "  /* Future Export (after 'to' date) */ "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, SUM(erl.qty) AS qty FROM export_receipt_lines erl "
                + "    JOIN export_receipts er ON er.export_id = erl.export_id "
                + "    JOIN product_skus s ON s.sku_id = erl.sku_id "
                + "    WHERE UPPER(er.status) IN ('CONFIRMED','COMPLETED','DONE') AND DATE(er.export_date) > ? GROUP BY s.product_id "
                + "  ) fe ON fe.product_id = p.product_id "
                + "  WHERE p.status = 'ACTIVE' "
                + (brandId != null ? " AND p.brand_id = ? " : "")
                + ") t";

        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = 1;
            ps.setDate(idx++, from); // ci
            ps.setDate(idx++, to); // ci
            ps.setDate(idx++, from); // ce
            ps.setDate(idx++, to); // ce
            ps.setDate(idx++, to); // fi (after to)
            ps.setDate(idx++, to); // fe (after to)
            if (brandId != null) {
                ps.setLong(idx++, brandId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.put("totalOpening", rs.getInt("tot_opening"));
                    m.put("totalImport", rs.getInt("tot_import"));
                    m.put("totalExport", rs.getInt("tot_export"));
                    m.put("totalClosing", rs.getInt("tot_closing"));
                    m.put("totalBelowRop", rs.getInt("below_rop"));
                    m.put("totalOutOfStock", rs.getInt("out_of_stock"));
                }
            }
        }
        return m;
    }

    /* ───── Count ───── */
    public int count(Date from, Date to, Long brandId, String keyword) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT p.product_id) "
                        + "FROM products p "
                        + "JOIN brands b ON b.brand_id = p.brand_id "
                        + "WHERE p.status = 'ACTIVE' AND b.is_active = 1 ");
        List<Object> params = new ArrayList<>();
        if (brandId != null) {
            sql.append(" AND p.brand_id = ? ");
            params.add(brandId);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ?) ");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
        }
        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            bindParams(ps, params, 1);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    /* ───── List ───── */
    public List<InventoryReportRow> list(Date from, Date to, Long brandId,
            String keyword, int page, int pageSize)
            throws Exception {

        int offset = (page - 1) * pageSize;
        String sql = "SELECT "
                + "  p.product_id, p.product_code, p.product_name, b.brand_name, "
                + "  COALESCE(cur.total_qty, 0) AS current_qty, "
                + "  COALESCE(ci.qty, 0) AS import_period, "
                + "  COALESCE(ce.qty, 0) AS export_period, "
                + "  COALESCE(fi.qty, 0) AS future_imp, "
                + "  COALESCE(fe.qty, 0) AS future_exp, "
                + "  COALESCE(p.min_stock, 10) AS threshold "
                + "FROM products p "
                + "JOIN brands b ON b.brand_id = p.brand_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, COUNT(*) AS total_qty FROM product_units pu "
                + "  JOIN product_skus s ON s.sku_id = pu.sku_id "
                + "  WHERE pu.unit_status = 'ACTIVE' GROUP BY s.product_id "
                + ") cur ON cur.product_id = p.product_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, SUM(irl.qty) AS qty FROM import_receipt_lines irl "
                + "  JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "  JOIN product_skus s ON s.sku_id = irl.sku_id "
                + "  WHERE UPPER(ir.status) IN ('CONFIRMED','COMPLETED','DONE') AND DATE(ir.receipt_date) >= ? AND DATE(ir.receipt_date) <= ? GROUP BY s.product_id "
                + ") ci ON ci.product_id = p.product_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, SUM(erl.qty) AS qty FROM export_receipt_lines erl "
                + "  JOIN export_receipts er ON er.export_id = erl.export_id "
                + "  JOIN product_skus s ON s.sku_id = erl.sku_id "
                + "  WHERE UPPER(er.status) IN ('CONFIRMED','COMPLETED','DONE') AND DATE(er.export_date) >= ? AND DATE(er.export_date) <= ? GROUP BY s.product_id "
                + ") ce ON ce.product_id = p.product_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, SUM(irl.qty) AS qty FROM import_receipt_lines irl "
                + "  JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "  JOIN product_skus s ON s.sku_id = irl.sku_id "
                + "  WHERE UPPER(ir.status) IN ('CONFIRMED','COMPLETED','DONE') AND DATE(ir.receipt_date) > ? GROUP BY s.product_id "
                + ") fi ON fi.product_id = p.product_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, SUM(erl.qty) AS qty FROM export_receipt_lines erl "
                + "  JOIN export_receipts er ON er.export_id = erl.export_id "
                + "  JOIN product_skus s ON s.sku_id = erl.sku_id "
                + "  WHERE UPPER(er.status) IN ('CONFIRMED','COMPLETED','DONE') AND DATE(er.export_date) > ? GROUP BY s.product_id "
                + ") fe ON fe.product_id = p.product_id "
                + "WHERE p.status = 'ACTIVE' AND b.is_active = 1 ";

        if (brandId != null) {
            sql += " AND p.brand_id = ? ";
        }
        if (keyword != null && !keyword.isBlank()) {
            sql += " AND (p.product_name LIKE ? OR p.product_code LIKE ?) ";
        }
        sql += " ORDER BY b.brand_name, p.product_name LIMIT ? OFFSET ?";

        List<InventoryReportRow> list = new ArrayList<>();
        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = 1;
            ps.setDate(idx++, from); // ci
            ps.setDate(idx++, to); // ci
            ps.setDate(idx++, from); // ce
            ps.setDate(idx++, to); // ce
            ps.setDate(idx++, to); // fi
            ps.setDate(idx++, to); // fe

            if (brandId != null) {
                ps.setLong(idx++, brandId);
            }
            if (keyword != null && !keyword.isBlank()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int curQty = rs.getInt("current_qty");
                    int imp = rs.getInt("import_period");
                    int exp = rs.getInt("export_period");
                    int futImp = rs.getInt("future_imp");
                    int futExp = rs.getInt("future_exp");

                    // Backtracking logic:
                    // Closing (at 'to' date) = CurrentQty - AllImportsAfter('to') +
                    // AllExportsAfter('to')
                    int clo = curQty - futImp + futExp;
                    // Opening (at 'from' date) = Closing - ImportDuringPeriod + ExportDuringPeriod
                    int op = clo - imp + exp;
                    int threshold = rs.getInt("threshold");

                    String ropStatus;
                    int suggestedReorderQty = 0;

                    if (clo <= 0) {
                        ropStatus = "Out Of Stock";
                        suggestedReorderQty = threshold;
                    } else if (clo < threshold) {
                        ropStatus = "Reorder Needed";
                        suggestedReorderQty = threshold - clo;
                    } else if (clo == threshold) {
                        ropStatus = "At Threshold";
                    } else {
                        ropStatus = "OK";
                    }

                    InventoryReportRow row = new InventoryReportRow();
                    row.setProductId(rs.getInt("product_id"));
                    row.setProductCode(rs.getString("product_code"));
                    row.setProductName(rs.getString("product_name"));
                    row.setBrandName(rs.getString("brand_name"));
                    row.setUnit("Item");
                    row.setOpeningQty(op);
                    row.setImportQty(imp);
                    row.setExportQty(exp);
                    row.setClosingQty(clo);
                    row.setRop(threshold);
                    row.setRopStatus(ropStatus);
                    row.setSuggestedReorderQty(suggestedReorderQty);

                    // These fields are legacy/removed from DB, setting to 0
                    row.setAvgDailySales(0);
                    row.setLeadTimeDays(0);
                    row.setSafetyStock(0);

                    list.add(row);
                }
            }
        }
        return list;
    }

    private void bindParams(PreparedStatement ps, List<Object> params, int startIndex)
            throws SQLException {
        int idx = startIndex;
        for (Object o : params) {
            if (o instanceof String) {
                ps.setString(idx++, (String) o);
            } else if (o instanceof Date) {
                ps.setDate(idx++, (Date) o);
            } else if (o instanceof Long) {
                ps.setLong(idx++, (Long) o);
            } else if (o instanceof Integer) {
                ps.setInt(idx++, (Integer) o);
            } else {
                ps.setObject(idx++, o);
            }
        }
    }
}
