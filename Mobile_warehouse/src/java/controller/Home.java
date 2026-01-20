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

//        HttpSession session = request.getSession(false);
//        User u = (session == null) ? null : (User) session.getAttribute("authUser");
//
//        if (u == null) {
//            response.sendRedirect(request.getContextPath() + "/login");
//            return;
//        }
//
//        UserDAO dao = new UserDAO();
//
//        // roleName lấy từ session (đã set ở LoginServlet), nếu null thì query DB
//        String role = (String) session.getAttribute("roleName");
//        if (role == null || role.isBlank()) {
//            role = dao.getRoleNameByUserId(u.getUserId());
//        }
//        if (role == null) {
//            role = "STAFF";
//        }
//        role = role.toUpperCase();
//
//        String p = request.getParameter("p");
//        if (p == null || p.isBlank()) {
//            p = "dashboard";
//        }
//        p = p.trim().toLowerCase();
//
//        if (!isAllowed(role, p)) {
//            p = "denied";
//        }
//
//        // sidebar theo role
//        String sidebarPage;
//        switch (role) {
//            case "ADMIN":
//                sidebarPage = "/sidebar_admin.jsp";
//                break;
//            case "MANAGER":
//                sidebarPage = "/sidebar_manager.jsp";
//                break;
//            case "SALE":
//            case "SALER":
//                sidebarPage = "/sidebar_sales.jsp";
//                break;
//            default:
//                sidebarPage = "/sidebar_staff.jsp";
//                break;
//        }
//
//        request.setAttribute("sidebarPage", sidebarPage);
//        request.setAttribute("contentPage", "/content.jsp");
//        request.setAttribute("page", p);
//
//        request.getRequestDispatcher("/homepage.jsp").forward(request, response);
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
//        //Prepare Data
//        if ("user-list".equals(p)) {
//            String q = request.getParameter("q"); // nếu muốn search
//            List<UserRoleDetail> users = UserDAO.getAllUsersWithRole(q);
//            request.setAttribute("users", users);
//        }
//
//        if ("role-toggle".equals(p)) {
//            RoleDAO roleDAO = new RoleDAO();
//
//            // nếu có filter/search từ UI thì đọc param
//            String keyword = request.getParameter("q"); // hoặc "keyword"
//            String st = request.getParameter("status"); // "1" / "0" / null
//
//            Integer status = null;
//            if (st != null && !st.isBlank()) {
//                status = Integer.parseInt(st);
//            }
//
//            List<Role> roles = roleDAO.searchRoles(keyword, status);
//            request.setAttribute("roles", roles);   // nhớ đúng tên JSP đang dùng
//        }
//
//        if ("user-update".equals(p)) {
//            String idRaw = request.getParameter("id");
//            if (idRaw == null || idRaw.isBlank()) {
//                response.sendRedirect(request.getContextPath() + "/home?p=user-list&msg=Please select a user first");
//                return;
//            }
//
//            int userId = Integer.parseInt(idRaw);
//
//            UserDAO userDAO = new UserDAO();
//            User userObj = userDAO.getById(userId);
//
//            RoleDAO roleDAO = new RoleDAO();
//            List<Role> roleList = roleDAO.searchRoles(null, null);
//
//            request.setAttribute("user", userObj);    // ✅ JSP update_user_information.jsp đang dùng key "user"
//            request.setAttribute("roles", roleList);  // ✅ dropdown role
//        }
//
//        if ("user-toggle".equals(p)) {
//            String q = request.getParameter("q");
//            List<UserRoleDetail> users = UserDAO.getAllUsersWithRole(q);
//            request.setAttribute("users", users);
//        }
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

//    private boolean isAllowed(String role, String p) {
//        if ("dashboard".equals(p) || "denied".equals(p)) return true;
//
//        switch (role) {
//            case "ADMIN":
//                return p.equals("user-list") || p.equals("user-add") || p.equals("user-update") || p.equals("user-toggle")
//                        || p.equals("role-list") || p.equals("role-update") || p.equals("role-toggle")
//                        || p.equals("role-perm-view") || p.equals("role-perm-edit")
//                        ||  p.equals("change_password");
//
//            case "MANAGER":
//                return p.equals("reports") || p.equals("user-list") || p.equals("user-detail")
//                        ||  p.equals("change_password");
//
//            case "STAFF":
//                return p.equals("inbound") || p.equals("outbound") || p.equals("stock-count")
//                        || p.equals("change_password");
//
//            case "SALE":
//                return p.equals("inventory") || p.equals("create-out")
//                        ||  p.equals("change_password");
//        }
//        return false;
//    }
    private void prepareData(String p, HttpServletRequest request, HttpServletResponse response) throws IOException {

        UserDAO userDAO = new UserDAO();
        RoleDAO roleDAO = new RoleDAO();
        RolePermissionDAO rpDAO = new RolePermissionDAO();
       

        switch (p) {

           
            case "user-list":
            case "user-toggle": {
                String q = request.getParameter("q");
              
                List<UserRoleDetail> users = userDAO.getAllUsersWithRole(q);
                request.setAttribute("users", users);
                request.setAttribute("q", q);
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
