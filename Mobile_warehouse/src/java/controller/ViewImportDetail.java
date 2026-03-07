/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.ImportReceiptDetailDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.ImportReceiptDetail;
import model.ImportReceiptLineDetail;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet(name = "ViewImportDetail", urlPatterns = {"/import-receipt-detail"})
public class ViewImportDetail extends HttpServlet {

    private String ensureRole(HttpSession session, User u) {
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) role = "STAFF";
            session.setAttribute("roleName", role);
        }
        return role.toUpperCase();
    }

    private String resolveSidebar(String role) {
        if (role == null) return "sidebar_staff.jsp";
        switch (role.toUpperCase()) {
            case "ADMIN":   return "sidebar_admin.jsp";
            case "MANAGER": return "sidebar_manager.jsp";
            case "SALE":    return "sidebar_sales.jsp";
            default:        return "sidebar_staff.jsp";
        }
    }

    private long parseId(HttpServletRequest req) {
        try {
            String raw = req.getParameter("id");
            if (raw == null) return -1;
            return Long.parseLong(raw.trim());
        } catch (Exception e) {
            return -1;
        }
    }

    private String enc(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = ensureRole(session, u);

        long id = parseId(req);
        if (id <= 0) {
            resp.sendRedirect(req.getContextPath() + "/home?p=import-receipt-list&err=" + enc("Invalid id"));
            return;
        }

        try {
            ImportReceiptDetailDAO dao = new ImportReceiptDetailDAO();

            ImportReceiptDetail receipt = dao.getReceipt(id);
            if (receipt == null) {
                req.setAttribute("err", "Receipt not found");
            } else {
                List<ImportReceiptLineDetail> lines = dao.getLines(id);
                req.setAttribute("receipt", receipt);
                req.setAttribute("lines", lines);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("err", "Load detail failed: " + ex.getMessage());
        }

        req.setAttribute("role", role);
        req.setAttribute("sidebarPage", resolveSidebar(role));
        req.setAttribute("contentPage", "view_import_detail.jsp");
        req.setAttribute("currentPage", "import-receipt-detail");
        req.getRequestDispatcher("homepage.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = ensureRole(session, u);
        if (!"MANAGER".equalsIgnoreCase(role)) {
            resp.sendError(403, "Forbidden");
            return;
        }

        long id = parseId(req);
        if (id <= 0) {
            resp.sendRedirect(req.getContextPath() + "/home?p=import-receipt-list&err=" + enc("Invalid id"));
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        ImportReceiptDetailDAO dao = new ImportReceiptDetailDAO();

        try {
            boolean ok;
            String msg;

            if ("approve".equalsIgnoreCase(action)) {
                ok = dao.approve(id);
                msg = ok ? "Approved successfully" : "Only PENDING/DRAFT receipt can be approved";
                resp.sendRedirect(req.getContextPath() + "/import-receipt-detail?id=" + id + "&msg=" + enc(msg));
                return;
            }

            if ("cancel".equalsIgnoreCase(action)) {
                ok = dao.cancel(id);
                msg = ok ? "Cancelled successfully" : "Only PENDING/DRAFT receipt can be cancelled";
                resp.sendRedirect(req.getContextPath() + "/import-receipt-detail?id=" + id + "&msg=" + enc(msg));
                return;
            }

            // unknown action -> just reload
            resp.sendRedirect(req.getContextPath() + "/import-receipt-detail?id=" + id);
        } catch (Exception ex) {
            // ✅ Catch ALL (including SQLException if your DAO throws it)
            ex.printStackTrace();
            resp.sendRedirect(req.getContextPath()
                    + "/import-receipt-detail?id=" + id
                    + "&err=" + enc("Action failed: " + ex.getMessage()));
        }
    }
}