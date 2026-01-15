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
import model.UserRoleDetail;

@WebServlet(name = "AdminRoleDetailServlet", urlPatterns = {"/admin/role-detail"})
public class AdminRoleDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int userId = parseInt(req.getParameter("user_id"), 0);
        if (userId <= 0) {
            req.setAttribute("error", "Invalid user_id");
            req.getRequestDispatcher("/role_detail.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        UserRoleDetail detail = dao.getUserRoleDetail(userId);

        if (detail == null) {
            req.setAttribute("error", "User not found for user_id=" + userId);
            req.getRequestDispatcher("/role_detail.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("detail", detail);
        req.getRequestDispatcher("/role_detail.jsp").forward(req, resp);
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}