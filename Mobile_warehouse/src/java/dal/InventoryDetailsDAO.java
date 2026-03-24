/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class InventoryDetailsDAO {

    private static final int LOW_STOCK_THRESHOLD = 10;

    public static class ProductBrief {

        public long productId;
        public String productCode;
        public String productName;
    }

    public static class SkuRow {
        private long skuId;
        private String skuCode;
        private String color;
        private int ramGb;
        private int storageGb;
        private int qty;
        private String stockStatus;

        public long getSkuId() {
            return skuId;
        }

        public void setSkuId(long skuId) {
            this.skuId = skuId;
        }

        public String getSkuCode() {
            return skuCode;
        }

        public void setSkuCode(String skuCode) {
            this.skuCode = skuCode;
        }

        public String getColor() {
            return color;
        }

        public void setColor(String color) {
            this.color = color;
        }

        public int getRamGb() {
            return ramGb;
        }

        public void setRamGb(int ramGb) {
            this.ramGb = ramGb;
        }

        public int getStorageGb() {
            return storageGb;
        }

        public void setStorageGb(int storageGb) {
            this.storageGb = storageGb;
        }

        public int getQty() {
            return qty;
        }

        public void setQty(int qty) {
            this.qty = qty;
        }

        public String getStockStatus() {
            return stockStatus;
        }

        public void setStockStatus(String stockStatus) {
            this.stockStatus = stockStatus;
        }
    }

    public ProductBrief getProductByCode(String productCode) {
        String sql = "SELECT product_id, product_code, product_name " +
                     "FROM products " +
                     "WHERE product_code = ? AND status = 'ACTIVE' " +
                     "LIMIT 1";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, productCode);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductBrief p = new ProductBrief();
                    p.productId = rs.getLong("product_id");
                    p.productCode = rs.getString("product_code");
                    p.productName = rs.getString("product_name");
                    return p;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public int countSkus(long productId) {
        String sql = "SELECT COUNT(*) " +
                     "FROM product_skus " +
                     "WHERE product_id = ? AND status = 'ACTIVE'";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);

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

    public int sumQtyByProduct(long productId) {
        String sql =
            "SELECT COALESCE(COUNT(pu.unit_id), 0) AS total_qty " +
            "FROM product_skus sk " +
            "LEFT JOIN product_units pu ON pu.sku_id = sk.sku_id AND pu.unit_status = 'ACTIVE' " +
            "WHERE sk.product_id = ? AND sk.status = 'ACTIVE'";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("total_qty");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<SkuRow> listSkuRows(long productId, int page, int pageSize) {
        List<SkuRow> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        String sql =
            "SELECT " +
            "   sk.sku_id, " +
            "   sk.sku_code, " +
            "   sk.color, " +
            "   sk.ram_gb, " +
            "   sk.storage_gb, " +
            "   COALESCE(COUNT(pu.unit_id), 0) AS qty, " +
            "   CASE " +
            "       WHEN COALESCE(COUNT(pu.unit_id), 0) = 0 THEN 'OUT' " +
            "       WHEN COALESCE(COUNT(pu.unit_id), 0) < ? THEN 'LOW' " +
            "       ELSE 'OK' " +
            "   END AS stock_status " +
            "FROM product_skus sk " +
            "LEFT JOIN product_units pu ON pu.sku_id = sk.sku_id AND pu.unit_status = 'ACTIVE' " +
            "WHERE sk.product_id = ? AND sk.status = 'ACTIVE' " +
            "GROUP BY sk.sku_id, sk.sku_code, sk.color, sk.ram_gb, sk.storage_gb " +
            "ORDER BY sk.sku_code " +
            "LIMIT ? OFFSET ?";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, LOW_STOCK_THRESHOLD);
            ps.setLong(2, productId);
            ps.setInt(3, pageSize);
            ps.setInt(4, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SkuRow s = new SkuRow();
                    s.setSkuId(rs.getLong("sku_id"));
                    s.setSkuCode(rs.getString("sku_code"));
                    s.setColor(rs.getString("color"));
                    s.setRamGb(rs.getInt("ram_gb"));
                    s.setStorageGb(rs.getInt("storage_gb"));
                    s.setQty(rs.getInt("qty"));
                    s.setStockStatus(rs.getString("stock_status"));
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
