package controller;

import dal.ProductSkuDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ProductSku;

import java.io.IOException;

@WebServlet(name = "SkuToggleServlet", urlPatterns = {"/manager/sku/toggle"})
public class SkuToggleServlet extends HttpServlet {

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
                response.sendRedirect(request.getHeader("referer") != null ? request.getHeader("referer") : request.getContextPath() + "/home?p=product-list");
                return;
            }

            int skuId = Integer.parseInt(idRaw);
            ProductSkuDAO dao = new ProductSkuDAO();
            ProductSku sku = dao.getSkuById(skuId);

            if (sku != null) {
                String newStatus = "ACTIVE".equalsIgnoreCase(sku.getStatus()) ? "INACTIVE" : "ACTIVE";
                
                try {
                    dao.updateSku(skuId, sku.getSkuCode(), sku.getColor(), sku.getRamGb(), sku.getStorageGb(), newStatus);
                    session.setAttribute("msg", "Successfully " + (newStatus.equalsIgnoreCase("ACTIVE") ? "activated" : "deactivated") + " SKU " + sku.getSkuCode());
                } catch (Exception e) {
                    session.setAttribute("msgErr", "Failed to change status: " + e.getMessage());
                }
            }

            // Redirect back to referring page
            String referer = request.getHeader("referer");
            if (referer != null && !referer.isEmpty()) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect(request.getContextPath() + "/home?p=product-list");
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
