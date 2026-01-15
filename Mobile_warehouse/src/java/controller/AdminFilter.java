/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

@WebFilter(filterName = "AdminFilter", urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    // DEV: để true thì vào admin không cần login (chỉ để test)
    private static final boolean DEV_BYPASS_LOGIN = false;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (DEV_BYPASS_LOGIN) {
            chain.doFilter(request, response);
            return;
        }

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");

        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Ưu tiên roleName trong session (LoginServlet nên set)
        String roleName = (String) session.getAttribute("roleName");
        boolean isAdmin = false;

        if (roleName != null && roleName.equalsIgnoreCase("ADMIN")) {
            isAdmin = true;
        } else {
            // fallback: admin roleId = 1 (đổi nếu DB bạn khác)
            isAdmin = (u.getRoleId() == 1);
        }

        if (!isAdmin) {
            resp.sendRedirect(req.getContextPath() + "/home?p=denied");
            return;
        }

        chain.doFilter(request, response);
    }
}