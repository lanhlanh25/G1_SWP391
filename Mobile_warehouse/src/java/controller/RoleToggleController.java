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
public class RoleToggleController extends HttpServlet {

    private int toInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int roleId = toInt(req.getParameter("roleId"), -1);
        if (roleId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/role/active-page?msg=invalid");
            return;
        }

        RoleDAO dao = new RoleDAO();
        dao.toggleRoleStatus(roleId);

        // quay lại trang active_role để thấy thay đổi ngay
        resp.sendRedirect(req.getContextPath() + "/admin/role/active-page");
    }
}
