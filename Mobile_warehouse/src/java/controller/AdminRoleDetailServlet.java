package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import model.UserRoleDetail;

public class AdminRoleDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int userId = parseInt(req.getParameter("user_id"), 0);
        if (userId <= 0) {
            req.setAttribute("error", "Missing user_id. Example: /admin/role-detail?user_id=1");
            req.getRequestDispatcher("/WEB-INF/views/admin/role_detail.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        UserRoleDetail detail = dao.getUserRoleDetailByUserId(userId);

        if (detail == null) {
            req.setAttribute("error", "User not found or role not found for user_id=" + userId);
            req.getRequestDispatcher("/WEB-INF/views/admin/role_detail.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("detail", detail);
        req.getRequestDispatcher("/WEB-INF/views/admin/role_detail.jsp").forward(req, resp);
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
