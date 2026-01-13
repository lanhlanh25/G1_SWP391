/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;


import dal.UserDAO;
import util.PasswordUtil;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.PrintWriter;
/**
 *
 * @author Admin
 */
@WebServlet(name = "ChangePassword", urlPatterns = {"/change_password"})
public class ChangePassword extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("change_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = Integer.parseInt(session.getAttribute("userId").toString());

        String current = request.getParameter("current_password");
        String newPass = request.getParameter("new_password");
        String confirm = request.getParameter("confirm_new_password");

        if (isBlank(current) || isBlank(newPass) || isBlank(confirm)) {
            request.setAttribute("error", "Please fill in all fields.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        String storedHash = userDAO.getPasswordHashByUserId(userId);
        if (storedHash == null || !PasswordUtil.verifyPassword(current, storedHash)) {
            request.setAttribute("error", "Current password is incorrect.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        if (!newPass.equals(confirm)) {
            request.setAttribute("error", "Confirm password does not match.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        if (!newPass.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            request.setAttribute("error", "Password must be >=8 and contain uppercase, lowercase and number.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        if (PasswordUtil.verifyPassword(newPass, storedHash)) {
            request.setAttribute("error", "New password must be different from current password.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        boolean ok = userDAO.updatePasswordHash(userId, PasswordUtil.hashPassword(newPass));
        request.setAttribute(ok ? "success" : "error",
                ok ? "Password updated successfully!" : "Update failed!");
        request.getRequestDispatcher("change_password.jsp").forward(request, response);
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
