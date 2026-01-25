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

@WebServlet("/admin/user/edit")
public class UserEdit extends HttpServlet {

    private int toInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
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
        String roleName = rdao.getRoleNameById(u.getRoleId());

        req.setAttribute("user", u);
        req.setAttribute("roleName", roleName == null ? "" : roleName);

       
        req.getRequestDispatcher("/view_user_information.jsp").forward(req, resp);
    }

   
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
