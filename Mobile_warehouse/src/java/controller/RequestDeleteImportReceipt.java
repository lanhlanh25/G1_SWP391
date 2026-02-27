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
        if (importIdStr == null || importIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list?err=Missing+import+ID");
            return;
        }

        long importId;
        try {
            importId = Long.parseLong(importIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list?err=Invalid+import+ID");
            return;
        }

     
        ImportReceiptDeleteRequestDAO dao = new ImportReceiptDeleteRequestDAO();
        try {
            ImportReceiptDeleteRequest importInfo = dao.getImportInfoForRequest(importId);

            if (importInfo == null) {
                resp.sendRedirect(req.getContextPath() + "/import-receipt-list?err=Import+receipt+not+found");
                return;
            }

         
            req.setAttribute("role", role);
            req.setAttribute("username", user.getUsername());
            req.setAttribute("importInfo", importInfo);
            req.setAttribute("currentUser", user.getFullName());

            req.getRequestDispatcher("/request_delete_import_receipt.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list?err=Error+loading+request+form");
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

        if (importIdStr == null || importCode == null || note == null || note.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/request-delete-import-receipt?id=" + importIdStr
                    + "&err=" + URLEncoder.encode("Please provide reason for deletion", StandardCharsets.UTF_8));
            return;
        }

        long importId = Long.parseLong(importIdStr);

      
        ImportReceiptDeleteRequestDAO dao = new ImportReceiptDeleteRequestDAO();
        try {
            boolean success = dao.createRequest(importId, importCode, note.trim(), user.getUserId());

            if (success) {
                resp.sendRedirect(req.getContextPath() + "/import-receipt-list?msg="
                        + URLEncoder.encode("Delete request sent successfully", StandardCharsets.UTF_8));
            } else {
                resp.sendRedirect(req.getContextPath() + "/import-receipt-list?err="
                        + URLEncoder.encode("Failed to send delete request", StandardCharsets.UTF_8));
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list?err="
                    + URLEncoder.encode("Error: " + e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private String getRoleName(HttpSession session, User user) {
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(user.getUserId());
            if (role == null) {
                role = "STAFF";
            }
            session.setAttribute("roleName", role);
        }
        return role.toUpperCase();
    }
}
