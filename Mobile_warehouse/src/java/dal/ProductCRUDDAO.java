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

    public boolean existsByCode(String code) throws Exception {
        String sql = "SELECT 1 FROM products WHERE product_code = ? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void insert(Product p) throws Exception {
        String sql = "INSERT INTO products (product_code, product_name, brand_id, model, description, status) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getProductCode());
            ps.setString(2, p.getProductName());
            ps.setLong(3, p.getBrandId());
            ps.setString(4, p.getModel());
            ps.setString(5, p.getDescription());
            ps.setString(6, p.getStatus());
            ps.executeUpdate();
        }
    }
}

