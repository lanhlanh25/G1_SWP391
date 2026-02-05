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
import model.Product;

@WebServlet(name = "ManagerDeleteProduct", urlPatterns = {"/manager/product/delete"})
public class ManagerDeleteProduct extends HttpServlet {

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

            if (p != null) {
                int skuCount = dao.countSkuByProduct(id);
                String createdAt = dao.getCreatedAtText(id);

                request.setAttribute("skuCount", skuCount);
                request.setAttribute("createdAt", createdAt);
            }
            HttpSession session = request.getSession();
            Object msg = session.getAttribute("msg_delete_product");
            if (msg != null) {
                request.setAttribute("message", String.valueOf(msg));
                session.removeAttribute("msg_delete_product");
            }

            request.getRequestDispatcher("/delete_product.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idRaw = request.getParameter("id");
            if (idRaw == null || idRaw.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/home?p=product-list");
                return;
            }

            int id = Integer.parseInt(idRaw);

            ProductCRUDDAO dao = new ProductCRUDDAO();

            dao.inactivateSkusByProduct(id);
            dao.inactivateProduct(id);

            request.getSession().setAttribute("msg_delete_product", "Product set to INACTIVE successfully.");
            response.sendRedirect(request.getContextPath() + "/manager/product/delete?id=" + id);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
