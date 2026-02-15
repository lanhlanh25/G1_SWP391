/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.ImportReceiptListDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ImportReceiptListItem;
import model.User;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ImportReceiptList", urlPatterns = {"/import-receipt-list"})
public class ImportReceiptList extends HttpServlet {

    private String ensureRole(HttpSession session, User u) {
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) role = "STAFF";
            session.setAttribute("roleName", role);
        }
        return role.toUpperCase();
    }

    private int parseInt(String raw, int def) {
        try {
            if (raw == null || raw.isBlank()) return def;
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private LocalDate parseDate(String raw) {
        try {
            if (raw == null || raw.isBlank()) return null;
            return LocalDate.parse(raw.trim()); // yyyy-MM-dd
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User u = (User) session.getAttribute("authUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = ensureRole(session, u);

        String action = req.getParameter("action"); // export
        String q = req.getParameter("q");           // search import_code
        String status = req.getParameter("status"); // all/pending/completed/cancelled
        if (status == null || status.isBlank()) status = "all";

        LocalDate from = parseDate(req.getParameter("from"));
        LocalDate to = parseDate(req.getParameter("to"));

        int page = parseInt(req.getParameter("page"), 1);
        if (page < 1) page = 1;

        int pageSize = 10;

        ImportReceiptListDAO dao = new ImportReceiptListDAO();

        // EXPORT CSV
        if ("export".equalsIgnoreCase(action)) {
            try {
                List<ImportReceiptListItem> rows = dao.list(q, status, from, to, 1, 100000);
                exportCsv(rows, resp);
            } catch (SQLException e) {
                throw new ServletException(e);
            }
            return;
        }

        try {
            Map<String, Integer> tabCounts = dao.countByUiStatus(q, from, to);

            int totalItems = dao.count(q, status, from, to);
            int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<ImportReceiptListItem> rows = dao.list(q, status, from, to, page, pageSize);

            req.setAttribute("rows", rows);
            req.setAttribute("role", role);

            req.setAttribute("q", q);
            req.setAttribute("status", status);
            req.setAttribute("from", req.getParameter("from"));
            req.setAttribute("to", req.getParameter("to"));

            req.setAttribute("tabCounts", tabCounts);

            req.setAttribute("page", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalItems", totalItems);
            req.setAttribute("totalPages", totalPages);

          // set layout like /home
req.setAttribute("sidebarPage", resolveSidebar(role));     // sidebar theo role
req.setAttribute("contentPage", "import_receipt_list.jsp"); // content nhúng vào homepage
req.setAttribute("currentPage", "import-receipt-list");     // optional

req.getRequestDispatcher("/homepage.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // DELETE (Manager only, Pending only)
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User u = (User) session.getAttribute("authUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = ensureRole(session, u);
        String action = req.getParameter("action");

        if (!"delete".equalsIgnoreCase(action)) {
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list");
            return;
        }

        if (!"MANAGER".equalsIgnoreCase(role)) {
            resp.sendError(403, "Forbidden");
            return;
        }

        long id;
        try {
            id = Long.parseLong(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list?err=Invalid+id");
            return;
        }

        ImportReceiptListDAO dao = new ImportReceiptListDAO();
        try {
            boolean ok = dao.deleteDraft(id);
            String msg = ok ? "Deleted successfully" : "Only Pending receipt can be deleted";
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list?msg="
                    + URLEncoder.encode(msg, StandardCharsets.UTF_8));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void exportCsv(List<ImportReceiptListItem> rows, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"import_receipts.csv\"");

        try (PrintWriter out = resp.getWriter()) {
            out.write('\uFEFF');
            out.println("No,Import Code,Supplier,Created By,Created Date,Total Qty,Status");

            int no = 1;
            for (ImportReceiptListItem r : rows) {
                String createdDate = (r.getReceiptDate() == null) ? "" : r.getReceiptDate().toString();
                out.printf("%d,%s,%s,%s,%s,%d,%s%n",
                        no++,
                        safeCsv(r.getImportCode()),
                        safeCsv(r.getSupplierName()),
                        safeCsv(r.getCreatedByName()),
                        safeCsv(createdDate),
                        r.getTotalQuantity(),
                        safeCsv(r.getStatusUi())
                );
            }
        }
    }

    private String safeCsv(String s) {
        if (s == null) return "";
        String x = s.replace("\"", "\"\"");
        if (x.contains(",") || x.contains("\n") || x.contains("\r")) return "\"" + x + "\"";
        return x;
    }
    private String resolveSidebar(String role) {
    if (role == null) return "sidebar_staff.jsp";
    role = role.toUpperCase();
    switch (role) {
        case "ADMIN":   return "sidebar_admin.jsp";
        case "MANAGER": return "sidebar_manager.jsp";
        case "SALE":    return "sidebar_sales.jsp";
        default:        return "sidebar_staff.jsp";
    }
}
}