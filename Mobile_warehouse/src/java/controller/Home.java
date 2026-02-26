package controller;

import dal.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import model.*;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class Home extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(Home.class.getName());
    private static final DateTimeFormatter DTF_UI = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        User u = (User) session.getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String p = request.getParameter("p");
        if (p == null || p.isBlank()) {
            p = "dashboard";
        }

        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) {
                role = "STAFF";
            }
            session.setAttribute("roleName", role);
        }
        role = role.toUpperCase();

        String sidebarPage = resolveSidebar(role);
        String contentPage = resolveContent(role, p);
        if (contentPage == null) {
            response.sendError(403, "Forbidden");
            return;
        }

        try {
            prepareData(p, request, response, u);
        } catch (Exception ex) {
            LOG.log(Level.SEVERE, "prepareData failed", ex);
            request.setAttribute("err", "Internal error: " + ex.getMessage());
        }

        if (response.isCommitted()) {
            return;
        }

        request.setAttribute("sidebarPage", sidebarPage);
        request.setAttribute("contentPage", contentPage);
        request.setAttribute("currentPage", p);

        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }

    private void prepareData(String p, HttpServletRequest request, HttpServletResponse response, User authUser)
            throws Exception {

        BrandDAO brandDAO = new BrandDAO();
        UserDAO userDAO = new UserDAO();
        RoleDAO roleDAO = new RoleDAO();
        RolePermissionDAO rpDAO = new RolePermissionDAO();

        switch (p) {

            // =========================
            //  CREATE IMPORT RECEIPT 
            // =========================
            case "create-import-receipt": {
                SupplierDAO sdao = new SupplierDAO();
                ProductDAO pdao = new ProductDAO();
                ProductSkuDAO skdao = new ProductSkuDAO();
                ImportReceiptDAO irDao = new ImportReceiptDAO();

                request.setAttribute("suppliers", sdao.listActive());
                request.setAttribute("products", pdao.listActive());
                request.setAttribute("skus", skdao.listActive());

                try (Connection con = DBContext.getConnection()) {
                    String importCode = irDao.generateImportCode(con);
                    request.setAttribute("importCode", importCode);
                }

                String receiptDateDefault = LocalDateTime.now()
                        .withSecond(0).withNano(0)
                        .format(DTF_UI);
                request.setAttribute("receiptDateDefault", receiptDateDefault);

                String createdByName = "Staff";
                HttpSession session = request.getSession(false);
                if (session != null && session.getAttribute("fullName") != null) {
                    createdByName = String.valueOf(session.getAttribute("fullName"));
                } else if (authUser != null && authUser.getFullName() != null) {
                    createdByName = authUser.getFullName();
                }
                request.setAttribute("createdByName", createdByName);
                break;
            }

            // =========================
            //  CREATE EXPORT RECEIPT (FORM)
            // =========================
            case "create-export":
            case "create-export-receipt":
            case "upload-export-imeis": {
                ProductDAO pdao = new ProductDAO();
                ProductSkuDAO skdao = new ProductSkuDAO();

                request.setAttribute("products", pdao.listActive());
                request.setAttribute("skus", skdao.listActive());

                // demo code - bạn có thể thay bằng generateExportCode() sau
                request.setAttribute("exportCode", "EXP-" + System.currentTimeMillis());

                String dt = LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI);
                request.setAttribute("receiptDateDefault", dt);

                String createdByName = (authUser != null && authUser.getFullName() != null)
                        ? authUser.getFullName()
                        : "Sale";
                request.setAttribute("createdByName", createdByName);
                break;
            }

            // =========================
            // EXPORT RECEIPT DETAIL
            // =========================
            case "export-receipt-detail": {
                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=export-receipt-list&err=Missing+id");
                    return;
                }
                long id = Long.parseLong(idRaw.trim());

                ExportReceiptDAO dao = new ExportReceiptDAO();
                ExportReceiptDetailHeader header = dao.getDetailHeader(id);
                List<ExportReceiptDetailLine> lines = dao.getDetailLines(id);

                request.setAttribute("header", header);
                request.setAttribute("lines", lines);
                break;
            }

            // =========================
            // ✅ EXPORT RECEIPT LIST  (FIXED + tabCounts + normalize status)
            // =========================
            case "export-receipt-list": {
                ExportReceiptDAO dao = new ExportReceiptDAO();

                String q = request.getParameter("q");
                String status = request.getParameter("status"); // JSP dùng: all/pending/completed/cancelled
                String fromRaw = request.getParameter("from");
                String toRaw = request.getParameter("to");

                java.sql.Date fromDate = null, toDate = null;
                try {
                    if (fromRaw != null && !fromRaw.isBlank()) {
                        fromDate = java.sql.Date.valueOf(fromRaw.trim());
                    }
                } catch (Exception ignore) {
                }
                try {
                    if (toRaw != null && !toRaw.isBlank()) {
                        toDate = java.sql.Date.valueOf(toRaw.trim());
                    }
                } catch (Exception ignore) {
                }

                // normalize for UI
                if (status == null || status.isBlank()) {
                    status = "all";
                }
                status = status.trim().toLowerCase();

                // map for DB (nếu DB lưu PENDING/COMPLETED/CANCELLED)
                String statusForDao = status;
                if (!"all".equals(status)) {
                    statusForDao = status.toUpperCase();
                }

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 10;

                int totalItems = dao.countList(q, statusForDao, fromDate, toDate);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                List<ExportReceiptListItem> rows = dao.list(q, statusForDao, fromDate, toDate, page, pageSize);

                // tabCounts để JSP show số
                Map<String, Integer> tabCounts = new HashMap<>();
                tabCounts.put("all", dao.countList(q, "ALL", fromDate, toDate)); // dao ignoreCase ALL
                tabCounts.put("pending", dao.countList(q, "PENDING", fromDate, toDate));
                tabCounts.put("completed", dao.countList(q, "COMPLETED", fromDate, toDate));
                tabCounts.put("cancelled", dao.countList(q, "CANCELLED", fromDate, toDate));
                request.setAttribute("tabCounts", tabCounts);

                request.setAttribute("rows", rows);
                request.setAttribute("q", q);
                request.setAttribute("status", status); // để JSP compare 'pending'...
                request.setAttribute("from", fromRaw);
                request.setAttribute("to", toRaw);

                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalItems", totalItems);
                break;
            }

            // =========================
            // USERS
            // =========================
            case "user-list":
            case "user-toggle": {
                String q = request.getParameter("q");
                String st = request.getParameter("status");

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 5;
                int totalItems = userDAO.countUsersWithRole(q, st);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
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

            case "user-add": {
                request.setAttribute("roles", roleDAO.searchRoles(null, 1));
                break;
            }

            // =========================
            // ROLES
            // =========================
            case "role-list": {
                String keyword = request.getParameter("q");
                String st = request.getParameter("status");

                Integer status = null;
                if (st != null && !st.isBlank()) {
                    try {
                        status = Integer.parseInt(st.trim());
                    } catch (Exception e) {
                        status = null;
                        st = "";
                    }
                } else {
                    st = "";
                }

                if (keyword == null) {
                    keyword = "";
                }
                keyword = keyword.trim();

                List<Role> roles = roleDAO.searchRoles(keyword, status);

                request.setAttribute("roles", roles);
                request.setAttribute("q", keyword);
                request.setAttribute("status", st);
                break;
            }

            case "role-toggle": {
                String keyword = request.getParameter("q");
                String st = request.getParameter("status");

                Integer status = null;
                if (st != null && !st.isBlank()) {
                    status = Integer.parseInt(st.trim());
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
                request.setAttribute("rolePermIds", permIds);

                request.setAttribute("rolePerms", new ArrayList<Permission>());
                break;
            }

            // =========================
            // SKU / PRODUCT
            // =========================
            case "sku-add": {
                ProductDAO dao = new ProductDAO();
                request.setAttribute("products", dao.getAll());
                break;
            }

            case "product-add": {
                request.setAttribute("brands", brandDAO.list(null, "active", "name", "ASC", 1, 1000));
                break;
            }

            case "product-list": {
                String q = request.getParameter("q");
                String brandIdRaw = request.getParameter("brandId");
                String st = request.getParameter("status");

                Long brandId = null;
                if (brandIdRaw != null && !brandIdRaw.isBlank()) {
                    brandId = Long.parseLong(brandIdRaw);
                }

                String status = null;
                if (st != null && !st.isBlank()) {
                    status = st;
                }

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 5;

                ProductDAO pdao = new ProductDAO();
                int totalItems = pdao.count(q, brandId, status);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                List<ProductListItem> products = pdao.list(q, brandId, status, page, pageSize);

                request.setAttribute("products", products);
                request.setAttribute("q", q);
                request.setAttribute("brandId", brandIdRaw);
                request.setAttribute("status", st);

                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalItems", totalItems);
                request.setAttribute("totalPages", totalPages);

                request.setAttribute("allBrands", brandDAO.list(null, "", "name", "ASC", 1, 1000));
                break;
            }
            case "product-detail": {
                int productId = Integer.parseInt(request.getParameter("id"));
            }

            // =========================
            // BRANDS
            // =========================
            case "brand-list": {
                String q = request.getParameter("q");
                String st = request.getParameter("status");
                String sortBy = request.getParameter("sortBy");
                String sortOrder = request.getParameter("sortOrder");

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 5;

                int totalItems = brandDAO.count(q, st);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
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

            case "brand-add":
                break;

            // =========================
            // BRAND STATS
            // =========================
            case "brand-stats": {
                BrandStatsDAO statsDAO = new BrandStatsDAO();

                String q = request.getParameter("q");
                String brandStatus = request.getParameter("status");
                String sortBy = request.getParameter("sortBy");
                String sortOrder = request.getParameter("sortOrder");
                String brandIdRaw = request.getParameter("brandId");
                String range = request.getParameter("range");

                if (range == null || range.isBlank()) {
                    range = "all";
                }
                if (sortBy == null || sortBy.isBlank()) {
                    sortBy = "stock";
                }
                if (sortOrder == null || sortOrder.isBlank()) {
                    sortOrder = "DESC";
                }

                Date fromDate = null;
                Date toDate = null;

                LocalDate today = LocalDate.now();
                switch (range) {
                    case "today":
                        fromDate = Date.valueOf(today);
                        toDate = Date.valueOf(today);
                        break;
                    case "last7":
                        fromDate = Date.valueOf(today.minusDays(6));
                        toDate = Date.valueOf(today);
                        break;
                    case "last30":
                        fromDate = Date.valueOf(today.minusDays(29));
                        toDate = Date.valueOf(today);
                        break;
                    case "last90":
                        fromDate = Date.valueOf(today.minusDays(89));
                        toDate = Date.valueOf(today);
                        break;
                    case "month":
                        fromDate = Date.valueOf(today.withDayOfMonth(1));
                        toDate = Date.valueOf(today);
                        break;
                    case "lastMonth":
                        LocalDate firstDayLastMonth = today.minusMonths(1).withDayOfMonth(1);
                        LocalDate lastDayLastMonth = today.withDayOfMonth(1).minusDays(1);
                        fromDate = Date.valueOf(firstDayLastMonth);
                        toDate = Date.valueOf(lastDayLastMonth);
                        break;
                    default:
                        fromDate = null;
                        toDate = null;
                        range = "all";
                        break;
                }

                Long brandId = null;
                if (brandIdRaw != null && !brandIdRaw.isBlank()) {
                    brandId = Long.parseLong(brandIdRaw);
                }

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 5;
                int lowThreshold = 5;

                int totalItems = statsDAO.countBrands(q, brandStatus, brandId, fromDate, toDate);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                BrandStatsSummary summary = statsDAO.getSummary(q, brandStatus, brandId, lowThreshold, fromDate, toDate);
                List<BrandStatsRow> rows = statsDAO.listBrandStats(q, brandStatus, brandId, sortBy, sortOrder, page, pageSize, lowThreshold, fromDate, toDate);
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

                String dSortBy = request.getParameter("dSortBy");
                String dSortOrder = request.getParameter("dSortOrder");
                if (dSortBy == null || dSortBy.isBlank()) {
                    dSortBy = "stock";
                }
                if (dSortOrder == null || dSortOrder.isBlank()) {
                    dSortOrder = "DESC";
                }

                String range = request.getParameter("listRange");
                if (range == null || range.isBlank()) {
                    range = "all";
                }

                Date fromDate = null, toDate = null;
                LocalDate today = LocalDate.now();
                switch (range) {
                    case "today":
                        fromDate = Date.valueOf(today);
                        toDate = Date.valueOf(today);
                        break;
                    case "last7":
                        fromDate = Date.valueOf(today.minusDays(6));
                        toDate = Date.valueOf(today);
                        break;
                    case "last30":
                        fromDate = Date.valueOf(today.minusDays(29));
                        toDate = Date.valueOf(today);
                        break;
                    case "last90":
                        fromDate = Date.valueOf(today.minusDays(89));
                        toDate = Date.valueOf(today);
                        break;
                    case "month":
                        fromDate = Date.valueOf(today.withDayOfMonth(1));
                        toDate = Date.valueOf(today);
                        break;
                    case "lastMonth":
                        LocalDate first = today.minusMonths(1).withDayOfMonth(1);
                        LocalDate last = today.withDayOfMonth(1).minusDays(1);
                        fromDate = Date.valueOf(first);
                        toDate = Date.valueOf(last);
                        break;
                    default:
                        break;
                }

                Brand b = brandDAO.findById(brandId);
                if (b == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=brand-stats&err=Brand not found");
                    return;
                }

                BrandStatsSummary detailSummary = statsDAO.getBrandDetailSummary(brandId, lowThreshold, fromDate, toDate);
                List<ProductStatsRow> products = statsDAO.listBrandDetail(brandId, lowThreshold, fromDate, toDate, dSortBy, dSortOrder);

                request.setAttribute("brand", b);
                request.setAttribute("products", products);
                request.setAttribute("dSortBy", dSortBy);
                request.setAttribute("dSortOrder", dSortOrder);
                request.setAttribute("detailSummary", detailSummary);
                request.setAttribute("range", range);
                break;
            }

            // =========================
            // SUPPLIER
            // =========================
            case "view_supplier": {
                SupplierDAO supplierDAO = new SupplierDAO();

                String q = request.getParameter("q");
                String status = request.getParameter("status");
                String sortBy = request.getParameter("sortBy");
                String sortOrder = request.getParameter("sortOrder");

                if (sortBy == null || sortBy.isBlank()) {
                    sortBy = "newest";
                }
                if (sortOrder == null || sortOrder.isBlank()) {
                    sortOrder = "DESC";
                }

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 5;

                try {
                    int totalItems = supplierDAO.countSuppliers(q, status);
                    int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                    if (totalPages < 1) {
                        totalPages = 1;
                    }
                    if (page > totalPages) {
                        page = totalPages;
                    }

                    List<SupplierListItem> suppliers = supplierDAO.searchSuppliers(q, status, sortBy, sortOrder, page, pageSize);

                    request.setAttribute("suppliers", suppliers);
                    request.setAttribute("q", q);
                    request.setAttribute("status", status);
                    request.setAttribute("sortBy", sortBy);
                    request.setAttribute("sortOrder", sortOrder);

                    request.setAttribute("page", page);
                    request.setAttribute("pageSize", pageSize);
                    request.setAttribute("totalItems", totalItems);
                    request.setAttribute("totalPages", totalPages);

                } catch (SQLException ex) {
                    LOG.log(Level.SEVERE, "Database error while loading supplier list", ex);

                    request.setAttribute("suppliers", Collections.emptyList());
                    request.setAttribute("q", q);
                    request.setAttribute("status", status);
                    request.setAttribute("sortBy", sortBy);
                    request.setAttribute("sortOrder", sortOrder);

                    request.setAttribute("page", 1);
                    request.setAttribute("pageSize", pageSize);
                    request.setAttribute("totalItems", 0);
                    request.setAttribute("totalPages", 1);

                    request.setAttribute("msg", "Database error while loading supplier list.");
                }
                break;
            }

            case "supplier_detail": {
                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Please select a supplier");
                    return;
                }

                long supplierId;
                try {
                    supplierId = Long.parseLong(idRaw.trim());
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Invalid supplier id");
                    return;
                }

                SupplierDAO supplierDAO = new SupplierDAO();
                try {
                    SupplierDetailDTO dto = supplierDAO.getSupplierDetail(supplierId);
                    if (dto == null) {
                        response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Supplier not found");
                        return;
                    }
                    request.setAttribute("supplierDetail", dto);
                } catch (SQLException ex) {
                    LOG.log(Level.SEVERE, "Database error while loading supplier detail", ex);
                    request.setAttribute("msg", "Database error while loading supplier detail.");
                }
                break;
            }

            case "update_supplier": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !"MANAGER".equalsIgnoreCase(roleName)) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Please choose a supplier to update");
                    return;
                }

                long supplierId;
                try {
                    supplierId = Long.parseLong(idRaw.trim());
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Invalid supplier id");
                    return;
                }

                SupplierDAO supplierDAO = new SupplierDAO();
                try {
                    Supplier s = supplierDAO.getById(supplierId);
                    if (s == null) {
                        response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Supplier not found");
                        return;
                    }
                    request.setAttribute("supplier", s);
                } catch (SQLException ex) {
                    LOG.log(Level.SEVERE, "Database error while loading supplier", ex);
                    request.setAttribute("msg", "Database error while loading supplier.");
                }
                break;
            }

            case "supplier_inactive": {
                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Please select a supplier");
                    return;
                }

                long supplierId = Long.parseLong(idRaw.trim());

                SupplierDAO supplierDAO = new SupplierDAO();
                Supplier supplier = supplierDAO.getById(supplierId);

                if (supplier == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Supplier not found");
                    return;
                }

                request.setAttribute("supplier", supplier);
                break;
            }

            case "view_history": {
                String sidRaw = request.getParameter("supplierId");
                if (sidRaw == null || sidRaw.isBlank()) {
                    sidRaw = request.getParameter("id");
                }
                if (sidRaw == null || sidRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Please select a supplier");
                    return;
                }

                long supplierId;
                try {
                    supplierId = Long.parseLong(sidRaw.trim());
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Invalid supplier id");
                    return;
                }

                String q = request.getParameter("q");
                String status = request.getParameter("status");
                String fromRaw = request.getParameter("from");
                String toRaw = request.getParameter("to");

                java.sql.Date fromDate = null;
                java.sql.Date toDate = null;

                try {
                    if (fromRaw != null && !fromRaw.isBlank()) {
                        fromDate = java.sql.Date.valueOf(fromRaw.trim());
                    }
                } catch (Exception ignore) {
                }
                try {
                    if (toRaw != null && !toRaw.isBlank()) {
                        toDate = java.sql.Date.valueOf(toRaw.trim());
                    }
                } catch (Exception ignore) {
                }

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }
                int pageSize = 5;

                SupplierDAO supplierDAO = new SupplierDAO();
                try {
                    Supplier sup = supplierDAO.getById(supplierId);
                    if (sup == null) {
                        response.sendRedirect(request.getContextPath() + "/home?p=view_supplier&msg=Supplier not found");
                        return;
                    }

                    int totalItems = supplierDAO.countImportReceiptsHistory(supplierId, q, fromDate, toDate, status);
                    int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                    if (totalPages < 1) {
                        totalPages = 1;
                    }
                    if (page > totalPages) {
                        page = totalPages;
                    }

                    List<SupplierReceiptHistoryItem> receipts
                            = supplierDAO.searchImportReceiptsHistory(supplierId, q, fromDate, toDate, status, page, pageSize);

                    request.setAttribute("supplier", sup);
                    request.setAttribute("receipts", receipts);

                    request.setAttribute("q", q);
                    request.setAttribute("status", status);
                    request.setAttribute("from", fromRaw);
                    request.setAttribute("to", toRaw);

                    request.setAttribute("page", page);
                    request.setAttribute("pageSize", pageSize);
                    request.setAttribute("totalItems", totalItems);
                    request.setAttribute("totalPages", totalPages);

                } catch (SQLException ex) {
                    LOG.log(Level.SEVERE, "Database error while loading transaction history", ex);
                    request.setAttribute("msg", "Database error while loading transaction history.");
                    request.setAttribute("receipts", Collections.emptyList());
                }
                break;
            }
            // =========================
