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

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.sql.Date;
import java.util.List;

/**
 *
 * @author Admin
 */
@WebServlet(name = "ExportRequestListServlet", urlPatterns = {"/export-request-list"})
public class ExportRequestListServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private static final SimpleDateFormat DF = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        // ===== RBAC basic check =====
        String role = (String) req.getSession().getAttribute("roleName");
        if (role == null || !role.equalsIgnoreCase("MANAGER")) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String q = req.getParameter("q");
        Date reqDate = parseDate(req.getParameter("reqDate"));
        Date expDate = parseDate(req.getParameter("expDate"));

        // (UI của bạn chỉ có 1 date cho mỗi loại => mình filter exact date)
        int page = parseInt(req.getParameter("page"), 1);
        if (page < 1) {
            page = 1;
        }

        int offset = (page - 1) * PAGE_SIZE;

        try {
            ExportRequestDAO dao = new ExportRequestDAO();
            String roleName = (String) req.getSession().getAttribute("roleName");
            Integer userId = (Integer) req.getSession().getAttribute("userId");

            Long requestedBy = null;
            if (roleName != null && roleName.equalsIgnoreCase("SALE")) {
                if (userId == null) {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp");
                    return;
                }
                requestedBy = userId.longValue();
            }
            int totalItems = dao.count(q, reqDate, expDate, requestedBy);
            int totalPages = (int) Math.ceil(totalItems * 1.0 / PAGE_SIZE);

            if (totalPages == 0) {
                totalPages = 1;
            }
            if (page > totalPages) {
                page = totalPages;
                offset = (page - 1) * PAGE_SIZE;
            }

            List<ExportRequest> list = dao.list(q, reqDate, expDate, requestedBy, offset, PAGE_SIZE);

            req.setAttribute("list", list);
            req.setAttribute("q", q);
            req.setAttribute("reqDate", req.getParameter("reqDate"));
            req.setAttribute("expDate", req.getParameter("expDate"));

            req.setAttribute("page", page);
            req.setAttribute("pageSize", PAGE_SIZE);
            req.setAttribute("totalItems", totalItems);
            req.setAttribute("totalPages", totalPages);

            req.getRequestDispatcher("/view_export_request_list.jsp").forward(req, resp);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private java.sql.Date parseDate(String s) {
        try {
            if (s == null || s.trim().isEmpty()) {
                return null;
            }
            return java.sql.Date.valueOf(s.trim()); // yyyy-MM-dd
        } catch (Exception e) {
            return null;
        }
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}
