/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;



/**
 *
 * @author Admin
 */
import dal.UserDAO;
import util.PasswordUtil;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
 
@WebServlet(name = "ChangePassword", urlPatterns = {"/change_password"})
public class ChangePassword extends HttpServlet {
 
    private final UserDAO userDAO = new UserDAO();
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to home controller
        response.sendRedirect(request.getContextPath() + "/home?p=change-password");
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
            session.setAttribute("cp_error", "Please fill in all fields.");
            response.sendRedirect(request.getContextPath() + "/home?p=change-password");
            return;
        }
 
        String storedHash = userDAO.getPasswordHashByUserId(userId);
        if (storedHash == null || !PasswordUtil.verifyPassword(current, storedHash)) {
            session.setAttribute("cp_error", "Current password is incorrect.");
            response.sendRedirect(request.getContextPath() + "/home?p=change-password");
            return;
        }
 
        if (!newPass.equals(confirm)) {
            session.setAttribute("cp_error", "Confirm password does not match.");
            response.sendRedirect(request.getContextPath() + "/home?p=change-password");
            return;
        }
 
        if (!newPass.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            session.setAttribute("cp_error", "Password must be >=8 and contain uppercase, lowercase and number.");
            response.sendRedirect(request.getContextPath() + "/home?p=change-password");
            return;
        }
 
        if (PasswordUtil.verifyPassword(newPass, storedHash)) {
            session.setAttribute("cp_error", "New password must be different from current password.");
            response.sendRedirect(request.getContextPath() + "/home?p=change-password");
            return;
        }
 
        boolean ok = userDAO.updatePasswordHash(userId, PasswordUtil.hashPassword(newPass));
        if (ok) {
            session.setAttribute("cp_success", "Password updated successfully!");
        } else {
            session.setAttribute("cp_error", "Update failed!");
        }
        response.sendRedirect(request.getContextPath() + "/home?p=change-password");
    }
 
    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
 
