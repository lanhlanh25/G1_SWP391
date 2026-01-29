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
@WebServlet(name="BrandUpdate", urlPatterns={"/manager/brand-update"})
public class BrandUpdate extends HttpServlet{

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = (User) req.getSession().getAttribute("authUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idRaw = req.getParameter("id");
        String name = req.getParameter("brandName");
        String desc = req.getParameter("description");
        String activeRaw = req.getParameter("isActive");

        if (idRaw == null || idRaw.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&err=Missing brand id");
            return;
        }
        long id = Long.parseLong(idRaw);

        if (name == null || name.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-update&id=" + id + "&err=Brand name is required");
            return;
        }

        try {
            BrandDAO dao = new BrandDAO();

            if (dao.existsByName(name, id)) {
                resp.sendRedirect(req.getContextPath() + "/home?p=brand-update&id=" + id + "&err=Brand name already exists");
                return;
            }

            Brand b = dao.findById(id);
            if (b == null) {
                resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&err=Brand not found");
                return;
            }

            b.setBrandName(name.trim());
            b.setDescription(desc);
            b.setActive("1".equals(activeRaw));

            dao.update(b);
            
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&msg=Updated successfully");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-lis&err=Server error");
        }
    }
}
