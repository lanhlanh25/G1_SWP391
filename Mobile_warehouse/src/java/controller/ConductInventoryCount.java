/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.ConductInventoryCountDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet(name = "ConductInventoryCountServlet", urlPatterns = {"/inventory-count"})
public class ConductInventoryCount extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = getRole(session).toUpperCase();
        // ✅ chỉ STAFF + MANAGER được thao tác inventory count
        if (!"STAFF".equals(role) && !"MANAGER".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        String q = request.getParameter("q");
        String brandId = request.getParameter("brandId");

        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), 10);
        if (page < 1) page = 1;
        if (pageSize <= 0) pageSize = 10;

        ConductInventoryCountDAO dao = new ConductInventoryCountDAO();

        int totalItems = dao.countRows(q, brandId);
        int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        request.setAttribute("brands", dao.getActiveBrands());
        request.setAttribute("rows", dao.listRows(q, brandId, page, pageSize));

        request.setAttribute("q", q);
        request.setAttribute("brandId", brandId);
        request.setAttribute("pageNumber", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("sidebarPage", resolveSidebar(role));
        request.setAttribute("contentPage", "conduct_inventory_count.jsp");
        request.setAttribute("currentPage", "inventory-count");

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

        String role = getRole(session).toUpperCase();
        if (!"STAFF".equals(role) && !"MANAGER".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        String q = request.getParameter("q");
        String brandId = request.getParameter("brandId");
        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), 10);

        String[] skuIds = request.getParameterValues("skuId");
        String[] counted = request.getParameterValues("countedQty");

        if (skuIds == null || counted == null || skuIds.length != counted.length) {
            redirectBack(request, response, q, brandId, page, pageSize, "Invalid form data");
            return;
        }

        Map<Long, Integer> updates = new LinkedHashMap<>();
        try {
            for (int i = 0; i < skuIds.length; i++) {
                long skuId = Long.parseLong(skuIds[i]);
                String raw = (counted[i] == null) ? "" : counted[i].trim();
                int qty = raw.isEmpty() ? 0 : Integer.parseInt(raw);
                if (qty < 0) qty = 0;
                updates.put(skuId, qty);
            }
        } catch (Exception e) {
            redirectBack(request, response, q, brandId, page, pageSize, "Invalid number");
            return;
        }

        ConductInventoryCountDAO dao = new ConductInventoryCountDAO();
        boolean ok = dao.saveCountedQty(updates);

        if (ok) {
            response.sendRedirect(request.getContextPath() + "/inventory-count"
                    + buildQuery(q, brandId, page, pageSize)
                    + "&msg=" + URLEncoder.encode("Saved successfully", StandardCharsets.UTF_8));
        } else {
            redirectBack(request, response, q, brandId, page, pageSize, "Save failed");
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

    private int parseInt(String raw, int def) {
        try {
            if (raw == null || raw.isBlank()) return def;
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private void redirectBack(HttpServletRequest req, HttpServletResponse resp,
                              String q, String brandId, int page, int pageSize, String err) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/inventory-count"
                + buildQuery(q, brandId, page, pageSize)
                + "&err=" + URLEncoder.encode(err, StandardCharsets.UTF_8));
    }

    private String buildQuery(String q, String brandId, int page, int pageSize) {
        StringBuilder sb = new StringBuilder("?");
        sb.append("page=").append(page).append("&pageSize=").append(pageSize);
        if (q != null && !q.isBlank()) sb.append("&q=").append(URLEncoder.encode(q, StandardCharsets.UTF_8));
        if (brandId != null && !brandId.isBlank()) sb.append("&brandId=").append(URLEncoder.encode(brandId, StandardCharsets.UTF_8));
        return sb.toString();
    }

    private String resolveSidebar(String role) {
        return "MANAGER".equals(role) ? "sidebar_manager.jsp" : "sidebar_staff.jsp";
    }
}