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
import model.User;

@WebServlet("/forgot-password")
public class ForgotPassword extends HttpServlet {

    private final UserDAO dao = new UserDAO();

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

        if (email.isBlank() ) {
            req.setAttribute("err", "Please enter and confirm your email.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

       

        User u = dao.getUserByEmail(email);
        if (u == null) {
            req.setAttribute("err", "Email not found. Please try again.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }
        if (dao.hasPendingResetRequest(u.getUserId())) {
            req.setAttribute("err", "You already sent a reset request and it is still pending. Please wait for admin response.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        

        if (u.getStatus() == 0) {
            req.setAttribute("err", "This account is inactive.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        boolean ok = dao.createResetRequest(u.getUserId(), email);
        if (!ok) {
            req.setAttribute("err", "Cannot submit request. Please try again.");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("msg", "Your request has been sent to admin. Please check your email later.");
        req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
    }
}
