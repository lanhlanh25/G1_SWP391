/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");

        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        UserDAO dao = new UserDAO();

        // roleName lấy từ session (đã set ở LoginServlet), nếu null thì query DB
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = dao.getRoleNameByUserId(u.getUserId());
        }
        if (role == null) role = "STAFF";
        role = role.toUpperCase();

        String p = request.getParameter("p");
        if (p == null || p.isBlank()) p = "dashboard";
        p = p.trim().toLowerCase();

        if (!isAllowed(role, p)) {
            p = "denied";
        }

        

        // sidebar theo role
        String sidebarPage;
        switch (role) {
            case "ADMIN":
                sidebarPage = "/sidebar_admin.jsp";
                break;
            case "MANAGER":
                sidebarPage = "/sidebar_manager.jsp";
                break;
            case "SALE":
            case "SALER":
                sidebarPage = "/sidebar_sales.jsp";
                break;
            default:
                sidebarPage = "/sidebar_staff.jsp";
                break;
        }

        request.setAttribute("sidebarPage", sidebarPage);
        request.setAttribute("contentPage", "/content.jsp");
        request.setAttribute("page", p);

        request.getRequestDispatcher("/homepage.jsp").forward(request, response);
    }

    private boolean isAllowed(String role, String p) {
        if ("dashboard".equals(p) || "denied".equals(p)) return true;

        switch (role) {
            case "ADMIN":
                return p.equals("user-list") || p.equals("user-add") || p.equals("user-update") || p.equals("user-toggle")
                        || p.equals("role-list") || p.equals("role-update") || p.equals("role-toggle")
                        || p.equals("role-perm-view") || p.equals("role-perm-edit")
                        ||  p.equals("change_password");

            case "MANAGER":
                return p.equals("reports") || p.equals("user-list") || p.equals("user-detail")
                        ||  p.equals("change_password");

            case "STAFF":
                return p.equals("inbound") || p.equals("outbound") || p.equals("stock-count")
                        || p.equals("change_password");

            case "SALE":
                return p.equals("inventory") || p.equals("create-out")
                        ||  p.equals("change_password");
        }
        return false;
    }
}
