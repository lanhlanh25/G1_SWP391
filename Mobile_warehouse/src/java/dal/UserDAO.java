package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.User;

public class UserDAO extends DBContext {

    public boolean usernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username=? LIMIT 1";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean emailExists(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        String sql = "SELECT 1 FROM users WHERE email=? LIMIT 1";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // check user đang login có role_name='ADMIN' không
    public boolean isAdmin(int userId) {
        String sql = """
            SELECT 1
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            WHERE u.user_id=? AND r.role_name='ADMIN' AND u.status=1
            LIMIT 1
        """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // tạo user + ghi audit log, return user_id mới
    public int createUser(String username, String passwordPlain, String fullName,
                          String email, String phone, int roleId, int status,
                          int createdByUserId) throws Exception {

        String insertUser = """
            INSERT INTO users(username, password_hash, full_name, email, phone, role_id, status)
            VALUES(?,?,?,?,?,?,?)
        """;

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            try {
                int newUserId = -1;

                try (PreparedStatement ps = con.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, username);
                    ps.setString(2, passwordPlain); // không hash để khớp sample data
                    ps.setString(3, fullName);
                    ps.setString(4, (email == null || email.isBlank()) ? null : email.trim());
                    ps.setString(5, (phone == null || phone.isBlank()) ? null : phone.trim());
                    ps.setInt(6, roleId);
                    ps.setInt(7, status);
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) newUserId = rs.getInt(1);
                    }
                }

                // audit log
                String audit = """
                    INSERT INTO audit_logs(user_id, action, entity, entity_id, detail)
                    VALUES(?, 'USER_CREATE', 'users', ?, ?)
                """;
                try (PreparedStatement pa = con.prepareStatement(audit)) {
                    pa.setInt(1, createdByUserId);
                    pa.setString(2, String.valueOf(newUserId));
                    pa.setString(3, "Created user: " + username);
                    pa.executeUpdate();
                }

                con.commit();
                return newUserId;
            } catch (Exception ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }
      public List<User> getAllUsersWithRole() {
        List<User> list = new ArrayList<>();
        String sql = """
            SELECT u.user_id, u.username, u.full_name, u.email, u.phone,
                   u.role_id, u.status, u.created_at,
                   r.role_name
            FROM users u
            JOIN roles r ON u.role_id = r.role_id
            ORDER BY u.user_id DESC
        """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("phone"));
                u.setRoleId(rs.getInt("role_id"));
                u.setRoleName(rs.getString("role_name"));
                u.setStatus(rs.getInt("status"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===== Task #10: Active/Deactive user =====
    public boolean updateUserStatus(int targetUserId, int newStatus, int actorUserId) throws Exception {
        if (targetUserId <= 0) return false;
        if (newStatus != 0 && newStatus != 1) return false;

        String sqlUpdate = "UPDATE users SET status=? WHERE user_id=?";
        String sqlAudit  = """
            INSERT INTO audit_logs(user_id, action, entity, entity_id, detail)
            VALUES(?, 'USER_TOGGLE', 'users', ?, ?)
        """;

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(sqlUpdate)) {
                ps.setInt(1, newStatus);
                ps.setInt(2, targetUserId);
                int n = ps.executeUpdate();
                if (n == 0) {
                    con.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps2 = con.prepareStatement(sqlAudit)) {
                ps2.setInt(1, actorUserId);
                ps2.setString(2, String.valueOf(targetUserId));
                ps2.setString(3, "Set status=" + newStatus + " for user_id=" + targetUserId);
                ps2.executeUpdate();
            }

            con.commit();
            return true;
        }
    }
}
