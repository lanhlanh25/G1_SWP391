/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Lanhlanh
 */


import dal.ProductCRUDDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import model.Product;

@WebServlet(name = "ManagerUpdateProduct", urlPatterns = {"/manager/product/update"})
public class ManagerUpdateProduct extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idRaw = request.getParameter("id");
            if (idRaw == null || idRaw.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/home?p=product-list");
                return;
            }

            int id = Integer.parseInt(idRaw);
            ProductCRUDDAO dao = new ProductCRUDDAO();
            Product p = dao.getByIdForUpdate(id);

            request.setAttribute("product", p);

            HttpSession session = request.getSession();
            Object msg = session.getAttribute("msg_update_product");
            if (msg != null) {
                request.setAttribute("message", String.valueOf(msg));
                session.removeAttribute("msg_update_product");
            }

            request.getRequestDispatcher("/update_product.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Map<String, String> errors = new HashMap<>();

            int id = Integer.parseInt(request.getParameter("id"));
            String productName = request.getParameter("productName");
            String model = request.getParameter("model");
            String description = request.getParameter("description");
            String status = request.getParameter("status");

            if (productName == null || productName.trim().isEmpty()) {
                errors.put("productName", "Product name is required.");
            }

            if (status == null || (!"ACTIVE".equals(status) && !"INACTIVE".equals(status))) {
                status = "ACTIVE";
            }

            ProductCRUDDAO dao = new ProductCRUDDAO();
            Product db = dao.getByIdForUpdate(id);

            if (db == null) {
                response.sendRedirect(request.getContextPath() + "/home?p=product-list");
                return;
            }

            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("product", db);
                request.getRequestDispatcher("/update_product.jsp").forward(request, response);
                return;
            }

            dao.updateProductByManager(id,
                    productName.trim(),
                    model == null ? null : model.trim(),
                    description == null ? null : description.trim(),
                    status);

            request.getSession().setAttribute("msg_update_product", "Update product successfully.");
            response.sendRedirect(request.getContextPath() + "/manager/product/update?id=" + id);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}