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
import model.Brand;
import model.User;

/**
 *
 * @author ADMIN
 */
@WebServlet(name = "BrandCreate", urlPatterns = {"/manager/brand-create"})
public class BrandCreate extends HttpServlet {

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

        if (name == null || name.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-add&err=Brand name is required");
            return;
        }

        try {
            BrandDAO dao = new BrandDAO();

            if (dao.existsByName(name, null)) {
                resp.sendRedirect(req.getContextPath() + "/home?p=brand-add&err=Brand name already exists");
                return;
            }

            Brand b = new Brand();
            b.setBrandName(name.trim());
            b.setDescription(desc);
            b.setActive("1".equals(activeRaw));
            b.setCreatedBy(u.getUserId());

            dao.insert(b);

            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&msg=Created successfully");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-add&err=Server error");
        }
    }
}
