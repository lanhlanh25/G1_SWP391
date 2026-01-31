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
import java.util.ArrayList;
import java.util.List;
import model.ProductListItem;

public class ProductDAO {

    public int count(String q, Long brandId, String status) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) " +
                "FROM products p " +
                "LEFT JOIN brands b ON p.brand_id = b.brand_id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (p.product_code LIKE ? OR p.product_name LIKE ?) ");
            params.add("%" + q.trim() + "%");
            params.add("%" + q.trim() + "%");
        }

        if (brandId != null) {
            sql.append(" AND p.brand_id = ? ");
            params.add(brandId);
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND p.status = ? ");
            params.add(status);
        }

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object x : params) {
                if (x instanceof Long) ps.setLong(idx++, (Long) x);
                else ps.setString(idx++, x.toString());
            }

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    public List<ProductListItem> list(String q, Long brandId, String status, int page, int pageSize) throws Exception {
        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.product_code, p.product_name, p.status, p.created_at, b.brand_name " +
                "FROM products p " +
                "LEFT JOIN brands b ON p.brand_id = b.brand_id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (p.product_code LIKE ? OR p.product_name LIKE ?) ");
            params.add("%" + q.trim() + "%");
            params.add("%" + q.trim() + "%");
        }

        if (brandId != null) {
            sql.append(" AND p.brand_id = ? ");
            params.add(brandId);
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND p.status = ? ");
            params.add(status);
        }

        sql.append(" ORDER BY p.created_at DESC ");
        sql.append(" LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object x : params) {
                if (x instanceof Integer) ps.setInt(idx++, (Integer) x);
                else if (x instanceof Long) ps.setLong(idx++, (Long) x);
                else ps.setString(idx++, x.toString());
            }

            try (ResultSet rs = ps.executeQuery()) {
                List<ProductListItem> list = new ArrayList<>();
                while (rs.next()) {
                    ProductListItem it = new ProductListItem();
                    it.setProductId(rs.getLong("product_id"));
                    it.setProductCode(rs.getString("product_code"));
                    it.setProductName(rs.getString("product_name"));
                    it.setBrandName(rs.getString("brand_name"));
                    it.setStatus(rs.getString("status"));
                    it.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(it);
                }
                return list;
            }
        }
    }
}