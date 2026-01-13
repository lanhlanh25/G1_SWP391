package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import model.User;

@WebServlet(name = "AdminUserToggleServlet", urlPatterns = {"/admin/users/toggle"})
public class AdminUserToggleServlet extends HttpServlet {

//    @Override
//    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
//            throws ServletException, IOException {
//
//        req.setCharacterEncoding("UTF-8");
//
//        // actor (admin đang đăng nhập)
//        HttpSession session = req.getSession(false);
//        User actor = (session != null) ? (User) session.getAttribute("user") : null;
//        if (actor == null) {
//            resp.sendRedirect(req.getContextPath() + "/login.jsp");
//            return;
//        }
//
//        int actorId = actor.getUserId();
@Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

    req.setCharacterEncoding("UTF-8");

    // ===== TEMP: bypass login để test =====
    int actorId = 1; // admin giả
    
        int targetId = parseInt(req.getParameter("user_id"), 0);
        int curStatus = parseInt(req.getParameter("cur_status"), 1); // 1/0
        int newStatus = (curStatus == 1) ? 0 : 1;

        if (targetId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=invalid");
            return;
        }

        // Không cho tự deactive chính mình (tránh tự khóa)
        if (targetId == actorId && newStatus == 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=cannot_deactive_self");
            return;
        }

        try {
            UserDAO dao = new UserDAO();
            boolean ok = dao.updateUserStatus(targetId, newStatus, actorId);

            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/users?msg=updated");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/users?msg=update_fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=error");
        }
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}