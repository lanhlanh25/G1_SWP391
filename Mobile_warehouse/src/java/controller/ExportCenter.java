package controller;

/**
 *
 * @author Admin
 */
import dal.BrandDAO;
import dal.BrandStatsDAO;
import dal.CodeGeneratorDAO;
import dal.DBContext;
import dal.ExportReceiptReportDAO;
import dal.ImportReceiptReportDAO;
import dal.InventoryReportDAO;
import dal.LowStockReportDAO;
import dal.ReportRequestDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.*;
import util.ExcelExportUtil;
import util.PdfExportUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import org.openpdf.text.PageSize;

@WebServlet(name = "ExportCenterServlet", urlPatterns = {"/export-center"})
public class ExportCenter extends HttpServlet {

    private static final int PREVIEW_SIZE = 50;
    private static final int EXPORT_MAX_ROWS = 10000;
    private static final int LOW_THRESHOLD = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User u = (session == null) ? null : (User) session.getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
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

        if (!"MANAGER".equals(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        String reportType = nv(request.getParameter("reportType"), "inventory");
        String fromRaw = trim(request.getParameter("from"));
        String toRaw = trim(request.getParameter("to"));
        String brandIdRaw = trim(request.getParameter("brandId"));
        String keyword = trim(request.getParameter("keyword"));
        String stockStatus = trim(request.getParameter("ropStatus"));
        String format = nv(request.getParameter("format"), "xlsx");
        String detailLevel = nv(request.getParameter("detailLevel"), "detail");
        String pdfOrientation = nv(request.getParameter("pdfOrientation"), "landscape");
        String action = nv(request.getParameter("action"), "");

        request.setAttribute("reportType", reportType);
        request.setAttribute("from", fromRaw == null ? "" : fromRaw);
        request.setAttribute("to", toRaw == null ? "" : toRaw);
        request.setAttribute("brandId", brandIdRaw == null ? "" : brandIdRaw);
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        request.setAttribute("ropStatus", stockStatus == null ? "" : stockStatus);
        request.setAttribute("format", format);
        request.setAttribute("detailLevel", detailLevel);
        request.setAttribute("pdfOrientation", pdfOrientation);

        try {
            BrandDAO brandDAO = new BrandDAO();
            request.setAttribute("allBrands", brandDAO.list(null, "active", "name", "ASC", 1, 1000));
        } catch (Exception e) {
            request.setAttribute("allBrands", Collections.emptyList());
        }

        try {
            if ("export".equalsIgnoreCase(action)) {
                ExportPayload payload = buildPayload(
                        reportType, fromRaw, toRaw, brandIdRaw, keyword, stockStatus, detailLevel, 1, EXPORT_MAX_ROWS
                );

                String reportCode;
                String fileName;
                String reportDbType = mapReportType(reportType);
                Date fromDate = parseDate(fromRaw);
                Date toDate = parseDate(toRaw);

                try (Connection con = DBContext.getConnection()) {
                    CodeGeneratorDAO codeDAO = new CodeGeneratorDAO();
                    ReportRequestDAO reportDAO = new ReportRequestDAO();

                    reportCode = codeDAO.generateReportCode(con);

                    String baseName = safeFileName(payload.reportTitle);
                    if ("pdf".equalsIgnoreCase(format)) {
                        fileName = baseName + "_" + reportCode + ".pdf";
                    } else {
                        fileName = baseName + "_" + reportCode + ".xlsx";
                    }

                    reportDAO.createGeneratedReport(
                            con,
                            reportCode,
                            reportDbType,
                            fromDate,
                            toDate,
                            u.getUserId(),
                            fileName,
                            "Export Center " + format.toUpperCase() + " - " + payload.reportTitle
                    );
                }

                if ("pdf".equalsIgnoreCase(format)) {
                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

                    boolean landscape = "landscape".equalsIgnoreCase(pdfOrientation);
                    PdfExportUtil.export(
                            response.getOutputStream(),
                            reportCode,
                            payload.reportTitle,
                            payload.filterLines,
                            payload.summaryLines,
                            payload.headers,
                            payload.rows,
                            landscape ? PageSize.A4.rotate() : PageSize.A4
                    );
                    return;
                } else {
                    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

                    ExcelExportUtil.export(
                            response.getOutputStream(),
                            reportCode,
                            payload.reportTitle,
                            payload.filterLines,
                            payload.summaryLines,
                            payload.headers,
                            payload.rows
                    );
                    return;
                }
            }

            if ("preview".equalsIgnoreCase(action)) {
                ExportPayload payload = buildPayload(
                        reportType, fromRaw, toRaw, brandIdRaw, keyword, stockStatus, detailLevel, 1, PREVIEW_SIZE
                );

                request.setAttribute("previewTitle", payload.reportTitle);
                request.setAttribute("filterLines", payload.filterLines);
                request.setAttribute("summaryLines", payload.summaryLines);
                request.setAttribute("previewHeaders", payload.headers);
                request.setAttribute("previewRows", payload.rows);
            }

        } catch (Exception e) {
            request.setAttribute("err", "Export center error: " + e.getMessage());
        }

        request.setAttribute("sidebarPage", "sidebar_manager.jsp");
        request.setAttribute("contentPage", "export_center.jsp");
        request.setAttribute("currentPage", "export-center");
        request.setAttribute("role", "MANAGER");
        request.getRequestDispatcher("homepage.jsp").forward(request, response);
    }

    private ExportPayload buildPayload(
            String reportType,
            String fromRaw,
            String toRaw,
            String brandIdRaw,
            String keyword,
            String stockStatus,
            String detailLevel,
            int page,
            int pageSize
    ) throws Exception {

        Date from = parseDate(fromRaw);
        Date to = parseDate(toRaw);
        Long brandId = parseLong(brandIdRaw);

        ExportPayload p = new ExportPayload();
        p.generatedAt = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        p.filterLines.put("Generated At", p.generatedAt);
        p.filterLines.put("Detail Level", "summary".equalsIgnoreCase(detailLevel) ? "Summary" : "Detail");

        switch (reportType) {
            case "low-stock":
                p.filterLines.put("Brand", brandIdRaw == null || brandIdRaw.isBlank() ? "All Brands" : brandIdRaw);
                p.filterLines.put("Stock Status", stockStatus == null || stockStatus.isBlank() ? "All" : stockStatus);
                buildLowStockPayload(p, brandId, stockStatus, detailLevel, page, pageSize);
                break;

            case "import":
                p.filterLines.put("Date From", fromRaw == null ? "All" : fromRaw);
                p.filterLines.put("Date To", toRaw == null ? "All" : toRaw);
                buildImportPayload(p, from, to, detailLevel, page, pageSize);
                break;

            case "export":
                p.filterLines.put("Date From", fromRaw == null ? "All" : fromRaw);
                p.filterLines.put("Date To", toRaw == null ? "All" : toRaw);
                buildExportPayload(p, from, to, detailLevel, page, pageSize);
                break;

            case "brand-statistic":
                p.filterLines.put("Date From", fromRaw == null ? "All" : fromRaw);
                p.filterLines.put("Date To", toRaw == null ? "All" : toRaw);
                p.filterLines.put("Brand", brandIdRaw == null || brandIdRaw.isBlank() ? "All Brands" : brandIdRaw);
                buildBrandStatisticPayload(p, from, to, brandId, detailLevel, page, pageSize);
                break;

            case "inventory":
            default:
                p.filterLines.put("Date From", fromRaw == null ? "All" : fromRaw);
                p.filterLines.put("Date To", toRaw == null ? "All" : toRaw);
                p.filterLines.put("Brand", brandIdRaw == null || brandIdRaw.isBlank() ? "All Brands" : brandIdRaw);
                p.filterLines.put("Keyword", keyword == null || keyword.isBlank() ? "-" : keyword);
                buildInventoryPayload(p, from, to, brandId, keyword, detailLevel, page, pageSize);
                break;
        }

        return p;
    }

    private void buildInventoryPayload(
            ExportPayload p,
            Date from,
            Date to,
            Long brandId,
            String keyword,
            String detailLevel,
            int page,
            int pageSize
    ) throws Exception {

        InventoryReportDAO dao = new InventoryReportDAO();
        Map<String, Integer> summary = dao.getSummary(from, to, brandId);
        List<InventoryReportRow> rows = dao.list(from, to, brandId, keyword, page, pageSize);

        p.reportTitle = "Inventory Report";
        p.summaryLines.put("Opening Stock", String.valueOf(summary.getOrDefault("totalOpening", 0)));
        p.summaryLines.put("Total Import", String.valueOf(summary.getOrDefault("totalImport", 0)));
        p.summaryLines.put("Total Export", String.valueOf(summary.getOrDefault("totalExport", 0)));
        p.summaryLines.put("Closing Stock", String.valueOf(summary.getOrDefault("totalClosing", 0)));
        p.summaryLines.put("Variance", String.valueOf(summary.getOrDefault("totalVariance", 0)));

        if ("summary".equalsIgnoreCase(detailLevel)) {
            p.headers = Arrays.asList("Product Code", "Product Name", "Brand", "Closing Stock");
            for (InventoryReportRow r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getProductCode()),
                        nn(r.getProductName()),
                        nn(r.getBrandName()),
                        String.valueOf(r.getClosingQty())
                ));
            }
        } else {
            p.headers = Arrays.asList(
                    "Product Code", "Product Name", "Brand", "Unit",
                    "Opening Stock", "Import", "Export", "Closing Stock", "Variance"
            );
            for (InventoryReportRow r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getProductCode()),
                        nn(r.getProductName()),
                        nn(r.getBrandName()),
                        nn(r.getUnit()),
                        String.valueOf(r.getOpeningQty()),
                        String.valueOf(r.getImportQty()),
                        String.valueOf(r.getExportQty()),
                        String.valueOf(r.getClosingQty())
                ));
            }
        }
    }

    private void buildImportPayload(
            ExportPayload p,
            Date from,
            Date to,
            String detailLevel,
            int page,
            int pageSize
    ) throws Exception {

        ImportReceiptReportDAO dao = new ImportReceiptReportDAO();
        ImportReceiptReportSummary summary = dao.getSummary(from, to, null, null);
        List<ImportReceiptListItem> rows = dao.list(from, to, null, null, page, pageSize);

        p.reportTitle = "Import Report";
        p.summaryLines.put("Total Receipts", String.valueOf(summary.getTotalReceipts()));
        p.summaryLines.put("Total Item Quantity", String.valueOf(summary.getTotalItemQty()));
        p.summaryLines.put("Completed Count", String.valueOf(summary.getCompletedCount()));
        p.summaryLines.put("Cancelled Count", String.valueOf(summary.getCancelledCount()));

        if ("summary".equalsIgnoreCase(detailLevel)) {
            p.headers = Arrays.asList("Receipt Code", "Created Date", "Total Quantity");
            for (ImportReceiptListItem r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getImportCode()),
                        r.getReceiptDate() == null ? "" : r.getReceiptDate().toString(),
                        String.valueOf(r.getTotalQuantity())
                ));
            }
        } else {
            p.headers = Arrays.asList("Receipt Code", "Created Date", "Supplier", "Created By", "Total Quantity", "Status");
            for (ImportReceiptListItem r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getImportCode()),
                        r.getReceiptDate() == null ? "" : r.getReceiptDate().toString(),
                        nn(r.getSupplierName()),
                        nn(r.getCreatedByName()),
                        String.valueOf(r.getTotalQuantity()),
                        nn(r.getStatusUi())
                ));
            }
        }
    }

    private void buildExportPayload(
            ExportPayload p,
            Date from,
            Date to,
            String detailLevel,
            int page,
            int pageSize
    ) {

        ExportReceiptReportDAO dao = new ExportReceiptReportDAO();
        ExportReceiptReportSummary summary = dao.getSummary(from, to);
        List<ExportReceiptListItem> rows = dao.list(from, to, page, pageSize);

        p.reportTitle = "Export Report";
        p.summaryLines.put("Total Export Receipts", String.valueOf(summary.getTotalExportReceipts()));
        p.summaryLines.put("Total Item Quantity", String.valueOf(summary.getTotalItemQty()));

        if ("summary".equalsIgnoreCase(detailLevel)) {
            p.headers = Arrays.asList("Receipt Code", "Created Date", "Total Quantity");
            for (ExportReceiptListItem r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getExportCode()),
                        nn(r.getExportDateUi()),
                        String.valueOf(r.getTotalQuantity())
                ));
            }
        } else {
            p.headers = Arrays.asList("Receipt Code", "Created Date", "Created By", "Total Quantity", "Status");
            for (ExportReceiptListItem r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getExportCode()),
                        nn(r.getExportDateUi()),
                        nn(r.getCreatedByName()),
                        String.valueOf(r.getTotalQuantity()),
                        nn(r.getStatus())
                ));
            }
        }
    }

    private void buildBrandStatisticPayload(
            ExportPayload p,
            Date from,
            Date to,
            Long brandId,
            String detailLevel,
            int page,
            int pageSize
    ) throws Exception {

        BrandStatsDAO dao = new BrandStatsDAO();
        BrandStatsSummary summary = dao.getSummary(null, null, brandId, LOW_THRESHOLD, from, to);
        List<BrandStatsRow> rows = dao.listBrandStats(
                null, null, brandId, "stock", "DESC", page, pageSize, LOW_THRESHOLD, from, to
        );

        p.reportTitle = "Brand Statistic";
        p.summaryLines.put("Total Brands", String.valueOf(summary.getTotalBrands()));
        p.summaryLines.put("Total Products", String.valueOf(summary.getTotalProducts()));
        p.summaryLines.put("Total Stock Units", String.valueOf(summary.getTotalStockUnits()));
        p.summaryLines.put("Low Stock Products", String.valueOf(summary.getLowStockProducts()));
        p.summaryLines.put("Imported Units In Range", String.valueOf(summary.getImportedUnitsInRange()));
        p.summaryLines.put("Exported Units In Range", String.valueOf(summary.getExportedUnitsInRange()));

        if ("summary".equalsIgnoreCase(detailLevel)) {
            p.headers = Arrays.asList("Brand Name", "Total Products", "Total Stock");
            for (BrandStatsRow r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getBrandName()),
                        String.valueOf(r.getTotalProducts()),
                        String.valueOf(r.getTotalStockUnits())
                ));
            }
        } else {
            p.headers = Arrays.asList(
                    "Brand Name", "Status", "Total Products", "Total Stock",
                    "Low Stock Count", "Imported Units", "Exported Units"
            );
            for (BrandStatsRow r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getBrandName()),
                        r.isActive() ? "Active" : "Inactive",
                        String.valueOf(r.getTotalProducts()),
                        String.valueOf(r.getTotalStockUnits()),
                        String.valueOf(r.getLowStockProducts()),
                        String.valueOf(r.getImportedUnits()),
                        String.valueOf(r.getExportedUnits())
                ));
            }
        }
    }

    private void buildLowStockPayload(
            ExportPayload p,
            Long brandId,
            String stockStatus,
            String detailLevel,
            int page,
            int pageSize
    ) throws Exception {

        LowStockReportDAO dao = new LowStockReportDAO();

        List<LowStockReportItem> rows = dao.getLowStockReport(
                null,
                null,
                stockStatus,
                null,
                null,
                page,
                pageSize
        );

        if (brandId != null) {
            // Nếu sau này DAO có filter brand trực tiếp thì nên chuyển xuống SQL.
            // Tạm thời giữ nguyên vì dữ liệu hiện có brandName trong item.
            List<LowStockReportItem> filtered = new ArrayList<>();
            for (LowStockReportItem r : rows) {
                if (r.getBrandName() != null && !r.getBrandName().isBlank()) {
                    filtered.add(r);
                }
            }
            rows = filtered;
        }

        LowStockSummaryDTO summary = dao.getSummary();

        p.reportTitle = "Low Stock Report";
        p.summaryLines.put("Products At Or Below Threshold",
                String.valueOf(summary != null ? summary.getProductsAtOrBelowThreshold() : 0));
        p.summaryLines.put("Out Of Stock",
                String.valueOf(summary != null ? summary.getOutOfStock() : 0));
        p.summaryLines.put("Reorder Needed",
                String.valueOf(summary != null ? summary.getReorderNeeded() : 0));
        p.summaryLines.put("Total Products",
                String.valueOf(summary != null ? summary.getTotalProducts() : 0));

        if ("summary".equalsIgnoreCase(detailLevel)) {
            p.headers = Arrays.asList(
                    "Product Code",
                    "Product Name",
                    "Brand",
                    "Current Stock",
                    "Threshold",
                    "Stock Status"
            );

            for (LowStockReportItem r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getProductCode()),
                        nn(r.getProductName()),
                        nn(r.getBrandName()),
                        String.valueOf(r.getCurrentStock()),
                        String.valueOf(r.getThreshold()),
                        nn(r.getStockStatus())
                ));
            }
        } else {
            p.headers = Arrays.asList(
                    "Product Code",
                    "Product Name",
                    "Brand",
                    "Supplier",
                    "Current Stock",
                    "Threshold",
                    "Stock Status",
                    "Suggested Reorder Qty",
                    "Has Active Import Request"
            );

            for (LowStockReportItem r : rows) {
                p.rows.add(Arrays.asList(
                        nn(r.getProductCode()),
                        nn(r.getProductName()),
                        nn(r.getBrandName()),
                        nn(r.getSupplierName()),
                        String.valueOf(r.getCurrentStock()),
                        String.valueOf(r.getThreshold()),
                        nn(r.getStockStatus()),
                        String.valueOf(r.getSuggestedReorderQty()),
                        r.isHasActiveImportRequest() ? "Yes" : "No"
                ));
            }
        }
    }

    private String mapReportType(String reportType) {
        if (reportType == null) {
            return "INVENTORY";
        }

        switch (reportType.toLowerCase()) {
            case "import":
            case "export":
                return "IMPORT_EXPORT";
            case "brand-statistic":
                return "BRAND";
            case "low-stock":
                return "INVENTORY";
            case "inventory":
            default:
                return "INVENTORY";
        }
    }

    private static class ExportPayload {
        String reportTitle;
        String generatedAt;
        Map<String, String> filterLines = new LinkedHashMap<>();
        Map<String, String> summaryLines = new LinkedHashMap<>();
        List<String> headers = new ArrayList<>();
        List<List<String>> rows = new ArrayList<>();
    }

    private String safeFileName(String s) {
        return s.toLowerCase().replace(" ", "_").replaceAll("[^a-z0-9_\\-]", "");
    }

    private String nv(String s, String def) {
        return (s == null || s.isBlank()) ? def : s.trim();
    }

    private String trim(String s) {
        if (s == null) {
            return null;
        }
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private Date parseDate(String raw) {
        try {
            return raw == null ? null : Date.valueOf(raw);
        } catch (Exception e) {
            return null;
        }
    }

    private Long parseLong(String raw) {
        try {
            return raw == null ? null : Long.parseLong(raw);
        } catch (Exception e) {
            return null;
        }
    }

    private String nn(String s) {
        return s == null ? "" : s;
    }
}