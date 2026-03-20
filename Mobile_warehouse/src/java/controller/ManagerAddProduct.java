package controller;

import dal.BrandDAO;
import dal.ProductCRUDDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Product;

@WebServlet(name = "ManagerAddProduct", urlPatterns = {"/manager/product/add"})
public class ManagerAddProduct extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String productName = request.getParameter("productName");
        String brandId = request.getParameter("brandId");
        String model = request.getParameter("model");
        String description = request.getParameter("description");
        String status = request.getParameter("status");

        Map<String, String> errors = new HashMap<>();

        if (productName == null || productName.trim().isEmpty()) {
            errors.put("productName", "Product Name is required");
        }

        if (brandId == null || brandId.isEmpty()) {
            errors.put("brandId", "Brand is required");
        }

        try {

            ProductCRUDDAO dao = new ProductCRUDDAO();
            if (dao.existsByName(productName)) {
                errors.put("productName", "Product name already exists");
                request.setAttribute("errors", errors);
                keepData(request, null, productName, brandId, model, description, status);

                request.setAttribute("brands", new BrandDAO().list(null, "active", "name", "ASC", 1, 1000));
                request.setAttribute("contentPage", "add_product.jsp");
                request.setAttribute("sidebarPage", "sidebar_manager.jsp");
                request.getRequestDispatcher("/homepage.jsp").forward(request, response);
                return;
            }
            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                keepData(request, null, productName, brandId, model, description, status);

                request.setAttribute("brands", new BrandDAO().list(null, "active", "name", "ASC", 1, 1000));
                request.setAttribute("contentPage", "add_product.jsp");
                request.setAttribute("sidebarPage", "sidebar_manager.jsp");
                request.getRequestDispatcher("/homepage.jsp").forward(request, response);
                return;
            }

            long bId = Long.parseLong(brandId);

            String productCode = dao.generateProductCode(bId);
            Product p = new Product();
            p.setProductCode(productCode);
            p.setProductName(productName);
            p.setBrandId(Long.parseLong(brandId));
            p.setModel(model);
            p.setDescription(description);
            p.setStatus(status);

            dao.insert(p);

            response.sendRedirect(request.getContextPath() + "/home?p=product-list&msg=Added successfully");

        } catch (Exception e) {

            errors.put("db", "Database error");

            request.setAttribute("errors", errors);

            try {
                request.setAttribute("brands", new BrandDAO().list(null, "active", "name", "ASC", 1, 1000));
            } catch (Exception ex) {
                Logger.getLogger(ManagerAddProduct.class.getName()).log(Level.SEVERE, null, ex);
            }
            request.setAttribute("contentPage", "add_product.jsp");
            request.setAttribute("sidebarPage", "sidebar_manager.jsp");
            request.getRequestDispatcher("/homepage.jsp").forward(request, response);
        }
    }

    private void keepData(HttpServletRequest request,
            String productCode, String productName, String brandId,
            String model, String description, String status) {

        request.setAttribute("productCode", productCode);
        request.setAttribute("productName", productName);
        request.setAttribute("brandId", brandId);
        request.setAttribute("model", model);
        request.setAttribute("description", description);
        request.setAttribute("status", status);
    }
}
