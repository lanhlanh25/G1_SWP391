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

@WebServlet("/role_add")
public class RoleAddController extends HttpServlet {

    private String n(String s){ return s == null ? "" : s.trim(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/role_add.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String roleName = n(req.getParameter("role_name"));
        String desc = n(req.getParameter("description"));

        // defaults theo yêu cầu
        int userCount = 1;
        int isActive = 0; // Deactive

        if (roleName.isEmpty()) {
            req.setAttribute("error", "Role Name is required.");
            req.setAttribute("v_role_name", roleName);
            req.setAttribute("v_description", desc);
            req.getRequestDispatcher("/role_add.jsp").forward(req, resp);
            return;
        }

        RoleDAO dao = new RoleDAO();

        // (optional) check trùng tên role
        if (dao.existsRoleName(roleName)) {
            req.setAttribute("error", "Role name already exists!");
            req.setAttribute("v_role_name", roleName);
            req.setAttribute("v_description", desc);
            req.getRequestDispatcher("/role_add.jsp").forward(req, resp);
            return;
        }

        boolean ok = dao.createRole(roleName, desc, isActive);

        if (!ok) {
            req.setAttribute("error", "Create role failed!");
            req.setAttribute("v_role_name", roleName);
            req.setAttribute("v_description", desc);
            req.getRequestDispatcher("/role_add.jsp").forward(req, resp);
            return;
        }

        // tạo xong về role list
        resp.sendRedirect(req.getContextPath() + "/role_list?msg=created");
    }
}
