/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */

import dal.RoleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/role/toggle")
public class RoleToggle extends HttpServlet {

    private int toInt(String s, int def) {
        try { return Integer.parseInt(s == null ? "" : s.trim()); }
        catch (Exception e) { return def; }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int roleId    = toInt(req.getParameter("role_id"),    -1);
        int curStatus = toInt(req.getParameter("cur_status"),  0);

        if (roleId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/home?p=role-toggle&msg=Invalid+role+ID");
            return;
        }

        RoleDAO dao = new RoleDAO();
        dao.toggleRoleStatus(roleId);

        // ✅ Luôn redirect về home?p=role-toggle để có layout đầy đủ
        resp.sendRedirect(req.getContextPath() + "/home?p=role-toggle&msg=ok");
    }
}

