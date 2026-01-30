package controller;

import dal.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Supplier;
import model.User;

@WebServlet(name = "SupplierToggleServlet", urlPatterns = {"/supplier-toggle"})
public class SupplierToggleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // 1) Auth
        User u = (User) session.getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2) Role check (only MANAGER)
        String role = (String) session.getAttribute("roleName");
        if (role == null) {
            role = "STAFF";
        }
        if (!"MANAGER".equalsIgnoreCase(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        // 3) Read supplierId
        String idRaw = request.getParameter("supplierId");
        long supplierId;
        try {
            supplierId = Long.parseLong(idRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Invalid supplier id");
            return;
        }

        SupplierDAO dao = new SupplierDAO();
        List<String> errors = new ArrayList<>();

        try {
            Supplier s = dao.getById(supplierId);
            if (s == null) {
                response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Supplier not found");
                return;
            }

            // Only reactivate here (inactive -> active)
            if (s.getIsActive() == 1) {
                // already active, go back
                response.sendRedirect(request.getContextPath() + "/home?p=supplier_detail&id=" + supplierId);
                return;
            }

            boolean ok = dao.setActive(supplierId, 1, (long) u.getUserId());
            if (!ok) {
                errors.add("Reactivate failed. Supplier may not exist.");
                session.setAttribute("flashErrors", errors);
                response.sendRedirect(request.getContextPath() + "/home?p=supplier_detail&id=" + supplierId);
                return;
            }

            response.sendRedirect(request.getContextPath()
                    + "/home?p=supplier_detail&id=" + supplierId + "&reactive=1");

        } catch (SQLException ex) {
            ex.printStackTrace();
            errors.add("Database error: cannot reactivate supplier.");
            session.setAttribute("flashErrors", errors);
            response.sendRedirect(request.getContextPath() + "/home?p=supplier_detail&id=" + supplierId);
        }
    }
}
