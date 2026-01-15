/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name="LoginServlet", urlPatterns={"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        username = (username == null) ? "" : username.trim();
        password = (password == null) ? "" : password.trim();

        request.setAttribute("usernameVal", username);

        if (username.isBlank() || password.isBlank()) {
            request.setAttribute("err", "Please enter username and password!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        User u = dao.login(username, password);

        if (u == null) {
            request.setAttribute("err", "Invalid username/password or inactive account!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // IMPORTANT: set session để các servlet khác dùng (ChangePassword, RolePermissions...)
        HttpSession session = request.getSession(true);
        session.setAttribute("authUser", u);
        session.setAttribute("userId", u.getUserId());
        session.setAttribute("roleId", u.getRoleId());

        // HomeServlet của bạn bạn dùng roleName => ta lưu thêm roleName vào session
        String roleName = dao.getRoleNameByUserId(u.getUserId());
        session.setAttribute("roleName", roleName);

        response.sendRedirect(request.getContextPath() + "/home");
    }
}
