package controller;

import dal.PermissionDAO;
import dal.RoleDAO;
import dal.RolePermissionDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import model.Permission;

@WebServlet(name = "AdminRoleDetailServlet", urlPatterns = {"/admin/role-detail"})
public class AdminRoleDetail extends HttpServlet {

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

        int roleId = parseInt(req.getParameter("roleId"), 0);
        if (roleId <= 0) {
            req.setAttribute("error", "Invalid roleId");
            req.getRequestDispatcher("/role_detail.jsp").forward(req, resp);
            return;
        }

        String roleName = roleDAO.getRoleNameById(roleId);

       
        Set<Integer> checkedIds = rpDAO.getPermissionIdsByRole(roleId);
        List<Permission> allPerms = permDAO.getAllActive();

        List<Permission> assigned = new ArrayList<>();
        for (Permission p : allPerms) {
            if (checkedIds.contains(p.getPermissionId())) {
                assigned.add(p);
            }
        }

        req.setAttribute("roleId", roleId);
        req.setAttribute("roleName", roleName);
        req.setAttribute("rolePerms", assigned); 
        req.getRequestDispatcher("/role_detail.jsp").forward(req, resp);
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}