// EXPORT REQUEST (MANAGER + SALE)
// =========================
            case "export-request-list": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !(roleName.equalsIgnoreCase("MANAGER")
                        || roleName.equalsIgnoreCase("SALE")
                        || roleName.equalsIgnoreCase("STAFF"))) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                Integer userId = (Integer) request.getSession().getAttribute("userId");
                ExportRequestDAO dao = new ExportRequestDAO();

                String q = request.getParameter("q");
                String reqDateRaw = request.getParameter("reqDate");
                String expDateRaw = request.getParameter("expDate");

                java.sql.Date reqDate = null, expDate = null;
                try {
                    if (reqDateRaw != null && !reqDateRaw.isBlank()) {
                        reqDate = java.sql.Date.valueOf(reqDateRaw.trim());
                    }
                } catch (Exception ignore) {
                }
                try {
                    if (expDateRaw != null && !expDateRaw.isBlank()) {
                        expDate = java.sql.Date.valueOf(expDateRaw.trim());
                    }
                } catch (Exception ignore) {
                }

                int page = parseInt(request.getParameter("page"), 1);
                int pageSize = 10;

                boolean onlyMine = roleName.equalsIgnoreCase("SALE");
                Long requestedBy = null;
                if (onlyMine) {
                    if (userId == null) {
                        response.sendRedirect(request.getContextPath() + "/login.jsp");
                        return;
                    }
                    requestedBy = userId.longValue();
                }

                int totalItems = dao.count(q, reqDate, expDate, requestedBy);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
                    totalPages = 1;
                }

                if (page < 1) {
                    page = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                int offset = (page - 1) * pageSize;

                List<ExportRequest> list = dao.list(q, reqDate, expDate, requestedBy, offset, pageSize);

                request.setAttribute("erList", list);
                request.setAttribute("q", q);
                request.setAttribute("reqDate", reqDateRaw);
                request.setAttribute("expDate", expDateRaw);

                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalItems", totalItems);
                request.setAttribute("totalPages", totalPages);
                break;
            }
            case "export-request-detail": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !(roleName.equalsIgnoreCase("MANAGER")
                        || roleName.equalsIgnoreCase("SALE")
                        || roleName.equalsIgnoreCase("STAFF"))) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=export-request-list&msg=Missing id");
                    return;
                }
                long requestId;
                try {
                    requestId = Long.parseLong(idRaw.trim());
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/home?p=export-request-list&msg=Invalid id");
                    return;
                }

                ExportRequestDAO dao = new ExportRequestDAO();
                ExportRequest header = dao.getHeader(requestId);
                if (header == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=export-request-list&msg=Request not found");
                    return;
                }

                // ✅ Sale chỉ xem request của mình
                if (roleName.equalsIgnoreCase("SALE")) {
                    Integer userId = (Integer) request.getSession().getAttribute("userId");
                    if (userId == null || header.getCreatedBy() != userId.longValue()) {
                        response.sendError(403, "Forbidden");
                        return;
                    }
                }

                List<ExportRequestItem> items = dao.listItems(requestId);

                request.setAttribute("erHeader", header);
                request.setAttribute("erItems", items);
                break;
            }
            case "create-export-request": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !roleName.equalsIgnoreCase("SALE")) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                ProductDAO pdao = new ProductDAO();
                ProductSkuDAO skdao = new ProductSkuDAO();
                ExportRequestCreateDAO dao = new ExportRequestCreateDAO();

                request.setAttribute("erProducts", pdao.listForExportRequest()); // ✅ List<Product>
                request.setAttribute("erSkus", skdao.listActive());

                try (Connection con = DBContext.getConnection()) {
                    request.setAttribute("erCreateCode", dao.generateRequestCode(con));
                }

                String createdByName = String.valueOf(request.getSession().getAttribute("fullName"));
                request.setAttribute("erCreatedByName", createdByName);

                request.setAttribute("erRequestDateDefault", LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI));
                break;
            }
            case "create-import-request": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !"SALE".equalsIgnoreCase(roleName)) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                ProductDAO pdao = new ProductDAO();
                ProductSkuDAO skdao = new ProductSkuDAO();
                ImportRequestCreateDAO dao = new ImportRequestCreateDAO();

                request.setAttribute("irProducts", pdao.listForExportRequest());
                request.setAttribute("irSkus", skdao.listActive());

                try (Connection con = DBContext.getConnection()) {
                    request.setAttribute("irCreateCode", dao.generateRequestCode(con));
                }

                // created by name
                HttpSession session = request.getSession(false);
                String createdByName = "Sale User";
                if (session != null && session.getAttribute("fullName") != null) {
                    String x = String.valueOf(session.getAttribute("fullName")).trim();
                    if (!x.isBlank() && !"null".equalsIgnoreCase(x)) {
                        createdByName = x;
                    }
                }
                request.setAttribute("irCreatedByName", createdByName);

                request.setAttribute("irRequestDateDefault",
                        LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI));

                break;
            }
            case "import-request-list": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !(roleName.equalsIgnoreCase("MANAGER")
                        || roleName.equalsIgnoreCase("SALE")
                        || roleName.equalsIgnoreCase("STAFF"))) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                Integer userId = (Integer) request.getSession().getAttribute("userId");
                if (userId == null) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    return;
                }

                ImportRequestDAO dao = new ImportRequestDAO();

                String q = request.getParameter("q");
                String reqDateRaw = request.getParameter("reqDate");
                String expDateRaw = request.getParameter("expDate");

                java.sql.Date reqDate = null, expDate = null;
                try {
                    if (reqDateRaw != null && !reqDateRaw.isBlank()) {
                        reqDate = java.sql.Date.valueOf(reqDateRaw.trim());
                    }
                } catch (Exception ignore) {
                }
                try {
                    if (expDateRaw != null && !expDateRaw.isBlank()) {
                        expDate = java.sql.Date.valueOf(expDateRaw.trim());
                    }
                } catch (Exception ignore) {
                }

                int page = parseInt(request.getParameter("page"), 1);
                int pageSize = 10;
                if (page < 1) {
                    page = 1;
                }

                Long requestedBy = null;
                if (roleName.equalsIgnoreCase("SALE")) {
                    requestedBy = userId.longValue();
                }

                int totalItems = dao.count(q, reqDate, expDate, requestedBy);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                int offset = (page - 1) * pageSize;

                List<ImportRequest> list = dao.list(q, reqDate, expDate, requestedBy, offset, pageSize);

                request.setAttribute("irList", list);
                request.setAttribute("q", q);
                request.setAttribute("reqDate", reqDateRaw);
                request.setAttribute("expDate", expDateRaw);
                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalItems", totalItems);
                request.setAttribute("totalPages", totalPages);
                break;
            }
            case "import-request-detail": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !(roleName.equalsIgnoreCase("SALE")
                        || roleName.equalsIgnoreCase("MANAGER")
                        || roleName.equalsIgnoreCase("STAFF"))) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=import-request-list&msg=Missing id");
                    return;
                }

                long requestId;
                try {
                    requestId = Long.parseLong(idRaw.trim());
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/home?p=import-request-list&msg=Invalid id");
                    return;
                }

                ImportRequestDAO dao = new ImportRequestDAO();

                ImportRequest header = dao.getHeader(requestId);
                if (header == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=import-request-list&msg=Request not found");
                    return;
                }

                // ✅ SALE chỉ được xem request của mình
                if (roleName.equalsIgnoreCase("SALE")) {
                    Integer userId = (Integer) request.getSession().getAttribute("userId");
                    if (userId == null || header.getCreatedBy() != userId.longValue()) {
                        response.sendError(403, "Forbidden");
                        return;
                    }
                }

                List<ImportRequestItem> items = dao.listItems(requestId);

                request.setAttribute("irHeader", header);
                request.setAttribute("irItems", items);
                break;
            }
            case "request-delete-import-receipt": {
                String importIdStr = request.getParameter("id");
                if (importIdStr == null || importIdStr.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=import-receipt-list&err=Missing+import+ID");
                    return;
                }

                long importId = Long.parseLong(importIdStr.trim());

                ImportReceiptDeleteRequestDAO dao = new ImportReceiptDeleteRequestDAO();
                ImportReceiptDeleteRequest importInfo = dao.getImportInfoForRequest(importId);

                if (importInfo == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=import-receipt-list&err=Import+receipt+not+found");
                    return;
                }

                request.setAttribute("importInfo", importInfo);
                request.setAttribute("currentUser", authUser.getFullName());
                break;
            }
            case "request-delete-import-receipt-list": {
                String importCodeSearch = request.getParameter("q");
                String transactionTimeStr = request.getParameter("transactionTime");

                java.sql.Date searchDate = null;
                if (transactionTimeStr != null && !transactionTimeStr.trim().isEmpty()) {
                    try {
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                        sdf.setLenient(false);
                        java.util.Date utilDate = sdf.parse(transactionTimeStr.trim());
                        searchDate = new java.sql.Date(utilDate.getTime());
                    } catch (Exception e) {
                        // ignore
                    }
                }

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }
                int pageSize = 10;

                ImportReceiptDeleteRequestDAO dao = new ImportReceiptDeleteRequestDAO();

                int totalItems = dao.countRequests(importCodeSearch, searchDate);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                List<ImportReceiptDeleteRequest> requests = dao.listRequests(importCodeSearch, searchDate, page, pageSize);

                request.setAttribute("requests", requests);
                request.setAttribute("q", importCodeSearch);
                request.setAttribute("transactionTime", transactionTimeStr);
                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalItems", totalItems);
                break;
            }
            default:
                break;
        }
    }

    private int parseInt(String raw, int def) {
        try {
            if (raw == null || raw.isBlank()) {
                return def;
            }
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private String resolveSidebar(String role) {
        switch (role) {
            case "ADMIN":
                return "sidebar_admin.jsp";
            case "MANAGER":
                return "sidebar_manager.jsp";
            case "SALE":
                return "sidebar_sales.jsp";
            default:
                return "sidebar_staff.jsp";
        }
    }

    private String resolveContent(String role, String p) {
        if (role == null) {
            role = "";
        }
        if (p == null) {
            p = "";
        }
        role = role.toUpperCase();

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
                    case "my-profile":
                    case "profile":
                        return "view_profile.jsp";
                    case "change-password":
                    case "change_password":
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
                    case "product-add":
                        return "add_product.jsp";
                    case "product-list":
                        return "product_list.jsp";
                    case "user-list":
                        return "user_list.jsp";
                    case "user-detail":
                        return "view_user_information.jsp";
                    case "sku-add":
                        return "add_sku.jsp";

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
                    case "product-detail":
                        return "product_detail.jsp";
                    case "add_supplier":
                        return "add_supplier.jsp";
                    case "view_supplier":
                        return "supplier_list.jsp";
                    case "supplier_detail":
                        return "supplier_detail.jsp";
                    case "update_supplier":
                        return "update_supplier.jsp";
                    case "supplier_inactive":
                        return "inactive_supplier.jsp";
                    case "view_history":
                        return "supplier_history.jsp";
                    case "import-receipt-detail":
                        return "view_import_detail.jsp";
                    case "create-import-receipt":
                        return "create_import_receipt.jsp";
                    case "import-receipt-list":
                        return "import_receipt_list.jsp";
                    case "request-delete-import-receipt-list":
                        return "request_delete_import_receipt_list.jsp";

                    case "import-request-list":
                        return "view_import_request_list.jsp";
                    case "import-request-detail":
                        return "view_import_request_detail.jsp";

                    case "export-request-list":
                        return "view_export_request_list.jsp";
                    case "export-request-detail":
                        return "view_export_request_detail.jsp";
                    case "export-receipt-list":
                        return "export_receipt_list.jsp";
                    case "export-receipt-detail":
                        return "export_receipt_detail.jsp";

                    case "my-profile":
                    case "profile":
                        return "view_profile.jsp";
                    case "change-password":
                    case "change_password":
                        return "change_password.jsp";
                    default:
                        return null;
                }

            case "SALE":
                switch (p) {
                    case "dashboard":
                        return "sales_dashboard.jsp";
                    case "view_supplier":
                        return "supplier_list.jsp";
                    case "supplier_detail":
                        return "supplier_detail.jsp";
                    case "my-profile":
                    case "profile":
                        return "view_profile.jsp";
                    case "change-password":
                    case "change_password":
                        return "change_password.jsp";

                    case "create-export-request":
                        return "create_export_request.jsp";
                    case "export-request-list":
                        return "view_export_request_list.jsp";
                    case "export-request-detail":
                        return "view_export_request_detail.jsp";
                    case "export-request-edit":
                        return "export_request_edit.jsp";
                    case "create-import-request":
                        return "create_import_request.jsp";
                    case "import-request-list":
                        return "view_import_request_list.jsp";
                    case "import-request-detail":
                        return "view_import_request_detail.jsp";
                    default:
                        return null;
                }

            default: // STAFF
                switch (p) {
                    case "dashboard":
                        return "staff_dashboard.jsp";

                    case "create-import-receipt":
                        return "create_import_receipt.jsp";
                    case "import-receipt-list":
                        return "import_receipt_list.jsp";
                    case "request-delete-import-receipt":
                        return "request_delete_import_receipt.jsp";
                    case "create-export-request":
                        return "create_export_request.jsp";
                    case "export-request-list":
                        return "view_export_request_list.jsp";
                    case "export-request-detail":
                        return "view_export_request_detail.jsp";
                    case "export-receipt-list":
                        return "export_receipt_list.jsp";
                    case "create-export-receipt":
                        return "create_export_receipt.jsp";
                    case "export-receipt-detail":
                        return "export_receipt_detail.jsp";
                    case "import-request-list":
                        return "view_import_request_list.jsp";
                    case "import-request-detail":
                        return "view_import_request_detail.jsp";
                    case "view_supplier":
                        return "supplier_list.jsp";
                    case "supplier_detail":
                        return "supplier_detail.jsp";

                    case "brand-list":
                        return "brand_list.jsp";
                    case "brand-detail":
                        return "brand_detail.jsp";

                    case "my-profile":
                    case "profile":
                        return "view_profile.jsp";
                    case "change-password":
                    case "change_password":
                        return "change_password.jsp";

                    default:
                        return null;
                }
        }
    }
}