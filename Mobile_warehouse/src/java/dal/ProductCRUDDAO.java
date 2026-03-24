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

    public String generateProductCode(long brandId) throws Exception {

        String brandSql = "SELECT brand_name FROM brands WHERE brand_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps1 = con.prepareStatement(brandSql)) {

            ps1.setLong(1, brandId);

            ResultSet rs1 = ps1.executeQuery();

            if (!rs1.next()) {
                throw new RuntimeException("Brand not found");
            }

            String brandName = rs1.getString("brand_name");

            // lấy 3 ký tự đầu
            String brandCode = brandName.substring(0, Math.min(3, brandName.length())).toUpperCase();

            String sql = """
            SELECT COUNT(*) c
            FROM products
            WHERE brand_id = ?
        """;

            PreparedStatement ps2 = con.prepareStatement(sql);

            ps2.setLong(1, brandId);

            ResultSet rs2 = ps2.executeQuery();

            int number = 1;

            if (rs2.next()) {
                number = rs2.getInt("c") + 1;
            }

            return String.format("PRD-%s-%05d", brandCode, number);
        }
    }

    public boolean existsByName(String name) throws Exception {

        String sql = "SELECT 1 FROM products WHERE LOWER(product_name) = LOWER(?) LIMIT 1";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name == null ? "" : name.trim());

            ResultSet rs = ps.executeQuery();

            return rs.next();
        }
    }

    public void inactivateProduct(int productId) throws Exception {
        String sql = "UPDATE products SET status = 'INACTIVE' WHERE product_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
        inactivateSkusByProduct(productId);
    }

    public String getBlockReasonForInactivate(int productId) throws Exception {
        try (Connection con = DBContext.getConnection()) {

            // 1. Check Export Requests (Not completed/cancelled/rejected)
            String sqlExpReq = """
                SELECT er.request_code 
                FROM export_request_lines erl
                JOIN export_requests er ON erl.request_id = er.request_id
                WHERE erl.product_id = ? 
                  AND er.status NOT IN ('COMPLETED', 'CANCELLED', 'REJECTED')
                LIMIT 1
            """;
            try (PreparedStatement ps = con.prepareStatement(sqlExpReq)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return "Sản phẩm đang nằm trong Yêu cầu xuất kho đang xử lý: " + rs.getString(1);
                    }
                }
            }

            // 2. Check Import Requests (Not completed/cancelled/rejected)
            String sqlImpReq = """
                SELECT ir.request_code 
                FROM import_request_lines irl
                JOIN import_requests ir ON irl.request_id = ir.request_id
                WHERE irl.product_id = ? 
                  AND ir.status NOT IN ('COMPLETED', 'CANCELLED', 'REJECTED')
                LIMIT 1
            """;
            try (PreparedStatement ps = con.prepareStatement(sqlImpReq)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return "Sản phẩm đang nằm trong Yêu cầu nhập kho đang xử lý: " + rs.getString(1);
                    }
                }
            }

            // 3. Check Export Receipts (Draft or Pending)
            String sqlExpRec = """
                SELECT er.export_code 
                FROM export_receipt_lines erl
                JOIN export_receipts er ON erl.export_id = er.export_id
                WHERE erl.product_id = ? 
                  AND er.status IN ('DRAFT', 'PENDING')
                LIMIT 1
            """;
            try (PreparedStatement ps = con.prepareStatement(sqlExpRec)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return "Sản phẩm đang nằm trong Phiếu xuất kho chưa hoàn tất: " + rs.getString(1);
                    }
                }
            }

            // 4. Check Import Receipts (Draft or Pending)
            String sqlImpRec = """
                SELECT ir.import_code 
                FROM import_receipt_lines irl
                JOIN import_receipts ir ON irl.import_id = ir.import_id
                WHERE irl.product_id = ? 
                  AND ir.status IN ('DRAFT', 'PENDING')
                LIMIT 1
            """;
            try (PreparedStatement ps = con.prepareStatement(sqlImpRec)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return "Sản phẩm đang nằm trong Phiếu nhập kho chưa hoàn tất: " + rs.getString(1);
                    }
                }
            }
        }
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

            if ("INACTIVE".equalsIgnoreCase(status)) {
                inactivateSkusByProduct(id);
            }
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
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }
}
