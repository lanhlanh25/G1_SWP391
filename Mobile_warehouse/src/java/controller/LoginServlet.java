/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;


import dal.UserDBContext;
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

        UserDBContext db = new UserDBContext();
        User u = db.login(username, password);

        if (u == null) {
            request.setAttribute("err", "Invalid username/password or inactive account!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("authUser", u);

        response.sendRedirect(request.getContextPath() + "/home");
    }
}
