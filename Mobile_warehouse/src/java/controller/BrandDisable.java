/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import com.sun.net.httpserver.HttpServer;
import dal.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author ADMIN
 */
@WebServlet(name="BrandDisable", urlPatterns={"/manager/brand-disable"})
public class BrandDisable extends HttpServlet{

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
            String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&err=Missing brand id");
            return;
        }

        long id = Long.parseLong(idRaw);

        try {
            BrandDAO dao = new BrandDAO();
            dao.disable(id);
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&msg=Disabled successfully");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&err=Server error");
        }
    }

}
