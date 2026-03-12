/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author Admin
 */


@WebServlet("/admin/users/active-page")
public class ActiveUserPage extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // ✅ Redirect về home controller để có layout đầy đủ (sidebar, header, footer)
        String q = req.getParameter("q");
        String msg = req.getParameter("msg");

        StringBuilder url = new StringBuilder(req.getContextPath() + "/home?p=user-toggle");
        if (q != null && !q.isBlank()) {
            url.append("&q=").append(java.net.URLEncoder.encode(q, "UTF-8"));
        }
        if (msg != null && !msg.isBlank()) {
            url.append("&msg=").append(java.net.URLEncoder.encode(msg, "UTF-8"));
        }
        resp.sendRedirect(url.toString());
    }
}
