/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.admin;

import dal.RoleDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import model.Role;

/**
 *
 * @author Admin
 */
@WebServlet("/admin/roles")
public class RoleListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        RoleDBContext rdb = new RoleDBContext();
        List<Role> roles = rdb.getAllRolesIncludeInactive();

        req.setAttribute("roles", roles);
        req.getRequestDispatcher("/view/request/admin/role_list.jsp").forward(req, resp);
    }
}
