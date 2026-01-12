package controller;

import dal.RoleDAO;
import dal.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

@WebServlet(name = "AdminAddUserServlet", urlPatterns = {"/admin/user-add"})
public class AdminAddUserServlet extends HttpServlet {

    private String n(String s) {
        return s == null ? "" : s.trim();
    }

    private int toInt(String s, int d) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return d;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // AdminFilter đã chặn rồi, nhưng vẫn load data
        RoleDAO rdao = new RoleDAO();
        req.setAttribute("roles", rdao.getActiveRoles());

        req.getRequestDispatcher("/WEB-INF/views/admin/user_add.jsp").forward(req, resp);
    }

  @Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

    req.setCharacterEncoding("UTF-8");

    // ===== DEV MODE: chưa login vẫn cho tạo user để test =====
    HttpSession session = req.getSession(false);
    User admin = (session != null) ? (User) session.getAttribute("user") : null;

    // nếu chưa login thì tạm coi createdBy = 1 (admin01)
    int createdBy = (admin == null ? 1 : admin.getUserId());

    String username = n(req.getParameter("username"));
    String password = n(req.getParameter("password"));
    String fullName = n(req.getParameter("full_name"));
    String email    = n(req.getParameter("email"));
    String phone    = n(req.getParameter("phone"));
    int roleId      = toInt(req.getParameter("role_id"), 0);
    int status      = toInt(req.getParameter("status"), 1);

    UserDAO udao = new UserDAO();

    // validate
    String error = null;
    if (username.isEmpty()) error = "Username không được để trống.";
    else if (password.isEmpty()) error = "Password không được để trống.";
    else if (fullName.isEmpty()) error = "Full name không được để trống.";
    else if (roleId <= 0) error = "Bạn phải chọn Role.";
    else if (udao.usernameExists(username)) error = "Username đã tồn tại.";
    else if (!email.isEmpty() && udao.emailExists(email)) error = "Email đã tồn tại.";

    if (error != null) {
        RoleDAO rdao = new RoleDAO();
        req.setAttribute("roles", rdao.getActiveRoles());
        req.setAttribute("error", error);

        // giữ lại input
        req.setAttribute("v_username", username);
        req.setAttribute("v_full_name", fullName);
        req.setAttribute("v_email", email);
        req.setAttribute("v_phone", phone);
        req.setAttribute("v_role_id", roleId);
        req.setAttribute("v_status", status);

        req.getRequestDispatcher("/WEB-INF/views/admin/user_add.jsp").forward(req, resp);
        return;
    }

    try {
        int newId = udao.createUser(
                username, password, fullName,
                email.isEmpty() ? null : email,
                phone.isEmpty() ? null : phone,
                roleId, status,
                createdBy
        );

        resp.sendRedirect(req.getContextPath() + "/admin/user-add?success=1&id=" + newId);

    } catch (Exception e) {
        e.printStackTrace();
        RoleDAO rdao = new RoleDAO();
        req.setAttribute("roles", rdao.getActiveRoles());
        req.setAttribute("error", "Lỗi tạo user: " + e.getMessage());
        req.getRequestDispatcher("/WEB-INF/views/admin/user_add.jsp").forward(req, resp);
    }
}

}
