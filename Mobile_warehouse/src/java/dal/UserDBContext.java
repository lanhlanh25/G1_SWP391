/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import static dal.DBContext.getConnection;
import model.User;
import java.sql.*;

public class UserDBContext extends DBContext {

    public User login(String username, String password) {
        String sql = """
            SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.status,
                   u.role_id, r.role_name
            FROM users u
            JOIN roles r ON r.role_id = u.role_id
            WHERE u.username = ?
              AND u.password_hash = ?
              AND u.status = 1
              AND r.is_active = 1
            LIMIT 1
        """;

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                return null;
            }

            User u = new User();
            u.setUserId(rs.getInt("user_id"));
            u.setUsername(rs.getString("username"));
            u.setFullName(rs.getString("full_name"));
            u.setEmail(rs.getString("email"));
            u.setPhone(rs.getString("phone"));
            u.setStatus(rs.getInt("status"));
            u.setRoleId(rs.getInt("role_id"));
            u.setRoleName(rs.getString("role_name"));
            return u;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public User getById(int userId) {
        String sql = """
        SELECT u.user_id, u.username, u.full_name, u.email, u.phone, u.status,
               u.role_id, r.role_name
        FROM users u
        JOIN roles r ON r.role_id = u.role_id
        WHERE u.user_id = ?
        LIMIT 1
    """;

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                return null;
            }

            User u = new User();
            u.setUserId(rs.getInt("user_id"));
            u.setUsername(rs.getString("username"));
            u.setFullName(rs.getString("full_name"));
            u.setEmail(rs.getString("email"));
            u.setPhone(rs.getString("phone"));
            u.setStatus(rs.getInt("status"));
            u.setRoleId(rs.getInt("role_id"));
            u.setRoleName(rs.getString("role_name"));
            return u;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}