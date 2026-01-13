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
}
