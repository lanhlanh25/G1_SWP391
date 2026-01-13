/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import model.Permission;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PermissionDAO {
     public List<Permission> getAllActive() {
        List<Permission> list = new ArrayList<>();
        String sql = "SELECT permission_id, code, name, module, description, is_active " +
                     "FROM permissions WHERE is_active = 1 ORDER BY module, name";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new Permission(
                        rs.getInt("permission_id"),
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getString("module"),
                        rs.getString("description"),
                        rs.getInt("is_active")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
