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
        sql.append("SELECT r.role_id, r.role_name, r.description, r.status, ");
        sql.append("       COUNT(u.user_id) AS user_count ");
        sql.append("FROM roles r ");
        sql.append("LEFT JOIN users u ON u.role_id = r.role_id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND r.role_name LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

        // status: null => All, 1 => Active, 0 => Inactive
        if (status != null) {
            sql.append("AND r.status = ? ");
            params.add(status);
        }

        sql.append("GROUP BY r.role_id, r.role_name, r.description, r.status ");
        sql.append("ORDER BY r.role_id ASC");

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Role r = new Role(
                            rs.getInt("role_id"),
                            rs.getString("role_name"),
                            rs.getString("description"),
                            rs.getInt("status"),
                            rs.getInt("user_count")
                    );
                    list.add(r);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean toggleRoleStatus(int roleId) {
        String sql = "UPDATE roles " +
                     "SET status = CASE WHEN status = 1 THEN 0 ELSE 1 END " +
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
}
