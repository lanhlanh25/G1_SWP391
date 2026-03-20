package controller;

import dal.ProductDAO;
import dal.ProductSkuDAO;
import dal.ProductCRUDDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ProductSku;
import model.Product;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ManagerUpdateSku", urlPatterns = {"/manager/sku/update"})
public class ManagerUpdateSku extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String roleName = (String) session.getAttribute("roleName");

        if (roleName == null || !"MANAGER".equalsIgnoreCase(roleName)) {
            response.sendError(403, "Forbidden");
            return;
        }

        try {
            String idRaw = request.getParameter("id");
            if (idRaw == null || idRaw.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/home?p=product-list");
                return;
            }

            int skuId = Integer.parseInt(idRaw);
            ProductSkuDAO skuDAO = new ProductSkuDAO();
            ProductSku sku = skuDAO.getSkuById(skuId);

            if (sku == null) {
                response.sendRedirect(request.getContextPath() + "/home?p=product-list");
                return;
            }

            ProductCRUDDAO pdao = new ProductCRUDDAO();
            Product p = pdao.getByIdForUpdate(sku.getProductId());

            request.setAttribute("sku", sku);
            request.setAttribute("product", p);
            
            request.setAttribute("contentPage", "update_sku.jsp");
            request.setAttribute("sidebarPage", "sidebar_manager.jsp");
            request.getRequestDispatcher("/homepage.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
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

        Map<String, String> errors = new HashMap<>();

        try {
            int skuId = Integer.parseInt(request.getParameter("skuId"));
            int productId = Integer.parseInt(request.getParameter("productId"));
            String skuCode = request.getParameter("skuCode");
            String color = request.getParameter("color");
            String storageRaw = request.getParameter("storageGb");
            String ramRaw = request.getParameter("ramGb");
            String status = request.getParameter("status");

            if (skuCode == null || skuCode.trim().isEmpty()) {
                errors.put("skuCode", "SKU Code is required");
            }
            if (color == null || color.trim().isEmpty()) {
                errors.put("color", "Color is required");
            }
            
            int storageGb = -1;
            int ramGb = -1;
            try {
                storageGb = Integer.parseInt(storageRaw);
            } catch (Exception e) {
                errors.put("storageGb", "Invalid storage value");
            }
            try {
                ramGb = Integer.parseInt(ramRaw);
            } catch (Exception e) {
                errors.put("ramGb", "Invalid RAM value");
            }

            ProductSkuDAO skuDAO = new ProductSkuDAO();

            if (skuCode != null && skuDAO.existsSkuCodeOther(skuCode, skuId)) {
                errors.put("skuCode", "This SKU Code is already used by another variant");
            }
            
            if (color != null && skuDAO.existsVariantOther(productId, color, ramGb, storageGb, skuId)) {
                errors.put("variant", "This variant already exists for this product (same specs)");
            }

            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("sku", skuDAO.getSkuById(skuId));
                request.setAttribute("product", new ProductCRUDDAO().getByIdForUpdate(productId));
                request.setAttribute("contentPage", "update_sku.jsp");
                request.setAttribute("sidebarPage", "sidebar_manager.jsp");
                request.getRequestDispatcher("/homepage.jsp").forward(request, response);
                return;
            }

            skuDAO.updateSku(skuId, skuCode, color, ramGb, storageGb, status);
            session.setAttribute("msg", "Update SKU successfully");
            response.sendRedirect(request.getContextPath() + "/manager/product/update?id=" + productId);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
