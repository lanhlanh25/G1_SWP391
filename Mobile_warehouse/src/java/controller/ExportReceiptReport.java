/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.ExportReceiptReportDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import model.ExportReceiptListItem;
import model.ExportReceiptReportSummary;
import model.User;

@WebServlet(name = "ExportReceiptReport", urlPatterns = {"/export-receipt-report"})
public class ExportReceiptReport extends HttpServlet {

    private static int parseInt(String raw, int def) {
        try {
            if (raw == null) return def;
            raw = raw.trim();
            if (raw.isEmpty()) return def;
            return Integer.parseInt(raw);
        } catch (Exception e) {
            return def;
        }
    }

    private static Date parseDate(String raw) {
        try {
            if (raw == null) return null;
            raw = raw.trim();
            if (raw.isEmpty()) return null;
            return Date.valueOf(raw); // yyyy-MM-dd
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // role check
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) role = "STAFF";
            session.setAttribute("roleName", role);
        }
        role = role.toUpperCase();
        if (!"MANAGER".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        String fromRaw = request.getParameter("from");
        String toRaw = request.getParameter("to");

        Date from = parseDate(fromRaw);
        Date to = parseDate(toRaw);

        int page = parseInt(request.getParameter("page"), 1);
        if (page < 1) page = 1;
        final int pageSize = 5;

        try {
            ExportReceiptReportDAO dao = new ExportReceiptReportDAO();

            int totalItems = dao.count(from, to);
            int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            ExportReceiptReportSummary summary = dao.getSummary(from, to);
            List<ExportReceiptListItem> rows = dao.list(from, to, page, pageSize);

            request.setAttribute("reportSummary", summary);
            request.setAttribute("rows", rows);

            request.setAttribute("from", fromRaw == null ? "" : fromRaw);
            request.setAttribute("to", toRaw == null ? "" : toRaw);

            request.setAttribute("page", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalItems", totalItems);
            request.setAttribute("totalPages", totalPages);

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("err", "Load report failed: " + ex.getMessage());
        }

        // Render inside global layout
        request.setAttribute("sidebarPage", "sidebar_manager.jsp");
        request.setAttribute("contentPage", "export_receipt_report.jsp");
        request.setAttribute("currentPage", "export-receipt-report");
        request.setAttribute("role", "MANAGER");

        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }
}

