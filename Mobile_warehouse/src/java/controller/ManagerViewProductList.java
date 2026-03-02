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
import dal.ProductDAO;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;

import model.ProductListItem;

public class ManagerViewProductList {

    public static void handle(HttpServletRequest request) throws Exception {

        String q = request.getParameter("q");
        String brandIdRaw = request.getParameter("brandId");
        String st = request.getParameter("status");

        Long brandId = null;
        if (brandIdRaw != null && !brandIdRaw.isBlank()) {
            brandId = Long.parseLong(brandIdRaw);
        }

        String status = null;
        if (st != null && !st.isBlank()) {
            status = st;
        }

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (Exception ignored) {}

        int pageSize = 5;

        ProductDAO pdao = new ProductDAO();
        BrandDAO brandDAO = new BrandDAO();

        int totalItems = pdao.count(q, brandId, status);
        int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<ProductListItem> products =
                pdao.list(q, brandId, status, page, pageSize);

        request.setAttribute("products", products);
        request.setAttribute("q", q);
        request.setAttribute("brandId", brandIdRaw);
        request.setAttribute("status", st);

        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("allBrands",
                brandDAO.list(null, "", "name", "ASC", 1, 1000));
    }
}