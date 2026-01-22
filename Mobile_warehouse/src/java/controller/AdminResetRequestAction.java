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

/**
 *
 * @author ADMIN
 */
@WebServlet("/admin/reset-requests/action")
public class AdminResetRequestAction extends HttpServlet {

    private final UserDAO dao = new UserDAO();
    private static final int LINK_EXPIRE_MIN = 30;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer adminId = (session == null) ? null : (Integer) session.getAttribute("userId");
        if (adminId == null || !dao.isAdmin(adminId)) {
            resp.sendError(403);
            return;
        }

        String ridRaw = req.getParameter("requestId");
        String action = req.getParameter("action"); // APPROVE / REJECT
        String reason = req.getParameter("reason");

        if (ridRaw == null || ridRaw.isBlank() || action == null || action.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin/reset-requests");
            return;
        }

        long requestId = Long.parseLong(ridRaw);

        // Lấy request theo id
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

        } else { // APPROVE
            String token = EmailUtil.randomToken32();

            // reuse password_resets để lưu token link
            dao.createOtp(rr.getUserId(), token, LINK_EXPIRE_MIN);

            dao.decideResetRequest(requestId, "APPROVED", null, adminId);

            // Build link chuẩn hơn (không dùng replace URL)
            String link = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort()
                    + req.getContextPath()
                    + "/reset-password?uid=" + rr.getUserId()
                    + "&token=" + token;

            EmailUtil.sendText(
                    rr.getEmail(),
                    "Reset your password",
                    "Hello " + rr.getFullName() + ",\n\n"
                    + "Your request was approved.\n"
                    + "Click this link to reset password (expires in " + LINK_EXPIRE_MIN + " minutes):\n"
                    + link + "\n\n"
                    + "If you did not request this, please ignore this email."
            );
        }

        resp.sendRedirect(req.getContextPath() + "/admin/reset-requests");
    }
}
