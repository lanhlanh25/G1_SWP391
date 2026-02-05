/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Lanhlanh
 */
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class ProductSkuDAO {

    public void insert(long productId, String skuCode, String color, int ramGb, int storageGb, String status) throws Exception {
        String st = "INACTIVE".equalsIgnoreCase(status) ? "INACTIVE" : "ACTIVE";
        String sql = "INSERT INTO product_skus (product_id, sku_code, color, ram_gb, storage_gb, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);
            ps.setString(2, skuCode == null ? null : skuCode.trim());
            ps.setString(3, color == null ? null : color.trim());
            ps.setInt(4, ramGb);
            ps.setInt(5, storageGb);
            ps.setString(6, st);

            ps.executeUpdate();
        }
    }

    public boolean existsSkuCode(String skuCode) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE sku_code = ? LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, skuCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsVariant(long productId, String color, int ramGb, int storageGb) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE product_id = ? AND color = ? AND ram_gb = ? AND storage_gb = ? LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);
            ps.setString(2, color.trim());
            ps.setInt(3, ramGb);
            ps.setInt(4, storageGb);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long insertSku(long productId, String skuCode, String color, int ramGb, int storageGb, String status) throws Exception {
        String st = "INACTIVE".equalsIgnoreCase(status) ? "INACTIVE" : "ACTIVE";
        String sql = "INSERT INTO product_skus (product_id, sku_code, color, ram_gb, storage_gb, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, productId);
            ps.setString(2, skuCode.trim());
            ps.setString(3, color.trim());
            ps.setInt(4, ramGb);
            ps.setInt(5, storageGb);
            ps.setString(6, st);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return -1;
    }
}
