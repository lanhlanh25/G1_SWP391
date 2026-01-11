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
@WebServlet(name="ChangePassword", urlPatterns={"/changepassword"})
public class ChangePassword extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ChangePassword</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ChangePassword at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
          request.getRequestDispatcher("change_password.jsp").forward(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // 1) Lấy userId từ session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            // chưa login
            response.sendRedirect("login"); // đổi theo trang login của bạn
            return;
        }

        int userId = (int) session.getAttribute("userId");

        // 2) Lấy dữ liệu form
        String current = request.getParameter("current_password");
        String newPass = request.getParameter("new_password");
        String confirm = request.getParameter("confirm_new_password");

        // 3) Validate rỗng
        if (isBlank(current) || isBlank(newPass) || isBlank(confirm)) {
            request.setAttribute("error", "Please fill in all fields.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        // 4) Lấy mật khẩu hiện tại trong DB
        String storedHash = userDAO.getPasswordHashByUserId(userId);
        if (storedHash == null) {
            request.setAttribute("error", "User not found or password not available.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        // 5) Check current password đúng không
        if (!PasswordUtil.verifyPassword(current, storedHash)) {
            request.setAttribute("error", "Current password is incorrect.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        // 6) Check confirm
        if (!newPass.equals(confirm)) {
            request.setAttribute("error", "Confirm password does not match.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        // 7) Check new password requirement
        if (!isStrongPassword(newPass)) {
            request.setAttribute("error",
                    "New password must be at least 8 characters and contain uppercase, lowercase, and a number.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        // 8) Không được trùng password cũ
        if (PasswordUtil.verifyPassword(newPass, storedHash)) {
            request.setAttribute("error", "New password must be different from current password.");
            request.getRequestDispatcher("change_password.jsp").forward(request, response);
            return;
        }

        // 9) Hash và update
        String newHash = PasswordUtil.hashPassword(newPass);
        boolean ok = userDAO.updatePasswordHash(userId, newHash);

        if (!ok) {
            request.setAttribute("error", "Update password failed. Please try again.");
        } else {
            request.setAttribute("success", "Password updated successfully!");
        }

        request.getRequestDispatcher("change_password.jsp").forward(request, response);
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
 private boolean isStrongPassword(String s) {
        return s != null && s.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$");
    }
    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
