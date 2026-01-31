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

        
        User u = (User) session.getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

    
        String role = (String) session.getAttribute("roleName");
        if (role == null) {
            role = "STAFF";
        }
        if (!"MANAGER".equalsIgnoreCase(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

       
        String idRaw = trim(request.getParameter("supplierId"));
        String reason = trim(request.getParameter("reason"));
        String confirmText = trim(request.getParameter("confirmText"));

        long supplierId;
        try {
            supplierId = Long.parseLong(idRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Invalid supplier id");
            return;
        }

        List<String> errors = new ArrayList<>();

        
        if (confirmText == null || !confirmText.equalsIgnoreCase("Inactive")) {
            errors.add("You must type exactly 'Inactive' to confirm.");
        }

        // (optional) reason required? -> bạn muốn bắt buộc thì mở dòng dưới
        // if (reason == null || reason.isBlank()) errors.add("Reason is required.");
        if (!errors.isEmpty()) {
            session.setAttribute("flashErrors", errors);
            session.setAttribute("flashReason", reason);
            response.sendRedirect(request.getContextPath() + "/home?p=supplier_inactive&id=" + supplierId);
            return;
        }

        SupplierDAO dao = new SupplierDAO();

        try {
            Supplier s = dao.getById(supplierId);
            if (s == null) {
                response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Supplier not found");
                return;
            }

            
            if (s.getIsActive() == 0) {
                response.sendRedirect(request.getContextPath() + "/home?p=supplier_detail&id=" + supplierId + "&inactive=1");
                return;
            }

            boolean ok = dao.setActive(supplierId, 0, (long) u.getUserId());
            if (!ok) {
                errors.add("Inactive failed. Supplier may not exist.");
                session.setAttribute("flashErrors", errors);
                session.setAttribute("flashReason", reason);
                response.sendRedirect(request.getContextPath() + "/home?p=supplier_inactive&id=" + supplierId);
                return;
            }

            
            response.sendRedirect(request.getContextPath() + "/home?p=supplier_detail&id=" + supplierId + "&inactive=1");

        } catch (SQLException ex) {
            ex.printStackTrace();
            errors.add("Database error: cannot inactive supplier.");
            session.setAttribute("flashErrors", errors);
            session.setAttribute("flashReason", reason);
            response.sendRedirect(request.getContextPath() + "/home?p=supplier_inactive&id=" + supplierId);
        }
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}
