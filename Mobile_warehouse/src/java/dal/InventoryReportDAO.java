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

    public Map<String, Integer> getSummary(Date from, Date to, Long brandId) throws Exception {

        Map<String, Integer> m = new HashMap<>();
        m.put("totalImport", 0);
        m.put("totalExport", 0);
        m.put("totalClosing", 0);
        m.put("totalOpening", 0);
        m.put("totalVariance", 0);

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
                        m.put("totalImport", rs.getInt("val"));
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
                        m.put("totalExport", rs.getInt("val"));
                    }
                }
            }
        }

        {
            StringBuilder sql = new StringBuilder(
                    "SELECT COALESCE(COUNT(pu.unit_id), 0) AS val "
                    + "FROM product_units pu "
                    + "JOIN product_skus s ON s.sku_id = pu.sku_id "
                    + "JOIN products p     ON p.product_id = s.product_id "
                    + "WHERE pu.unit_status = 'ACTIVE' AND p.status = 'ACTIVE' "
            );
            List<Object> p2 = new ArrayList<>();
            if (brandId != null) {
                sql.append(" AND p.brand_id = ? ");
                p2.add(brandId);
            }

            try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
                bindParams(ps, p2, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        m.put("totalClosing", rs.getInt("val"));
                    }
                }
            }
        }

        int imp = m.get("totalImport");
        int exp = m.get("totalExport");
        int clo = m.get("totalClosing");
        int open = Math.max(clo - imp + exp, 0);
        m.put("totalOpening", open);
        m.put("totalVariance", clo - (open + imp - exp));

        return m;
    }

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

    public List<InventoryReportRow> list(Date from, Date to, Long brandId,
            String keyword, int page, int pageSize)
            throws Exception {

        int offset = (page - 1) * pageSize;
        List<Object> params = new ArrayList<>();

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

        StringBuilder sql = new StringBuilder(
                "SELECT "
                + "  p.product_code, p.product_name, b.brand_name, "
                + "  COALESCE(imp.imp_qty, 0) AS import_qty, "
                + "  COALESCE(exp.exp_qty, 0) AS export_qty, "
                + "  COALESCE(("
                + "    SELECT COUNT(*) FROM product_units pu2 "
                + "    JOIN product_skus s2 ON s2.sku_id = pu2.sku_id "
                + "    WHERE s2.product_id = p.product_id AND pu2.unit_status = 'ACTIVE'"
                + "  ), 0) AS closing_qty "
                + "FROM products p "
                + "JOIN brands b ON b.brand_id = p.brand_id "
                + "LEFT JOIN (" + impSub + ") imp ON imp.product_id = p.product_id "
                + "LEFT JOIN (" + expSub + ") exp ON exp.product_id = p.product_id "
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
                    int clo2 = rs.getInt("closing_qty");
                    int open2 = Math.max(clo2 - imp2 + exp2, 0);
                    list.add(new InventoryReportRow(
                            rs.getString("product_code"),
                            rs.getString("product_name"),
                            rs.getString("brand_name"),
                            open2, imp2, exp2, clo2
                    ));
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
