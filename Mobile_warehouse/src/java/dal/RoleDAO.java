package dal;

import java.sql.*;
import java.util.*;
import model.Role;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.Role;
import model.User;


public class RoleDAO extends DBContext {

    public List<Role> getActiveRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT role_id, role_name FROM roles WHERE is_active=1 ORDER BY role_name";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role r = new Role();
                r.setRoleId(rs.getInt("role_id"));
                r.setRoleName(rs.getString("role_name"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Role getRoleById(int roleId) {
        String sql = """
            SELECT role_id, role_name, description, is_active, created_at, updated_at
            FROM roles
            WHERE role_id = ?
            LIMIT 1
        """;

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role r = new Role();
                    r.setRoleId(rs.getInt("role_id"));
                    r.setRoleName(rs.getString("role_name"));
                    r.setDescription(rs.getString("description"));
                    r.setIsActive(rs.getInt("is_active"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    r.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
// Task #13: View role details by user_id
public model.UserRoleDetail getUserRoleDetailByUserId(int userId) {
    String sql = """
        SELECT u.user_id, u.username, u.full_name, u.email, u.phone, uIF(u.status IS NULL,0,u.status) AS user_status,
               r.role_id, r.role_name, r.description, r.is_active
        FROM users u
        JOIN roles r ON u.role_id = r.role_id
        WHERE u.user_id = ?
        LIMIT 1
    """;

    try (Connection con = getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                // user
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("phone"));
                u.setStatus(rs.getInt("user_status"));
                u.setRoleId(rs.getInt("role_id"));
                u.setRoleName(rs.getString("role_name"));

                // role
                Role r = new Role();
                r.setRoleId(rs.getInt("role_id"));
                r.setRoleName(rs.getString("role_name"));
                r.setDescription(rs.getString("description"));
                r.setIsActive(rs.getInt("is_active"));

                return new model.UserRoleDetail(u, r);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}

}
