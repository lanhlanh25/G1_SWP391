package controller;


import dal.PermissionDAO;
import dal.RoleDAO;
import dal.RolePermissionDAO;
import dal.UserDAO;
import model.Permission;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet(name = "RolePermissionsServlet", urlPatterns = {"/role_permissions"})
public class RolePermissions extends HttpServlet {

    private final PermissionDAO permDAO = new PermissionDAO();
    private final RoleDAO roleDAO       = new RoleDAO();
    private final RolePermissionDAO rpDAO = new RolePermissionDAO();
    private final UserDAO userDAO       = new UserDAO();

    private boolean isAdmin(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        int userId = Integer.parseInt(session.getAttribute("userId").toString());
        String roleName = userDAO.getRoleNameByUserId(userId);
        return roleName != null && roleName.equalsIgnoreCase("ADMIN");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // ✅ Redirect về home controller để có layout đầy đủ
        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String roleIdParam = req.getParameter("roleId");
        resp.sendRedirect(req.getContextPath() + "/home?p=role-permissions&roleId=" + (roleIdParam != null ? roleIdParam : ""));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int adminId = Integer.parseInt(session.getAttribute("userId").toString());
        int roleId  = Integer.parseInt(req.getParameter("roleId"));

        String[] permIds = req.getParameterValues("permId");
        List<Integer> list = new ArrayList<>();
        if (permIds != null) {
            for (String s : permIds) list.add(Integer.parseInt(s));
        }

        boolean ok = rpDAO.saveRolePermissions(roleId, list, adminId);

        // ✅ Redirect về home?p=role-permissions để có layout đầy đủ
        String msg = ok ? "Update+successfully!" : "Update+failed!";
        resp.sendRedirect(req.getContextPath() + "/home?p=role-permissions&roleId=" + roleId + "&msg=" + msg);
    }
}
