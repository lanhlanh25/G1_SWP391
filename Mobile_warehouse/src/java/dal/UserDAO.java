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

    public static List<UserRoleDetail> getAllUsersWithRole(String q) {
        List<UserRoleDetail> list = new ArrayList<>();

        String sql
                = "SELECT u.user_id, u.username, u.full_name, u.status, u.role_id, r.role_name "
                + "FROM users u JOIN roles r ON u.role_id = r.role_id "
                + "WHERE (? IS NULL OR ? = '' OR u.username LIKE ? OR u.full_name LIKE ?) "
                + "ORDER BY u.user_id ASC";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, q);
            ps.setString(2, q);
            ps.setString(3, "%" + (q == null ? "" : q.trim()) + "%");
            ps.setString(4, "%" + (q == null ? "" : q.trim()) + "%");

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

}
