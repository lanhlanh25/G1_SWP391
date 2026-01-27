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

@WebServlet("/admin/user/update")
public class UserUpdate extends HttpServlet {

    private int toInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private String n(String s) {
        return s == null ? "" : s.trim();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = toInt(req.getParameter("id"), -1);
        if (id <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=invalid");
            return;
        }

        UserDAO udao = new UserDAO();
        User u = udao.getById(id);
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=notfound");
            return;
        }

        RoleDAO rdao = new RoleDAO();
        req.setAttribute("user", u);
        req.setAttribute("roles", rdao.searchRoles(null, null)); // load dropdown role

        req.getRequestDispatcher("/update_user_information.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int userId = toInt(req.getParameter("user_id"), -1);
        int roleId = toInt(req.getParameter("role_id"), -1);

        String fullName = n(req.getParameter("full_name"));
        String email = n(req.getParameter("email"));
        String phone = n(req.getParameter("phone"));

        int status = 1;

        if (userId <= 0 || roleId <= 0 || fullName.isEmpty()) {
            req.setAttribute("error", "Invalid input!");
            doGet(req, resp);
            return;
        }
        
        //10 digits and start 0
        if (phone.isEmpty() || !phone.matches("^0\\d{9}$")) {
            req.setAttribute("error", "Phone must be 10 digits and start with 0 (e.g. 0912345678).");
            doGet(req, resp); // doGet sẽ load lại user + roles để render lại form
            return;
        }

        UserDAO dao = new UserDAO();

        boolean ok = dao.updateUserInfo(userId, fullName, email, phone, roleId, status);

        resp.sendRedirect(req.getContextPath() + "/admin/users?msg=" + (ok ? "updated" : "failed"));
    }
}
