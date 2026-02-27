/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
/**
 *
 * @author Admin
 */
package controller;

import dal.DBContext;
import dal.ExportReceiptDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.*;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@WebServlet(name = "CreateExportReceipt", urlPatterns = {"/create-export-receipt"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 20L * 1024 * 1024, // 20MB
        maxRequestSize = 50L * 1024 * 1024 // 50MB
)
public class CreateExportReceipt extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String mode = nvl(req.getParameter("mode")).trim().toLowerCase(); // manual | excel
        if (!mode.equals("manual") && !mode.equals("excel")) {
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=Invalid+mode");
            return;
        }

        // user đang login
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        model.User u = (model.User) session.getAttribute("authUser");
        long createdBy = u.getUserId();

        // receiptDate: datetime-local => "yyyy-MM-ddTHH:mm"
        Timestamp exportDate;
        try {
            exportDate = parseDatetimeLocalToTs(req.getParameter("receiptDate"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=Invalid+transaction+time");
            return;
        }

        String note = nvl(req.getParameter("note")).trim();

        ExportReceiptDAO dao = new ExportReceiptDAO();

        if (mode.equals("manual")) {
            handleManual(req, resp, dao, createdBy, exportDate, note);
        } else {
            handleExcel(req, resp, dao, createdBy, exportDate, note);
        }
    }

    // =========================
    // MANUAL MODE (dropdown IMEI)
    // =========================
    private void handleManual(HttpServletRequest req, HttpServletResponse resp,
                              ExportReceiptDAO dao,
                              long createdBy, Timestamp exportDate, String note)
            throws IOException {

        String[] rowKeys = req.getParameterValues("rowKey");
        if (rowKeys == null || rowKeys.length == 0) {
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=Please+add+at+least+1+product+line");
            return;
        }

        List<ManualRowInput> rows = new ArrayList<>();

        for (String rk : rowKeys) {
            String rowIdx = nvl(rk).trim();
            if (rowIdx.isEmpty()) continue;

            long productId = parseLong(req.getParameter("productId_" + rowIdx), -1);
            long skuId = parseLong(req.getParameter("skuId_" + rowIdx), -1);
            int qty = parseInt(req.getParameter("qty_" + rowIdx), 0);

            if (productId <= 0 || skuId <= 0 || qty <= 0) {
                resp.sendRedirect(req.getContextPath()
                        + "/home?p=create-export-receipt&err=Invalid+line+(product/sku/qty)+at+row+" + rowIdx);
                return;
            }

            // IMEIs: dropdown -> chỉ cần check not blank + 15 digits
            List<String> imeis = new ArrayList<>();
            Set<String> uniqueCheck = new HashSet<>();
            for (int i = 1; i <= qty; i++) {
                String imei = nvl(req.getParameter("imei_" + rowIdx + "_" + i)).trim();
                if (imei.isEmpty()) {
                    resp.sendRedirect(req.getContextPath()
                            + "/home?p=create-export-receipt&err=Missing+IMEI+at+row+" + rowIdx + "+index+" + i);
                    return;
                }
                if (!isValidImei15(imei)) {
                    resp.sendRedirect(req.getContextPath()
                            + "/home?p=create-export-receipt&err=Invalid+IMEI+format+at+row+" + rowIdx + "+index+" + i);
                    return;
                }
                if (!uniqueCheck.add(imei)) {
                    resp.sendRedirect(req.getContextPath()
                            + "/home?p=create-export-receipt&err=Duplicate+IMEI+in+same+row:+"
                            + imei);
                    return;
                }
                imeis.add(imei);
            }

            String itemNote = nvl(req.getParameter("itemNote_" + rowIdx)).trim();
            rows.add(new ManualRowInput(productId, skuId, qty, imeis, itemNote));
        }

        if (rows.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=No+valid+rows");
            return;
        }

        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            long exportId = dao.createReceipt(con, null, createdBy, exportDate, note, "CONFIRMED");

            for (ManualRowInput r : rows) {
                long lineId = dao.createLine(con, exportId, r.productId, r.skuId, r.qty, r.itemNote);

                // ✅ Mark IMEI out of stock FIRST (ACTIVE -> INACTIVE)
                for (String imei : r.imeis) {
                    boolean ok = dao.markUnitInactive(con, r.skuId, imei);
                    if (!ok) {
                        throw new RuntimeException("IMEI not available (already exported): " + imei);
                    }
                }

                // ✅ Insert export units
                dao.insertUnitImeis(con, lineId, r.imeis);
            }

            con.commit();
            resp.sendRedirect(req.getContextPath() + "/home?p=export-receipt-list&msg=Created+export+receipt");

        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (Exception ignore) {}

            String msg = e.getMessage() == null ? "" : e.getMessage();
            resp.sendRedirect(req.getContextPath()
                    + "/home?p=create-export-receipt&err=" + url("Create failed: " + msg));
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignore) {}
        }
    }

    // =========================
    // EXCEL MODE (mark INACTIVE)
    // Excel format: 4 columns: product_code, sku_code, imei, item_note
    // =========================
    private void handleExcel(HttpServletRequest req, HttpServletResponse resp,
                             ExportReceiptDAO dao,
                             long createdBy, Timestamp exportDate, String note)
            throws IOException, ServletException {

        Part part;
        try {
            part = req.getPart("excelFile");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=Missing+excel+file");
            return;
        }

        if (part == null || part.getSize() <= 0) {
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=Missing+excel+file");
            return;
        }

        Connection con = null;

        try (InputStream is = part.getInputStream()) {

            List<String[]> rawRows = read4ColsFromXlsx(is); // [productCode, skuCode, imei, item_note]
            if (rawRows.isEmpty()) throw new ExcelFormatException("Excel has no valid data rows");

            // group: key = productCode|skuCode|itemNote -> list imeis
            Map<String, List<String>> grouped = new LinkedHashMap<>();
            Set<String> imeiSet = new HashSet<>();

            int rowNo = 0;
            for (String[] r : rawRows) {
                rowNo++;

                String productCode = nvl(r[0]).trim();
                String skuCode = nvl(r[1]).trim();
                String imei = nvl(r[2]).trim();
                String itemNote = (r.length >= 4) ? nvl(r[3]).trim() : "";

                if (productCode.isEmpty() || skuCode.isEmpty() || imei.isEmpty()) {
                    throw new ExcelFormatException("Row " + rowNo + ": product_code/sku_code/imei must not be blank");
                }
                if (!isValidImei15(imei)) {
                    throw new ExcelFormatException("Row " + rowNo + ": IMEI must be exactly 15 digits");
                }
                if (!imeiSet.add(imei)) {
                    throw new ExcelFormatException("Row " + rowNo + ": duplicate IMEI in file: " + imei);
                }

                String key = productCode + "|" + skuCode + "|" + itemNote;
                grouped.computeIfAbsent(key, k -> new ArrayList<>()).add(imei);
            }

            con = DBContext.getConnection();
            con.setAutoCommit(false);

            long exportId = dao.createReceipt(con, null, createdBy, exportDate, note, "CONFIRMED");

            Map<String, Long> productCache = new HashMap<>();
            Map<String, Long> skuCache = new HashMap<>();

            for (Map.Entry<String, List<String>> en : grouped.entrySet()) {
                String key = en.getKey();
                List<String> imeis = en.getValue();

                String[] parts = key.split("\\|", 3);
                String productCode = parts[0];
                String skuCode = parts[1];
                String itemNote = (parts.length >= 3) ? parts[2] : "";

                Long productId = productCache.get(productCode);
                if (productId == null) {
                    productId = dao.findProductIdByCode(con, productCode);
                    if (productId == null) throw new ExcelFormatException("Product not found: " + productCode);
                    productCache.put(productCode, productId);
                }

                Long skuId = skuCache.get(skuCode);
                if (skuId == null) {
                    skuId = dao.findSkuIdByCode(con, skuCode);
                    if (skuId == null) throw new ExcelFormatException("SKU not found: " + skuCode);
                    skuCache.put(skuCode, skuId);
                }

                if (!dao.skuBelongsToProduct(con, skuId, productId)) {
                    throw new ExcelFormatException("SKU " + skuCode + " does not belong to product " + productCode);
                }

                // ✅ Mark INACTIVE before insert export units
                for (String imei : imeis) {
                    boolean ok = dao.markUnitInactive(con, skuId, imei);
                    if (!ok) throw new ExcelFormatException("IMEI not available: " + imei);
                }

                int qty = imeis.size();
                long lineId = dao.createLine(con, exportId, productId, skuId, qty, itemNote);
                dao.insertUnitImeis(con, lineId, imeis);
            }

            con.commit();
            resp.sendRedirect(req.getContextPath() + "/home?p=export-receipt-list&msg=Created+export+receipt+from+Excel");

        } catch (ExcelFormatException ex) {
            try { if (con != null) con.rollback(); } catch (Exception ignore) {}
            resp.sendRedirect(req.getContextPath()
                    + "/home?p=create-export-receipt&err=" + url(ex.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (Exception ignore) {}
            resp.sendRedirect(req.getContextPath()
                    + "/home?p=create-export-receipt&err=" + url("Create failed: " + (e.getMessage() == null ? "" : e.getMessage())));
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignore) {}
        }
    }

    // =========================
    // EXCEL PARSER
    // =========================
    private static List<String[]> read4ColsFromXlsx(InputStream is) throws Exception {
        List<String[]> out = new ArrayList<>();

        try (Workbook wb = new XSSFWorkbook(is)) {
            Sheet sheet = wb.getNumberOfSheets() > 0 ? wb.getSheetAt(0) : null;
            if (sheet == null) return out;

            DataFormatter fmt = new DataFormatter();
            boolean firstRowChecked = false;

            for (Row row : sheet) {
                String c0 = fmt.formatCellValue(row.getCell(0)).trim();
                String c1 = fmt.formatCellValue(row.getCell(1)).trim();
                String c2 = fmt.formatCellValue(row.getCell(2)).trim();
                String c3 = fmt.formatCellValue(row.getCell(3)).trim();

                if (c0.isEmpty() && c1.isEmpty() && c2.isEmpty() && c3.isEmpty()) continue;

                if (!firstRowChecked) {
                    firstRowChecked = true;
                    String h = (c0 + " " + c1 + " " + c2 + " " + c3).toLowerCase();
                    if (h.contains("product") || h.contains("sku") || h.contains("imei")) {
                        continue;
                    }
                }

                out.add(new String[]{c0, c1, c2, c3});
            }
        }
        return out;
    }

    // =========================
    // HELPERS
    // =========================
    private static String nvl(String s) { return s == null ? "" : s; }

    private static int parseInt(String raw, int def) {
        try {
            if (raw == null || raw.isBlank()) return def;
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private static long parseLong(String raw, long def) {
        try {
            if (raw == null || raw.isBlank()) return def;
            return Long.parseLong(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private static Timestamp parseDatetimeLocalToTs(String raw) {
        if (raw == null || raw.isBlank()) throw new IllegalArgumentException("empty");
        LocalDateTime ldt = LocalDateTime.parse(raw.trim());
        return Timestamp.valueOf(ldt);
    }

    private static boolean isValidImei15(String imei) {
        if (imei == null || imei.length() != 15) return false;
        for (int i = 0; i < imei.length(); i++) {
            if (!Character.isDigit(imei.charAt(i))) return false;
        }
        return true;
    }

    private static class ManualRowInput {
        long productId;
        long skuId;
        int qty;
        List<String> imeis;
        String itemNote;

        ManualRowInput(long productId, long skuId, int qty, List<String> imeis, String itemNote) {
            this.productId = productId;
            this.skuId = skuId;
            this.qty = qty;
            this.imeis = imeis;
            this.itemNote = itemNote;
        }
    }

    private static class ExcelFormatException extends Exception {
        ExcelFormatException(String msg) { super(msg); }
    }

    private static String url(String s) {
        try {
            return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8).replace("+", "%20");
        } catch (Exception e) {
            return "Invalid+data";
        }
    }
}