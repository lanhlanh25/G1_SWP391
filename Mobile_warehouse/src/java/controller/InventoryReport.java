/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Lanhlanh
 */
import dal.InventoryReportDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.InventoryReportRow;
import model.User;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Map;

@WebServlet(name = "InventoryReport", urlPatterns = {"/inventory-report"})
public class InventoryReport extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) {
                role = "STAFF";
            }
            session.setAttribute("roleName", role);
        }
        role = role.toUpperCase();

        if (!"MANAGER".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        String fromRaw = trim(request.getParameter("from"));
        String toRaw = trim(request.getParameter("to"));
        String brandIdRaw = trim(request.getParameter("brandId"));
        String keyword = trim(request.getParameter("keyword"));

        Date from = parseDate(fromRaw);
        Date to = parseDate(toRaw);

        // Set default dates if not provided: current month (yyyy-mm-01 to today)
        java.time.LocalDate today = java.time.LocalDate.now();
        if (from == null) {
            java.time.LocalDate firstOfMonth = today.withDayOfMonth(1);
            from = java.sql.Date.valueOf(firstOfMonth);
            fromRaw = from.toString();
        }
        if (to == null) {
            to = java.sql.Date.valueOf(today);
            toRaw = to.toString();
        }

        Long brandId = parseLong(brandIdRaw);
        int page = parseInt(request.getParameter("page"), 1);
        if (page < 1) {
            page = 1;
        }

        InventoryReportDAO dao = new InventoryReportDAO();

        try {

            Map<String, Integer> summary = dao.getSummary(from, to, brandId);

            int totalItems = dao.count(from, to, brandId, keyword);
            int totalPages = (int) Math.ceil(totalItems * 1.0 / PAGE_SIZE);
            if (totalPages < 1) {
                totalPages = 1;
            }
            if (page > totalPages) {
                page = totalPages;
            }

            List<InventoryReportRow> rows
                    = dao.list(from, to, brandId, keyword, page, PAGE_SIZE);

            request.setAttribute("brands", dao.getActiveBrands());
            request.setAttribute("summary", summary);
            request.setAttribute("rows", rows);

            request.setAttribute("from", fromRaw == null ? "" : fromRaw);
            request.setAttribute("to", toRaw == null ? "" : toRaw);
            request.setAttribute("brandId", brandId);
            request.setAttribute("keyword", keyword == null ? "" : keyword);

            request.setAttribute("page", page);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("totalItems", totalItems);
            request.setAttribute("totalPages", totalPages);

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("err", "Failed to load report: " + ex.getMessage());
        }

        request.setAttribute("sidebarPage", "sidebar_manager.jsp");
        request.setAttribute("contentPage", "inventory_report.jsp");
        request.setAttribute("currentPage", "inventory-report");
        request.setAttribute("role", "MANAGER");

        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }

    private String trim(String s) {
        if (s == null) {
            return null;
        }
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private Date parseDate(String raw) {
        try {
            if (raw == null) {
                return null;
            }
            return Date.valueOf(raw);
        } catch (Exception e) {
            return null;
        }
    }

    private Long parseLong(String raw) {
        try {
            if (raw == null) {
                return null;
            }
            return Long.parseLong(raw);
        } catch (Exception e) {
            return null;
        }
    }

    private int parseInt(String raw, int def) {
        try {
            if (raw == null) {
                return def;
            }
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }
}
