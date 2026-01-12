package controller;

import dal.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

public class AdminFilter implements Filter {

    // ✅ DEV MODE: để true thì cho vào admin mà không cần login (chỉ để test)
    private static final boolean DEV_BYPASS_LOGIN = true;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        User u = (session != null) ? (User) session.getAttribute("user") : null;

        // ✅ Nếu chưa login mà đang dev => cho qua luôn để test add-user
        if (u == null && DEV_BYPASS_LOGIN) {
            chain.doFilter(request, response);
            return;
        }

        // ❌ Không login và không dev => đá về login
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // ✅ Có login => check ADMIN thật sự
        UserDAO dao = new UserDAO();
        if (!dao.isAdmin(u.getUserId())) {
            resp.sendError(403, "Forbidden - Admin only");
            return;
        }

        chain.doFilter(request, response);
    }
}
