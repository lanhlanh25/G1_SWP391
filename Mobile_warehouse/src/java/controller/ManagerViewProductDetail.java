/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.ProductDAO;
import dal.ProductSkuDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.Product;
import model.ProductSku;

public class ManagerViewProductDetail {

    public static void handle(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/home?p=product-list&msg=Missing product id");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idRaw.trim());
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/home?p=product-list&msg=Invalid product id");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        ProductSkuDAO skuDAO = new ProductSkuDAO();

        try {
            // Đổi method này nếu ProductDAO của bạn đang dùng tên khác
            Product product = productDAO.getProductById(productId);

            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/home?p=product-list&msg=Product not found");
                return;
            }

            List<ProductSku> skuList = skuDAO.getSkuStockByProductId(productId);

            // Giữ attribute tên "product" cho dễ dùng ở JSP
            request.setAttribute("product", product);
            request.setAttribute("skuList", skuList);

        } catch (Exception ex) {
            throw new ServletException("Load product detail failed", ex);
        }
    }
}
