/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import util.PasswordUtil;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final UserDAO dao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isVerified(session)) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }
        req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isVerified(session)) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        int userId = (Integer) session.getAttribute("fp_userId");
        String otp = (String) session.getAttribute("fp_otp");

        String newPass = req.getParameter("new_password");
        String confirm = req.getParameter("confirm_password");

        if (isBlank(newPass) || isBlank(confirm)) {
            req.setAttribute("err", "Please fill in all fields.");
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        if (!newPass.equals(confirm)) {
            req.setAttribute("err", "Confirm password does not match.");
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        // dùng y hệt rule bạn đang dùng ở ChangePassword
        if (!newPass.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            req.setAttribute("err", "Password must be >=8 and contain uppercase, lowercase and number.");
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        boolean ok = dao.updatePasswordHash(userId, PasswordUtil.hashPassword(newPass));
        if (!ok) {
            req.setAttribute("err", "Reset password failed. Please try again.");
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        // mark OTP used
        if (otp != null) {
            dao.markOtpUsedLatest(userId, otp);
        }

        // clear session flow
        session.removeAttribute("fp_userId");
        session.removeAttribute("fp_email");
        session.removeAttribute("fp_verified");
        session.removeAttribute("fp_otp");

        // redirect về login + message
        resp.sendRedirect(req.getContextPath() + "/login?msg=Password+reset+successfully.+Please+login+again.");
    }

    private boolean isVerified(HttpSession session) {
        if (session == null) {
            return false;
        }
        Boolean v = (Boolean) session.getAttribute("fp_verified");
        Integer uid = (Integer) session.getAttribute("fp_userId");
        return v != null && v && uid != null;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
