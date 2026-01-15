/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/users/toggle")
public class AdminUserToggleServlet extends HttpServlet {

    private int toInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int userId = toInt(req.getParameter("user_id"), -1);
        if (userId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/users/active-page?msg=invalid");
            return;
        }

        UserDAO dao = new UserDAO();
        boolean ok = dao.toggleUserStatus(userId);

        // ✅ QUAY LẠI ACTIVE_USER.JSP sau khi toggle
        resp.sendRedirect(req.getContextPath() + "/admin/users/active-page?msg=" + (ok ? "ok" : "failed"));
    }
}