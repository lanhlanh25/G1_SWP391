/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */
import dal.BrandDAO;
import dal.RoleDAO;
import dal.RolePermissionDAO;
import dal.UserDAO;
import dal.BrandStatsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Brand;
import model.Permission;
import model.Role;
import model.User;
import model.UserRoleDetail;
import model.BrandStatsRow;
import model.BrandStatsSummary;
import model.ProductStatsRow;
import java.time.LocalDate;
import java.sql.Date;

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

        try {
            prepareData(p, request, response);
        } catch (Exception ex) {
            Logger.getLogger(Home.class.getName()).log(Level.SEVERE, null, ex);
        }
        // nếu prepareData redirect thì return để khỏi forward tiếp
        if (response.isCommitted()) {
            return;
        }
        request.setAttribute("sidebarPage", sidebarPage);
        request.setAttribute("contentPage", contentPage);
        request.setAttribute("currentPage", p);

        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }

    private void prepareData(String p, HttpServletRequest request, HttpServletResponse response) throws IOException, Exception {
        BrandDAO brandDAO = new BrandDAO();
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

                int pageSize = 5; // bạn muốn 5/10/20 tuỳ bạn

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
            case "brand-list": {
                String q = request.getParameter("q");
                String st = request.getParameter("status");       // active/inactive/"" 
                String sortBy = request.getParameter("sortBy");   // name/createdAt/status
                String sortOrder = request.getParameter("sortOrder"); // ASC/DESC

                int page = 1;
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (Exception e) {
                }
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 5;

                int totalItems = brandDAO.count(q, st);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages == 0) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                List<Brand> brands = brandDAO.list(q, st, sortBy, sortOrder, page, pageSize);

                request.setAttribute("brands", brands);
                request.setAttribute("q", q);
                request.setAttribute("status", st);
                request.setAttribute("sortBy", sortBy);
                request.setAttribute("sortOrder", sortOrder);
                request.setAttribute("page", page);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalItems", totalItems);
                request.setAttribute("pageSize", pageSize);

                break;
            }

            case "brand-detail":
            case "brand-update":
            case "brand-disable": {
                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=brand-list&msg=Please select a brand first");
                    return;
                }
                long id = Long.parseLong(idRaw);
                Brand b = brandDAO.findById(id);
                if (b == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=brand-list&msg=Brand not found");
                    return;
                }
                request.setAttribute("brand", b);
                break;
            }

            case "brand-add": {
                // form trống, không cần data
                break;
            }
            case "brand-stats": {
                BrandStatsDAO statsDAO = new BrandStatsDAO();

                String q = request.getParameter("q");
                String brandStatus = request.getParameter("status"); // active/inactive/""
                String sortBy = request.getParameter("sortBy");      // stock/products/low
                String sortOrder = request.getParameter("sortOrder");// ASC/DESC
                String brandIdRaw = request.getParameter("brandId"); // combobox
                String range = request.getParameter("range"); // all / last7 / last30 / month

                if (range == null || range.isBlank()) {
                    range = "all";
                }

                Date fromDate = null;
                Date toDate = null;

                LocalDate today = LocalDate.now();
                switch (range) {
                    case "last7":
                        fromDate = Date.valueOf(today.minusDays(6));
                        toDate = Date.valueOf(today);
                        break;
                    case "last30":
                        fromDate = Date.valueOf(today.minusDays(29));
                        toDate = Date.valueOf(today);
                        break;
                    case "month":
                        fromDate = Date.valueOf(today.withDayOfMonth(1));
                        toDate = Date.valueOf(today);
                        break;
                    case "today":
                        fromDate = Date.valueOf(today);
                        toDate = Date.valueOf(today);
                        break;

                    case "lastMonth":
                        LocalDate firstDayLastMonth = today.minusMonths(1).withDayOfMonth(1);
                        LocalDate lastDayLastMonth = today.withDayOfMonth(1).minusDays(1);
                        fromDate = Date.valueOf(firstDayLastMonth);
                        toDate = Date.valueOf(lastDayLastMonth);
                        break;

                    default: // "all"
                        fromDate = null;
                        toDate = null;
                        break;
                }
                Long brandId = null;
                if (brandIdRaw != null && !brandIdRaw.isBlank()) {
                    brandId = Long.parseLong(brandIdRaw);
                }

                int page = 1;
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (Exception e) {
                }
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 5;
                int lowThreshold = 5;

                int totalItems = statsDAO.countBrands(q, brandStatus, brandId, fromDate, toDate);

                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages == 0) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                BrandStatsSummary summary = statsDAO.getSummary(q, brandStatus, brandId, lowThreshold, fromDate, toDate);
                List<BrandStatsRow> rows = statsDAO.listBrandStats(q, brandStatus, brandId, sortBy, sortOrder, page, pageSize, lowThreshold, fromDate, toDate);

                // combobox brand list (reuse brandDAO)
                List<Brand> allBrands = brandDAO.list(null, "", "name", "ASC", 1, 1000);

                request.setAttribute("summary", summary);
                request.setAttribute("rows", rows);
                request.setAttribute("allBrands", allBrands);

                request.setAttribute("q", q);
                request.setAttribute("status", brandStatus);
                request.setAttribute("sortBy", sortBy);
                request.setAttribute("sortOrder", sortOrder);
                request.setAttribute("brandId", brandIdRaw);

                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalItems", totalItems);
                request.setAttribute("range", range);
                break;
            }

            case "brand-stats-detail": {
                BrandStatsDAO statsDAO = new BrandStatsDAO();
                String brandIdRaw = request.getParameter("brandId");
                if (brandIdRaw == null || brandIdRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=brand-stats&err=Missing brandId");
                    return;
                }
                long brandId = Long.parseLong(brandIdRaw);

                int lowThreshold = 5;

                Brand b = brandDAO.findById(brandId);
                if (b == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=brand-stats&err=Brand not found");
                    return;
                }

                List<ProductStatsRow> products = statsDAO.listBrandDetail(brandId, lowThreshold);

                request.setAttribute("brand", b);
                request.setAttribute("products", products);
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
                    case "my-profile":
                        return "view_profile.jsp";
                    case "change-password":
                        return "change_password.jsp";

                    case "brand-list":
                        return "brand_list.jsp";
                    case "brand-add":
                        return "brand_add.jsp";
                    case "brand-detail":
                        return "brand_detail.jsp";
                    case "brand-update":
                        return "brand_update.jsp";
                    case "brand-disable":
                        return "brand_disable_confirm.jsp";
                    case "brand-stats":
                        return "brand_stats.jsp";
                    case "brand-stats-detail":
                        return "brand_stats_detail.jsp";

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
                    case "brand-list":
                        return "brand_list.jsp";
                    case "brand-detail":
                        return "brand_detail.jsp";

                    default:
                        return null;
                }
        }
    }
}
