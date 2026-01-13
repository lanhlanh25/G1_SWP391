/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.admin;

import dal.RoleDBContext;
import dal.UserDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.Role;
import model.User;

/**
 *
 * @author Admin
 */
@WebServlet("/admin/user/edit")

public class UserEditController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idRaw = req.getParameter("id");
        if (idRaw == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=failed");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idRaw);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=failed");
            return;
        }

        UserDBContext udb = new UserDBContext();
        User user = udb.getUserById(id);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=failed");
            return;
        }

        RoleDBContext rdb = new RoleDBContext();
        List<Role> roles = rdb.getAllRoles();

        req.setAttribute("user", user);
        req.setAttribute("roles", roles);

        req.getRequestDispatcher("/view/request/admin/user_edit.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        int id = Integer.parseInt(req.getParameter("id"));
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        int roleId = Integer.parseInt(req.getParameter("roleId"));
        int status = Integer.parseInt(req.getParameter("status"));

        // validate basic
        if (fullName == null || fullName.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/user/edit?id=" + id + "&msg=invalid");
            return;
        }

        User u = new User();
        u.setUserId(id);
        u.setFullName(fullName.trim());
        u.setEmail(email != null && email.trim().isEmpty() ? null : email);
        u.setPhone(phone);
        u.setRoleId(roleId);
        u.setStatus(status);

        UserDBContext udb = new UserDBContext();
        boolean ok = udb.updateUser(u);

        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=updated");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=failed");
        }
    }
}
