/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

@WebServlet("/profile")
public class Profile extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");

        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        UserDAO dao = new UserDAO();
        User fresh = dao.getById(u.getUserId());

      
        if (fresh != null) {
            session.setAttribute("authUser", fresh);
            request.setAttribute("profileUser", fresh);
        } else {
            request.setAttribute("profileUser", u);
        }

        
        request.getRequestDispatcher("/view_profile.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
