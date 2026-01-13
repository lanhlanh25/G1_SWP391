/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Role;

/**
 *
 * @author Admin
 */
public class RoleDBContext {

    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();
        try {
            String sql = "select role_id, role_name from roles where is_active=1 order by role_name asc";
            Connection con = DBContext.getConnection();
            PreparedStatement stm = con.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
                Role r = new Role();
                r.setRoleId(rs.getInt("role_id"));
                r.setRoleName(rs.getString("role_name"));
                list.add(r);
            }
        } catch (Exception e) {
            System.out.println("RoleDBContext.getAllRoles ERROR:");
            e.printStackTrace();
        }
        return list;
    }

    public List<Role> getAllRolesIncludeInactive() {
        List<Role> list = new ArrayList<>();
        try {
            String sql = "SELECT role_id, role_name, description, is_active, created_at, updated_at "
                    + "FROM roles ORDER BY role_id ASC";
            Connection con = DBContext.getConnection();
            PreparedStatement stm = con.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Role r = new Role();
                r.setRoleId(rs.getInt("role_id"));
                r.setRoleName(rs.getString("role_name"));
                r.setDescription(rs.getString("description"));
                r.setIsActive(rs.getInt("is_active"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setUpdatedAt(rs.getTimestamp("updated_at"));
                list.add(r);
            }
        } catch (Exception e) {
            System.out.println("RoleDBContext.getAllRolesIncludeInactive ERROR:");
            e.printStackTrace();
        }
        return list;
    }

    public boolean toggleRole(int roleId, int newActive) {
        try {
            // optional: block ADMIN role
            String checkSql = "SELECT role_name FROM roles WHERE role_id = ?";
            Connection con = DBContext.getConnection();
            PreparedStatement checkStm = con.prepareStatement(checkSql);
            checkStm.setInt(1, roleId);
            ResultSet rs = checkStm.executeQuery();
            if (rs.next()) {
                String roleName = rs.getString("role_name");
                if ("ADMIN".equalsIgnoreCase(roleName)) {
                    return false; // do not allow disabling admin
                }
            }

            String sql = "UPDATE roles SET is_active = ?, updated_at = NOW() WHERE role_id = ?";
            PreparedStatement stm = con.prepareStatement(sql);
            stm.setInt(1, newActive);
            stm.setInt(2, roleId);
            return stm.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("RoleDBContext.toggleRole ERROR:");
            e.printStackTrace();
        }
        return false;
    }
}
