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
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;
import util.PasswordUtil;

@WebServlet(name = "AdminAddUserServlet", urlPatterns = {"/admin/user-add"})
public class AdminAddUserServlet extends HttpServlet {

    private String n(String s){ return s == null ? "" : s.trim(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        RoleDAO roleDAO = new RoleDAO();
        req.setAttribute("roles", roleDAO.searchRoles(null, 1)); // role active

        req.getRequestDispatcher("/user_add.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = n(req.getParameter("username"));
        String password = n(req.getParameter("password"));
        String fullName = n(req.getParameter("full_name"));
        String email = n(req.getParameter("email"));
        String phone = n(req.getParameter("phone"));
        int roleId = parseInt(req.getParameter("role_id"), 0);

        if (username.isEmpty() || password.isEmpty() || fullName.isEmpty() || roleId <= 0) {
            req.setAttribute("error", "Please fill required fields (username, password, full name, role).");
            doGet(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();

        // check username exists
        if (dao.getUserByUsername(username) != null) {
            req.setAttribute("error", "Username already exists!");
            doGet(req, resp);
            return;
        }

        User u = new User();
        u.setUsername(username);
        u.setPasswordHash(PasswordUtil.hashPassword(password));
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setRoleId(roleId);
        u.setStatus(1);

        boolean ok = dao.createUser(u);

        if (!ok) {
            req.setAttribute("error", "Create user failed!");
            doGet(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users?msg=created");
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
