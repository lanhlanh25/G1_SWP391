package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AdminUserListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        UserDAO dao = new UserDAO();
        req.setAttribute("users", dao.getAllUsersWithRole());

        // forward tới JSP
        req.getRequestDispatcher("/WEB-INF/views/admin/user_list.jsp")
           .forward(req, resp);
    }
}
