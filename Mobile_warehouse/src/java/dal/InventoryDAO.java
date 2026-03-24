/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import model.IdName;
import model.InventoryModelRow;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

public class InventoryDAO {

    private static final int LOW_STOCK_THRESHOLD = 10;

    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }

    public List<IdName> getActiveBrands() {
        List<IdName> list = new ArrayList<>();
        String sql = "SELECT brand_id, brand_name " +
                     "FROM brands " +
                     "WHERE is_active = 1 " +
                     "ORDER BY brand_name";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new IdName(rs.getLong("brand_id"), rs.getString("brand_name")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Map<String, Integer> getSummary(String q, String brandId) {
        Map<String, Integer> m = new HashMap<>();
        m.put("totalProducts", 0);
        m.put("totalQty", 0);
        m.put("lowStockItems", 0);
        m.put("outOfStockItems", 0);

        StringBuilder where = new StringBuilder(" WHERE p.status = 'ACTIVE' AND b.is_active = 1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(where, params, q, brandId);

        String countExpr =
            "COALESCE(SUM(( " +
            "   SELECT COUNT(*) " +
            "   FROM product_units pu " +
            "   WHERE pu.sku_id = sk.sku_id AND pu.unit_status = 'ACTIVE' " +
            ")), 0)";

        String sqlTotal =
            "SELECT " +
            "   COUNT(DISTINCT p.product_id) AS total_products, " +
            "   " + countExpr + " AS total_qty " +
            "FROM products p " +
            "JOIN brands b ON b.brand_id = p.brand_id " +
            "LEFT JOIN product_skus sk ON sk.product_id = p.product_id AND sk.status = 'ACTIVE' " +
            where;

        String sqlStatus =
            "SELECT " +
            "   SUM(CASE WHEN x.current_stock = 0 THEN 1 ELSE 0 END) AS out_items, " +
            "   SUM(CASE WHEN x.current_stock > 0 AND x.current_stock < ? THEN 1 ELSE 0 END) AS low_items " +
            "FROM ( " +
            "   SELECT p.product_id, " +
            "          " + countExpr + " AS current_stock " +
            "   FROM products p " +
            "   JOIN brands b ON b.brand_id = p.brand_id " +
            "   LEFT JOIN product_skus sk ON sk.product_id = p.product_id AND sk.status = 'ACTIVE' " +
            where +
            "   GROUP BY p.product_id " +
            ") x";

        try (Connection con = getConn()) {
            try (PreparedStatement ps = con.prepareStatement(sqlTotal)) {
                bindParams(ps, params, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        m.put("totalProducts", rs.getInt("total_products"));
                        m.put("totalQty", rs.getInt("total_qty"));
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(sqlStatus)) {
                int idx = 1;
                ps.setInt(idx++, LOW_STOCK_THRESHOLD);
                bindParams(ps, params, idx);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        m.put("outOfStockItems", rs.getInt("out_items"));
                        m.put("lowStockItems", rs.getInt("low_items"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return m;
    }

    public int countModels(String q, String brandId, String stockStatus) {
        StringBuilder where = new StringBuilder(" WHERE p.status = 'ACTIVE' AND b.is_active = 1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(where, params, q, brandId);

        String having = buildHaving(stockStatus);

        String sql =
            "SELECT COUNT(*) " +
            "FROM ( " +
            "   SELECT p.product_id, " +
            "          COALESCE(SUM(( " +
            "              SELECT COUNT(*) " +
            "              FROM product_units pu " +
            "              WHERE pu.sku_id = sk.sku_id AND pu.unit_status = 'ACTIVE' " +
            "          )), 0) AS current_stock " +
            "   FROM products p " +
            "   JOIN brands b ON b.brand_id = p.brand_id " +
            "   LEFT JOIN product_skus sk ON sk.product_id = p.product_id AND sk.status = 'ACTIVE' " +
            where +
            "   GROUP BY p.product_id " +
            having +
            ") x";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int idx = bindParams(ps, params, 1);
            if (having.contains("?")) {
                ps.setInt(idx, LOW_STOCK_THRESHOLD);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<InventoryModelRow> listModels(String q, String brandId, String stockStatus, int page, int pageSize) {
        List<InventoryModelRow> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder where = new StringBuilder(" WHERE p.status = 'ACTIVE' AND b.is_active = 1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(where, params, q, brandId);

        String having = buildHaving(stockStatus);

        String countExpr =
            "COALESCE(SUM(( " +
            "   SELECT COUNT(*) " +
            "   FROM product_units pu " +
            "   WHERE pu.sku_id = sk.sku_id AND pu.unit_status = 'ACTIVE' " +
            ")), 0)";

        String sql =
            "SELECT " +
            "   p.product_code, " +
            "   p.product_name, " +
            "   b.brand_name, " +
            "   " + countExpr + " AS current_stock, " +
            "   CASE " +
            "       WHEN " + countExpr + " = 0 THEN 'OUT' " +
            "       WHEN " + countExpr + " < ? THEN 'LOW' " +
            "       ELSE 'OK' " +
            "   END AS stock_status, " +
            "   DATE_FORMAT(COALESCE(p.updated_at, p.created_at), '%Y-%m-%d') AS last_updated " +
            "FROM products p " +
            "JOIN brands b ON b.brand_id = p.brand_id " +
            "LEFT JOIN product_skus sk ON sk.product_id = p.product_id AND sk.status = 'ACTIVE' " +
            where +
            "GROUP BY p.product_id, p.product_code, p.product_name, b.brand_name, p.updated_at, p.created_at " +
            having +
            " ORDER BY p.product_name " +
            " LIMIT ? OFFSET ?";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int idx = 1;
            ps.setInt(idx++, LOW_STOCK_THRESHOLD);

            idx = bindParams(ps, params, idx);

            if (having.contains("?")) {
                ps.setInt(idx++, LOW_STOCK_THRESHOLD);
            }

            ps.setInt(idx++, pageSize);
            ps.setInt(idx, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new InventoryModelRow(
                        rs.getString("product_code"),
                        rs.getString("product_name"),
                        rs.getString("brand_name"),
                        rs.getInt("current_stock"),
                        rs.getString("stock_status"),
                        rs.getString("last_updated")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private void appendFilters(StringBuilder where, List<Object> params, String q, String brandId) {
        if (q != null && !q.trim().isEmpty()) {
            where.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ? OR sk.sku_code LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (brandId != null && !brandId.trim().isEmpty()) {
            long brand = parseLongSafe(brandId);
            if (brand > 0) {
                where.append(" AND p.brand_id = ? ");
                params.add(brand);
            }
        }
    }

    private String buildHaving(String stockStatus) {
        if (stockStatus == null || stockStatus.trim().isEmpty()) return "";

        switch (stockStatus.trim().toUpperCase()) {
            case "OK":
                return " HAVING current_stock >= ? ";
            case "LOW":
                return " HAVING current_stock > 0 AND current_stock < ? ";
            case "OUT":
                return " HAVING current_stock = 0 ";
            default:
                return "";
        }
    }

    private int bindParams(PreparedStatement ps, List<Object> params, int startIndex) throws SQLException {
        int idx = startIndex;
        for (Object o : params) {
            if (o instanceof String) {
                ps.setString(idx++, (String) o);
            } else if (o instanceof Long) {
                ps.setLong(idx++, (Long) o);
            } else {
                ps.setObject(idx++, o);
            }
        }
        return idx;
    }

    private long parseLongSafe(String s) {
        try {
            return Long.parseLong(s.trim());
        } catch (Exception e) {
            return -1;
        }
    }

    public Map<Long, Integer> mapQtyOnHand() throws Exception {
        String sql = "SELECT sku_id, COUNT(*) AS qty " +
                     "FROM product_units " +
                     "WHERE unit_status = 'ACTIVE' " +
                     "GROUP BY sku_id";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            Map<Long, Integer> map = new HashMap<>();
            while (rs.next()) {
                map.put(rs.getLong("sku_id"), rs.getInt("qty"));
            }
            return map;
        }
    }
}
