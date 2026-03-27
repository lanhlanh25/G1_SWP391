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
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet(name = "ConductInventoryCountServlet", urlPatterns = {"/inventory-count"})
public class ConductInventoryCount extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = getRole(session).toUpperCase();
        if (!"STAFF".equals(role) && !"MANAGER".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden");
            return;
        }

        User user = (User) session.getAttribute("authUser");
        int userId = user.getUserId();

        String q = trimToNull(request.getParameter("q"));
        String brandId = trimToNull(request.getParameter("brandId"));

        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), DEFAULT_PAGE_SIZE);

        if (page < 1) page = 1;
        if (pageSize <= 0) pageSize = DEFAULT_PAGE_SIZE;

        ConductInventoryCountDAO dao = new ConductInventoryCountDAO();

        int totalItems = dao.countRows(q, brandId);
        int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        request.setAttribute("brands", dao.getActiveBrands());

        // QUAN TRỌNG: phải truyền userId
        request.setAttribute("rows", dao.listRows(userId, q, brandId, page, pageSize));

        request.setAttribute("q", q == null ? "" : q);
        request.setAttribute("brandId", brandId == null ? "" : brandId);
        request.setAttribute("pageNumber", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        // để homepage.jsp include đúng layout
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
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden");
            return;
        }

        String q = trimToNull(request.getParameter("q"));
        String brandId = trimToNull(request.getParameter("brandId"));
        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), DEFAULT_PAGE_SIZE);

        if (page < 1) page = 1;
        if (pageSize <= 0) pageSize = DEFAULT_PAGE_SIZE;

        String[] skuIds = request.getParameterValues("skuId");
        String[] countedQtys = request.getParameterValues("countedQty");

        if (skuIds == null || countedQtys == null || skuIds.length == 0 || skuIds.length != countedQtys.length) {
            redirectBack(request, response, q, brandId, page, pageSize, "Invalid form data");
            return;
        }

        Map<Long, Integer> updates = new LinkedHashMap<>();

        try {
            for (int i = 0; i < skuIds.length; i++) {
                long skuId = Long.parseLong(skuIds[i].trim());

                String rawQty = countedQtys[i] == null ? "" : countedQtys[i].trim();
                int countedQty = rawQty.isEmpty() ? 0 : Integer.parseInt(rawQty);

                if (countedQty < 0) countedQty = 0;

                updates.put(skuId, countedQty);
            }
        } catch (Exception e) {
            redirectBack(request, response, q, brandId, page, pageSize, "Invalid counted quantity");
            return;
        }

        User user = (User) session.getAttribute("authUser");
        int userId = user.getUserId();

        ConductInventoryCountDAO dao = new ConductInventoryCountDAO();
        boolean ok = dao.saveCountedQty(userId, updates);

        if (ok) {
            response.sendRedirect(request.getContextPath() + "/inventory-count"
                    + buildQuery(q, brandId, page, pageSize)
                    + "&msg=" + URLEncoder.encode("Saved successfully", StandardCharsets.UTF_8));
        } else {
            redirectBack(request, response, q, brandId, page, pageSize, "Save failed");
        }
    }

    private String getRole(HttpSession session) {
        String role = (String) session.getAttribute("roleName");

        if (role == null || role.isBlank()) {
            User u = (User) session.getAttribute("authUser");
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) {
                role = "STAFF";
            }
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

    private String trimToNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private void redirectBack(HttpServletRequest req, HttpServletResponse resp,
                              String q, String brandId, int page, int pageSize, String err) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/inventory-count"
                + buildQuery(q, brandId, page, pageSize)
                + "&err=" + URLEncoder.encode(err, StandardCharsets.UTF_8));
    }

    private String buildQuery(String q, String brandId, int page, int pageSize) {
        StringBuilder sb = new StringBuilder("?");
        sb.append("page=").append(page);
        sb.append("&pageSize=").append(pageSize);

        if (q != null) {
            sb.append("&q=").append(URLEncoder.encode(q, StandardCharsets.UTF_8));
        }
        if (brandId != null) {
            sb.append("&brandId=").append(URLEncoder.encode(brandId, StandardCharsets.UTF_8));
        }

        return sb.toString();
    }

    private String resolveSidebar(String role) {
        return "MANAGER".equalsIgnoreCase(role) ? "sidebar_manager.jsp" : "sidebar_staff.jsp";
    }
}