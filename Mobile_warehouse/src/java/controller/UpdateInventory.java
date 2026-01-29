/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.UpdateInventoryDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet(name = "UpdateInventoryServlet", urlPatterns = {"/inventory-update"})
public class UpdateInventory extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = getRole(session);
        role = role.toUpperCase();

        // UC: STAFF, MANAGER, SALE can view
        if (!"STAFF".equals(role) && !"MANAGER".equals(role) && !"SALE".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        String productCode = request.getParameter("productCode");
        if (productCode == null || productCode.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/inventory?err=Missing productCode");
            return;
        }

        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), 10);
        if (page < 1) page = 1;
        if (pageSize <= 0) pageSize = 10;

        UpdateInventoryDAO dao = new UpdateInventoryDAO();

        UpdateInventoryDAO.ProductBrief p = dao.getProductByCode(productCode);
        if (p == null) {
            response.sendRedirect(request.getContextPath() + "/inventory?err=Product not found");
            return;
        }

        int totalItems = dao.countSkus(p.productId);
        int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        request.setAttribute("productCode", p.productCode);
        request.setAttribute("productModel", p.productName);
        request.setAttribute("totalQty", dao.sumQtyByProduct(p.productId));

        request.setAttribute("skuRows", dao.listSkuRows(p.productId, page, pageSize));
        request.setAttribute("pageNumber", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("sidebarPage", resolveSidebar(role));
        request.setAttribute("contentPage", "update_inventory.jsp");
        request.setAttribute("currentPage", "inventory");

        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = getRole(session);
        role = role.toUpperCase();

        String productCode = request.getParameter("productCode");
        if (productCode == null || productCode.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/inventory?err=Missing productCode");
            return;
        }

        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), 10);

        // ✅ IMPORTANT: SALE is VIEW-ONLY => block updates
        if ("SALE".equals(role)) {
            redirectBack(response, request, productCode, page, pageSize,
                    "SALE role is view-only. You cannot update inventory.");
            return;
        }

        // Only STAFF / MANAGER can update
        if (!"STAFF".equals(role) && !"MANAGER".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        String[] skuIds = request.getParameterValues("skuId");
        String[] qtys = request.getParameterValues("qty");
        if (skuIds == null || qtys == null || skuIds.length != qtys.length) {
            redirectBack(response, request, productCode, page, pageSize, "Invalid form data");
            return;
        }

        Map<Long, Integer> updates = new LinkedHashMap<>();
        try {
            for (int i = 0; i < skuIds.length; i++) {
                long skuId = Long.parseLong(skuIds[i]);

                // qty can be blank in some browsers -> treat as 0
                String qRaw = (qtys[i] == null) ? "" : qtys[i].trim();
                int qty = qRaw.isEmpty() ? 0 : Integer.parseInt(qRaw);

                if (qty < 0) qty = 0;
                updates.put(skuId, qty);
            }
        } catch (Exception e) {
            redirectBack(response, request, productCode, page, pageSize, "Invalid quantity value");
            return;
        }

        UpdateInventoryDAO dao = new UpdateInventoryDAO();
        boolean ok = dao.saveQuantities(updates);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/inventory-update?productCode=" + url(productCode)
                    + "&page=" + page + "&pageSize=" + pageSize
                    + "&msg=" + URLEncoder.encode("Saved successfully", StandardCharsets.UTF_8));
        } else {
            redirectBack(response, request, productCode, page, pageSize, "Save failed");
        }
    }

    // ===== helpers =====

    private String getRole(HttpSession session) {
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            model.User u = (model.User) session.getAttribute("authUser");
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null) role = "STAFF";
            session.setAttribute("roleName", role);
        }
        return role;
    }

    private void redirectBack(HttpServletResponse response, HttpServletRequest request,
                              String productCode, int page, int pageSize, String err) throws IOException {
        response.sendRedirect(request.getContextPath()
                + "/inventory-update?productCode=" + url(productCode)
                + "&page=" + page + "&pageSize=" + pageSize
                + "&err=" + URLEncoder.encode(err, StandardCharsets.UTF_8));
    }

    private String url(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    private int parseInt(String raw, int def) {
        try {
            if (raw == null || raw.isBlank()) return def;
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private String resolveSidebar(String role) {
        switch (role) {
            case "ADMIN": return "sidebar_admin.jsp";
            case "MANAGER": return "sidebar_manager.jsp";
            case "SALE": return "sidebar_sales.jsp";
            default: return "sidebar_staff.jsp";
        }
    }
}