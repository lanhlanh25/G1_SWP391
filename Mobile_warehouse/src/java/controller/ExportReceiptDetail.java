/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.ExportReceiptDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.ExportReceiptDetailHeader;
import model.ExportReceiptDetailLine;
import model.User;

import java.util.List;

/**
 *
 * @author Admin
 */
@WebServlet(name = "ExportReceiptDetail", urlPatterns = {"/export-receipt-detail"})
public class ExportReceiptDetail extends HttpServlet {

    private String ensureRole(HttpSession session, User u) {
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) {
                role = "STAFF";
            }
            session.setAttribute("roleName", role);
        }
        return role.toUpperCase();
    }

    private String resolveSidebar(String role) {
        if (role == null) return "sidebar_staff.jsp";
        switch (role.toUpperCase()) {
            case "ADMIN":
                return "sidebar_admin.jsp";
            case "MANAGER":
                return "sidebar_manager.jsp";
            case "SALE":
                return "sidebar_sales.jsp";
            default:
                return "sidebar_staff.jsp";
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");

        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = ensureRole(session, u);

        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/home?p=export-receipt-list&err=Missing+id");
            return;
        }

        long exportId;
        try {
            exportId = Long.parseLong(idRaw.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/home?p=export-receipt-list&err=Invalid+id");
            return;
        }

        try {
            ExportReceiptDAO dao = new ExportReceiptDAO();
            ExportReceiptDetailHeader receiptHeader = dao.getDetailHeader(exportId);
            List<ExportReceiptDetailLine> lines = dao.getDetailLines(exportId);

            req.setAttribute("receiptHeader", receiptHeader);
            req.setAttribute("lines", lines);

        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("err", "Load export receipt detail failed: " + ex.getMessage());
        }

        req.setAttribute("role", role);
        req.setAttribute("sidebarPage", resolveSidebar(role));
        req.setAttribute("contentPage", "export_receipt_detail.jsp");
        req.setAttribute("currentPage", "export-receipt-detail");

        req.getRequestDispatcher("homepage.jsp").forward(req, resp);
    }
}