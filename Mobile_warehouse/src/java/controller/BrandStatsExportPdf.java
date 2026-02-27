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
import dal.BrandStatsDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import model.Brand;
import model.BrandStatsRow;
import model.BrandStatsSummary;
import model.ProductStatsRow;
import model.User;

// OpenPDF (add openpdf jar)
import org.openpdf.text.*;
import org.openpdf.text.pdf.*;
import org.openpdf.text.pdf.draw.LineSeparator;

@WebServlet(name = "BrandStatsExportPdf", urlPatterns = {"/manager/brand-stats-export-pdf"})
public class BrandStatsExportPdf extends HttpServlet {

    private static final DateTimeFormatter FILE_DTF = DateTimeFormatter.ofPattern("yyyyMMdd_HHmm");
    private static final DateTimeFormatter UI_DTF = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // 0) Auth
        User u = (session == null) ? null : (User) session.getAttribute("authUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 1) Role check (MANAGER only)
        String role = (String) session.getAttribute("roleName");
        if (role == null || role.isBlank()) {
            try {
                role = UserDAO.getRoleNameByUserId(u.getUserId());
                if (role == null) {
                    role = "";
                }
                session.setAttribute("roleName", role);
            } catch (Exception ignore) {
                role = "";
            }
        }
        if (!"MANAGER".equalsIgnoreCase(role)) {
            response.sendError(403, "Forbidden");
            return;
        }

        // 2) Params (LIST screen uses q/status/sortBy/sortOrder/range)
        //    DETAIL screen uses brandId + listRange + dSortBy/dSortOrder (optional)
        String q = trimOrNull(request.getParameter("q"));
        String brandStatus = trimOrNull(request.getParameter("status"));

        // LIST sort
        String sortBy = trimOrDefault(request.getParameter("sortBy"), "stock");
        String sortOrder = trimOrDefault(request.getParameter("sortOrder"), "DESC");

        // brandId is OPTIONAL now
        String brandIdRaw = trimOrNull(request.getParameter("brandId"));
        Long brandId = null;
        if (brandIdRaw != null) {
            try {
                brandId = Long.parseLong(brandIdRaw);
            } catch (Exception ignore) {
            }
        }

// Range: LIST uses "range", DETAIL often uses "listRange"
        String range = trimOrDefault(request.getParameter("range"), null);
        if (range == null) {
            range = trimOrDefault(request.getParameter("listRange"), "all");
        }

        // DETAIL sort (fallback to LIST sort if missing)
        String dSortBy = trimOrDefault(request.getParameter("dSortBy"), null);
        if (dSortBy == null) {
            dSortBy = sortBy;
        }

        String dSortOrder = trimOrDefault(request.getParameter("dSortOrder"), null);
        if (dSortOrder == null) {
            dSortOrder = sortOrder;
        }

        // 3) Range -> from/to
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
                range = "all";
                fromDate = null;
                toDate = null;
                break;
        }

        // 4) Generated by
        String generatedBy = (String) session.getAttribute("fullName");
        if (generatedBy == null || generatedBy.isBlank()) {
            generatedBy = u.getFullName();
        }
        if (generatedBy == null || generatedBy.isBlank()) {
            generatedBy = u.getUsername();
        }

        // 5) Query data
        BrandStatsDAO statsDAO = new BrandStatsDAO();
        BrandDAO brandDAO = new BrandDAO();
        int lowThreshold = 5;

