/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.User;
import model.UserRoleDetail;
import util.PasswordUtil;

public class UserDAO {

    public String getPasswordHashByUserId(int userId) {
        String sql = "SELECT password_hash FROM users WHERE user_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("password_hash");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePasswordHash(int userId, String newHash) {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static String getRoleNameByUserId(int userId) {
        String sql = "SELECT r.role_name "
                + "FROM users u JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.user_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getUserByUsername(String username) {
        String sql = "SELECT user_id, username, password_hash, full_name, email, phone, role_id, status "
                + "FROM users WHERE username = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getString("password_hash"),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            rs.getInt("role_id"),
                            rs.getInt("status")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getById(int userId) {
        String sql = "SELECT user_id, username, password_hash, full_name, email, phone, role_id, status "
                + "FROM users WHERE user_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getString("password_hash"),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            rs.getInt("role_id"),
                            rs.getInt("status")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User login(String username, String password) {
        User u = getUserByUsername(username);
        if (u == null) {
            return null;
        }

        if (u.getStatus() == 0) {
            return null;
        }

        if (!PasswordUtil.verifyPassword(password, u.getPasswordHash())) {
            return null;
        }

        return u;
    }

    public boolean isAdmin(int userId) {
        String role = getRoleNameByUserId(userId);
        return role != null && role.equalsIgnoreCase("ADMIN");
    }

    public Integer getRoleIdByUserId(int userId) {
        String sql = "SELECT role_id FROM users WHERE user_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<UserRoleDetail> getAllUsersWithRole(String q, String statusFilter) {
        List<UserRoleDetail> list = new ArrayList<>();

        String sql
                = "SELECT u.user_id, u.username, u.full_name, u.status, u.role_id, r.role_name "
                + "FROM users u JOIN roles r ON u.role_id = r.role_id "
                + "WHERE (? IS NULL OR ? = '' OR u.username LIKE ? OR u.full_name LIKE ?) "
                + "  AND (? IS NULL OR ? = '' OR u.status = ?) "
                + "ORDER BY u.user_id ASC";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            // ---- filter q ----
            String qTrim = (q == null) ? "" : q.trim();
            ps.setString(1, q);
            ps.setString(2, q);
            ps.setString(3, "%" + qTrim + "%");
            ps.setString(4, "%" + qTrim + "%");

            // ---- filter status ----
            ps.setString(5, statusFilter);
            ps.setString(6, statusFilter);
            if (statusFilter == null || statusFilter.isBlank()) {
                ps.setInt(7, 0); // value bất kỳ, vì điều kiện OR sẽ bỏ qua
            } else {
                ps.setInt(7, Integer.parseInt(statusFilter)); // 1 hoặc 0
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new UserRoleDetail(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getInt("role_id"),
                            rs.getString("role_name"),
                            rs.getString("full_name"),
                            rs.getInt("status")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<UserRoleDetail> getAllUsersWithRole(String q) {
        return getAllUsersWithRole(q, null);
    }

    public boolean toggleUserStatus(int userId) {
        String sql = "UPDATE users SET status = CASE WHEN status = 1 THEN 0 ELSE 1 END WHERE user_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean createUser(User u) {
        String sql = "INSERT INTO users(username, password_hash, full_name, email, phone, role_id, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getUsername());
            ps.setString(2, u.getPasswordHash());
            ps.setString(3, u.getFullName());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getPhone());
            ps.setInt(6, u.getRoleId());
            ps.setInt(7, u.getStatus());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public UserRoleDetail getUserRoleDetail(int userId) {
        String sql
                = "SELECT u.user_id, u.username, u.full_name, u.status, u.role_id, r.role_name "
                + "FROM users u JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.user_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new UserRoleDetail(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getInt("role_id"),
                            rs.getString("role_name"),
                            rs.getString("full_name"),
                            rs.getInt("status") // ✅ thêm status
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateUserInfo(int userId, String fullName, String email, String phone, int roleId, int status) {
        String sql = "UPDATE users SET full_name=?, email=?, phone=?, role_id=?, status=? WHERE user_id=?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setInt(4, roleId);
            ps.setInt(5, status);
            ps.setInt(6, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public User getUserByEmail(String email) {
        String sql = "SELECT user_id, username, password_hash, full_name, email, phone, role_id, status "
                + "FROM users WHERE email = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getString("password_hash"),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            rs.getInt("role_id"),
                            rs.getInt("status")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createOtp(int userId, String otp, int minutes) {
        String sql = "INSERT INTO password_resets(user_id, token_hash, expires_at) "
                + "VALUES(?, ?, DATE_ADD(NOW(), INTERVAL ? MINUTE))";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, otp);
            ps.setInt(3, minutes);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean verifyOtpLatest(int userId, String otp) {
        String sql = "SELECT reset_id FROM password_resets "
                + "WHERE user_id=? AND token_hash=? AND used_at IS NULL AND expires_at > NOW() "
                + "ORDER BY reset_id DESC LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, otp);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void markOtpUsedLatest(int userId, String otp) {
        String sql = "UPDATE password_resets SET used_at=NOW() "
                + "WHERE user_id=? AND token_hash=? AND used_at IS NULL "
                + "ORDER BY reset_id DESC LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, otp);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

// 1) user tạo request
    public boolean createResetRequest(int userId, String email) {
        String sql = "INSERT INTO password_reset_requests(user_id, email, status) VALUES(?, ?, 'PENDING')";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

// 2) admin list pending
    public List<model.ResetRequest> getPendingResetRequests() {
        List<model.ResetRequest> list = new ArrayList<>();
        String sql
                = "SELECT r.request_id, r.user_id, r.email, r.status, r.reason, r.created_at, "
                + "       u.username, u.full_name "
                + "FROM password_reset_requests r "
                + "JOIN users u ON u.user_id = r.user_id "
                + "WHERE r.status = 'PENDING' "
                + "ORDER BY r.created_at DESC";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                model.ResetRequest rr = new model.ResetRequest();
                rr.setRequestId(rs.getLong("request_id"));
                rr.setUserId(rs.getInt("user_id"));
                rr.setEmail(rs.getString("email"));
                rr.setStatus(rs.getString("status"));
                rr.setReason(rs.getString("reason"));
                rr.setCreatedAt(rs.getTimestamp("created_at"));
                rr.setUsername(rs.getString("username"));
                rr.setFullName(rs.getString("full_name"));
                list.add(rr);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

// 3) lấy info email + userId theo requestId (để action servlet dùng)
    public model.ResetRequest getResetRequestById(long requestId) {
        String sql
                = "SELECT r.request_id, r.user_id, r.email, r.status, r.reason, r.created_at, "
                + "       u.username, u.full_name "
                + "FROM password_reset_requests r "
                + "JOIN users u ON u.user_id = r.user_id "
                + "WHERE r.request_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    model.ResetRequest rr = new model.ResetRequest();
                    rr.setRequestId(rs.getLong("request_id"));
                    rr.setUserId(rs.getInt("user_id"));
                    rr.setEmail(rs.getString("email"));
                    rr.setStatus(rs.getString("status"));
                    rr.setReason(rs.getString("reason"));
                    rr.setCreatedAt(rs.getTimestamp("created_at"));
                    rr.setUsername(rs.getString("username"));
                    rr.setFullName(rs.getString("full_name"));
                    return rr;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

// 4) approve/reject (chỉ xử lý nếu đang PENDING)
    public boolean decideResetRequest(long requestId, String status, String reason, int adminId) {
        // status chỉ nên là APPROVED hoặc REJECTED
        String sql
                = "UPDATE password_reset_requests "
                + "SET status=?, reason=?, decided_by=?, decided_at=NOW() "
                + "WHERE request_id=? AND status='PENDING'";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, reason);
            ps.setInt(3, adminId);
            ps.setLong(4, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
// kiểm tra user có request PENDING chưa

    public boolean hasPendingResetRequest(int userId) {
        String sql = "SELECT 1 FROM password_reset_requests WHERE user_id=? AND status='PENDING' LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

// nếu muốn lấy request pending gần nhất để hiện thông báo
    public Long getLatestPendingRequestId(int userId) {
        String sql = "SELECT request_id FROM password_reset_requests WHERE user_id=? AND status='PENDING' ORDER BY created_at DESC LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
