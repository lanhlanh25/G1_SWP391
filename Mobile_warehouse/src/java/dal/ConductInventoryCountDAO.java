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
import model.InventoryCountRow;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
public class ConductInventoryCountDAO {

    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }


    public List<IdName> getActiveBrands() {
        List<IdName> list = new ArrayList<>();
        String sql = "SELECT brand_id, brand_name FROM brands WHERE is_active = 1 ORDER BY brand_name";
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

    public int countRows(String q, String brandId) {
        StringBuilder where = new StringBuilder(" WHERE s.status='ACTIVE' AND p.status='ACTIVE' ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            where.append(" AND (p.product_name LIKE ? OR s.sku_code LIKE ? OR p.product_code LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (brandId != null && !brandId.trim().isEmpty()) {
            where.append(" AND p.brand_id = ? ");
            params.add(parseLongSafe(brandId));
        }

        String sql =
                "SELECT COUNT(*) " +
                "FROM product_skus s " +
                "JOIN products p ON p.product_id = s.product_id " +
                where;

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

  public List<InventoryCountRow> listRows(String q, String brandId, int page, int pageSize) {
    List<InventoryCountRow> list = new ArrayList<>();
    int offset = (page - 1) * pageSize;

    StringBuilder where = new StringBuilder(" WHERE s.status='ACTIVE' AND p.status='ACTIVE' ");
    List<Object> params = new ArrayList<>();

    if (q != null && !q.trim().isEmpty()) {
        where.append(" AND (p.product_name LIKE ? OR s.sku_code LIKE ? OR p.product_code LIKE ?) ");
        String like = "%" + q.trim() + "%";
        params.add(like);
        params.add(like);
        params.add(like);
    }
    if (brandId != null && !brandId.trim().isEmpty()) {
        where.append(" AND p.brand_id = ? ");
        params.add(parseLongSafe(brandId));
    }


    String sql =
            "SELECT " +
            "  s.sku_id, s.sku_code, p.product_name, s.color, s.ram_gb, s.storage_gb, " +
            "  COALESCE((" +
            "    SELECT COUNT(*) FROM product_units pu " +
            "    WHERE pu.sku_id = s.sku_id AND pu.unit_status = 'ACTIVE'" +
            "  ), 0) AS system_qty " +
            "FROM product_skus s " +
            "JOIN products p ON p.product_id = s.product_id " +
            where +
            "ORDER BY s.sku_code " +
            "LIMIT ? OFFSET ?";

    try (Connection con = getConn();
         PreparedStatement ps = con.prepareStatement(sql)) {

        int idx = bind(ps, params);
        ps.setInt(idx++, pageSize);
        ps.setInt(idx++, offset);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                InventoryCountRow r = new InventoryCountRow();
                r.setSkuId(rs.getLong("sku_id"));
                r.setSkuCode(rs.getString("sku_code"));
                r.setProductName(rs.getString("product_name"));
                r.setColor(rs.getString("color"));
                r.setRamGb(rs.getInt("ram_gb"));
                r.setStorageGb(rs.getInt("storage_gb"));

                int sys = rs.getInt("system_qty");
                r.setSystemQty(sys);
                r.setCountedQty(sys); 

                list.add(r);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}

    public boolean saveCountedQty(Map<Long, Integer> skuToCountedQty) {
        String sql =
                "INSERT INTO inventory_balance (sku_id, qty_on_hand, updated_at) " +
                "VALUES (?, ?, NOW()) " +
                "ON DUPLICATE KEY UPDATE qty_on_hand = VALUES(qty_on_hand), updated_at = NOW()";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            con.setAutoCommit(false);

            for (Map.Entry<Long, Integer> e : skuToCountedQty.entrySet()) {
                ps.setLong(1, e.getKey());
                ps.setInt(2, e.getValue());
                ps.addBatch();
            }

            ps.executeBatch();
            con.commit();
            return true;

        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    private int bind(PreparedStatement ps, List<Object> params) throws Exception {
        int idx = 1;
        for (Object o : params) {
            if (o instanceof String) ps.setString(idx++, (String) o);
            else if (o instanceof Long) ps.setLong(idx++, (Long) o);
            else ps.setObject(idx++, o);
        }
        return idx;
    }

    private long parseLongSafe(String s) {
        try { return Long.parseLong(s.trim()); }
        catch (Exception e) { return -1; }
    }
}