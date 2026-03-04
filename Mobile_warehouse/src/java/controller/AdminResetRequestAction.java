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
import model.User; // Đảm bảo đã import model User
import util.EmailUtil;
import util.PasswordUtil;

@WebServlet("/admin/reset-requests/action")
public class AdminResetRequestAction extends HttpServlet {

    private final UserDAO dao = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        
        model.User userFromSession = (session == null) ? null : (model.User) session.getAttribute("authUser");
        // 1. Kiểm tra đăng nhập
    if (userFromSession == null) {
        resp.sendRedirect(req.getContextPath() + "/login"); 
        return;
    }

    // 2. Kiểm tra quyền Admin (Sử dụng trực tiếp roleName đã lưu trong session ở file Login)
    String sessionRole = (String) session.getAttribute("roleName");
    if (!"ADMIN".equalsIgnoreCase(sessionRole)) {
        resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    int adminId = userFromSession.getUserId();

        // 2. Lấy tham số
        String ridRaw = req.getParameter("requestId");
        String action = req.getParameter("action");
        String reason = req.getParameter("reason");

        // URL quay về danh sách (phải khớp với cách bạn đặt trong Home.java)
        String redirectUrl = req.getContextPath() + "/home?p=admin/reset-requests";

        if (ridRaw == null || action == null) {
            resp.sendRedirect(redirectUrl);
            return;
        }

        try {
            long requestId = Long.parseLong(ridRaw);
            ResetRequest rr = dao.getResetRequestById(requestId);

            if (rr != null && "PENDING".equalsIgnoreCase(rr.getStatus())) {

                if ("REJECT".equalsIgnoreCase(action)) {
                    // Xử lý Từ chối
                    String finalReason = (reason == null || reason.isBlank()) ? "No specific reason provided." : reason.trim();
                    dao.decideResetRequest(requestId, "REJECTED", finalReason, adminId);

                    EmailUtil.sendText(
                            rr.getEmail(),
                            "Password Reset Request Rejected",
                            "Hello " + rr.getFullName() + ",\n\nYour password reset request was rejected.\nReason: " + finalReason
                    );
                    session.setAttribute("message", "Rejected request #" + requestId);

                } else if ("APPROVE".equalsIgnoreCase(action)) {
                    // Xử lý Đồng ý
                    String newPassword = EmailUtil.randomPassword8();
                    String newHash = PasswordUtil.hashPassword(newPassword);

                    boolean ok = dao.updatePasswordHash(rr.getUserId(), newHash);
                    if (ok) {
                        dao.decideResetRequest(requestId, "APPROVED", "Accepted by Admin", adminId);
                        EmailUtil.sendApprovePasswordToUser(rr.getEmail(), rr.getFullName(), newPassword);
                        session.setAttribute("message", "Approved and sent email to " + rr.getEmail());
                    } else {
                        session.setAttribute("error", "Database error: Could not update password.");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "An error occurred: " + e.getMessage());
        }

        // 3. Quan trọng: Redirect về đúng trang list của Admin
        resp.sendRedirect(redirectUrl);
    }
}
