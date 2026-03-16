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
import jakarta.servlet.http.Cookie;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class Login extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession s = request.getSession(false);
        if (s != null && s.getAttribute("authUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Read cookies for "Remember Me"
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if (c.getName().equals("c_user")) {
                    request.setAttribute("usernameVal", c.getValue());
                }
                if (c.getName().equals("c_pass")) {
                    request.setAttribute("passwordVal", c.getValue());
                }
                if (c.getName().equals("c_rem")) {
                    request.setAttribute("rememberVal", c.getValue());
                }
            }
        }

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

        HttpSession session = request.getSession(true);
        session.setAttribute("authUser", u);
        session.setAttribute("userId", u.getUserId());
        session.setAttribute("roleId", u.getRoleId());
        session.setAttribute("fullName", u.getFullName());

        String roleName = dao.getRoleNameByUserId(u.getUserId());
        session.setAttribute("roleName", roleName);

        // Handle "Remember Me"
        String remember = request.getParameter("remember");
        if ("true".equals(remember)) {
            Cookie cu = new Cookie("c_user", username);
            Cookie cp = new Cookie("c_pass", password);
            Cookie cr = new Cookie("c_rem", "checked");
            cu.setMaxAge(60 * 60 * 24 * 7); // 7 days
            cp.setMaxAge(60 * 60 * 24 * 7);
            cr.setMaxAge(60 * 60 * 24 * 7);
            response.addCookie(cu);
            response.addCookie(cp);
            response.addCookie(cr);
        } else {
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie c : cookies) {
                    if (c.getName().equals("c_user") || c.getName().equals("c_pass") || c.getName().equals("c_rem")) {
                        c.setMaxAge(0);
                        response.addCookie(c);
                    }
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/home");
    }

}
