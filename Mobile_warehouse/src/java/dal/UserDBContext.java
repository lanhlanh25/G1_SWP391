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
import model.User;
/**
 *
 * @author Admin
 */
public class UserDBContext {

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        try {
            String sql = """
                     select u.user_id, u.username, u.full_name, u.email, u.phone, u.role_id, r.role_name, u.status, u.created_at
                     from users u
                     join roles r on u.role_id = r.role_id
                     order by u.user_id ASC""";
            Connection con = DBContext.getConnection();
            PreparedStatement stm = con.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
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
                u.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(u);
            }
        } catch (Exception e) {
            System.out.println("UserDAO.getAllUsers ERROR:");
            e.printStackTrace();
        }
        return list;
    }
}
