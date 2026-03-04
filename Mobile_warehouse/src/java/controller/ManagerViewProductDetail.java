/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.ProductDAO;
import dal.ProductSkuDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.Product;

public class ManagerViewProductDetail {

    public static void handle(HttpServletRequest request,
                              HttpServletResponse response) throws Exception {

        String idRaw = request.getParameter("id");

        if (idRaw == null || idRaw.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/home?p=product-list");
            return;
        }

        int productId = Integer.parseInt(idRaw);

        ProductDAO pdao = new ProductDAO();
        ProductSkuDAO skdao = new ProductSkuDAO();

        Product product = pdao.getProductById(productId);
        request.setAttribute("product", product);

        if (product != null) {
            request.setAttribute("skuList",
                    skdao.getSkusByProductId(productId));
        }
    }
}