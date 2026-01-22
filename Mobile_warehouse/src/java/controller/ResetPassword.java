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
public class ResetPassword extends HttpServlet {

    private final UserDAO dao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uidRaw = req.getParameter("uid");
        String token = req.getParameter("token");

        if (uidRaw == null || uidRaw.isBlank() || token == null || token.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(uidRaw);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // ✅ Verify token in DB (NOT session)
        if (!dao.verifyOtpLatest(userId, token)) { // bạn đang reuse password_resets -> ok
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // để JSP dùng hidden input
        req.setAttribute("uid", userId);
        req.setAttribute("token", token);

        req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uidRaw = req.getParameter("uid");
        String token = req.getParameter("token");

        int userId;
        try {
            userId = Integer.parseInt(uidRaw);
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        // ✅ Verify again for safety
        if (token == null || token.isBlank() || !dao.verifyOtpLatest(userId, token)) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String newPass = req.getParameter("new_password");
        String confirm = req.getParameter("confirm_password");

        if (isBlank(newPass) || isBlank(confirm)) {
            req.setAttribute("err", "Please fill in all fields.");
            req.setAttribute("uid", userId);
            req.setAttribute("token", token);
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        if (!newPass.equals(confirm)) {
            req.setAttribute("err", "Confirm password does not match.");
            req.setAttribute("uid", userId);
            req.setAttribute("token", token);
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        if (!newPass.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            req.setAttribute("err", "Password must be >=8 and contain uppercase, lowercase and number.");
            req.setAttribute("uid", userId);
            req.setAttribute("token", token);
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        boolean ok = dao.updatePasswordHash(userId, PasswordUtil.hashPassword(newPass));
        if (!ok) {
            req.setAttribute("err", "Reset password failed. Please try again.");
            req.setAttribute("uid", userId);
            req.setAttribute("token", token);
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        // ✅ mark token used (token chính là token lưu trong password_resets.token_hash)
        dao.markOtpUsedLatest(userId, token);

        resp.sendRedirect(req.getContextPath() + "/login?msg=Password+reset+successfully.+Please+login+again.");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

}
