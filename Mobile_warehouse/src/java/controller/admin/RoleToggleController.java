/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.admin;

import dal.RoleDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 *
 * @author Admin
 */
@WebServlet("/admin/role/toggle")
public class RoleToggleController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String roleIdRaw = req.getParameter("id");
        String activeRaw = req.getParameter("active");

        int roleId, active;
        try {
            roleId = Integer.parseInt(roleIdRaw);
            active = Integer.parseInt(activeRaw); // 1 or 0
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/roles?msg=failed");
            return;
        }

        RoleDBContext rdb = new RoleDBContext();
        boolean ok = rdb.toggleRole(roleId, active);

        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/admin/roles?msg=updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/roles?msg=failed");
        }
    }
}
