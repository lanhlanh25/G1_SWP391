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

@WebServlet(name="RolePermissionsServlet", urlPatterns={"/role_permissions"})
public class RolePermissionsServlet extends HttpServlet {

    private final PermissionDAO permDAO = new PermissionDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private final RolePermissionDAO rpDAO = new RolePermissionDAO();
    private final UserDAO userDAO = new UserDAO();

    private boolean isAdmin(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        int userId = Integer.parseInt(session.getAttribute("userId").toString());
        String roleName = userDAO.getRoleNameByUserId(userId);
        return roleName != null && roleName.equalsIgnoreCase("ADMIN");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int roleId = Integer.parseInt(req.getParameter("roleId"));

        List<Permission> allPerms = permDAO.getAllActive();           // 17 quyền
        Set<Integer> checked = rpDAO.getPermissionIdsByRole(roleId);  // tick sẵn

        req.setAttribute("roleId", roleId);
        req.setAttribute("roleName", roleDAO.getRoleNameById(roleId));
        req.setAttribute("allPerms", allPerms);
        req.setAttribute("checked", checked);
        req.setAttribute("msg", req.getParameter("msg"));

        req.getRequestDispatcher("edit_role_permissions.jsp").forward(req, resp);
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
        int roleId = Integer.parseInt(req.getParameter("roleId"));

        String[] permIds = req.getParameterValues("permId");
        List<Integer> list = new ArrayList<>();
        if (permIds != null) {
            for (String s : permIds) list.add(Integer.parseInt(s));
        }

        boolean ok = rpDAO.saveRolePermissions(roleId, list, adminId);

        resp.sendRedirect(req.getContextPath() + "/role_permissions?roleId=" + roleId
        + "&msg=" + (ok ? "Update successfully!" : "Update failed!"));

    }
}
