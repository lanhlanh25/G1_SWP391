/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Lanhlanh
 */
import model.InventoryReportRow;
import model.IdName;

import java.sql.Connection;
import java.sql.Date;          // java.sql.Date — dùng duy nhất loại này
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
        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
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

        // Calculate all metrics in one query by summing product-level transactions
        String sql = "SELECT "
                + "  SUM(opening_qty) AS tot_opening, "
                + "  SUM(import_period) AS tot_import, "
                + "  SUM(export_period) AS tot_export, "
                + "  SUM(opening_qty + import_period - export_period) AS tot_closing, "
                + "  SUM(CASE WHEN (opening_qty + import_period - export_period) < rop THEN 1 ELSE 0 END) AS below_rop, "
                + "  SUM(CASE WHEN (opening_qty + import_period - export_period) <= 0 THEN 1 ELSE 0 END) AS out_of_stock "
                + "FROM ( "
                + "  SELECT p.product_id, "
                + "    CEIL(COALESCE(p.avg_daily_sales, 0) * COALESCE(p.lead_time_days, 0) + COALESCE(p.safety_stock, 0)) AS rop, "
                + "    (COALESCE(oi.qty, 0) - COALESCE(oe.qty, 0)) AS opening_qty, "
                + "    COALESCE(ci.qty, 0) AS import_period, "
                + "    COALESCE(ce.qty, 0) AS export_period "
                + "  FROM products p "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, SUM(irl.qty) AS qty FROM import_receipt_lines irl "
                + "    JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "    JOIN product_skus s ON s.sku_id = irl.sku_id "
                + "    WHERE UPPER(ir.status) = 'CONFIRMED' AND DATE(ir.receipt_date) < ? GROUP BY s.product_id "
                + "  ) oi ON oi.product_id = p.product_id "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, SUM(erl.qty) AS qty FROM export_receipt_lines erl "
                + "    JOIN export_receipts er ON er.export_id = erl.export_id "
                + "    JOIN product_skus s ON s.sku_id = erl.sku_id "
                + "    WHERE UPPER(er.status) = 'CONFIRMED' AND DATE(er.export_date) < ? GROUP BY s.product_id "
                + "  ) oe ON oe.product_id = p.product_id "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, SUM(irl.qty) AS qty FROM import_receipt_lines irl "
                + "    JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "    JOIN product_skus s ON s.sku_id = irl.sku_id "
                + "    WHERE UPPER(ir.status) = 'CONFIRMED' AND DATE(ir.receipt_date) >= ? AND DATE(ir.receipt_date) <= ? GROUP BY s.product_id "
                + "  ) ci ON ci.product_id = p.product_id "
                + "  LEFT JOIN ( "
                + "    SELECT s.product_id, SUM(erl.qty) AS qty FROM export_receipt_lines erl "
                + "    JOIN export_receipts er ON er.export_id = erl.export_id "
                + "    JOIN product_skus s ON s.sku_id = erl.sku_id "
                + "    WHERE UPPER(er.status) = 'CONFIRMED' AND DATE(er.export_date) >= ? AND DATE(er.export_date) <= ? GROUP BY s.product_id "
                + "  ) ce ON ce.product_id = p.product_id "
                + "  WHERE p.status = 'ACTIVE' "
                + (brandId != null ? " AND p.brand_id = ? " : "")
                + ") t";

        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = 1;
            ps.setDate(idx++, from); // oi
            ps.setDate(idx++, from); // oe
            ps.setDate(idx++, from); // ci
            ps.setDate(idx++, to);   // ci
            ps.setDate(idx++, from); // ce
            ps.setDate(idx++, to);   // ce
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
                + "WHERE p.status = 'ACTIVE' AND b.is_active = 1 "
        );
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

    /* ───── List with ROP ───── */
    public List<InventoryReportRow> list(Date from, Date to, Long brandId,
            String keyword, int page, int pageSize)
            throws Exception {

        int offset = (page - 1) * pageSize;
        String sql = "SELECT "
                + "  p.product_id, p.product_code, p.product_name, b.brand_name, "
                + "  (COALESCE(oi.qty, 0) - COALESCE(oe.qty, 0)) AS opening_qty, "
                + "  COALESCE(ci.qty, 0) AS import_qty, "
                + "  COALESCE(ce.qty, 0) AS export_qty, "
                + "  COALESCE(p.avg_daily_sales, 0) AS avg_daily_sales, "
                + "  COALESCE(p.lead_time_days, 0) AS lead_time_days, "
                + "  COALESCE(p.safety_stock, 0) AS safety_stock, "
                + "  CEIL(COALESCE(p.avg_daily_sales, 0) * COALESCE(p.lead_time_days, 0) + COALESCE(p.safety_stock, 0)) AS rop "
                + "FROM products p "
                + "JOIN brands b ON b.brand_id = p.brand_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, SUM(irl.qty) AS qty FROM import_receipt_lines irl "
                + "  JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "  JOIN product_skus s ON s.sku_id = irl.sku_id "
                + "  WHERE UPPER(ir.status) = 'CONFIRMED' AND DATE(ir.receipt_date) < ? GROUP BY s.product_id "
                + ") oi ON oi.product_id = p.product_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, SUM(erl.qty) AS qty FROM export_receipt_lines erl "
                + "  JOIN export_receipts er ON er.export_id = erl.export_id "
                + "  JOIN product_skus s ON s.sku_id = erl.sku_id "
                + "  WHERE UPPER(er.status) = 'CONFIRMED' AND DATE(er.export_date) < ? GROUP BY s.product_id "
                + ") oe ON oe.product_id = p.product_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, SUM(irl.qty) AS qty FROM import_receipt_lines irl "
                + "  JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "  JOIN product_skus s ON s.sku_id = irl.sku_id "
                + "  WHERE UPPER(ir.status) = 'CONFIRMED' AND DATE(ir.receipt_date) >= ? AND DATE(ir.receipt_date) <= ? GROUP BY s.product_id "
                + ") ci ON ci.product_id = p.product_id "
                + "LEFT JOIN ( "
                + "  SELECT s.product_id, SUM(erl.qty) AS qty FROM export_receipt_lines erl "
                + "  JOIN export_receipts er ON er.export_id = erl.export_id "
                + "  JOIN product_skus s ON s.sku_id = erl.sku_id "
                + "  WHERE UPPER(er.status) = 'CONFIRMED' AND DATE(er.export_date) >= ? AND DATE(er.export_date) <= ? GROUP BY s.product_id "
                + ") ce ON ce.product_id = p.product_id "
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
            ps.setDate(idx++, from); // oi
            ps.setDate(idx++, from); // oe
            ps.setDate(idx++, from); // ci
            ps.setDate(idx++, to);   // ci
            ps.setDate(idx++, from); // ce
            ps.setDate(idx++, to);   // ce

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
                    int op = rs.getInt("opening_qty");
                    int imp = rs.getInt("import_qty");
                    int exp = rs.getInt("export_qty");
                    int clo = op + imp - exp;
                    int rop = rs.getInt("rop");

                    String ropStatus;
                    int suggestedReorderQty = 0;

                    if (clo <= 0) {
                        ropStatus = "Out Of Stock";
                        suggestedReorderQty = rop;
                    } else if (clo < rop) {
                        ropStatus = "Reorder Needed";
                        suggestedReorderQty = rop - clo;
                    } else if (clo == rop) {
                        ropStatus = "At ROP Level";
                    } else {
                        ropStatus = "OK";
                    }

                    InventoryReportRow row = new InventoryReportRow();
                    row.setProductId(rs.getInt("product_id"));
                    row.setProductCode(rs.getString("product_code"));
                    row.setProductName(rs.getString("product_name"));
                    row.setBrandName(rs.getString("brand_name"));
                    row.setUnit("Phone");
                    row.setOpeningQty(op);
                    row.setImportQty(imp);
                    row.setExportQty(exp);
                    row.setClosingQty(clo);
                    row.setAvgDailySales(rs.getDouble("avg_daily_sales"));
                    row.setLeadTimeDays(rs.getInt("lead_time_days"));
                    row.setSafetyStock(rs.getInt("safety_stock"));
                    row.setRop(rop);
                    row.setRopStatus(ropStatus);
                    row.setSuggestedReorderQty(suggestedReorderQty);

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
                // java.sql.Date — unambiguous
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
