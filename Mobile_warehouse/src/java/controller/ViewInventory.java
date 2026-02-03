/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.InventoryDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "ViewInventoryServlet", urlPatterns = {"/inventory"})
public class ViewInventory extends HttpServlet {

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
            if (role == null) role = "STAFF";
            session.setAttribute("roleName", role);
        }
        role = role.toUpperCase();

        if (!"STAFF".equals(role) && !"MANAGER".equals(role) && !"SALE".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

    
        String q = request.getParameter("q");
        String brandId = request.getParameter("brandId");
        String stockStatus = request.getParameter("stockStatus"); 
        int page = parseInt(request.getParameter("page"), 1);
        int pageSize = parseInt(request.getParameter("pageSize"), 10);
        if (page < 1) page = 1;
        if (pageSize <= 0) pageSize = 10;

      
        InventoryDAO dao = new InventoryDAO();

        request.setAttribute("brands", dao.getActiveBrands());

        Map<String, Integer> sum = dao.getSummary(q, brandId);
        request.setAttribute("totalProducts", sum.getOrDefault("totalProducts", 0)); 
        request.setAttribute("totalQty", sum.getOrDefault("totalQty", 0));           
        request.setAttribute("lowStockItems", sum.getOrDefault("lowStockItems", 0)); 
        request.setAttribute("outOfStockItems", sum.getOrDefault("outOfStockItems", 0)); 

        int totalItems = dao.countModels(q, brandId, stockStatus);
        int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        request.setAttribute("inventoryModels",
                dao.listModels(q, brandId, stockStatus, page, pageSize));

       
        request.setAttribute("q", q);
        request.setAttribute("brandId", brandId);
        request.setAttribute("stockStatus", stockStatus);

        request.setAttribute("pageNumber", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);

        
        request.setAttribute("sidebarPage", resolveSidebar(role));
        request.setAttribute("contentPage", "view_inventory.jsp");
        request.setAttribute("currentPage", "inventory");
        request.getRequestDispatcher("homepage.jsp").forward(request, response);

       
        // request.getRequestDispatcher("view_inventory.jsp").forward(request, response);
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
}