        try {
            if (brandId == null) {
                // ===== LIST MODE: export all brands stats =====
                BrandStatsSummary summary = statsDAO.getSummary(q, brandStatus, null, lowThreshold, fromDate, toDate);

                int page = 1;
                int pageSize = 100000;
                List<BrandStatsRow> rows = statsDAO.listBrandStats(
                        q, brandStatus, null,
                        sortBy, sortOrder,
                        page, pageSize,
                        lowThreshold,
                        fromDate, toDate
                );

                String filename = "brand_stats_" + LocalDateTime.now().format(FILE_DTF) + ".pdf";
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

                try (OutputStream os = response.getOutputStream()) {
                    writeBrandStatsListPdf(os, summary, rows, q, brandStatus,
                            range, fromDate, toDate, sortBy, sortOrder, generatedBy);
                }

            } else {
                // ===== DETAIL MODE: export product stats of one brand =====
                Brand brand = brandDAO.findById(brandId.longValue());
                if (brand == null) {
                    response.sendRedirect(request.getContextPath() + "/home?p=brand-stats&err=Brand not found");
                    return;
                }

                BrandStatsSummary summary = statsDAO.getBrandDetailSummary(brandId.longValue(), lowThreshold, fromDate, toDate);
                List<ProductStatsRow> products = statsDAO.listBrandDetail(
                        brandId.longValue(), lowThreshold, fromDate, toDate, dSortBy, dSortOrder
                );

                String filename = "brand_" + brandId + "_product_stats_" + LocalDateTime.now().format(FILE_DTF) + ".pdf";
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

                try (OutputStream os = response.getOutputStream()) {
                    writePdf(os, brand, summary, products, range, fromDate, toDate, dSortBy, dSortOrder, generatedBy);
                }
            }

        } catch (Exception ex) {
            throw new ServletException("Export PDF failed: " + ex.getMessage(), ex);
        }

    }

    private void writePdf(OutputStream os,
            Brand brand,
            BrandStatsSummary summary,
            List<ProductStatsRow> products,
            String range, Date fromDate, Date toDate,
            String sortBy, String sortOrder,
            String generatedBy) throws Exception {

        // Portrait A4 like receipt
        Document doc = new Document(PageSize.A4, 36, 36, 36, 40);
        PdfWriter writer = PdfWriter.getInstance(doc, os);
        writer.setPageEvent(new ReceiptFooter());

        doc.open();

        // Fonts (simple, clean)
        Font fH1 = new Font(Font.HELVETICA, 14, Font.BOLD);
        Font fH2 = new Font(Font.HELVETICA, 11, Font.BOLD);
        Font fN = new Font(Font.HELVETICA, 9, Font.NORMAL);
        Font fB = new Font(Font.HELVETICA, 9, Font.BOLD);

        // ===== Top header (left/right) =====
        PdfPTable header = new PdfPTable(2);
        header.setWidthPercentage(100);
        header.setWidths(new float[]{3.2f, 1.2f});
        header.getDefaultCell().setBorder(Rectangle.NO_BORDER);

        PdfPCell left = new PdfPCell();
        left.setBorder(Rectangle.NO_BORDER);
        left.addElement(new Paragraph("Mobile Warehouse Management", fH2));
        left.addElement(new Paragraph("[Address | Phone | Email]", fN));

        String reportNo = "RPT-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMMddHHmmss"));
        PdfPCell right = new PdfPCell();
        right.setBorder(Rectangle.NO_BORDER);
        Paragraph pNo = new Paragraph("Report No: " + reportNo, fB);
        pNo.setAlignment(Element.ALIGN_RIGHT);
        Paragraph pDate = new Paragraph("Date: " + LocalDate.now(), fB);
        pDate.setAlignment(Element.ALIGN_RIGHT);
        right.addElement(pNo);
        right.addElement(pDate);

        header.addCell(left);
        header.addCell(right);
        doc.add(header);

        doc.add(blank(6));

        // ===== Center title =====
        Paragraph title = new Paragraph("PRODUCT STATISTIC BY BRAND", fH1);
        title.setAlignment(Element.ALIGN_CENTER);
        doc.add(title);

        Paragraph sub = new Paragraph("Brand: " + safe(brand.getBrandName()) + " (ID: " + brand.getBrandId() + ")", fB);
        sub.setAlignment(Element.ALIGN_CENTER);
        sub.setSpacingAfter(6f);
        doc.add(sub);

        doc.add(dashLine());

        // ===== Info block like receipt (Requested/Created/Filters) =====
        PdfPTable info = new PdfPTable(2);
        info.setWidthPercentage(100);
        info.setWidths(new float[]{1f, 1f});
        info.getDefaultCell().setBorder(Rectangle.NO_BORDER);

        String dateRangeText = (fromDate == null || toDate == null)
                ? "ALL TIME"
                : (fromDate + " → " + toDate);

        PdfPCell infoL = new PdfPCell(new Phrase(
                "Range: " + safe(range).toUpperCase() + "\n"
                + "Date range: " + dateRangeText + "\n"
                + "Sort: " + safe(sortBy).toUpperCase() + " " + safe(sortOrder).toUpperCase(),
                fN
        ));
        infoL.setBorder(Rectangle.NO_BORDER);

        PdfPCell infoR = new PdfPCell(new Phrase(
                "Created by: " + safe(generatedBy) + "\n"
                + "Generated at: " + LocalDateTime.now().format(UI_DTF) + "\n"
                + "Brand status: " + (brand.isActive() ? "ACTIVE" : "INACTIVE"),
                fN
        ));
        infoR.setBorder(Rectangle.NO_BORDER);

        info.addCell(infoL);
        info.addCell(infoR);
        doc.add(info);

        doc.add(blank(6));
        doc.add(dashLine());

        // ===== ITEMS label =====
        Paragraph items = new Paragraph("ITEMS", fB);
        items.setSpacingBefore(6f);
        items.setSpacingAfter(6f);
        doc.add(items);

        // ===== Items table (like receipt) =====
        PdfPTable t = new PdfPTable(7);
        t.setWidthPercentage(100);
        t.setHeaderRows(1);
        t.setWidths(new float[]{0.6f, 1.8f, 1.2f, 1.0f, 1.0f, 1.0f, 1.0f});

        addTH(t, "#", fB);
        addTH(t, "Product*", fB);
        addTH(t, "Product Code", fB);
        addTH(t, "In Stock", fB);
        addTH(t, "Imported*", fB);
        addTH(t, "Exported*", fB);
        addTH(t, "Status", fB);

        if (products == null || products.isEmpty()) {
            PdfPCell c = new PdfPCell(new Phrase("No data", fN));
            c.setColspan(7);
            c.setHorizontalAlignment(Element.ALIGN_CENTER);
            c.setPadding(8f);
            t.addCell(c);
        } else {
            int idx = 1;
            for (ProductStatsRow r : products) {
                addTD(t, String.valueOf(idx++), fN, Element.ALIGN_CENTER);
                addTD(t, safe(r.getProductName()), fN, Element.ALIGN_LEFT);
                addTD(t, safe(r.getProductCode()), fN, Element.ALIGN_LEFT);

                addTD(t, String.valueOf(r.getTotalStockUnits()), fN, Element.ALIGN_CENTER);
                addTD(t, String.valueOf(r.getImportedUnits()), fN, Element.ALIGN_CENTER);
                addTD(t, String.valueOf(r.getExportedUnits()), fN, Element.ALIGN_CENTER);

                // You already set stockStatus in DAO as OUT/LOW/OK
                addTD(t, safe(r.getStockStatus()), fN, Element.ALIGN_CENTER);
            }
        }

        doc.add(t);

        // ===== Summary block (like receipt, right side) =====
        doc.add(blank(8));

        int totalLines = (products == null) ? 0 : products.size();
        long totalStock = 0, totalImp = 0, totalExp = 0;
        if (products != null) {
            for (ProductStatsRow r : products) {
                totalStock += r.getTotalStockUnits();
                totalImp += r.getImportedUnits();
                totalExp += r.getExportedUnits();
            }
        }

        PdfPTable sumWrap = new PdfPTable(2);
        sumWrap.setWidthPercentage(100);
        sumWrap.setWidths(new float[]{2.2f, 1.0f});
        sumWrap.getDefaultCell().setBorder(Rectangle.NO_BORDER);

        PdfPCell blankLeft = new PdfPCell(new Phrase("", fN));
        blankLeft.setBorder(Rectangle.NO_BORDER);

        PdfPTable sum = new PdfPTable(1);
        sum.setWidthPercentage(100);

        PdfPCell sTitle = new PdfPCell(new Phrase("Summary", fB));
        sTitle.setBorder(Rectangle.NO_BORDER);
        sTitle.setPaddingBottom(4f);
        sum.addCell(sTitle);

        sum.addCell(noBorderLine("Total lines: " + totalLines, fN));
        sum.addCell(noBorderLine("Total stock: " + totalStock, fN));
        sum.addCell(noBorderLine("Total imported: " + totalImp, fN));
        sum.addCell(noBorderLine("Total exported: " + totalExp, fN));

        PdfPCell sumRight = new PdfPCell(sum);
        sumRight.setBorder(Rectangle.NO_BORDER);

        sumWrap.addCell(blankLeft);
        sumWrap.addCell(sumRight);

        doc.add(sumWrap);

        doc.add(blank(10));
        doc.add(dashLine()); // bottom line (no signatures)

        doc.close();
    }

    // ===== Helpers =====
    private static Element dashLine() {
        LineSeparator ls = new LineSeparator();
        ls.setLineWidth(1f);
        ls.setPercentage(100);
        // dashed effect
        ls.setLineColor(new java.awt.Color(50, 50, 50));
        return ls;
    }

    private static Paragraph blank(float space) {
        Paragraph p = new Paragraph(" ");
        p.setSpacingAfter(space);
        return p;
    }

    private static void addTH(PdfPTable t, String text, Font f) {
        PdfPCell c = new PdfPCell(new Phrase(text, f));
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(5f);
        c.setHorizontalAlignment(Element.ALIGN_CENTER);
        t.addCell(c);
    }

    private static void addTD(PdfPTable t, String text, Font f, int align) {
        PdfPCell c = new PdfPCell(new Phrase(text == null ? "" : text, f));
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(5f);
        c.setHorizontalAlignment(align);
        t.addCell(c);
    }

    private static PdfPCell noBorderLine(String text, Font f) {
        PdfPCell c = new PdfPCell(new Phrase(text, f));
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(2f);
        return c;
    }

    private static class ReceiptFooter extends PdfPageEventHelper {

        Font f = new Font(Font.HELVETICA, 8, Font.NORMAL);

        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            try {
                PdfPTable footer = new PdfPTable(1);
                footer.setTotalWidth(document.right() - document.left());
                PdfPCell c = new PdfPCell(new Phrase(
                        "Footer: Generated by Mobile WMS - " + LocalDateTime.now().format(UI_DTF),
                        f
                ));
                c.setBorder(Rectangle.NO_BORDER);
                c.setHorizontalAlignment(Element.ALIGN_CENTER);
                footer.addCell(c);
                footer.writeSelectedRows(0, -1, document.left(), document.bottom() - 10, writer.getDirectContent());
            } catch (Exception ignored) {
            }
        }
    }

    private static String trimOrNull(String s) {
        if (s == null) {
            return null;
        }
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private static String trimOrDefault(String s, String def) {
        s = trimOrNull(s);
        return (s == null) ? def : s;
    }

    private static String safe(String s) {
        return (s == null || s.isBlank()) ? "-" : s;
    }

    private void writeBrandStatsListPdf(OutputStream os,
            BrandStatsSummary summary,
            List<model.BrandStatsRow> rows,
            String q, String brandStatus,
            String range, Date fromDate, Date toDate,
            String sortBy, String sortOrder,
            String generatedBy) throws Exception {

        Document doc = new Document(PageSize.A4, 36, 36, 36, 40); // portrait like receipt
        PdfWriter writer = PdfWriter.getInstance(doc, os);
        writer.setPageEvent(new ReceiptFooter()); // reuse your footer
        doc.open();

        // Fonts
        Font fH1 = new Font(Font.HELVETICA, 14, Font.BOLD);
        Font fH2 = new Font(Font.HELVETICA, 11, Font.BOLD);
        Font fN = new Font(Font.HELVETICA, 9, Font.NORMAL);
        Font fB = new Font(Font.HELVETICA, 9, Font.BOLD);

        // ===== Top header (left/right) =====
        PdfPTable header = new PdfPTable(2);
        header.setWidthPercentage(100);
        header.setWidths(new float[]{3.2f, 1.2f});
        header.getDefaultCell().setBorder(Rectangle.NO_BORDER);

        PdfPCell left = new PdfPCell();
        left.setBorder(Rectangle.NO_BORDER);
        left.addElement(new Paragraph("Mobile Warehouse Management", fH2));
        left.addElement(new Paragraph("[Address | Phone | Email]", fN));

        String reportNo = "RPT-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMMddHHmmss"));
        PdfPCell right = new PdfPCell();
        right.setBorder(Rectangle.NO_BORDER);

        Paragraph pNo = new Paragraph("Report No: " + reportNo, fB);
        pNo.setAlignment(Element.ALIGN_RIGHT);
        Paragraph pDate = new Paragraph("Date: " + LocalDate.now(), fB);
        pDate.setAlignment(Element.ALIGN_RIGHT);

        right.addElement(pNo);
        right.addElement(pDate);

        header.addCell(left);
        header.addCell(right);
        doc.add(header);

        doc.add(blank(6));

        // ===== Center title =====
        Paragraph title = new Paragraph("VIEW PRODUCT STATISTICS BY BRAND", fH1);
        title.setAlignment(Element.ALIGN_CENTER);
        doc.add(title);

        Paragraph sub = new Paragraph("BRAND STATISTICS REPORT", fB);
        sub.setAlignment(Element.ALIGN_CENTER);
        sub.setSpacingAfter(6f);
        doc.add(sub);

        doc.add(dashLine());

        // ===== Info block (filters like receipt) =====
        String dateRangeText = (fromDate == null || toDate == null) ? "ALL TIME" : (fromDate + " → " + toDate);
        String keyword = (q == null || q.isBlank()) ? "-" : q;
        String stt = (brandStatus == null || brandStatus.isBlank()) ? "ALL" : brandStatus.toUpperCase();

        PdfPTable info = new PdfPTable(2);
        info.setWidthPercentage(100);
        info.setWidths(new float[]{1f, 1f});
        info.getDefaultCell().setBorder(Rectangle.NO_BORDER);

        PdfPCell infoL = new PdfPCell(new Phrase(
                "Range: " + safe(range).toUpperCase() + "\n"
                + "Date range: " + dateRangeText + "\n"
                + "Status: " + stt + "\n"
                + "Keyword: " + keyword,
                fN
        ));
        infoL.setBorder(Rectangle.NO_BORDER);

        PdfPCell infoR = new PdfPCell(new Phrase(
                "Created by: " + safe(generatedBy) + "\n"
                + "Generated at: " + LocalDateTime.now().format(UI_DTF) + "\n"
                + "Sort: " + safe(sortBy).toUpperCase() + " " + safe(sortOrder).toUpperCase(),
                fN
        ));
        infoR.setBorder(Rectangle.NO_BORDER);

        info.addCell(infoL);
        info.addCell(infoR);
        doc.add(info);

        doc.add(blank(6));
        doc.add(dashLine());

        // ===== ITEMS label =====
        Paragraph items = new Paragraph("ITEMS", fB);
        items.setSpacingBefore(6f);
        items.setSpacingAfter(6f);
        doc.add(items);

        // ===== Items table  =====
        PdfPTable t = new PdfPTable(7);
        t.setWidthPercentage(100);
        t.setHeaderRows(1);
        t.setWidths(new float[]{0.6f, 2.0f, 0.9f, 1.0f, 1.0f, 1.0f, 1.0f});

        addTH(t, "#", fB);
        addTH(t, "Brand*", fB);
        addTH(t, "ID", fB);
        addTH(t, "Products", fB);
        addTH(t, "Stock", fB);
        addTH(t, "Imported*", fB);
        addTH(t, "Status", fB);

        if (rows == null || rows.isEmpty()) {
            PdfPCell c = new PdfPCell(new Phrase("No data", fN));
            c.setColspan(7);
            c.setHorizontalAlignment(Element.ALIGN_CENTER);
            c.setPadding(8f);
            c.setBorder(Rectangle.NO_BORDER);
            t.addCell(c);
        } else {
            int idx = 1;
            for (model.BrandStatsRow r : rows) {
                addTD(t, String.valueOf(idx++), fN, Element.ALIGN_CENTER);
                addTD(t, safe(r.getBrandName()), fN, Element.ALIGN_LEFT);
                addTD(t, String.valueOf(r.getBrandId()), fN, Element.ALIGN_CENTER);
                addTD(t, String.valueOf(r.getTotalProducts()), fN, Element.ALIGN_CENTER);
                addTD(t, String.valueOf(r.getTotalStockUnits()), fN, Element.ALIGN_CENTER);
                addTD(t, String.valueOf(r.getImportedUnits()), fN, Element.ALIGN_CENTER);
                addTD(t, r.isActive() ? "ACTIVE" : "INACTIVE", fN, Element.ALIGN_CENTER);
            }
        }

        doc.add(t);

        // ===== Summary block (right side like receipt) =====
        doc.add(blank(8));

        int totalLines = (rows == null) ? 0 : rows.size();

        PdfPTable sumWrap = new PdfPTable(2);
        sumWrap.setWidthPercentage(100);
        sumWrap.setWidths(new float[]{2.2f, 1.0f});
        sumWrap.getDefaultCell().setBorder(Rectangle.NO_BORDER);

        PdfPCell blankLeft = new PdfPCell(new Phrase("", fN));
        blankLeft.setBorder(Rectangle.NO_BORDER);

        PdfPTable sum = new PdfPTable(1);
        sum.setWidthPercentage(100);

        PdfPCell sTitle = new PdfPCell(new Phrase("Summary", fB));
        sTitle.setBorder(Rectangle.NO_BORDER);
        sTitle.setPaddingBottom(4f);
        sum.addCell(sTitle);

        sum.addCell(noBorderLine("Total lines: " + totalLines, fN));
        sum.addCell(noBorderLine("Total brands: " + summary.getTotalBrands(), fN));
        sum.addCell(noBorderLine("Total products: " + summary.getTotalProducts(), fN));
        sum.addCell(noBorderLine("Total stock: " + summary.getTotalStockUnits(), fN));
        sum.addCell(noBorderLine("Low stock: " + summary.getLowStockProducts(), fN));
        sum.addCell(noBorderLine("Imported (range): " + summary.getImportedUnitsInRange(), fN));
        sum.addCell(noBorderLine("Exported (range): " + summary.getExportedUnitsInRange(), fN));

        PdfPCell sumRight = new PdfPCell(sum);
        sumRight.setBorder(Rectangle.NO_BORDER);

        sumWrap.addCell(blankLeft);
        sumWrap.addCell(sumRight);

        doc.add(sumWrap);

        doc.add(blank(10));
        doc.add(dashLine());

        doc.close();
    }

}
