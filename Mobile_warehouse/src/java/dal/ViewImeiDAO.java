/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import model.ImeiRow;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ViewImeiDAO {

    public static class SkuHeader {
        public long skuId;
        public String skuCode;
        public String productCode;
        public String productName;
        public String color;
        public int ramGb;
        public int storageGb;
    }

    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }

    public SkuHeader getSkuHeader(long skuId) {
        String sql =
                "SELECT s.sku_id, s.sku_code, p.product_code, p.product_name, s.color, s.ram_gb, s.storage_gb " +
                "FROM product_skus s " +
                "JOIN products p ON p.product_id = s.product_id " +
                "WHERE s.sku_id = ?";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, skuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SkuHeader h = new SkuHeader();
                    h.skuId = rs.getLong("sku_id");
                    h.skuCode = rs.getString("sku_code");
                    h.productCode = rs.getString("product_code");
                    h.productName = rs.getString("product_name");
                    h.color = rs.getString("color");
                    h.ramGb = rs.getInt("ram_gb");
                    h.storageGb = rs.getInt("storage_gb");
                    return h;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int countImeis(long skuId, String q, String status) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM product_units pu WHERE pu.sku_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(skuId);

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND pu.imei LIKE ? ");
            params.add("%" + q.trim() + "%");
        }

        // ✅ DB của bạn dùng unit_status ENUM('INACTIVE','ACTIVE')
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND pu.unit_status = ? ");
            params.add(status.trim().toUpperCase()); // ACTIVE/INACTIVE
        }

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<ImeiRow> listImeis(long skuId, String q, String status, int page, int pageSize) {
        List<ImeiRow> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder(
                "SELECT pu.imei, pu.unit_status " +
                "FROM product_units pu " +
                "WHERE pu.sku_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(skuId);

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND pu.imei LIKE ? ");
            params.add("%" + q.trim() + "%");
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND pu.unit_status = ? ");
            params.add(status.trim().toUpperCase()); // ACTIVE/INACTIVE
        }

        sql.append(" ORDER BY pu.imei LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add(offset);

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImeiRow r = new ImeiRow();
                    r.setImei(rs.getString("imei"));
                    r.setStatus(rs.getString("unit_status")); // ACTIVE/INACTIVE
                    list.add(r);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        int idx = 1;
        for (Object o : params) {
            if (o instanceof Long) ps.setLong(idx++, (Long) o);
            else if (o instanceof Integer) ps.setInt(idx++, (Integer) o);
            else ps.setString(idx++, String.valueOf(o));
        }
    }
}