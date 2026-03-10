/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.ImportReceiptDeleteRequestDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ImportReceiptDeleteRequest;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "RequestDeleteImportReceipt", urlPatterns = {"/request-delete-import-receipt"})
public class RequestDeleteImportReceipt extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("authUser");
        String role = getRoleName(session, user);

        if (!"STAFF".equalsIgnoreCase(role)) {
            resp.sendError(403, "Only staff can create delete requests");
            return;
        }

        String importIdStr = req.getParameter("id");
        long importId;

        try {
            importId = Long.parseLong(importIdStr);
        } catch (Exception e) {
            redirectToImportList(req, resp, "err", "Invalid import ID");
            return;
        }

        ImportReceiptDeleteRequestDAO dao = new ImportReceiptDeleteRequestDAO();

        try {
            ImportReceiptDeleteRequest importInfo = dao.getImportInfoForRequest(importId);
            if (importInfo == null) {
                redirectToImportList(req, resp, "err", "Import receipt not found");
                return;
            }

            req.setAttribute("role", role);
            req.setAttribute("username", user.getUsername());
            req.setAttribute("importInfo", importInfo);
            req.setAttribute("currentUser", user.getFullName());

            req.getRequestDispatcher("/request_delete_import_receipt.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            redirectToImportList(req, resp, "err", "Error loading request form");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("authUser");
        String role = getRoleName(session, user);

        if (!"STAFF".equalsIgnoreCase(role)) {
            resp.sendError(403, "Only staff can create delete requests");
            return;
        }

        String importIdStr = req.getParameter("importId");
        String importCode = req.getParameter("importCode");
        String note = req.getParameter("note");

        long importId;
        try {
            importId = Long.parseLong(importIdStr);
        } catch (Exception e) {
            redirectToImportList(req, resp, "err", "Invalid import ID");
            return;
        }

        if (note == null || note.trim().isEmpty()) {
            
            String back = req.getContextPath()
                    + "/home?p=request-delete-import-receipt&id=" + importId
                    + "&err=" + url("Please provide reason for deletion");
            resp.sendRedirect(back);
            return;
        }

        ImportReceiptDeleteRequestDAO dao = new ImportReceiptDeleteRequestDAO();

        try {
            boolean success = dao.createRequest(importId, importCode, note.trim(), user.getUserId());

            if (success) {
               
                redirectToImportList(req, resp, "msg", "Delete request sent successfully");
            } else {
                redirectToImportList(req, resp, "err", "Failed to send delete request");
            }

        } catch (Exception e) {
            e.printStackTrace();
            redirectToImportList(req, resp, "err", "Error: " + e.getMessage());
        }
    }

    private void redirectToImportList(HttpServletRequest req, HttpServletResponse resp,
                                      String key, String message) throws IOException {
        String url = req.getContextPath()
                + "/home?p=import-receipt-list&" + key + "=" + url(message);
        resp.sendRedirect(url);
    }

    private String url(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    private String getRoleName(HttpSession session, User user) {
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(user.getUserId());
            if (role == null) role = "STAFF";
            session.setAttribute("roleName", role);
        }
        return role.toUpperCase();
    }
}