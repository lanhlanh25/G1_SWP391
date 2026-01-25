/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 *
 * @author ADMIN
 */
@WebServlet("/admin/reset-requests")
public class AdminResetRequests extends HttpServlet {

    private final UserDAO dao = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer adminId = (session == null) ? null : (Integer) session.getAttribute("userId");
        if (adminId == null || !dao.isAdmin(adminId)) {
            resp.sendError(403);
            return;
        }

        req.setAttribute("pendingRequests", dao.getPendingResetRequests());
        req.getRequestDispatcher("/admin_reset_requests.jsp").forward(req, resp);
    }

}
