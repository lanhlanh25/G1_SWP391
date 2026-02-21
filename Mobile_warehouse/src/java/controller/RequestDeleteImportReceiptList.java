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
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet(name = "RequestDeleteImportReceiptList", urlPatterns = {"/request-delete-import-receipt-list"})
public class RequestDeleteImportReceiptList extends HttpServlet {
    
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
        
        // Only MANAGER can view delete requests
        if (!"MANAGER".equalsIgnoreCase(role)) {
            resp.sendError(403, "Only managers can view delete requests");
            return;
        }
        
        // Get search parameters
        String importCodeSearch = req.getParameter("q");
        String transactionTimeStr = req.getParameter("transactionTime");
        
        java.sql.Date searchDate = null;
        if (transactionTimeStr != null && !transactionTimeStr.trim().isEmpty()) {
            try {
                // Parse date string yyyy-MM-dd
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                sdf.setLenient(false);
                java.util.Date utilDate = sdf.parse(transactionTimeStr.trim());
                
                // Convert to java.sql.Date (only date, no time)
                searchDate = new java.sql.Date(utilDate.getTime());
                
                System.out.println("DEBUG Controller: Searching with date = " + searchDate);
            } catch (Exception e) {
                System.err.println("ERROR: Failed to parse date: " + transactionTimeStr);
                e.printStackTrace();
                // Invalid date format, will be ignored
            }
        }
        
        // Pagination
        int page = parseInt(req.getParameter("page"), 1);
        if (page < 1) page = 1;
        int pageSize = 10;
        
        ImportReceiptDeleteRequestDAO dao = new ImportReceiptDeleteRequestDAO();
        
        try {
            int totalItems = dao.countRequests(importCodeSearch, searchDate);
            int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;
            
            List<ImportReceiptDeleteRequest> requests = dao.listRequests(
                importCodeSearch, searchDate, page, pageSize
            );
            
            System.out.println("DEBUG: Found " + requests.size() + " requests (total: " + totalItems + ")");
            
            // Set attributes for JSP
            req.setAttribute("role", role);
            req.setAttribute("username", user.getUsername());
            req.setAttribute("requests", requests);
            req.setAttribute("q", importCodeSearch);
            req.setAttribute("transactionTime", transactionTimeStr);
            req.setAttribute("page", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalItems", totalItems);
            
            req.getRequestDispatcher("/request_delete_import_receipt_list.jsp").forward(req, resp);
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list?err=Error+loading+requests");
        }
    }
    
    private int parseInt(String raw, int def) {
        try {
            if (raw == null || raw.isBlank()) return def;
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return def;
        }
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