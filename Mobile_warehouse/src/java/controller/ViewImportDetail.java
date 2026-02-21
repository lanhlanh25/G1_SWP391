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
import java.sql.SQLException;
import java.util.List;

@WebServlet(name="ViewImportDetail", urlPatterns={"/import-receipt-detail"})
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
        switch (role) {
            case "ADMIN":   return "sidebar_admin.jsp";
            case "MANAGER": return "sidebar_manager.jsp";
            case "SALE":    return "sidebar_sales.jsp";
            default:        return "sidebar_staff.jsp";
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

        long id;
        try {
            id = Long.parseLong(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/home?p=import-receipt-list&err=Invalid+id");
            return;
        }

        ImportReceiptDetailDAO dao = new ImportReceiptDetailDAO();

        try {
            ImportReceiptDetail receipt = dao.getReceipt(id);
            if (receipt == null) {
                req.setAttribute("err", "Receipt not found");
            } else {
                List<ImportReceiptLineDetail> lines = dao.getLines(id);
                req.setAttribute("receipt", receipt);
                req.setAttribute("lines", lines);
            }

            req.setAttribute("role", role);
            req.setAttribute("sidebarPage", resolveSidebar(role));
            req.setAttribute("contentPage", "view_import_detail.jsp");
            req.setAttribute("currentPage", "import-receipt-detail");

            req.getRequestDispatcher("homepage.jsp").forward(req, resp);

        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User u = (User) session.getAttribute("authUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = ensureRole(session, u);
        if (!"MANAGER".equalsIgnoreCase(role)) {
            resp.sendError(403, "Forbidden");
            return;
        }

        String action = req.getParameter("action"); // approve | cancel
        long id;
        try {
            id = Long.parseLong(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/home?p=import-receipt-list&err=Invalid+id");
            return;
        }

        ImportReceiptDetailDAO dao = new ImportReceiptDetailDAO();

        try {
            boolean ok;
            String msg;

            if ("approve".equalsIgnoreCase(action)) {
                ok = dao.approve(id);
                msg = ok ? "Approved successfully" : "Only Pending receipt can be approved";
            } else if ("cancel".equalsIgnoreCase(action)) {
                ok = dao.cancel(id);
                msg = ok ? "Cancelled successfully" : "Only Pending receipt can be cancelled";
            } else {
                resp.sendRedirect(req.getContextPath() + "/import-receipt-detail?id=" + id);
                return;
            }

            resp.sendRedirect(req.getContextPath()
                    + "/import-receipt-detail?id=" + id
                    + "&msg=" + URLEncoder.encode(msg, StandardCharsets.UTF_8));

        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }
}