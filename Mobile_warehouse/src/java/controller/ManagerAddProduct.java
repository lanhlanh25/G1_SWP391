/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Lanhlanh
 */
import dal.BrandDAO;
import dal.ProductCRUDDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import model.Brand;
import model.Product;

@WebServlet(name = "ManagerAddProduct", urlPatterns = {"/manager/product/add"})
public class ManagerAddProduct extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Object role = session.getAttribute("roleName");
        if (role == null || !"MANAGER".equalsIgnoreCase(role.toString())) {
            response.sendError(403);
            return;
        }

        try {
            BrandDAO brandDAO = new BrandDAO();
            request.setAttribute("brands", brandDAO.list(null, "active", "name", "ASC", 1, 1000));
        } catch (Exception e) {
            request.setAttribute("brands", java.util.Collections.emptyList());
        }

        request.getRequestDispatcher("/add_product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Object role = session.getAttribute("roleName");
        if (role == null || !"MANAGER".equalsIgnoreCase(role.toString())) {
            response.sendError(403);
            return;
        }

        String productCode = trim(request.getParameter("productCode"));
        String productName = trim(request.getParameter("productName"));
        String brandIdRaw = trim(request.getParameter("brandId"));
        String model = trim(request.getParameter("model"));
        String description = trim(request.getParameter("description"));
        String status = trim(request.getParameter("status"));

        Map<String, String> errors = new HashMap<>();

        if (productCode == null || productCode.isEmpty()) errors.put("productCode", "Product Code is required");
        if (productName == null || productName.isEmpty()) errors.put("productName", "Product Name is required");
        if (brandIdRaw == null || brandIdRaw.isEmpty()) errors.put("brandId", "Brand is required");

        long brandId = 0;
        if (!errors.containsKey("brandId")) {
            try {
                brandId = Long.parseLong(brandIdRaw);
            } catch (Exception e) {
                errors.put("brandId", "Invalid brand");
            }
        }

        if (status == null || status.isEmpty()) status = "ACTIVE";
        if (!"ACTIVE".equalsIgnoreCase(status) && !"INACTIVE".equalsIgnoreCase(status)) {
            errors.put("status", "Invalid status");
        }

        try {
            BrandDAO brandDAO = new BrandDAO();
            request.setAttribute("brands", brandDAO.list(null, "active", "name", "ASC", 1, 1000));
        } catch (Exception e) {
            request.setAttribute("brands", java.util.Collections.emptyList());
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/add_product.jsp").forward(request, response);
            return;
        }

        try {
            ProductCRUDDAO pdao = new ProductCRUDDAO();

            if (pdao.existsByCode(productCode)) {
                errors.put("productCode", "Product Code already exists");
                request.setAttribute("errors", errors);
                request.getRequestDispatcher("/add_product.jsp").forward(request, response);
                return;
            }

            Product p = new Product();
            p.setProductCode(productCode);
            p.setProductName(productName);
            p.setBrandId(brandId);
            p.setModel(model);
            p.setDescription(description);
            p.setStatus(status.toUpperCase());

            pdao.insert(p);

            response.sendRedirect(request.getContextPath() + "/home?p=product-list&msg=Added successfully");
        } catch (Exception e) {
            errors.put("db", "Database error");
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/add_product.jsp").forward(request, response);
        }
    }

    private String trim(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}