/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.RoleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/role/active-page")
public class ActiveRolePage extends HttpServlet {

  @Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

    String roleIdRaw = req.getParameter("role_id");
    String page = req.getParameter("page");
    String q = req.getParameter("q");
    String status = req.getParameter("status");

    try {
        int roleId = Integer.parseInt(roleIdRaw);

        RoleDAO dao = new RoleDAO();
        dao.toggleRoleStatus(roleId);

        StringBuilder url = new StringBuilder(req.getContextPath() + "/home?p=role-toggle&msg=ok");

        if (page != null && !page.isBlank()) {
            url.append("&page=").append(page);
        }
        if (q != null && !q.isBlank()) {
            url.append("&q=").append(java.net.URLEncoder.encode(q, "UTF-8"));
        }
        if (status != null && !status.isBlank()) {
            url.append("&status=").append(java.net.URLEncoder.encode(status, "UTF-8"));
        }

        resp.sendRedirect(url.toString());

    } catch (Exception e) {
        resp.sendRedirect(req.getContextPath() + "/home?p=role-toggle&msg=error");
    }
}
}
