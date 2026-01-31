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

@WebServlet(name = "UpdateSupplierServlet", urlPatterns = {"/supplier-update"})
public class UpdateSupplierServlet extends HttpServlet {

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

        // 3) Read inputs (NO STATUS)
        String idRaw = trim(request.getParameter("supplierId"));
        String supplierName = trim(request.getParameter("supplierName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String address = trim(request.getParameter("address"));

        long supplierId;
        try {
            supplierId = Long.parseLong(idRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Invalid supplier id");
            return;
        }

        // 4) Validate
        List<String> errors = new ArrayList<>();

        if (supplierName == null || supplierName.isBlank()) {
            errors.add("Supplier Name is required.");
        } else if (supplierName.length() > 150) {
            errors.add("Supplier Name must be <= 150 characters.");
        }

        if (email == null || email.isBlank()) {
            errors.add("Email is required.");
        } else if (!email.matches("^[\\w.%+-]+@[\\w.-]+\\.[A-Za-z]{2,}$")) {
            errors.add("Email format is invalid.");
        } else if (email.length() > 120) {
            errors.add("Email must be <= 120 characters.");
        }

        if (phone != null && !phone.isBlank()) {
            if (!phone.matches("^0\\d{9}$")) {
                errors.add("Phone must be 10 digits and start with 0 (e.g. 0912345678).");
            }
        }

        SupplierDAO dao = new SupplierDAO();

        // 5) If validate fail -> flash + redirect back GET form
        if (!errors.isEmpty()) {
            putFlash(session, errors, supplierName, phone, email, address);
            response.sendRedirect(request.getContextPath() + "/home?p=update_supplier&id=" + supplierId);
            return;
        }

        try {
            // 6) Load existing
            Supplier existing = dao.getById(supplierId);
            if (existing == null) {
                response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Supplier not found");
                return;
            }

            // 7) Duplicate check (exclude current supplier)
            if (dao.existsByNameOrEmailExceptId(supplierId, supplierName, email)) {
                errors.add("Supplier Name or Email already exists.");
                putFlash(session, errors, supplierName, phone, email, address);
                response.sendRedirect(request.getContextPath() + "/home?p=update_supplier&id=" + supplierId);
                return;
            }

            // 8) Update info (KEEP STATUS)
            Supplier s = new Supplier();
            s.setSupplierId(supplierId);
            s.setSupplierName(supplierName);
            s.setPhone(phone);
            s.setEmail(email);
            s.setAddress(address);

            // keep current status (readonly on this screen)
            s.setIsActive(existing.getIsActive());

            s.setUpdatedBy((long) u.getUserId());

            boolean ok = dao.updateSupplierInfo(s);
            if (!ok) {
                errors.add("Update failed. Supplier may not exist.");
                putFlash(session, errors, supplierName, phone, email, address);
                response.sendRedirect(request.getContextPath() + "/home?p=update_supplier&id=" + supplierId);
                return;
            }

            // success -> redirect detail
            response.sendRedirect(request.getContextPath()
                    + "/home?p=supplier_detail&id=" + supplierId + "&updated=1");

        } catch (SQLException ex) {
            ex.printStackTrace();
            errors.add("Database error: cannot update supplier.");
            putFlash(session, errors, supplierName, phone, email, address);
            response.sendRedirect(request.getContextPath() + "/home?p=update_supplier&id=" + supplierId);
        }
    }

    private void putFlash(HttpSession session,
            List<String> errors,
            String supplierName, String phone, String email, String address) {

        session.setAttribute("flashErrors", errors);
        session.setAttribute("flashSupplierName", supplierName);
        session.setAttribute("flashPhone", phone);
        session.setAttribute("flashEmail", email);
        session.setAttribute("flashAddress", address);
        // NOTE: NO flashStatus anymore
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}
