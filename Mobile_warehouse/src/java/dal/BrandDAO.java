/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.*;
import java.util.*;
import model.Brand;

/**
 *
 * @author ADMIN
 */
public class BrandDAO {

    private Brand map(ResultSet rs) throws SQLException {
        Brand b = new Brand();
        b.setBrandId(rs.getLong("brand_id"));
        b.setBrandName(rs.getString("brand_name"));
        b.setDescription(rs.getString("description"));
        b.setActive(rs.getInt("is_active") == 1);
        int cb = rs.getInt("created_by");
        b.setCreatedBy(rs.wasNull() ? null : cb);
        b.setCreatedAt(rs.getTimestamp("created_at"));
        b.setUpdatedAt(rs.getTimestamp("updated_at"));
        return b;
    }

    public boolean existsByName(String name, Long excludeId) throws SQLException, Exception {
        String sql = "SELECT 1 FROM brands WHERE brand_name = ?"
                + (excludeId != null ? " AND brand_id <> ?" : "")
                + " LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            if (excludeId != null) {
                ps.setLong(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long insert(Brand b) throws SQLException, Exception {
        String sql = "INSERT INTO brands (brand_name, description, is_active, created_by) "
                + "VALUES (?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, b.getBrandName().trim());
            ps.setString(2, b.getDescription());
            ps.setInt(3, b.isActive() ? 1 : 0);
            if (b.getCreatedBy() == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, b.getCreatedBy());
            }
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return -1;
    }

    public Brand findById(long id) throws SQLException, Exception {
        String sql = "SELECT * FROM brands WHERE brand_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }
        return null;
    }

    public void update(Brand b) throws SQLException, Exception {
        String sql = "UPDATE brands SET brand_name=?, description=?, is_active=? WHERE brand_id=?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, b.getBrandName().trim());
            ps.setString(2, b.getDescription());
            ps.setInt(3, b.isActive() ? 1 : 0);
            ps.setLong(4, b.getBrandId());
            ps.executeUpdate();
        }
    }

    public void disable(long id) throws SQLException, Exception {
        String sql = "UPDATE brands SET is_active = 0 WHERE brand_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    // list with paging + filter + sort
    public List<Brand> list(String q, String status, String sortBy, String sortOrder, int page, int pageSize) throws SQLException, Exception {
        String sortCol = switch (sortBy == null ? "" : sortBy) {
            case "name" ->
                "brand_name";
            case "createdAt" ->
                "created_at";
            case "status" ->
                "is_active";
            default ->
                "brand_id";
        };
        String order = "DESC".equalsIgnoreCase(sortOrder) ? "DESC" : "ASC";

        StringBuilder sql = new StringBuilder("SELECT * FROM brands WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND brand_name LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if ("active".equalsIgnoreCase(status)) {
            sql.append(" AND is_active = 1 ");
        } else if ("inactive".equalsIgnoreCase(status)) {
            sql.append(" AND is_active = 0 ");
        }

        sql.append(" ORDER BY ").append(sortCol).append(" ").append(order);
        sql.append(" LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object x = params.get(i);
                if (x instanceof Integer) {
                    ps.setInt(i + 1, (Integer) x);
                } else {
                    ps.setString(i + 1, x.toString());
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Brand> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public int count(String q, String status) throws SQLException, Exception {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM brands WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND brand_name LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if ("active".equalsIgnoreCase(status)) {
            sql.append(" AND is_active = 1 ");
        } else if ("inactive".equalsIgnoreCase(status)) {
            sql.append(" AND is_active = 0 ");
        }

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i).toString());
            }
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }
}
