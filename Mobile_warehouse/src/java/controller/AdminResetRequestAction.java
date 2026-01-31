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
import model.ResetRequest;
import util.EmailUtil;
import util.PasswordUtil;

/**
 *
 * @author ADMIN
 */
@WebServlet("/admin/reset-requests/action")
public class AdminResetRequestAction extends HttpServlet {

    private final UserDAO dao = new UserDAO();
    

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer adminId = (session == null) ? null : (Integer) session.getAttribute("userId");
        if (adminId == null || !dao.isAdmin(adminId)) {
            resp.sendError(403);
            return;
        }

        String ridRaw = req.getParameter("requestId");
        String action = req.getParameter("action"); 
        String reason = req.getParameter("reason");

        if (ridRaw == null || ridRaw.isBlank() || action == null || action.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin/reset-requests");
            return;
        }

        long requestId = Long.parseLong(ridRaw);

        
        ResetRequest rr = dao.getResetRequestById(requestId);
        if (rr == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/reset-requests");
            return;
        }

        // Chỉ xử lý nếu còn PENDING
        if (!"PENDING".equalsIgnoreCase(rr.getStatus())) {
            resp.sendRedirect(req.getContextPath() + "/admin/reset-requests");
            return;
        }

        if ("REJECT".equalsIgnoreCase(action)) {
            String finalReason = (reason == null || reason.isBlank())
                    ? "No reason provided."
                    : reason.trim();

            dao.decideResetRequest(requestId, "REJECTED", finalReason, adminId);

            EmailUtil.sendText(
                    rr.getEmail(),
                    "Password Reset Request Rejected",
                    "Hello " + rr.getFullName() + ",\n\n"
                    + "Your password reset request was rejected.\n"
                    + "Reason: " + finalReason + "\n\n"
                    + "If you believe this is a mistake, please contact administrator."
            );

        } else { 
           
            String newPassword = EmailUtil.randomPassword8();

         
            String newHash = PasswordUtil.hashPassword(newPassword);
            boolean ok = dao.updatePasswordHash(rr.getUserId(), newHash);

            if (ok) {
                
                dao.decideResetRequest(requestId, "APPROVED", null, adminId);

                
                EmailUtil.sendApprovePasswordToUser(rr.getEmail(), rr.getFullName(), newPassword);

            } else {
               
                dao.decideResetRequest(requestId, "REJECTED", "System error: cannot reset password now.", adminId);
                EmailUtil.sendRejectToUser(rr.getEmail(), rr.getFullName(),
                        "System error: cannot reset password now. Please request again later.");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/reset-requests");
    }
}
