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

@WebServlet(name = "AddSupplierServlet", urlPatterns = {"/supplier-add"})
public class AddSupplierServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // 1) Auth check
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

        // 3) Read + trim inputs
        String supplierName = trim(request.getParameter("supplierName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String address = trim(request.getParameter("address"));
        String status = trim(request.getParameter("status")); // active/inactive

        int isActive = "inactive".equalsIgnoreCase(status) ? 0 : 1;

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

        // 5) If validate fail -> flash + redirect GET
        if (!errors.isEmpty()) {
            putFlash(session, errors, supplierName, phone, email, address, isActive);
            response.sendRedirect(request.getContextPath() + "/home?p=add_supplier");
            return;
        }

        // 6) DAO checks + insert
        SupplierDAO dao = new SupplierDAO();

        try {
            // Check duplicate for nicer message
            if (dao.existsByNameOrEmail(supplierName, email)) {
                errors.add("Supplier Name or Email already exists.");
                putFlash(session, errors, supplierName, phone, email, address, isActive);
                response.sendRedirect(request.getContextPath() + "/home?p=add_supplier");
                return;
            }

            Supplier s = new Supplier();
            s.setSupplierName(supplierName);
            s.setPhone(phone);
            s.setEmail(email);
            s.setAddress(address);
            s.setIsActive(isActive);
            s.setCreatedBy((long) u.getUserId());

            dao.insert(s);

            // success -> redirect with param
            response.sendRedirect(request.getContextPath() + "/home?p=add_supplier&success=1");
        } catch (SQLException ex) {
            ex.printStackTrace();
            errors.add("Database error: cannot create supplier.");
            putFlash(session, errors, supplierName, phone, email, address, isActive);
            response.sendRedirect(request.getContextPath() + "/home?p=add_supplier");
        } //catch (Exception ex) {
//            // phòng trường hợp DBContext throws Exception
//            ex.printStackTrace();
//            errors.add("System error: cannot create supplier.");
//            putFlash(session, errors, supplierName, phone, email, address, isActive);
//            response.sendRedirect(request.getContextPath() + "/home?p=add_supplier");
//        }
    }

    private void putFlash(HttpSession session,
            List<String> errors,
            String supplierName, String phone, String email, String address,
            int isActive) {

        session.setAttribute("flashErrors", errors);
        session.setAttribute("flashSupplierName", supplierName);
        session.setAttribute("flashPhone", phone);
        session.setAttribute("flashEmail", email);
        session.setAttribute("flashAddress", address);
        session.setAttribute("flashStatus", (isActive == 1 ? "active" : "inactive"));
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}
