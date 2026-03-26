package controller;

import dal.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
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

        if (p != null) {
            p = p.trim();
        }

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
        request.setAttribute("role", role);
        request.setAttribute("ctx", request.getContextPath());

        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }

    // ✅ ADD THIS: handle POST actions (Delete import receipt)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // load role
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            role = UserDAO.getRoleNameByUserId(u.getUserId());
            if (role == null || role.isBlank()) {
                role = "STAFF";
            }
            session.setAttribute("roleName", role);
        }
        role = role.toUpperCase();

        String p = request.getParameter("p");
        if (p != null) {
            p = p.trim();
        }
        if (p == null || p.isBlank()) {
            p = "dashboard";
        }

        String action = request.getParameter("action");
        if (action != null) {
            action = action.trim();
        }

        // ✅ only handle delete for import-receipt-list here
        if ("import-receipt-list".equalsIgnoreCase(p) && "delete".equalsIgnoreCase(action)) {

            // only MANAGER can delete directly
            if (!"MANAGER".equalsIgnoreCase(role)) {
                response.sendRedirect(buildBackImportListUrl(request, "err", "Forbidden"));
                return;
            }

            long importId;
            try {
                importId = Long.parseLong(request.getParameter("id"));
            } catch (Exception e) {
                response.sendRedirect(buildBackImportListUrl(request, "err", "Invalid id"));
                return;
            }

            try {
                ImportReceiptListDAO dao = new ImportReceiptListDAO();

                // ✅ deleteDraft() already allows DRAFT/PENDING only
                boolean ok = dao.deleteDraft(importId);

                if (ok) {
                    String ctx = request.getContextPath();
                    String status = nvl(request.getParameter("status"));
                    String from = nvl(request.getParameter("from"));
                    String to = nvl(request.getParameter("to"));

                    response.sendRedirect(request.getContextPath()
                            + "/home?p=import-receipt-list"
                            + "&q="
                            + "&status=all"
                            + "&from="
                            + "&to="
                            + "&page=1"
                            + "&msg=Deleted+successfully");
                    return;
                } else {
                    response.sendRedirect(buildBackImportListUrl(request, "err",
                            "Cannot delete (only PENDING/DRAFT receipts can be deleted)"));
                }
                return;

            } catch (Exception ex) {
                LOG.log(Level.SEVERE, "Delete import receipt failed", ex);
                response.sendRedirect(buildBackImportListUrl(request, "err", "Delete failed: " + ex.getMessage()));
                return;
            }
        }

        // If POST not supported for other pages -> go back to GET
        response.sendRedirect(request.getContextPath() + "/home?p=" + url(p));
    }

