/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.ExportRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.ExportRequest;
import model.ExportRequestItem;

import java.io.IOException;
import java.util.List;

/**
 *
 * @author Admin
 */
@WebServlet(name = "ExportRequestDetailServlet", urlPatterns = {"/export-request-detail"})
public class ExportRequestDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        // ===== RBAC basic check =====
        String role = (String) req.getSession().getAttribute("roleName");
        if (role == null || !role.equalsIgnoreCase("MANAGER")) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/export-request-list?err=Missing+id");
            return;
        }

        long id;
        try {
            id = Long.parseLong(idRaw);
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/export-request-list?err=Invalid+id");
            return;
        }

        try {
            ExportRequestDAO dao = new ExportRequestDAO();
            ExportRequest header = dao.getHeader(id);
            if (header == null) {
                resp.sendRedirect(req.getContextPath() + "/export-request-list?err=Not+found");
                return;
            }

            List<ExportRequestItem> items = dao.listItems(id);

            req.setAttribute("header", header);
            req.setAttribute("items", items);

            req.getRequestDispatcher("/view_export_request_detail.jsp").forward(req, resp);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
