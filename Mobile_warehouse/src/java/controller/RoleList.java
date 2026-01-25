/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;
import dal.RoleDAO;
import model.Role;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
/**
 *
 * @author Admin
 */
@WebServlet(name="RoleListServlet", urlPatterns={"/role_list"})
public class RoleList extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String q = request.getParameter("q");
        String statusStr = request.getParameter("status");

        Integer status = null; 
        if (statusStr != null && !statusStr.isEmpty()) {
            
            status = Integer.parseInt(statusStr);
        }

        List<Role> roles = roleDAO.searchRoles(q, status);

        request.setAttribute("q", q);
        request.setAttribute("status", statusStr); 
        request.setAttribute("roles", roles);

        request.getRequestDispatcher("view_role_list.jsp").forward(request, response);
    }
}
