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
public class RoleAdd extends HttpServlet {

    private String n(String s) { return s == null ? "" : s.trim(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // ✅ Redirect về home controller để có layout đầy đủ
        resp.sendRedirect(req.getContextPath() + "/home?p=role-add");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String roleName = n(req.getParameter("role_name"));
        String desc     = n(req.getParameter("description"));
        int isActive    = 0; // luôn tạo mới với inactive

        HttpSession session = req.getSession();

        if (roleName.isEmpty()) {
            session.setAttribute("flash_role_error",   "Role Name is required.");
            session.setAttribute("flash_v_role_name",  roleName);
            session.setAttribute("flash_v_description", desc);
            resp.sendRedirect(req.getContextPath() + "/home?p=role-add");
            return;
        }

        RoleDAO dao = new RoleDAO();

        if (dao.existsRoleName(roleName)) {
            session.setAttribute("flash_role_error",   "Role name already exists!");
            session.setAttribute("flash_v_role_name",  roleName);
            session.setAttribute("flash_v_description", desc);
            resp.sendRedirect(req.getContextPath() + "/home?p=role-add");
            return;
        }

        boolean ok = dao.createRole(roleName, desc, isActive);
        if (!ok) {
            session.setAttribute("flash_role_error",   "Create role failed!");
            session.setAttribute("flash_v_role_name",  roleName);
            session.setAttribute("flash_v_description", desc);
            resp.sendRedirect(req.getContextPath() + "/home?p=role-add");
            return;
        }

        // ✅ Redirect về home?p=role-list với layout đầy đủ
        resp.sendRedirect(req.getContextPath() + "/home?p=role-list&msg=Role+created+successfully");
    }
}
