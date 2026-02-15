package controller;

import dal.UserDAO;
import dal.ViewImeiDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "ViewListImeiServlet", urlPatterns = {"/imei-list"})
public class View_List_Imei extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            model.User u = (model.User) session.getAttribute("authUser");
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) role = "STAFF";
            session.setAttribute("roleName", role);
        }
        role = role.toUpperCase();

        if (!"STAFF".equals(role) && !"MANAGER".equals(role) && !"SALE".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        String skuIdRaw = firstNonBlank(
                request.getParameter("skuId"),
                request.getParameter("skudl"),
                request.getParameter("skuID"),
                request.getParameter("sku")
        );

        if (skuIdRaw == null) {
            response.sendRedirect(request.getContextPath() + "/inventory-count?err=Missing skuId");
            return;
        }

        long skuId;
        try {
            skuId = Long.parseLong(skuIdRaw.trim());
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/inventory-count?err=Invalid skuId");
            return;
        }

        String q = request.getParameter("q");  // Search IMEI only

        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), 10);
        if (page < 1) page = 1;
        if (pageSize <= 0) pageSize = 10;

        ViewImeiDAO dao = new ViewImeiDAO();

        try {
            ViewImeiDAO.SkuHeader header = dao.getSkuHeader(skuId);
            if (header == null) {
                response.sendRedirect(request.getContextPath() + "/inventory-count?err=SKU not found");
                return;
            }

            // ✅ Updated: No status filter anymore
            int totalItems = dao.countImeis(skuId, q);
            int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            request.setAttribute("skuId", skuId);
            request.setAttribute("skuCode", header.skuCode);
            request.setAttribute("productCode", header.productCode);
            request.setAttribute("productModel", header.productName);
            request.setAttribute("color", header.color);
            request.setAttribute("ramGb", header.ramGb);
            request.setAttribute("storageGb", header.storageGb);

            request.setAttribute("q", q);

            // ✅ Updated: No status parameter
            request.setAttribute("imeiRows", dao.listImeis(skuId, q, page, pageSize));

            request.setAttribute("pageNumber", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalPages", totalPages);

            request.setAttribute("sidebarPage", resolveSidebar(role));
            request.setAttribute("contentPage", "view_imei_list.jsp");
            request.setAttribute("currentPage", "imei-list");

            request.getRequestDispatcher("homepage.jsp").forward(request, response);

        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/inventory-count?err=IMEI list error");
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

    private String resolveSidebar(String role) {
        switch (role) {
            case "ADMIN": return "sidebar_admin.jsp";
            case "MANAGER": return "sidebar_manager.jsp";
            case "SALE": return "sidebar_sales.jsp";
            default: return "sidebar_staff.jsp";
        }
    }

    private String firstNonBlank(String... arr) {
        if (arr == null) return null;
        for (String s : arr) {
            if (s != null && !s.isBlank()) return s;
        }
        return null;
    }
}
