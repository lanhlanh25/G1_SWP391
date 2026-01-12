package dal;

import java.sql.*;
import java.util.*;
import model.Role;

public class RoleDAO extends DBContext {

    public List<Role> getActiveRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT role_id, role_name FROM roles WHERE is_active=1 ORDER BY role_name";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Role(rs.getInt("role_id"), rs.getString("role_name")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
