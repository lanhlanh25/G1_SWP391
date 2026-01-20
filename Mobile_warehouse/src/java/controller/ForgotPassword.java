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
import java.security.SecureRandom;
import model.User;
import util.EmailUtil;

@WebServlet("/forgot-password")
public class ForgotPassword extends HttpServlet {

    private final UserDAO dao = new UserDAO();
    private static final int OTP_EXPIRE_MIN = 5;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        email = (email == null) ? "" : email.trim();

        req.setAttribute("emailVal", email);

        if (email.isBlank()) {
            req.setAttribute("err", "Please enter your email.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        User u = dao.getUserByEmail(email);
        if (u == null) {
            req.setAttribute("err", "Email not found. Please try again.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        if (u.getStatus() == 0) {
            req.setAttribute("err", "This account is inactive.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        String otp = generateOtp6();
        boolean saved = dao.createOtp(u.getUserId(), otp, OTP_EXPIRE_MIN);
        if (!saved) {
            req.setAttribute("err", "Cannot create OTP. Please try again.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        boolean sent = EmailUtil.sendOtp(email, otp, OTP_EXPIRE_MIN);
        if (!sent) {
            req.setAttribute("err", "Failed to send email. Please check SMTP/App Password.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

       
        HttpSession session = req.getSession(true);
        session.setAttribute("fp_userId", u.getUserId());
        session.setAttribute("fp_email", email);
        session.removeAttribute("fp_verified");
        session.removeAttribute("fp_otp"); 

        resp.sendRedirect(req.getContextPath() + "/verify-otp");
    }

    private String generateOtp6() {
        SecureRandom r = new SecureRandom();
        int n = r.nextInt(900000) + 100000;
        return String.valueOf(n);
    }
}
