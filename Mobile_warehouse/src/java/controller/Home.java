/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
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
import model.Role;
import model.User;
import model.UserRoleDetail;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class Home extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User u = (User) request.getSession().getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String p = request.getParameter("p");
        if (p == null || p.isBlank()) {
            p = "dashboard";
        }

        String role = (String) request.getSession().getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null) {
                role = "STAFF";
            }
            request.getSession().setAttribute("roleName", role);
        }
        role = role.toUpperCase();

        String sidebarPage;
        switch (role) {
            case "ADMIN":
                sidebarPage = "sidebar_admin.jsp";
                break;
            case "MANAGER":
                sidebarPage = "sidebar_manager.jsp";
                break;
            case "SALE":
                sidebarPage = "sidebar_sales.jsp";
                break;
            default:
                sidebarPage = "sidebar_staff.jsp";
                break;
        }

        String contentPage = resolveContent(role, p);
        if (contentPage == null) {
            response.sendError(403, "Forbidden");
            return;
        }

        prepareData(p, request, response);
        // nếu prepareData redirect thì return để khỏi forward tiếp
        if (response.isCommitted()) {
            return;
        }
        request.setAttribute("sidebarPage", sidebarPage);
        request.setAttribute("contentPage", contentPage);
        request.setAttribute("currentPage", p);

        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }

    private void prepareData(String p, HttpServletRequest request, HttpServletResponse response) throws IOException {

        UserDAO userDAO = new UserDAO();
        RoleDAO roleDAO = new RoleDAO();
        RolePermissionDAO rpDAO = new RolePermissionDAO();

        switch (p) {

            case "user-list":
            case "user-toggle": {
                String q = request.getParameter("q");
                String st = request.getParameter("status");
                // page
                int page = 1;
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                    if (page < 1) {
                        page = 1;
                    }
                } catch (Exception e) {
                    page = 1;
                }

                int pageSize = 2; // bạn muốn 5/10/20 tuỳ bạn

                int totalItems = userDAO.countUsersWithRole(q, st);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages == 0) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                List<UserRoleDetail> users = userDAO.getAllUsersWithRole(q, st, page, pageSize);

                request.setAttribute("users", users);
                request.setAttribute("q", q);
                request.setAttribute("status", st);

                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalItems", totalItems);
                request.setAttribute("totalPages", totalPages);

                break;
            }

            case "user-update": {
                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=user-list&msg=Please select a user first");
                    return;
                }

                int userId = Integer.parseInt(idRaw);

                User user = userDAO.getById(userId);
                if (user == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=user-list&msg=User not found");
                    return;
                }

                List<Role> roles = roleDAO.searchRoles(null, null);

                request.setAttribute("user", user);
                request.setAttribute("roles", roles);
                break;
            }

            case "role-list":
            case "role-toggle": {
                String keyword = request.getParameter("q");
                String st = request.getParameter("status");

                Integer status = null;
                if (st != null && !st.isBlank()) {
                    status = Integer.parseInt(st);
                }

                List<Role> roles = roleDAO.searchRoles(keyword, status);

                request.setAttribute("roles", roles);
                request.setAttribute("q", keyword);
                request.setAttribute("status", st);
                break;
            }

            case "role-perm-view": {
                String ridRaw = request.getParameter("roleId");
                if (ridRaw == null || ridRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=role-list&msg=Please select a role first");
                    return;
                }

                int roleId = Integer.parseInt(ridRaw);

                request.setAttribute("roleId", roleId);
                request.setAttribute("roleName", roleDAO.getRoleNameById(roleId));

                Set<Integer> permIds = rpDAO.getPermissionIdsByRole(roleId);

                request.setAttribute("rolePerms", new ArrayList<Permission>());

                break;
            }

            default:

                break;
        }
    }

    private String resolveContent(String role, String p) {
        switch (role) {
            case "ADMIN":
                switch (p) {
                    case "dashboard":
                        return "admin_dashboard.jsp";
                    case "user-list":
                        return "user_list.jsp";
                    case "user-add":
                        return "user_add.jsp";
                    case "user-update":
                        return "update_user_information.jsp";
                    case "user-toggle":
                        return "active_user.jsp";
                    case "role-list":
                        return "view_role_list.jsp";
                    case "role-update":
                        return "edit_role_permissions.jsp";
                    case "role-toggle":
                        return "active_role.jsp";
                    case "role-perm-view":
                        return "role_detail.jsp";
                    case "role-perm-edit":
                        return "update_user_information.jsp";
                    case "my-profile":
                        return "view_profile.jsp";
                    case "change-password":
                        return "change_password.jsp";
                    default:
                        return null;
                }

            case "MANAGER":
                switch (p) {
                    case "dashboard":
                        return "manager_dashboard.jsp";
                    case "reports":
                        return "reports.jsp";
                    case "user-list":
                        return "user_list.jsp";
                    case "user-detail":
                        return "view_user_information.jsp";
                    case "profile":
                        return "view_profile.jsp";
                    case "change-password":
                        return "change_password.jsp";
                    default:
                        return null;
                }

            case "SALE":
                switch (p) {
                    case "dashboard":
                        return "sales_dashboard.jsp";
                    case "profile":
                        return "view_profile.jsp";
                    case "change-password":
                        return "change_password.jsp";
                    default:
                        return null;
                }

            default: // STAFF
                switch (p) {
                    case "dashboard":
                        return "staff_dashboard.jsp";
                    case "profile":
                        return "view_profile.jsp";
                    case "change-password":
                        return "change_password.jsp";
                    default:
                        return null;
                }
        }
    }
}
