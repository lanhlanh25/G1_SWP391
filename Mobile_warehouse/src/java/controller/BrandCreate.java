/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import model.Brand;
import model.User;

/**
 *
 * @author ADMIN
 */
@WebServlet(name = "BrandCreate", urlPatterns = {"/manager/brand-create"})
public class BrandCreate extends HttpServlet {

    private String enc(String s) {
        if (s == null) return "";
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    private String listState(HttpServletRequest req) {
        String q = req.getParameter("q");
        String status = req.getParameter("status");
        String sortBy = req.getParameter("sortBy");
        String sortOrder = req.getParameter("sortOrder");
        String page = req.getParameter("page");

        return "&q=" + enc(q)
                + "&status=" + enc(status)
                + "&sortBy=" + enc(sortBy)
                + "&sortOrder=" + enc(sortOrder)
                + "&page=" + enc(page);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = (User) req.getSession().getAttribute("authUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String name = req.getParameter("brandName");
        String desc = req.getParameter("description");
        String activeRaw = req.getParameter("isActive");

        if (desc != null) desc = desc.trim();

        // validate
        if (name == null || name.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath()
                    + "/home?p=brand-add&err=" + enc("Brand name is required")
                    + "&brandName=" + enc(name)
                    + "&description=" + enc(desc)
                    + "&isActive=" + enc(activeRaw)
                    + listState(req));
            return;
        }

        if (desc != null && desc.length() > 255) {
            resp.sendRedirect(req.getContextPath()
                    + "/home?p=brand-add&err=" + enc("Description must be <= 255 characters")
                    + "&brandName=" + enc(name)
                    + "&description=" + enc(desc)
                    + "&isActive=" + enc(activeRaw)
                    + listState(req));
            return;
        }

        try {
            BrandDAO dao = new BrandDAO();

            if (dao.existsByName(name, null)) {
                resp.sendRedirect(req.getContextPath()
                        + "/home?p=brand-add&err=" + enc("Brand name already exists")
                        + "&brandName=" + enc(name)
                        + "&description=" + enc(desc)
                        + "&isActive=" + enc(activeRaw)
                        + listState(req));
                return;
            }

            Brand b = new Brand();
            b.setBrandName(name.trim());
            b.setDescription(desc);
            b.setActive("1".equals(activeRaw));
            b.setCreatedBy(u.getUserId());

            dao.insert(b);

            resp.sendRedirect(req.getContextPath()
                    + "/home?p=brand-list&msg=" + enc("Created successfully")
                    + listState(req));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath()
                    + "/home?p=brand-add&err=" + enc("Server error")
                    + "&brandName=" + enc(name)
                    + "&description=" + enc(desc)
                    + "&isActive=" + enc(activeRaw)
                    + listState(req));
        }
    }
}
