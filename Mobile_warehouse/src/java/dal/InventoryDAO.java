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

    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }

    public List<IdName> getActiveBrands() {
        List<IdName> list = new ArrayList<>();
        String sql = "SELECT brand_id, brand_name FROM brands WHERE is_active = 1 ORDER BY brand_name";
        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new IdName(rs.getLong("brand_id"), rs.getString("brand_name")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Summary cards dùng ROP formula:
     *   rop = CEIL(avg_daily_sales * lead_time_days + safety_stock)
     *   Out Of Stock  : current_stock = 0
     *   Low Stock     : 0 < current_stock <= rop
     */
    public Map<String, Integer> getSummary(String q, String brandId) {
        Map<String, Integer> m = new HashMap<>();
        m.put("totalProducts", 0);
        m.put("totalQty", 0);
        m.put("lowStockItems", 0);
        m.put("outOfStockItems", 0);

        StringBuilder where = new StringBuilder(" WHERE p.status='ACTIVE' AND b.is_active=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            where.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ? OR sk.sku_code LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (brandId != null && !brandId.trim().isEmpty()) {
            where.append(" AND p.brand_id = ? ");
            params.add(parseLongSafe(brandId));
        }

        // Total products & qty
        String sql1 =
            "SELECT COUNT(DISTINCT p.product_id) AS total_products, " +
            "       COALESCE(SUM(COALESCE(ib.qty_on_hand, 0)), 0) AS total_qty " +
            "FROM products p " +
            "JOIN brands b ON b.brand_id = p.brand_id " +
            "LEFT JOIN product_skus sk ON sk.product_id = p.product_id AND sk.status='ACTIVE' " +
            "LEFT JOIN inventory_balance ib ON ib.sku_id = sk.sku_id " +
            where;

        // Low / Out counts using ROP
        String sql2 =
            "SELECT " +
            "  SUM(CASE WHEN t.current_stock = 0 THEN 1 ELSE 0 END) AS out_items, " +
            "  SUM(CASE WHEN t.current_stock > 0 AND t.current_stock <= t.rop THEN 1 ELSE 0 END) AS low_items " +
            "FROM ( " +
            "  SELECT p.product_id, " +
            "    COALESCE(SUM(COALESCE(ib.qty_on_hand, 0)), 0) AS current_stock, " +
            "    CEIL(COALESCE(p.avg_daily_sales, 0) * COALESCE(p.lead_time_days, 0) + COALESCE(p.safety_stock, 0)) AS rop " +
            "  FROM products p " +
            "  JOIN brands b ON b.brand_id = p.brand_id " +
            "  LEFT JOIN product_skus sk ON sk.product_id = p.product_id AND sk.status='ACTIVE' " +
            "  LEFT JOIN inventory_balance ib ON ib.sku_id = sk.sku_id " +
            where +
            "  GROUP BY p.product_id, p.avg_daily_sales, p.lead_time_days, p.safety_stock " +
            ") t";

        try (Connection con = getConn()) {
            try (PreparedStatement ps = con.prepareStatement(sql1)) {
                bindParams(ps, params, 1);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        m.put("totalProducts", rs.getInt("total_products"));
                        m.put("totalQty", rs.getInt("total_qty"));
                    }
                }
            }
            try (PreparedStatement ps = con.prepareStatement(sql2)) {
                bindParams(ps, params, 1);
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
        StringBuilder where = new StringBuilder(" WHERE p.status='ACTIVE' AND b.is_active=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            where.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ? OR sk.sku_code LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (brandId != null && !brandId.trim().isEmpty()) {
            where.append(" AND p.brand_id = ? ");
            params.add(parseLongSafe(brandId));
        }

        String having = buildHaving(stockStatus);

        String sql =
            "SELECT COUNT(*) FROM ( " +
            "  SELECT p.product_id, " +
            "    COALESCE(SUM(COALESCE(ib.qty_on_hand, 0)), 0) AS current_stock, " +
            "    CEIL(COALESCE(p.avg_daily_sales, 0) * COALESCE(p.lead_time_days, 0) + COALESCE(p.safety_stock, 0)) AS rop " +
            "  FROM products p " +
            "  JOIN brands b ON b.brand_id = p.brand_id " +
            "  LEFT JOIN product_skus sk ON sk.product_id = p.product_id AND sk.status='ACTIVE' " +
            "  LEFT JOIN inventory_balance ib ON ib.sku_id = sk.sku_id " +
            where +
            "  GROUP BY p.product_id, p.avg_daily_sales, p.lead_time_days, p.safety_stock " +
            having +
            ") x";

        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql)) {
            bindParams(ps, params, 1);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<InventoryModelRow> listModels(String q, String brandId, String stockStatus,
            int page, int pageSize) {
        List<InventoryModelRow> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder where = new StringBuilder(" WHERE p.status='ACTIVE' AND b.is_active=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            where.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ? OR sk.sku_code LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (brandId != null && !brandId.trim().isEmpty()) {
            where.append(" AND p.brand_id = ? ");
            params.add(parseLongSafe(brandId));
        }

        String having = buildHaving(stockStatus);

        // stock_status dùng ROP formula thay cho ngưỡng cứng 10
        String sql =
            "SELECT " +
            "  p.product_code, p.product_name, b.brand_name, " +
            "  COALESCE(SUM(COALESCE(ib.qty_on_hand, 0)), 0) AS current_stock, " +
            "  CEIL(COALESCE(p.avg_daily_sales, 0) * COALESCE(p.lead_time_days, 0) + COALESCE(p.safety_stock, 0)) AS rop, " +
            "  CASE " +
            "    WHEN COALESCE(SUM(COALESCE(ib.qty_on_hand, 0)), 0) = 0 THEN 'OUT' " +
            "    WHEN COALESCE(SUM(COALESCE(ib.qty_on_hand, 0)), 0) <= " +
            "         CEIL(COALESCE(p.avg_daily_sales,0) * COALESCE(p.lead_time_days,0) + COALESCE(p.safety_stock,0)) " +
            "    THEN 'LOW' " +
            "    ELSE 'OK' " +
            "  END AS stock_status, " +
            "  DATE_FORMAT( " +
            "    GREATEST( " +
            "      COALESCE(MAX(ib.updated_at), '1970-01-01'), " +
            "      COALESCE(p.updated_at, p.created_at) " +
            "    ), '%Y-%m-%d' " +
            "  ) AS last_updated " +
            "FROM products p " +
            "JOIN brands b ON b.brand_id = p.brand_id " +
            "LEFT JOIN product_skus sk ON sk.product_id = p.product_id AND sk.status='ACTIVE' " +
            "LEFT JOIN inventory_balance ib ON ib.sku_id = sk.sku_id " +
            where +
            "GROUP BY p.product_id, p.product_code, p.product_name, b.brand_name, " +
            "         p.avg_daily_sales, p.lead_time_days, p.safety_stock " +
            having +
            "ORDER BY p.product_name " +
            "LIMIT ? OFFSET ?";

        try (Connection con = getConn(); PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = bindParams(ps, params, 1);
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

    /**
     * buildHaving dùng cột rop (đã tính trong subquery) thay ngưỡng cứng.
     * Với filter "OK"  : current_stock > rop
     * Với filter "LOW" : 0 < current_stock <= rop
     * Với filter "OUT" : current_stock = 0
     */
    private String buildHaving(String stockStatus) {
        if (stockStatus == null || stockStatus.trim().isEmpty()) return "";
        switch (stockStatus.trim().toUpperCase()) {
            case "OK":  return " HAVING current_stock > rop ";
            case "LOW": return " HAVING current_stock > 0 AND current_stock <= rop ";
            case "OUT": return " HAVING current_stock = 0 ";
            default:    return "";
        }
    }

    private int bindParams(PreparedStatement ps, List<Object> params, int startIndex) throws SQLException {
        int idx = startIndex;
        for (Object o : params) {
            if (o instanceof String)      ps.setString(idx++, (String) o);
            else if (o instanceof Long)   ps.setLong(idx++, (Long) o);
            else                          ps.setObject(idx++, o);
        }
        return idx;
    }

    private long parseLongSafe(String s) {
        try { return Long.parseLong(s.trim()); } catch (Exception e) { return -1; }
    }

    public Map<Long, Integer> mapQtyOnHand() throws Exception {
        String sql = "SELECT sku_id, qty_on_hand FROM inventory_balance";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            Map<Long, Integer> map = new HashMap<>();
            while (rs.next()) map.put(rs.getLong("sku_id"), rs.getInt("qty_on_hand"));
            return map;
        }
    }
}
