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

@WebServlet(name = "AdminUserToggleServlet", urlPatterns = {"/admin/users/toggle"})
public class AdminUserToggleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int userId = parseInt(req.getParameter("user_id"), 0);
        if (userId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/users?msg=invalid");
            return;
        }

        UserDAO dao = new UserDAO();
        boolean ok = dao.toggleUserStatus(userId);

        resp.sendRedirect(req.getContextPath() + "/users?msg=" + (ok ? "ok" : "error"));
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}