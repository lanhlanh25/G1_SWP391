/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Lanhlanh
 */
import java.sql.Statement;  
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.IdName;
import model.ProductSku;
public class ProductSkuDAO {

    public void inactivateSkusByProduct(long productId) throws Exception {
        // Nếu DB dùng status:
        String sql = "UPDATE product_skus SET status='INACTIVE' WHERE product_id=?";
        // Nếu DB dùng is_active: String sql = "UPDATE product_skus SET is_active=0 WHERE product_id=?";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.executeUpdate();
        }
    }

    public long insertSku(long productId, String skuCode, String color, int ramGb, int storageGb, String status) throws Exception {
        String st = "INACTIVE".equalsIgnoreCase(status) ? "INACTIVE" : "ACTIVE";

        // Nếu DB dùng status:
        String sql = "INSERT INTO product_skus(product_id, sku_code, color, ram_gb, storage_gb, status) VALUES(?,?,?,?,?,?)";

        // Nếu DB dùng is_active:
        // String sql = "INSERT INTO product_skus(product_id, sku_code, color, ram_gb, storage_gb, is_active) VALUES(?,?,?,?,?,?)";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, productId);
            ps.setString(2, skuCode == null ? null : skuCode.trim());
            ps.setString(3, color == null ? null : color.trim());
            ps.setInt(4, ramGb);
            ps.setInt(5, storageGb);

            // status
            ps.setString(6, st);
            // is_active (nếu dùng is_active):
            // ps.setInt(6, "ACTIVE".equals(st) ? 1 : 0);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        return -1;
    }

    public boolean existsSkuCode(String skuCode) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE sku_code=? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, skuCode == null ? "" : skuCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsVariant(long productId, String color, int ramGb, int storageGb) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE product_id=? AND color=? AND ram_gb=? AND storage_gb=? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);
            ps.setString(2, color == null ? null : color.trim());
            ps.setInt(3, ramGb);
            ps.setInt(4, storageGb);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

     public List<ProductSku> listActive() throws Exception {
        List<ProductSku> list = new ArrayList<>();

        // Nếu DB bạn dùng status ACTIVE/INACTIVE
        String sql = "SELECT sku_id, sku_code, product_id "
                   + "FROM product_skus "
                   + "WHERE status = 'ACTIVE' "
                   + "ORDER BY sku_code";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductSku k = new ProductSku();
                k.setSkuId(rs.getLong("sku_id"));
                k.setSkuCode(rs.getString("sku_code"));
                k.setProductId(rs.getLong("product_id"));
                list.add(k);
            }
        }
        return list;
    }
}