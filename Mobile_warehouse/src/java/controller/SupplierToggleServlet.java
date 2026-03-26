package controller;

import dal.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "SupplierToggleServlet", urlPatterns = {"/supplier-toggle"})
public class SupplierToggleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String supplierIdRaw = request.getParameter("supplierId");
        String action = request.getParameter("action");

        String redirectBase = request.getContextPath() + "/home?p=view_supplier";

        try {
            if (supplierIdRaw == null || supplierIdRaw.trim().isEmpty()) {
                response.sendRedirect(redirectBase + "&msg=Invalid supplier id");
                return;
            }

            long supplierId = Long.parseLong(supplierIdRaw.trim());

            if (action == null || action.trim().isEmpty()) {
                response.sendRedirect(redirectBase + "&msg=Invalid action");
                return;
            }

            action = action.trim().toLowerCase();

            int newStatus;
            String successMsg;

            switch (action) {
                case "activate":
                    newStatus = 1;
                    successMsg = "Supplier activated successfully";
                    break;
                case "deactivate":
                    newStatus = 0;
                    successMsg = "Supplier deactivated successfully";
                    break;
                default:
                    response.sendRedirect(redirectBase + "&msg=Invalid action");
                    return;
            }

            SupplierDAO dao = new SupplierDAO();

            // Dùng hàm update status chuẩn trong DAO của bạn
            boolean updated = dao.updateActiveStatus(supplierId, newStatus);

            if (updated) {
                response.sendRedirect(redirectBase + "&msg=" + encode(successMsg));
            } else {
                response.sendRedirect(redirectBase + "&msg=" + encode("No supplier was updated"));
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(redirectBase + "&msg=" + encode("Invalid supplier id format"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(redirectBase + "&msg=" + encode("Failed to update supplier status"));
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/home?p=view_supplier");
    }

    private String encode(String value) {
        try {
            return java.net.URLEncoder.encode(value, "UTF-8");
        } catch (Exception e) {
            return value;
        }
    }
}
