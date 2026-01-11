/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;
import dal.RoleDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
/**
 *
 * @author Admin
 */
@WebServlet(name="RoleToggleServlet", urlPatterns={"/role_toggle"})
public class RoleToggleServlet extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String roleIdStr = request.getParameter("roleId");
        if (roleIdStr != null) {
            int roleId = Integer.parseInt(roleIdStr);
            roleDAO.toggleRoleStatus(roleId);
        }

        // quay về list (giữ đơn giản)
        response.sendRedirect(request.getContextPath() + "/role_list");
    }
}
