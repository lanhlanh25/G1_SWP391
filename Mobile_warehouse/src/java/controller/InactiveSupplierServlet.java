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

@WebServlet(name = "InactiveSupplierServlet", urlPatterns = {"/supplier-inactive"})
public class InactiveSupplierServlet extends HttpServlet {

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

        // 2) Role (MANAGER only)
        String role = (String) session.getAttribute("roleName");
        if (role == null) {
            role = "STAFF";
        }
        if (!"MANAGER".equalsIgnoreCase(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        // 3) Read supplierId
        long supplierId;
        try {
            supplierId = Long.parseLong(request.getParameter("supplierId"));
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

            // already inactive -> back to detail
            if (s.getIsActive() == 0) {
                response.sendRedirect(request.getContextPath()
                        + "/home?p=supplier_detail&id=" + supplierId);
                return;
            }

            boolean ok = dao.setActive(supplierId, 0, (long) u.getUserId());
            if (!ok) {
                errors.add("Inactive failed.");
                session.setAttribute("flashErrors", errors);
                response.sendRedirect(request.getContextPath()
                        + "/home?p=supplier_detail&id=" + supplierId);
                return;
            }

            // success
            response.sendRedirect(request.getContextPath()
                    + "/home?p=supplier_detail&id=" + supplierId + "&inactive=1");

        } catch (SQLException ex) {
            ex.printStackTrace();
            errors.add("Database error: cannot inactive supplier.");
            session.setAttribute("flashErrors", errors);
            response.sendRedirect(request.getContextPath()
                    + "/home?p=supplier_detail&id=" + supplierId);
        }
    }
}