// ✅ helper: keep filter when redirect back to list
    private String buildBackImportListUrl(HttpServletRequest request, String key, String msg) {
        String ctx = request.getContextPath();

        String q = nvl(request.getParameter("q"));
        String status = nvl(request.getParameter("status"));
        String from = nvl(request.getParameter("from"));
        String to = nvl(request.getParameter("to"));
        String page = nvl(request.getParameter("page"));

        return ctx + "/home?p=import-receipt-list"
                + "&q=" + url(q)
                + "&status=" + url(status)
                + "&from=" + url(from)
                + "&to=" + url(to)
                + "&page=" + url(page)
                + "&" + key + "=" + url(msg);
    }

    private String nvl(String s) {
        return s == null ? "" : s;
    }

    private String url(String s) {
        try {
            return java.net.URLEncoder.encode(s == null ? "" : s, java.nio.charset.StandardCharsets.UTF_8);
        } catch (Exception e) {
            return "";
        }
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
            case "import-receipt-detail": {
                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=import-receipt-list&err=Missing+id");
                    return;
                }

                long id = Long.parseLong(idRaw.trim());

                ImportReceiptDetailDAO dao = new ImportReceiptDetailDAO();

                ImportReceiptDetail receipt = dao.getReceipt(id);
                if (receipt == null) {
                    request.setAttribute("err", "Receipt not found");
                    break;
                }

                List<ImportReceiptLineDetail> lines = dao.getLines(id);

                request.setAttribute("receipt", receipt);
                request.setAttribute("lines", lines);
                break;
            }

            case "variant-matrix": {
                ViewVariantMatrix.handle(request, response);
                break;
            }

            case "create-import-receipt": {
                SupplierDAO sdao = new SupplierDAO();
                ImportReceiptDAO irDao = new ImportReceiptDAO();

                request.setAttribute("suppliers", sdao.listActive());

                // Flash messages (from failed POST redirect)
                HttpSession ss = request.getSession(false);
                if (ss != null) {
                    Object ferr = ss.getAttribute("flash_err");
                    Object fmsg = ss.getAttribute("flash_msg");
                    Object fmode = ss.getAttribute("flash_mode");
                    if (ferr != null) {
                        request.setAttribute("err", String.valueOf(ferr));
                        ss.removeAttribute("flash_err");
                    }
                    if (fmsg != null) {
                        request.setAttribute("msg", String.valueOf(fmsg));
                        ss.removeAttribute("flash_msg");
                    }
                    if (fmode != null) {
                        request.setAttribute("mode", String.valueOf(fmode));
                        ss.removeAttribute("flash_mode");
                    }
                }

                try (Connection con = DBContext.getConnection()) {
                    request.setAttribute("importCode", irDao.generateImportCode(con));
                }
                request.setAttribute("receiptDateDefault",
                        LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI));

                String createdByName = "Staff";
                HttpSession ssName = request.getSession(false);
                if (ssName != null && ssName.getAttribute("fullName") != null) {
                    createdByName = String.valueOf(ssName.getAttribute("fullName"));
                } else if (authUser != null && authUser.getFullName() != null) {
                    createdByName = authUser.getFullName();
                }
                request.setAttribute("createdByName", createdByName);

                // ── Request mode: pre-fill from Import Request ──────────────
                String requestIdRaw = request.getParameter("requestId");
                if (requestIdRaw != null && !requestIdRaw.isBlank()) {
                    try {
                        long requestId = Long.parseLong(requestIdRaw.trim());
                        ImportRequestDAO irReqDao = new ImportRequestDAO();
                        ImportRequest irHeader = irReqDao.getHeader(requestId);

                        if (irHeader == null) {
                            request.setAttribute("err", "Import request not found.");
                        } else if ("COMPLETE".equalsIgnoreCase(irHeader.getStatus())) {
                            request.setAttribute("err", "This request has already been completed.");
                        } else {
                            List<ImportRequestItem> requestItems = irReqDao.listItemsForReceipt(requestId);
                            request.setAttribute("irHeader", irHeader);
                            request.setAttribute("requestItems", requestItems);
                            request.setAttribute("requestId", requestId);
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("err", "Invalid request ID.");
                    }
                    // In request mode products/skus not needed (rows are readonly)
                    request.setAttribute("products", java.util.Collections.emptyList());
                    request.setAttribute("skus", java.util.Collections.emptyList());
                } else {
                    // ── Manual mode: load products + skus for dropdowns ──────
                    ProductDAO pdao = new ProductDAO();
                    ProductSkuDAO skdao = new ProductSkuDAO();
                    request.setAttribute("products", pdao.listActive());
                    request.setAttribute("skus", skdao.listActive());
                }

                if (request.getAttribute("mode") == null) {
                    request.setAttribute("mode", "manual");
                }
                break;
            }

            // =========================
            //  CREATE EXPORT RECEIPT (FORM)
            // =========================
            case "create-export":
            case "create-export-receipt":
            case "upload-export-imeis": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !roleName.equalsIgnoreCase("STAFF")) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                ProductDAO pdao = new ProductDAO();
                ProductSkuDAO skdao = new ProductSkuDAO();
                ExportRequestDAO erDao = new ExportRequestDAO();
                ExportReceiptDAO exDao = new ExportReceiptDAO();

                // Flash messages like import
                HttpSession ss = request.getSession(false);
                if (ss != null) {
                    Object ferr = ss.getAttribute("flash_err");
                    Object fmsg = ss.getAttribute("flash_msg");
                    Object fmode = ss.getAttribute("flash_mode");

                    if (ferr != null) {
                        request.setAttribute("err", String.valueOf(ferr));
                        ss.removeAttribute("flash_err");
                    }
                    if (fmsg != null) {
                        request.setAttribute("msg", String.valueOf(fmsg));
                        ss.removeAttribute("flash_msg");
                    }
                    if (fmode != null) {
                        request.setAttribute("mode", String.valueOf(fmode));
                        ss.removeAttribute("flash_mode");
                    }
                }

                try (Connection con = DBContext.getConnection()) {
                    request.setAttribute("exportCode", exDao.generateExportCode(con));
                }

                request.setAttribute("receiptDateDefault",
                        LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI));

                String createdByName = "Staff";
                HttpSession ssName = request.getSession(false);
                if (ssName != null && ssName.getAttribute("fullName") != null) {
                    createdByName = String.valueOf(ssName.getAttribute("fullName"));
                } else if (authUser != null && authUser.getFullName() != null) {
                    createdByName = authUser.getFullName();
                }
                request.setAttribute("createdByName", createdByName);

                // requestId chuẩn hóa giống import
                String requestIdRaw = request.getParameter("requestId");
                if (requestIdRaw == null || requestIdRaw.isBlank()) {
                    requestIdRaw = request.getParameter("id"); // support link cũ
                }

                if (requestIdRaw != null && !requestIdRaw.isBlank()) {
                    try {
                        long requestId = Long.parseLong(requestIdRaw.trim());
                        ExportRequest erHeader = erDao.getHeader(requestId);

                        if (erHeader == null) {
                            request.setAttribute("err", "Export request not found.");
                        } else if ("COMPLETE".equalsIgnoreCase(erHeader.getStatus())) {
                            request.setAttribute("err", "This request has already been completed.");
                        } else {
                            List<ExportRequestItem> erItems = erDao.listItems(requestId);
                            request.setAttribute("sourceRequestId", requestId);
                            request.setAttribute("erHeader", erHeader);
                            request.setAttribute("erItems", erItems);
                        }

                        request.setAttribute("products", pdao.listActive());
                        request.setAttribute("skus", skdao.listActive());

                    } catch (NumberFormatException e) {
                        request.setAttribute("err", "Invalid request ID.");
                        request.setAttribute("products", pdao.listActive());
                        request.setAttribute("skus", skdao.listActive());
                    }
                } else {
                    request.setAttribute("products", pdao.listActive());
                    request.setAttribute("skus", skdao.listActive());
                }

                if (request.getAttribute("mode") == null) {
                    request.setAttribute("mode", "manual");
                }

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
                ExportReceiptDetailHeader receiptHeader = dao.getDetailHeader(id);
                List<ExportReceiptDetailLine> lines = dao.getDetailLines(id);

                request.setAttribute("receiptHeader", receiptHeader);
                request.setAttribute("lines", lines);
                break;
            }

            // =========================
            //  EXPORT RECEIPT LIST  (FIXED + tabCounts + normalize status)
            // =========================
            case "export-receipt-list": {
                ExportReceiptList.handle(request);
                break;
            }
            // =========================
            //  DASHBOARD
            // =========================
            case "dashboard": {
                String roleName = (String) request.getSession().getAttribute("roleName");

                if (roleName != null && roleName.equalsIgnoreCase("MANAGER")) {
                    String approvalType = request.getParameter("approvalType");
                    if (approvalType == null || approvalType.isBlank()) {
                        approvalType = "import";
                    }

                    ImportRequestDAO importRequestDAO = new ImportRequestDAO();
                    ExportRequestDAO exportRequestDAO = new ExportRequestDAO();
                    ImportReceiptDeleteRequestDAO deleteDAO = new ImportReceiptDeleteRequestDAO();
                    ImportReceiptListDAO importReceiptListDAO = new ImportReceiptListDAO();
                    ExportReceiptDAO exportReceiptDAO = new ExportReceiptDAO();
                    LowStockReportDAO lowStockDAO = new LowStockReportDAO();

                    // =========================
                    // APPROVAL COUNTS
                    // =========================
                    int pendingImportCount = importRequestDAO.countByStatus("NEW");
                    int pendingExportCount = exportRequestDAO.countByStatus("NEW");

                    int pendingApprovals = pendingImportCount + pendingExportCount;

                    List<DashboardApprovalRow> dashboardImportRequests = new ArrayList<>();
                    List<DashboardApprovalRow> dashboardExportRequests = new ArrayList<>();
                    List<DashboardApprovalRow> dashboardDeleteRequests = new ArrayList<>();

                    // =========================
                    // IMPORT REQUESTS 
                    // =========================
                    List<ImportRequest> importRequests = importRequestDAO.listByStatus("NEW", 5);
                    for (ImportRequest r : importRequests) {

                        dashboardImportRequests.add(new DashboardApprovalRow(
                                r.getRequestId(),
                                r.getRequestCode(),
                                r.getCreatedByName(),
                                formatDateTime(r.getRequestDate()),
                                r.getStatus()
                        ));
                    }

                    // =========================
                    // EXPORT REQUESTS 
                    // =========================
                    List<ExportRequest> exportRequests = exportRequestDAO.listByStatus("NEW", 5);
                    for (ExportRequest r : exportRequests) {

                        dashboardExportRequests.add(new DashboardApprovalRow(
                                r.getRequestId(),
                                r.getRequestCode(),
                                r.getCreatedByName(),
                                formatDateTime(r.getRequestDate()),
                                r.getStatus()
                        ));
                    }

                    // =========================
                    // TODAY IMPORTED UNITS
                    // =========================
                    LocalDate today = LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"));

                    List<ImportReceiptListItem> todayImports = importReceiptListDAO.list(null, "all", today, today, 1, 200);
                    int todayImportedUnits = 0;
                    for (ImportReceiptListItem item : todayImports) {
                        todayImportedUnits += item.getTotalQuantity();
                    }

                    // =========================
                    // TODAY EXPORTED UNITS
                    // =========================
                    List<ExportReceiptListItem> todayExports = exportReceiptDAO.list(
                            null,
                            "ALL",
                            java.sql.Date.valueOf(today),
                            java.sql.Date.valueOf(today),
                            1,
                            200
                    );

                    int todayExportedUnits = 0;
                    for (ExportReceiptListItem item : todayExports) {
                        todayExportedUnits += item.getTotalQty();
                    }

                    // =========================
                    // LOW STOCK SUMMARY + DASHBOARD ROWS
                    // =========================
                    LowStockSummaryDTO lowStockSummary = lowStockDAO.getSummary();
                    List<LowStockReportItem> dashboardLowStockRows
                            = lowStockDAO.getLowStockReport(null, null, null, null, null, 1, 5);

                    // =========================
                    // RECENT ACTIVITIES
                    // =========================
                    List<DashboardActivityRow> dashboardRecentActivities = new ArrayList<>();

                    List<ImportReceiptListItem> recentImports = importReceiptListDAO.list(null, "all", null, null, 1, 5);
                    for (ImportReceiptListItem item : recentImports) {
                        if (item.getReceiptDate() != null) {
                            dashboardRecentActivities.add(new DashboardActivityRow(
                                    item.getReceiptDate(),
                                    formatTimeOnly(item.getReceiptDate()),
                                    "Import Receipt",
                                    item.getImportCode(),
                                    item.getTotalQuantity()
                            ));
                        }
                    }

                    List<ExportReceiptListItem> recentExports = exportReceiptDAO.list(null, "ALL", null, null, 1, 5);
                    for (ExportReceiptListItem item : recentExports) {
                        if (item.getExportDate() != null) {
                            dashboardRecentActivities.add(new DashboardActivityRow(
                                    item.getExportDate(),
                                    formatTimeOnly(item.getExportDate()),
                                    "Export Receipt",
                                    item.getExportCode(),
                                    item.getTotalQty()
                            ));
                        }
                    }

                    dashboardRecentActivities.sort((a, b) -> b.getSortTime().compareTo(a.getSortTime()));

                    if (dashboardRecentActivities.size() > 6) {
                        dashboardRecentActivities = new ArrayList<>(dashboardRecentActivities.subList(0, 6));
                    }
                    int lowThreshold =10;
                    // =========================
                    // SET ATTRIBUTES
                    // =========================
                    request.setAttribute("approvalType", approvalType);

                    request.setAttribute("pendingApprovals", pendingApprovals);

                    request.setAttribute("todayImportedUnits", todayImportedUnits);
                    request.setAttribute("todayExportedUnits", todayExportedUnits);

                    request.setAttribute("dashboardImportRequests", dashboardImportRequests);
                    request.setAttribute("dashboardExportRequests", dashboardExportRequests);
                    request.setAttribute("dashboardDeleteRequests", dashboardDeleteRequests);

                    request.setAttribute("lowStockProducts",
                            lowStockSummary != null ? lowStockSummary.getProductsAtOrBelowThreshold() : 0);
                    request.setAttribute("dashboardLowStockRows", dashboardLowStockRows);

                    request.setAttribute("dashboardRecentActivities", dashboardRecentActivities);

                    request.setAttribute("alertsComingSoon", true);
                    request.setAttribute("lowStockComingSoon", false);
                    request.setAttribute("lowThreshold", lowThreshold);
                    // =========================
                    // INVENTORY REPORT SUMMARY (month-to-date)
                    // =========================
                    try {
                        InventoryReportDAO irDAO = new InventoryReportDAO();
                        LocalDate firstOfMonth = today.withDayOfMonth(1);
                        java.sql.Date invFrom = java.sql.Date.valueOf(firstOfMonth);
                        java.sql.Date invTo = java.sql.Date.valueOf(today);
                        java.util.Map<String, Integer> invSummary = irDAO.getSummary(invFrom, invTo, null);

                        request.setAttribute("invTotalOpening", invSummary.getOrDefault("totalOpening", 0));
                        request.setAttribute("invTotalImport", invSummary.getOrDefault("totalImport", 0));
                        request.setAttribute("invTotalExport", invSummary.getOrDefault("totalExport", 0));
                        request.setAttribute("invTotalClosing", invSummary.getOrDefault("totalClosing", 0));
                        request.setAttribute("invTotalVariance", invSummary.getOrDefault("totalVariance", 0));
                        request.setAttribute("invMonthLabel",
                                firstOfMonth.format(DateTimeFormatter.ofPattern("MMM yyyy")));
                    } catch (Exception exInv) {
                        LOG.log(Level.WARNING, "Could not load inventory summary for dashboard", exInv);
                    }
                }
                break;
            }

            case "export-center": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !"MANAGER".equalsIgnoreCase(roleName)) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                BrandDAO dao = new BrandDAO();
                request.setAttribute("allBrands", dao.list(null, "active", "name", "ASC", 1, 1000));
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
            case "user-view": {
                String idRaw = request.getParameter("id");
                if (idRaw == null || idRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=user-list&msg=Please select a user first");
                    return;
                }

                int userId = Integer.parseInt(idRaw.trim());
                User user = userDAO.getById(userId);
                if (user == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=user-list&msg=User not found");
                    return;
                }

                String roleName = roleDAO.getRoleNameById(user.getRoleId());

                request.setAttribute("user", user);
                request.setAttribute("roleName", roleName);
                request.setAttribute("now", new java.util.Date());
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
            case "role-detail": {
                String ridRaw = request.getParameter("roleId");
                if (ridRaw == null || ridRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=role-list&msg=Please select a role first");
                    return;
                }

                int roleId = Integer.parseInt(ridRaw.trim());

                request.setAttribute("roleId", roleId);
                request.setAttribute("roleName", roleDAO.getRoleNameById(roleId));
                request.setAttribute("rolePerms", rpDAO.getPermissionsByRoleId(roleId));
                break;
            }
            case "role-permissions": {
                String ridRaw = request.getParameter("roleId");
                if (ridRaw == null || ridRaw.isBlank()) {
                    response.sendRedirect(request.getContextPath() + "/home?p=role-list&msg=Please select a role first");
                    return;
                }

                int roleId = Integer.parseInt(ridRaw.trim());

                request.setAttribute("roleId", roleId);
                request.setAttribute("roleName", roleDAO.getRoleNameById(roleId));
                request.setAttribute("allPerms", rpDAO.getAllPermissions());
                request.setAttribute("checked", rpDAO.getPermissionIdsByRole(roleId));
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
                request.setAttribute("products", dao.listForSkuSelect());

                HttpSession ss = request.getSession(false);

                if (ss != null) {

                    Object ferr = ss.getAttribute("flash_errors");

                    if (ferr != null) {
                        request.setAttribute("errors", ferr);
                        ss.removeAttribute("flash_errors");
                    }

                }

                break;
            }

            case "product-add": {

                if (request.getAttribute("brands") == null) {
                    request.setAttribute("brands",
                            brandDAO.list(null, "active", "name", "ASC", 1, 1000));
                }

                break;
            }

            case "product-list": {
                ManagerViewProductList.handle(request);
                break;
            }

            case "product-detail": {
                ManagerViewProductDetail.handle(request, response);
                break;
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

                LocalDate today = LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"));
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
                int lowThreshold = 10;

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

                int lowThreshold = 10;

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
                LocalDate today = LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"));
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

                BrandStatsSummary detailSummary = statsDAO.getBrandDetailSummary(brandId, 10, fromDate, toDate);
                List<ProductStatsRow> products = statsDAO.listBrandDetail(brandId, lowThreshold, fromDate, toDate, dSortBy, dSortOrder);

                request.setAttribute("brand", b);
                request.setAttribute("products", products);
                request.setAttribute("dSortBy", dSortBy);
                request.setAttribute("dSortOrder", dSortOrder);
                request.setAttribute("detailSummary", detailSummary);
                request.setAttribute("range", range);
                request.setAttribute("lowThreshold", lowThreshold);
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
            case "import-receipt-list": {

                String action = request.getParameter("action");

                if ("export".equalsIgnoreCase(action)) {
                    response.setContentType("text/csv");
                    response.setHeader("Content-Disposition", "attachment; filename=import_receipts.csv");

                    PrintWriter out = response.getWriter();

                    // ✅ FIX: Declare dao before using it
                    ImportReceiptListDAO dao = new ImportReceiptListDAO();

                    // ✅ FIX: Add 'status' parameter (required by ImportReceiptListDAO.list())
                    List<ImportReceiptListItem> list = dao.list(null, "all", null, null, 1, 1000);

                    out.println("Import Code,Supplier,Created By,Created Date,Total Qty,Status");

                    for (ImportReceiptListItem r : list) {
                        out.println(r.getImportCode() + ","
                                + (r.getSupplierName() != null ? r.getSupplierName() : "") + ","
                                + (r.getCreatedByName() != null ? r.getCreatedByName() : "") + ","
                                + (r.getReceiptDate() != null ? r.getReceiptDate() : "") + ","
                                + r.getTotalQuantity() + ","
                                + (r.getStatus() != null ? r.getStatus() : ""));
                    }

                    out.flush();
                    return;
                }

                // ✅ Use ImportReceiptList handler for normal list view
                ImportReceiptList.handle(request);
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
                if (status != null) {
                    status = status.trim().toUpperCase();
                    if (status.isEmpty() || "ALL".equals(status)) {
                        status = null;
                    }
                }
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
                String status = request.getParameter("status");
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

                int totalItems = dao.count(q, status, reqDate, expDate, requestedBy);
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

                List<ExportRequest> list = dao.list(q, status, reqDate, expDate, requestedBy, offset, pageSize);

                request.setAttribute("erList", list);
                request.setAttribute("q", q);
                request.setAttribute("status", status);
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
                CodeGeneratorDAO codeDAO = new CodeGeneratorDAO();

                request.setAttribute("erProducts", pdao.listActive());
                request.setAttribute("erSkus", skdao.listActive());

                try (Connection con = DBContext.getConnection()) {
                    request.setAttribute("erCreateCode", codeDAO.generateExportRequestCode(con));
                }

                String createdByName = String.valueOf(request.getSession().getAttribute("fullName"));
                request.setAttribute("erCreatedByName", createdByName);

                request.setAttribute("erRequestDateDefault", LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI));
                request.setAttribute("today", LocalDate.now().toString());
                break;
            }
            case "create-import-request": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !(roleName.equalsIgnoreCase("SALE") || roleName.equalsIgnoreCase("MANAGER"))) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                ProductDAO pdao = new ProductDAO();
                ProductSkuDAO skdao = new ProductSkuDAO();
                CodeGeneratorDAO codeDAO = new CodeGeneratorDAO();

                request.setAttribute("irProducts", pdao.listActive());
                request.setAttribute("irSkus", skdao.listActive());

                try (Connection con = DBContext.getConnection()) {
                    request.setAttribute("irCreateCode", codeDAO.generateImportRequestCode(con));
                }

                HttpSession session = request.getSession(false);
                String createdByName = "User";
                if (session != null && session.getAttribute("fullName") != null) {
                    String x = String.valueOf(session.getAttribute("fullName")).trim();
                    if (!x.isBlank() && !"null".equalsIgnoreCase(x)) {
                        createdByName = x;
                    }
                }
                request.setAttribute("irCreatedByName", createdByName);

                request.setAttribute("irRequestDateDefault",
                        LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI));
                request.setAttribute("today", LocalDate.now().toString());

                String productIdRaw = request.getParameter("productId");
                if (productIdRaw != null && !productIdRaw.isBlank()) {
                    try {
                        long productId = Long.parseLong(productIdRaw.trim());

                        LowStockReportDAO lowStockDao = new LowStockReportDAO();
                        LowStockReportItem selectedItem = lowStockDao.getLowStockProductById(productId);

                        if (selectedItem == null) {
                            response.sendRedirect(request.getContextPath() + "/home?p=low-stock-report&err=Product+not+found");
                            return;
                        }

                        if ("OK".equalsIgnoreCase(selectedItem.getStockStatus())) {
                            response.sendRedirect(request.getContextPath() + "/home?p=low-stock-report&err=This+product+does+not+need+restocking");
                            return;
                        }

                        if (selectedItem.isHasActiveImportRequest()) {
                            response.sendRedirect(request.getContextPath() + "/home?p=low-stock-report&err=An+active+import+request+already+exists");
                            return;
                        }

                        request.setAttribute("selectedLowStockItem", selectedItem);

                        List<ProductSku> allSkuStocks = skdao.getSkuStockByProductId(productId);
                        List<ProductSku> selectedProductSkuStocks = new ArrayList<>();

                        if (allSkuStocks != null) {
                            for (ProductSku s : allSkuStocks) {
                                if (s == null) {
                                    continue;
                                }
                                String skuStatus = s.getStockStatus();
                                if ("Out Of Stock".equalsIgnoreCase(skuStatus) || "Low Stock".equalsIgnoreCase(skuStatus)) {
                                    selectedProductSkuStocks.add(s);
                                }
                            }
                        }

                        request.setAttribute("selectedProductSkuStocks", selectedProductSkuStocks);

                    } catch (Exception e) {
                        response.sendRedirect(request.getContextPath() + "/home?p=low-stock-report&err=Invalid+product");
                        return;
                    }
                }

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
                String status = request.getParameter("status");
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

                List<ImportRequest> list = dao.list(q, status, reqDate, expDate, requestedBy, offset, pageSize);

                request.setAttribute("irList", list);
                request.setAttribute("q", q);
                request.setAttribute("status", status);
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
            case "low-stock-report": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !"MANAGER".equalsIgnoreCase(roleName)) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                LowStockReportDAO dao = new LowStockReportDAO();
                SupplierDAO supplierDAO = new SupplierDAO();

                String q = request.getParameter("q");
                String stockStatus = request.getParameter("stockStatus");

                String supplierIdRaw = request.getParameter("supplierId");
                Long supplierId = null;
                try {
                    if (supplierIdRaw != null && !supplierIdRaw.isBlank()) {
                        supplierId = Long.parseLong(supplierIdRaw.trim());
                    }
                } catch (Exception e) {
                    supplierId = null;
                }

                String minStockRaw = request.getParameter("minStock");
                String maxStockRaw = request.getParameter("maxStock");

                Integer minStock = null;
                Integer maxStock = null;

                try {
                    if (minStockRaw != null && !minStockRaw.isBlank()) {
                        minStock = Integer.parseInt(minStockRaw.trim());
                    }
                } catch (Exception e) {
                    minStock = null;
                }

                try {
                    if (maxStockRaw != null && !maxStockRaw.isBlank()) {
                        maxStock = Integer.parseInt(maxStockRaw.trim());
                    }
                } catch (Exception e) {
                    maxStock = null;
                }

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }
                int pageSize = 10;

                if (minStock != null && maxStock != null && minStock > maxStock) {
                    request.setAttribute("err", "Min Stock cannot be greater than Max Stock.");
                    minStock = null;
                    maxStock = null;
                }

                int totalItems = dao.countLowStockReport(q, supplierId, stockStatus, minStock, maxStock);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                List<LowStockReportItem> rows = dao.getLowStockReport(q, supplierId, stockStatus, minStock, maxStock, page, pageSize);
                LowStockSummaryDTO summary = dao.getSummary();
                List<IdName> suppliers = supplierDAO.listActive();

                request.setAttribute("rows", rows);
                request.setAttribute("summary", summary);
                request.setAttribute("suppliers", suppliers);

                request.setAttribute("q", q);
                request.setAttribute("stockStatus", stockStatus);
                request.setAttribute("supplierId", supplierIdRaw);
                request.setAttribute("minStock", minStockRaw);
                request.setAttribute("maxStock", maxStockRaw);

                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalItems", totalItems);
                request.setAttribute("totalPages", totalPages);
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
            case "best-selling-product-statistics": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !"MANAGER".equalsIgnoreCase(roleName)) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                ManagerViewBestSellingProductStatistics.handle(request, response);
                break;
            }
            case "stock-movement-history": {
                String roleName = (String) request.getSession().getAttribute("roleName");
                if (roleName == null || !"MANAGER".equalsIgnoreCase(roleName)) {
                    response.sendError(403, "Forbidden");
                    return;
                }

                StockMovementHistoryDAO dao = new StockMovementHistoryDAO();

                String keyword = request.getParameter("keyword");
                String movementType = request.getParameter("movementType");
                String referenceCode = request.getParameter("referenceCode");
                String performedBy = request.getParameter("performedBy");
                String fromRaw = request.getParameter("from");
                String toRaw = request.getParameter("to");

                java.sql.Date from = null;
                java.sql.Date to = null;

                try {
                    if (fromRaw != null && !fromRaw.isBlank()) {
                        from = java.sql.Date.valueOf(fromRaw.trim());
                    }
                } catch (Exception e) {
                    from = null;
                }

                try {
                    if (toRaw != null && !toRaw.isBlank()) {
                        to = java.sql.Date.valueOf(toRaw.trim());
                    }
                } catch (Exception e) {
                    to = null;
                }

                if (movementType == null || movementType.isBlank()) {
                    movementType = "ALL";
                }

                int page = parseInt(request.getParameter("page"), 1);
                if (page < 1) {
                    page = 1;
                }

                int pageSize = 5;

                if (from != null && to != null && from.after(to)) {
                    request.setAttribute("err", "From Date cannot be later than To Date.");
                    from = null;
                    to = null;
                    fromRaw = "";
                    toRaw = "";
                }

                String productIdRaw = request.getParameter("productId");
                Long productId = null;
                try {
                    if (productIdRaw != null && !productIdRaw.isBlank()) {
                        productId = Long.parseLong(productIdRaw.trim());
                    }
                } catch (Exception e) {
                }

                int totalItems = dao.count(keyword, movementType, referenceCode, performedBy, from, to, productId);
                int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);
                if (totalPages < 1) {
                    totalPages = 1;
                }
                if (page > totalPages) {
                    page = totalPages;
                }

                List<StockMovementHistoryItem> rows
                        = dao.list(keyword, movementType, referenceCode, performedBy, from, to, productId, page, pageSize);

                request.setAttribute("productId", productId);
                request.setAttribute("rows", rows);

                request.setAttribute("keyword", keyword);
                request.setAttribute("movementType", movementType);
                request.setAttribute("referenceCode", referenceCode);
                request.setAttribute("performedBy", performedBy);
                request.setAttribute("from", fromRaw);
                request.setAttribute("to", toRaw);

                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalItems", totalItems);
                request.setAttribute("totalPages", totalPages);
                break;
            }
            case "admin/reset-requests": {

                List<ResetRequest> pending = userDAO.getPendingResetRequests();
                request.setAttribute("pendingRequests", pending);
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
        if (p != null) {
            p = p.trim();
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
                    case "user-view":
                        return "view_user_information.jsp";

                    case "role-list":
                        return "view_role_list.jsp";
                    case "role-add":
                        return "role_add.jsp";
                    case "role-toggle":
                        return "active_role.jsp";
                    case "role-detail":
                        return "role_detail.jsp";
                    case "role-permissions":
                        return "edit_role_permissions.jsp";

                    case "my-profile":
                    case "profile":
                        return "view_profile.jsp";

                    case "admin/reset-requests":
                        return "admin_reset_requests.jsp";

                    case "change-password":
                    case "change_password":
                        return "change_password.jsp";

                    case "brand-list":
                        return "brand_list.jsp";
                    case "brand-detail":
                        return "brand_detail.jsp";

                    default:
                        return null;
                }

            case "MANAGER":
                switch (p) {
                    case "dashboard":
                        return "manager_dashboard.jsp";
                    case "export-center":
                        return "export_center.jsp";
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
                    case "create-import-request":
                        return "create_import_request.jsp";
                    case "low-stock-report":
                        return "low_stock_report.jsp";
                    case "best-selling-product-statistics":
                        return "best_selling_product_statistics.jsp";
                    case "stock-movement-history":
                        return "stock_movement_history.jsp";
                    case "export-receipt-list":
                        return "export_receipt_list.jsp";
                    case "export-receipt-detail":
                        return "export_receipt_detail.jsp";
                    case "variant-matrix":
                        return "variant_matrix.jsp";
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

                    case "brand-list":
                        return "brand_list.jsp";
                    case "brand-detail":
                        return "brand_detail.jsp";

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
                    case "request-delete-import-receipt-list":
                        return "request_delete_import_receipt_list.jsp";
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
                    case "import-receipt-detail":
                        return "view_import_detail.jsp";
                    case "brand-list":
                        return "brand_list.jsp";
                    case "brand-detail":
                        return "brand_detail.jsp";
                    case "product-list":
                        return "product_list.jsp";
                    case "product-detail":
                        return "product_detail.jsp";
                    case "variant-matrix":
                        return "variant_matrix.jsp";

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

    private String formatDateTime(java.util.Date date) {
        if (date == null) {
            return "";
        }
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(date);
    }

    private String formatTimeOnly(java.util.Date date) {
        if (date == null) {
            return "";
        }
        return new java.text.SimpleDateFormat("HH:mm").format(date);
    }

    public static class DashboardApprovalRow {

        private long id;
        private String code;
        private String requestedBy;
        private String requestedTime;
        private String status;

        public DashboardApprovalRow(long id, String code, String requestedBy, String requestedTime, String status) {
            this.id = id;
            this.code = code;
            this.requestedBy = requestedBy;
            this.requestedTime = requestedTime;
            this.status = status;
        }

        public long getId() {
            return id;
        }

        public String getCode() {
            return code;
        }

        public String getRequestedBy() {
            return requestedBy;
        }

        public String getRequestedTime() {
            return requestedTime;
        }

        public String getStatus() {
            return status;
        }
    }

    public static class DashboardActivityRow {

        private java.util.Date sortTime;
        private String time;
        private String type;
        private String referenceCode;
        private int units;

        public DashboardActivityRow(java.util.Date sortTime, String time, String type, String referenceCode, int units) {
            this.sortTime = sortTime;
            this.time = time;
            this.type = type;
            this.referenceCode = referenceCode;
            this.units = units;
        }

        public java.util.Date getSortTime() {
            return sortTime;
        }

        public String getTime() {
            return time;
        }

        public String getType() {
            return type;
        }

        public String getReferenceCode() {
            return referenceCode;
        }

        public int getUnits() {
            return units;
        }
    }

}
