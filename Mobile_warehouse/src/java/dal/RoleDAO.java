/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import model.Role;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
public class RoleDAO {

    public List<Role> searchRoles(String keyword, Integer status) {
        List<Role> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.role_id, r.role_name, r.description, r.is_active, ");
        sql.append("       COUNT(u.user_id) AS user_count ");
        sql.append("FROM roles r ");
        sql.append("LEFT JOIN users u ON u.role_id = r.role_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND r.role_name LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

      
        if (status != null) {
            sql.append("AND r.is_active = ? ");
            params.add(status);
        }

        sql.append("GROUP BY r.role_id, r.role_name, r.description, r.is_active ");
        sql.append("ORDER BY r.role_id ASC");

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Role(
                            rs.getInt("role_id"),
                            rs.getString("role_name"),
                            rs.getString("description"),
                            rs.getInt("is_active"),     
                            rs.getInt("user_count")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean toggleRoleStatus(int roleId) {
        String sql = "UPDATE roles " +
                     "SET is_active = CASE WHEN is_active = 1 THEN 0 ELSE 1 END " +
                     "WHERE role_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String getRoleNameById(int roleId) {
        String sql = "SELECT role_name FROM roles WHERE role_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("role_name");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    public boolean existsRoleName(String roleName) {
    String sql = "SELECT 1 FROM roles WHERE role_name = ? LIMIT 1";
    try (Connection con = DBContext.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, roleName);
        try (ResultSet rs = ps.executeQuery()) {
            return rs.next();
        }
    } catch (Exception e) { e.printStackTrace(); }
    return false;
}

public boolean createRole(String roleName, String description, int isActive) {
    String sql = "INSERT INTO roles(role_name, description, is_active) VALUES (?, ?, ?)";
    try (Connection con = DBContext.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, roleName);
        ps.setString(2, description);
        ps.setInt(3, isActive);
        return ps.executeUpdate() > 0;
    } catch (Exception e) { e.printStackTrace(); }
    return false;
}

}
