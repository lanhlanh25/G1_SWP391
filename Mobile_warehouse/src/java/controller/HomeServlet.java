/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author ADMIN
 */
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User u = (User) request.getSession().getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = u.getRoleName();
        if (role == null) {
            role = "STAFF";
        }
        role = role.toUpperCase();

        String p = request.getParameter("p");
        if (p == null || p.isBlank()) {
            p = "dashboard";
        }
        p = p.trim().toLowerCase();

        if (!isAllowed(role, p)) {
            p = "denied";
        }

        // Nếu vào profile thì lấy fresh từ DB (optional)
        if ("profile".equals(p)) {
            dal.UserDBContext db = new dal.UserDBContext();
            model.User fresh = db.getById(u.getUserId());
            if (fresh != null) {
                request.setAttribute("profileUser", fresh);
            }
        }

        // sidebar theo role
        String sidebarPage;
        switch (role) {
            case "ADMIN":
                sidebarPage = "/views/home/home_sb/sidebar_admin.jsp";
                break;
            case "MANAGER":
                sidebarPage = "/views/home/home_sb/sidebar_manager.jsp";
                break;
            case "SALE":
                sidebarPage = "/views/home/home_sb/sidebar_sales.jsp";
                break;
            default:
                sidebarPage = "/views/home/home_sb/sidebar_staff.jsp";
                break;
        }

        request.setAttribute("sidebarPage", sidebarPage);
        request.setAttribute("contentPage", "/views/home/home_ct/content.jsp"); // 1 FILE CHUNG
        request.setAttribute("page", p);

        request.getRequestDispatcher("/views/home/homepage.jsp").forward(request, response);
    }

    private boolean isAllowed(String role, String p) {
        if ("dashboard".equals(p) || "denied".equals(p)) {
            return true;
        }

        switch (role) {
            case "ADMIN":
                return p.equals("user-list") || p.equals("user-add") || p.equals("user-update") || p.equals("user-toggle")
                        || p.equals("role-list") || p.equals("role-update") || p.equals("role-toggle")
                        || p.equals("role-perm-view") || p.equals("role-perm-edit")
                        || p.equals("profile") || p.equals("change-password");

            case "MANAGER":
                return p.equals("reports") || p.equals("user-list") || p.equals("user-detail")
                        || p.equals("profile") || p.equals("change-password");

            case "STAFF":
                return p.equals("inbound") || p.equals("outbound") || p.equals("stock-count")
                        || p.equals("profile") || p.equals("change-password");

            case "SALE":
                return p.equals("inventory") || p.equals("create-out")
                        || p.equals("profile") || p.equals("change-password");
        }
        return false;
    }
}