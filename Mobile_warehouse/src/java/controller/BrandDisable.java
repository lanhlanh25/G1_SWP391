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
public class BrandDisable extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&err=Missing brand id");
            return;
        }

        long id = Long.parseLong(idRaw);

        // NEW: nhận trạng thái muốn chuyển tới
        String toRaw = req.getParameter("to"); // "0" or "1"
        boolean toActive;
        if ("1".equals(toRaw)) toActive = true;
        else if ("0".equals(toRaw)) toActive = false;
        else {
            // nếu không truyền "to", thì tự đảo trạng thái
            toActive = true;
        }

        try {
            BrandDAO dao = new BrandDAO();

            // nếu không truyền "to" thì toggle theo DB
            if (toRaw == null || toRaw.isBlank()) {
                boolean current = dao.isActive(id);
                toActive = !current;
            }

            dao.setActive(id, toActive);

            String msg = toActive ? "Activated successfully" : "Disabled successfully";
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&msg=" + msg);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/home?p=brand-list&err=Server error");
        }
    }

}
