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
import java.util.*;
public class RolePermissionDAO {
  public Set<Integer> getPermissionIdsByRole(int roleId) {
        Set<Integer> set = new HashSet<>();
        String sql = "SELECT permission_id FROM role_permissions WHERE role_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) set.add(rs.getInt(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return set;
    }

    // demo: xóa hết rồi insert lại, có granted_by
    public boolean saveRolePermissions(int roleId, List<Integer> permIds, Integer grantedBy) {
        String del = "DELETE FROM role_permissions WHERE role_id = ?";
        String ins = "INSERT INTO role_permissions(role_id, permission_id, granted_by) VALUES (?, ?, ?)";

        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(del)) {
                ps.setInt(1, roleId);
                ps.executeUpdate();
            }

            if (permIds != null && !permIds.isEmpty()) {
                try (PreparedStatement ps = con.prepareStatement(ins)) {
                    for (int pid : permIds) {
                        ps.setInt(1, roleId);
                        ps.setInt(2, pid);
                        if (grantedBy == null) ps.setNull(3, java.sql.Types.INTEGER);
                        else ps.setInt(3, grantedBy);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }  
}
