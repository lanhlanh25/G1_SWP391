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

@WebServlet("/verify-otp")
public class VerifyOtpServlet extends HttpServlet {

    private final UserDAO dao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("verify_otp.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("fp_userId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String otp = req.getParameter("otp");
        otp = (otp == null) ? "" : otp.trim();

        if (otp.isBlank()) {
            req.setAttribute("err", "Please enter OTP.");
            req.getRequestDispatcher("verify_otp.jsp").forward(req, resp);
            return;
        }

        boolean ok = dao.verifyOtpLatest(userId, otp);
        if (!ok) {
            req.setAttribute("err", "Invalid or expired OTP. Please try again.");
            req.getRequestDispatcher("verify_otp.jsp").forward(req, resp);
            return;
        }

        session.setAttribute("fp_verified", true);
        session.setAttribute("fp_otp", otp); // để mark used sau khi reset pass
        resp.sendRedirect(req.getContextPath() + "/reset-password");
    }
}
