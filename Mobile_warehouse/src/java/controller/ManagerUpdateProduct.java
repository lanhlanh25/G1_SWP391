package controller;

import dal.ProductCRUDDAO;
import dal.ProductSkuDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
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
            ProductSkuDAO skuDAO = new ProductSkuDAO();

            Product p = dao.getByIdForUpdate(id);

            request.setAttribute("product", p);
            request.setAttribute("skuList", skuDAO.getSkusByProductId(id));

            request.setAttribute("contentPage", "update_product.jsp");
            request.setAttribute("sidebarPage", "sidebar_manager.jsp");

            request.getRequestDispatcher("/homepage.jsp").forward(request, response);

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
                errors.put("productName", "Product name is required");
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

                ProductSkuDAO skuDAO = new ProductSkuDAO();
                request.setAttribute("skuList", skuDAO.getSkusByProductId(id));

                request.getRequestDispatcher("/update_product.jsp").forward(request, response);
                return;
            }

            dao.updateProductByManager(
                    id,
                    productName.trim(),
                    model == null ? null : model.trim(),
                    description == null ? null : description.trim(),
                    status
            );

            request.getSession().setAttribute("msg", "Update product successfully");

            response.sendRedirect(request.getContextPath() + "/home?p=product-list");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}