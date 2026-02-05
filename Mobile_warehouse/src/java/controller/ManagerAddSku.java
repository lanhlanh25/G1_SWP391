/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Lanhlanh
 */
import dal.ProductDAO;
import dal.ProductSkuDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ManagerAddSku", urlPatterns = {"/manager/sku/add"})
public class ManagerAddSku extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/home?p=sku-add");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String roleName = (String) session.getAttribute("roleName");
        if (roleName == null || !"MANAGER".equalsIgnoreCase(roleName)) {
            response.sendError(403, "Forbidden");
            return;
        }
        request.setAttribute("message", "Add SKU successfully");
        request.getRequestDispatcher("/add_sku.jsp").forward(request, response);
        Map<String, String> errors = new HashMap<>();
        String productIdRaw = request.getParameter("productId");
        String color = request.getParameter("color");
        String storageRaw = request.getParameter("storageGb");
        String ramRaw = request.getParameter("ramGb");
        String skuCode = request.getParameter("skuCode");
        String status = request.getParameter("status");

        long productId = -1;
        int storageGb = -1;
        int ramGb = -1;

        try {
            if (productIdRaw == null || productIdRaw.isBlank()) {
                errors.put("productId", "Please select product");
            } else {
                productId = Long.parseLong(productIdRaw);
            }

            if (color == null || color.trim().isEmpty()) {
                errors.put("color", "Color is required");
            }

            if (storageRaw == null || storageRaw.isBlank()) {
                errors.put("storageGb", "Storage is required");
            } else {
                storageGb = Integer.parseInt(storageRaw);
                if (storageGb <= 0) {
                    errors.put("storageGb", "Storage must be > 0");
                }
            }

            if (ramRaw == null || ramRaw.isBlank()) {
                errors.put("ramGb", "RAM is required");
            } else {
                ramGb = Integer.parseInt(ramRaw);
                if (ramGb <= 0) {
                    errors.put("ramGb", "RAM must be > 0");
                }
            }

            if (skuCode == null || skuCode.trim().isEmpty()) {
                errors.put("skuCode", "SKU Code is required");
            }

            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("products", new ProductDAO().listForSkuSelect());
                request.getRequestDispatcher("/add_sku.jsp").forward(request, response);
                return;
            }

            ProductSkuDAO skuDAO = new ProductSkuDAO();

            if (skuDAO.existsSkuCode(skuCode)) {
                errors.put("skuCode", "SKU Code already exists");
            }
            if (skuDAO.existsVariant(productId, color, ramGb, storageGb)) {
                errors.put("variant", "This variant (color/ram/storage) already exists for this product");
            }

            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("products", new ProductDAO().listForSkuSelect());
                request.getRequestDispatcher("/add_sku.jsp").forward(request, response);
                return;
            }

            skuDAO.insertSku(productId, skuCode, color, ramGb, storageGb, status);

            response.sendRedirect(request.getContextPath() + "/home?p=sku-add&msg=Create SKU successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home?p=sku-add&err=Database error");
        }
    }
}
