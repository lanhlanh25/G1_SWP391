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

        // --- Total Import and Export in period ---
        int totalImportPeriod = 0;
        int totalExportPeriod = 0;

        {
            StringBuilder sql = new StringBuilder(
                    "SELECT COALESCE(SUM(irl.qty), 0) AS val "
                    + "FROM import_receipt_lines irl "
                    + "JOIN import_receipts ir ON ir.import_id = irl.import_id "
                    + "JOIN product_skus s     ON s.sku_id = irl.sku_id "
                    + "JOIN products p         ON p.product_id = s.product_id "
                    + "WHERE UPPER(ir.status) = 'CONFIRMED' "
            );
            List<Object> p2 = new ArrayList<>();
            if (from != null) {
                sql.append(" AND DATE(ir.receipt_date) >= ? ");
                p2.add(from);
            }
            if (to != null) {
                sql.append(" AND DATE(ir.receipt_date) <= ? ");
                p2.add(to);
            }
            if (brandId != null) {
                sql.append(" AND p.brand_id = ? ");
                p2.add(brandId);
            }

            try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
                bindParams(ps, p2, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalImportPeriod = rs.getInt("val");
                        m.put("totalImport", totalImportPeriod);
                    }
                }
            }
        }

        {
            StringBuilder sql = new StringBuilder(
                    "SELECT COALESCE(SUM(erl.qty), 0) AS val "
                    + "FROM export_receipt_lines erl "
                    + "JOIN export_receipts er ON er.export_id = erl.export_id "
                    + "JOIN product_skus s     ON s.sku_id = erl.sku_id "
                    + "JOIN products p         ON p.product_id = s.product_id "
                    + "WHERE 1=1 "
            );
            List<Object> p2 = new ArrayList<>();
            if (from != null) {
                sql.append(" AND DATE(er.export_date) >= ? ");
                p2.add(from);
            }
            if (to != null) {
                sql.append(" AND DATE(er.export_date) <= ? ");
                p2.add(to);
            }
            if (brandId != null) {
                sql.append(" AND p.brand_id = ? ");
                p2.add(brandId);
            }

            try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
                bindParams(ps, p2, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalExportPeriod = rs.getInt("val");
                        m.put("totalExport", totalExportPeriod);
                    }
                }
            }
        }

        // --- Total Closing (calculated backwards from current stock if to_date is provided) ---
        // sub-query for future import (after to_date)
        StringBuilder futureImpSub = new StringBuilder(
                "SELECT s.product_id, COALESCE(SUM(irl.qty), 0) AS future_imp "
                + "FROM import_receipt_lines irl "
                + "JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "JOIN product_skus s     ON s.sku_id = irl.sku_id "
                + "WHERE UPPER(ir.status) = 'CONFIRMED' "
        );
        List<Object> closingParams = new ArrayList<>();
        if (to != null) {
            futureImpSub.append(" AND DATE(ir.receipt_date) > ? ");
            closingParams.add(to);
        } else {
            futureImpSub.append(" AND 1=0 "); // if no to_date, no future
        }
        futureImpSub.append(" GROUP BY s.product_id");

        // sub-query for future export (after to_date)
        StringBuilder futureExpSub = new StringBuilder(
                "SELECT s.product_id, COALESCE(SUM(erl.qty), 0) AS future_exp "
                + "FROM export_receipt_lines erl "
                + "JOIN export_receipts er ON er.export_id = erl.export_id "
                + "JOIN product_skus s     ON s.sku_id = erl.sku_id "
                + "WHERE 1=1 "
        );
        if (to != null) {
            futureExpSub.append(" AND DATE(er.export_date) > ? ");
            closingParams.add(to);
        } else {
            futureExpSub.append(" AND 1=0 "); // if no to_date, no future
        }
        futureExpSub.append(" GROUP BY s.product_id");

        {
            StringBuilder sql = new StringBuilder(
                    "SELECT "
                    + "  COALESCE(SUM(x.closing_stock), 0) AS total_closing, "
                    + "  SUM(CASE WHEN x.closing_stock < x.rop THEN 1 WHEN x.closing_stock = x.rop AND x.rop > 0 AND x.closing_stock > 0 THEN 0 ELSE 0 END) AS below_rop, " // < ROP is Reorder Needed
                    + "  SUM(CASE WHEN x.closing_stock <= 0 THEN 1 ELSE 0 END) AS out_of_stock "
                    + "FROM ( "
                    + "  SELECT p.product_id, "
                    + "    COALESCE(SUM(ib.qty_on_hand), 0) AS current_stock, "
                    + "    CEIL(COALESCE(p.avg_daily_sales, 0) * COALESCE(p.lead_time_days, 0) + COALESCE(p.safety_stock, 0)) AS rop, "
                    + "    GREATEST(0, COALESCE(SUM(ib.qty_on_hand), 0) + COALESCE(f_exp.future_exp, 0) - COALESCE(f_imp.future_imp, 0)) AS closing_stock "
                    + "  FROM products p "
                    + "  LEFT JOIN product_skus ps ON ps.product_id = p.product_id AND ps.status = 'ACTIVE' "
                    + "  LEFT JOIN inventory_balance ib ON ib.sku_id = ps.sku_id "
                    + "  LEFT JOIN (" + futureImpSub + ") f_imp ON f_imp.product_id = p.product_id "
                    + "  LEFT JOIN (" + futureExpSub + ") f_exp ON f_exp.product_id = p.product_id "
                    + "  WHERE p.status = 'ACTIVE' "
            );
            if (brandId != null) {
                sql.append(" AND p.brand_id = ? ");
                closingParams.add(brandId);
            }
            sql.append(
                    "  GROUP BY p.product_id, p.avg_daily_sales, p.lead_time_days, p.safety_stock, f_imp.future_imp, f_exp.future_exp "
                    + ") x"
            );

            try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
                bindParams(ps, closingParams, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        m.put("totalClosing", rs.getInt("total_closing"));
                        m.put("totalBelowRop", rs.getInt("below_rop"));
                        m.put("totalOutOfStock", rs.getInt("out_of_stock"));
                    }
                }
            }
        }

        int clo = m.get("totalClosing");
        int open = Math.max(clo - totalImportPeriod + totalExportPeriod, 0);
        m.put("totalOpening", open);

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
        List<Object> params = new ArrayList<>();

        // Sub-query: import qty per product in period
        StringBuilder impSub = new StringBuilder(
                "SELECT s.product_id, COALESCE(SUM(irl.qty), 0) AS imp_qty "
                + "FROM import_receipt_lines irl "
                + "JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "JOIN product_skus s     ON s.sku_id = irl.sku_id "
                + "WHERE UPPER(ir.status) = 'CONFIRMED' "
        );
        if (from != null) {
            impSub.append(" AND DATE(ir.receipt_date) >= ? ");
            params.add(from);
        }
        if (to != null) {
            impSub.append(" AND DATE(ir.receipt_date) <= ? ");
            params.add(to);
        }
        impSub.append(" GROUP BY s.product_id");

        // Sub-query: export qty per product in period
        StringBuilder expSub = new StringBuilder(
                "SELECT s.product_id, COALESCE(SUM(erl.qty), 0) AS exp_qty "
                + "FROM export_receipt_lines erl "
                + "JOIN export_receipts er ON er.export_id = erl.export_id "
                + "JOIN product_skus s     ON s.sku_id = erl.sku_id "
                + "WHERE 1=1 "
        );
        if (from != null) {
            expSub.append(" AND DATE(er.export_date) >= ? ");
            params.add(from);
        }
        if (to != null) {
            expSub.append(" AND DATE(er.export_date) <= ? ");
            params.add(to);
        }
        expSub.append(" GROUP BY s.product_id");

        // Sub-query: future import (after to_date)
        StringBuilder futureImpSub = new StringBuilder(
                "SELECT s.product_id, COALESCE(SUM(irl.qty), 0) AS future_imp "
                + "FROM import_receipt_lines irl "
                + "JOIN import_receipts ir ON ir.import_id = irl.import_id "
                + "JOIN product_skus s     ON s.sku_id = irl.sku_id "
                + "WHERE UPPER(ir.status) = 'CONFIRMED' "
        );
        if (to != null) {
            futureImpSub.append(" AND DATE(ir.receipt_date) > ? ");
            params.add(to);
        } else {
            futureImpSub.append(" AND 1=0 ");
        }
        futureImpSub.append(" GROUP BY s.product_id");

        // Sub-query: future export (after to_date)
        StringBuilder futureExpSub = new StringBuilder(
                "SELECT s.product_id, COALESCE(SUM(erl.qty), 0) AS future_exp "
                + "FROM export_receipt_lines erl "
                + "JOIN export_receipts er ON er.export_id = erl.export_id "
                + "JOIN product_skus s     ON s.sku_id = erl.sku_id "
                + "WHERE 1=1 "
        );
        if (to != null) {
            futureExpSub.append(" AND DATE(er.export_date) > ? ");
            params.add(to);
        } else {
            futureExpSub.append(" AND 1=0 ");
        }
        futureExpSub.append(" GROUP BY s.product_id");

        // Main query: closing stock = current_stock + future_exp - future_imp
        StringBuilder sql = new StringBuilder(
                "SELECT "
                + "  p.product_code, p.product_name, b.brand_name, "
                + "  COALESCE(imp.imp_qty, 0) AS import_qty, "
                + "  COALESCE(exp.exp_qty, 0) AS export_qty, "
                + "  COALESCE(stk.current_stock, 0) AS current_stock, "
                + "  GREATEST(0, COALESCE(stk.current_stock, 0) + COALESCE(f_exp.future_exp, 0) - COALESCE(f_imp.future_imp, 0)) AS closing_stock, "
                + "  COALESCE(p.avg_daily_sales, 0) AS avg_daily_sales, "
                + "  COALESCE(p.lead_time_days, 0) AS lead_time_days, "
                + "  COALESCE(p.safety_stock, 0) AS safety_stock, "
                + "  CEIL(COALESCE(p.avg_daily_sales, 0) * COALESCE(p.lead_time_days, 0) "
                + "       + COALESCE(p.safety_stock, 0)) AS rop "
                + "FROM products p "
                + "JOIN brands b ON b.brand_id = p.brand_id "
                + "LEFT JOIN (" + impSub + ") imp ON imp.product_id = p.product_id "
                + "LEFT JOIN (" + expSub + ") exp ON exp.product_id = p.product_id "
                + "LEFT JOIN (" + futureImpSub + ") f_imp ON f_imp.product_id = p.product_id "
                + "LEFT JOIN (" + futureExpSub + ") f_exp ON f_exp.product_id = p.product_id "
                + "LEFT JOIN ( "
                + "  SELECT ps2.product_id, COALESCE(SUM(ib.qty_on_hand), 0) AS current_stock "
                + "  FROM product_skus ps2 "
                + "  LEFT JOIN inventory_balance ib ON ib.sku_id = ps2.sku_id "
                + "  WHERE ps2.status = 'ACTIVE' "
                + "  GROUP BY ps2.product_id "
                + ") stk ON stk.product_id = p.product_id "
                + "WHERE p.status = 'ACTIVE' AND b.is_active = 1 "
        );

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
        sql.append(" ORDER BY b.brand_name, p.product_name LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(offset);

        List<InventoryReportRow> list = new ArrayList<>();
        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            bindParams(ps, params, 1);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int imp2 = rs.getInt("import_qty");
                    int exp2 = rs.getInt("export_qty");
                    int closingStock = rs.getInt("closing_stock");
                    int rop = rs.getInt("rop");
                    
                    int open2 = Math.max(closingStock - imp2 + exp2, 0);
                    
                    String ropStatus;
                    int suggestedReorderQty = 0;
                    
                    if (closingStock == 0) {
                        ropStatus = "Out Of Stock";
                        suggestedReorderQty = rop;
                    } else if (closingStock < rop) { // Đồng bộ với LowStockReport: < ROP  
                        ropStatus = "Reorder Needed";
                        suggestedReorderQty = rop - closingStock;
                    } else if (closingStock == rop) { // = ROP
                        ropStatus = "At ROP Level";
                    } else {
                        ropStatus = "OK";
                    }

                    InventoryReportRow row = new InventoryReportRow();
                    row.setProductCode(rs.getString("product_code"));
                    row.setProductName(rs.getString("product_name"));
                    row.setBrandName(rs.getString("brand_name"));
                    row.setUnit("Phone");
                    row.setOpeningQty(open2);
                    row.setImportQty(imp2);
                    row.setExportQty(exp2);
                    row.setClosingQty(closingStock);
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
