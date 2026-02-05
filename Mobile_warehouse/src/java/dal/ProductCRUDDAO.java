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
import model.Product;

public class ProductCRUDDAO {

    public void inactivateProduct(int productId) throws Exception {
        String sql = "UPDATE products SET status = 'INACTIVE' WHERE product_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }

    public String getBlockReasonForInactivate(int productId) throws Exception {
        return null;
    }

    public boolean existsByCode(String code) throws Exception {
        String sql = "SELECT 1 FROM products WHERE product_code = ? LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public Product getByIdForUpdate(int id) throws Exception {
        String sql = "SELECT p.product_id, p.product_code, p.product_name, p.model, p.description, p.status, "
                + "b.brand_name "
                + "FROM products p "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.product_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setProductCode(rs.getString("product_code"));
                    p.setProductName(rs.getString("product_name"));
                    p.setModel(rs.getString("model"));
                    p.setDescription(rs.getString("description"));
                    p.setStatus(rs.getString("status"));
                    p.setBrandName(rs.getString("brand_name"));
                    return p;
                }
            }
        }
        return null;
    }

    public int countSkuByProduct(int productId) throws Exception {
        String sql = "SELECT COUNT(*) c FROM product_skus WHERE product_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("c");
                }
            }
        }
        return 0;
    }

    public void updateProductByManager(int id, String productName, String model, String description, String status) throws Exception {
        String sql = "UPDATE products SET product_name = ?, model = ?, description = ?, status = ? WHERE product_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, productName);
            ps.setString(2, model);
            ps.setString(3, description);
            ps.setString(4, status);
            ps.setInt(5, id);
            ps.executeUpdate();
        }
    }

    public int sumInventoryByProduct(int productId) throws Exception {
        String sql = "SELECT COALESCE(SUM(quantity),0) s FROM product_skus WHERE product_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("s");
                }
            }
        }
        return 0;
    }

    public String getCreatedAtText(int productId) throws Exception {
        String sql = "SELECT DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') v FROM products WHERE product_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("v");
                }
            }
        }
        return "";
    }

    public void insert(Product p) throws Exception {
        String sql = "INSERT INTO products (product_code, product_name, brand_id, model, description, status) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getProductCode());
            ps.setString(2, p.getProductName());
            ps.setLong(3, p.getBrandId());
            ps.setString(4, p.getModel());
            ps.setString(5, p.getDescription());
            ps.setString(6, p.getStatus());
            ps.executeUpdate();
        }
    }
    public void inactivateSkusByProduct(int productId) throws Exception {
    String sql = "UPDATE product_skus SET status = 'INACTIVE' WHERE product_id = ?";
    try (Connection con = DBContext.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, productId);
        ps.executeUpdate();
    }
}
}
