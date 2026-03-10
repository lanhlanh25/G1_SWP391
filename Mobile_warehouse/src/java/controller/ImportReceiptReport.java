/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.ImportReceiptReportDAO;
import dal.SupplierDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import model.ImportReceiptListItem;
import model.ImportReceiptReportSummary;
import model.User;

@WebServlet(name = "ImportReceiptReport", urlPatterns = {"/import-receipt-report"})
public class ImportReceiptReport extends HttpServlet {

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
            return Date.valueOf(raw); 
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
        String supplierIdRaw = request.getParameter("supplierId");
        String statusRaw = request.getParameter("status");

        Date from = parseDate(fromRaw);
        Date to = parseDate(toRaw);

       
        Long supplierId = null;
        if (supplierIdRaw != null) {
            supplierIdRaw = supplierIdRaw.trim();
            if (!supplierIdRaw.isEmpty()) {
                try {
                    supplierId = Long.parseLong(supplierIdRaw);
                } catch (Exception ignored) {
                }
            }
        }

        
        String status = null;
        if (statusRaw != null) {
            statusRaw = statusRaw.trim();
            if (!statusRaw.isEmpty() && !"all".equalsIgnoreCase(statusRaw)) {
                status = statusRaw;
            }
        }

        int page = parseInt(request.getParameter("page"), 1);
        if (page < 1) page = 1;

        final int pageSize = 5;

        try {
            SupplierDAO sdao = new SupplierDAO();
            request.setAttribute("suppliers", sdao.listActive()); 

            ImportReceiptReportDAO dao = new ImportReceiptReportDAO();

            int totalItems = dao.count(from, to, supplierId, status);
            int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            ImportReceiptReportSummary summary = dao.getSummary(from, to, supplierId, status);
            List<ImportReceiptListItem> rows = dao.list(from, to, supplierId, status, page, pageSize);

            
            request.setAttribute("reportSummary", summary);
            request.setAttribute("rows", rows);

            
            request.setAttribute("from", fromRaw == null ? "" : fromRaw);
            request.setAttribute("to", toRaw == null ? "" : toRaw);
            request.setAttribute("supplierId", supplierId);            
            request.setAttribute("status", statusRaw == null ? "all" : statusRaw);

          
            request.setAttribute("page", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalItems", totalItems);
            request.setAttribute("totalPages", totalPages);

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("err", "Load report failed: " + ex.getMessage());
        }

        
        request.setAttribute("sidebarPage", "sidebar_manager.jsp");
        request.setAttribute("contentPage", "import_receipt_report.jsp");
        request.setAttribute("currentPage", "import-receipt-report");
        request.setAttribute("role", "MANAGER");

        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }
}

