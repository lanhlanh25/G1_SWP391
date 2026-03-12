/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.DBContext;
import dal.ImportReceiptDAO;
import dal.ImportRequestDAO;
import dal.ProductDAO;
import dal.ProductSkuDAO;
import dal.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.ImportRequest;
import model.ImportRequestItem;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet(name = "CreateImportReceipt", urlPatterns = {"/create-import-receipt"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 15 * 1024 * 1024)
public class CreateImportReceipt extends HttpServlet {

    private static final DateTimeFormatter DTF_UI = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Connection con = null;
        try {
            con = DBContext.getConnection();

            SupplierDAO sdao = new SupplierDAO();
            ImportReceiptDAO irDao = new ImportReceiptDAO();

            req.setAttribute("suppliers", sdao.listActive());

            String importCode = irDao.generateImportCode(con);
            String receiptDateDefault = LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI);

            req.setAttribute("importCode", importCode);
            req.setAttribute("receiptDateDefault", receiptDateDefault);
            req.setAttribute("createdByName", getFullName(req));

            // ── Coming from Import Request List "Create" button ──────────
            String requestIdRaw = req.getParameter("requestId");
            if (requestIdRaw != null && !requestIdRaw.isBlank()) {
                long requestId = Long.parseLong(requestIdRaw.trim());
                ImportRequestDAO irReqDao = new ImportRequestDAO();
                ImportRequest irHeader = irReqDao.getHeader(requestId);

                if (irHeader == null) {
                    resp.sendRedirect(req.getContextPath() + "/home?p=import-request-list&err=Request+not+found");
                    return;
                }
                if ("COMPLETE".equalsIgnoreCase(irHeader.getStatus())) {
                    resp.sendRedirect(req.getContextPath() + "/home?p=import-request-list&err=Request+already+completed");
                    return;
                }

                List<ImportRequestItem> requestItems = irReqDao.listItemsForReceipt(requestId);
                req.setAttribute("irHeader", irHeader);
                req.setAttribute("requestItems", requestItems);
                req.setAttribute("requestId", requestId);

                // Flash messages
                HttpSession ss = req.getSession();
                Object ferr = ss.getAttribute("flash_err");
                Object fmsg = ss.getAttribute("flash_msg");
                if (ferr != null) { req.setAttribute("err", ferr); ss.removeAttribute("flash_err"); }
                if (fmsg != null) { req.setAttribute("msg", fmsg); ss.removeAttribute("flash_msg"); }

                // NOTE: products/skus NOT needed in request mode (rows are pre-filled/readonly)
                // but we set empty lists to avoid JSP JSTL errors
                req.setAttribute("products", java.util.Collections.emptyList());
                req.setAttribute("skus", java.util.Collections.emptyList());

                req.setAttribute("mode", "manual");
                req.getRequestDispatcher("/create_import_receipt.jsp").forward(req, resp);
                return;
            }

            // ── Normal manual create ─────────────────────────────────────
            ProductDAO pdao = new ProductDAO();
            ProductSkuDAO skdao = new ProductSkuDAO();
            req.setAttribute("products", pdao.listActive());
            req.setAttribute("skus", skdao.listActive());

            HttpSession ss = req.getSession();
            Object ferr = ss.getAttribute("flash_err");
            Object fmsg = ss.getAttribute("flash_msg");
            Object fmode = ss.getAttribute("flash_mode");

            if (ferr != null) { req.setAttribute("err", ferr); ss.removeAttribute("flash_err"); }
            if (fmsg != null) { req.setAttribute("msg", fmsg); ss.removeAttribute("flash_msg"); }
            if (fmode != null) { req.setAttribute("mode", String.valueOf(fmode)); ss.removeAttribute("flash_mode"); }

            if (req.getAttribute("mode") == null) req.setAttribute("mode", "manual");

            req.getRequestDispatcher("/create_import_receipt.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("err", "Load page failed: " + e.getMessage());
            req.setAttribute("mode", "manual");
            req.getRequestDispatcher("/create_import_receipt.jsp").forward(req, resp);
        } finally {
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String mode = Optional.ofNullable(req.getParameter("mode")).orElse("manual");
        String status = "CONFIRMED";

        String requestIdRaw = req.getParameter("requestId");
        Long requestId = null;
        if (requestIdRaw != null && !requestIdRaw.isBlank()) {
            try {
                requestId = Long.parseLong(requestIdRaw.trim());
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/home?p=import-request-list&err=Invalid+request+id");
                return;
            }
        }

        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            if ("excel".equalsIgnoreCase(mode)) {
                createByExcel(con, req, status);
            } else {
                createByManual(con, req, status);
            }

            // Mark the source import request as COMPLETE
            if (requestId != null) {
                ImportRequestDAO irReqDao = new ImportRequestDAO();
                irReqDao.updateImportRequestStatus(con, requestId, "COMPLETE");
            }

            con.commit();
            req.getSession().setAttribute("flash_msg", "Import receipt created successfully");

            if (requestId != null) {
                resp.sendRedirect(req.getContextPath() + "/home?p=import-request-list");
            } else {
                resp.sendRedirect(req.getContextPath() + "/home?p=import-receipt-list");
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) try { con.rollback(); } catch (Exception ignored) {}

            req.getSession().setAttribute("flash_err", e.getMessage());
            req.getSession().setAttribute("flash_mode", mode);

            if (requestId != null) {
                resp.sendRedirect(req.getContextPath() + "/home?p=create-import-receipt&requestId=" + requestId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/home?p=create-import-receipt");
            }
        } finally {
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }
    }

    // ─── Manual creation ────────────────────────────────────────────────────

    private void createByManual(Connection con, HttpServletRequest req, String status) throws Exception {
        ImportReceiptDAO dao = new ImportReceiptDAO();

        String importCode = req.getParameter("importCode");
        Long supplierId = parseLongNullable(req.getParameter("supplierId"));
        if (supplierId == null) throw new IllegalArgumentException("Supplier is required");

        Timestamp receiptDate = Timestamp.valueOf(parseDT(req.getParameter("receiptDate")));
        String note = req.getParameter("note");

        int createdBy = getUserId(req);
        if (createdBy <= 0) throw new IllegalArgumentException("Missing session userId.");

        String[] productIds = req.getParameterValues("productId");
        String[] skuIds     = req.getParameterValues("skuId");
        String[] qtys       = req.getParameterValues("qty");
        String[] itemNotes  = req.getParameterValues("itemNote");

        if (productIds == null || productIds.length == 0)
            throw new IllegalArgumentException("Please add at least 1 product line.");

        int n = productIds.length;
        if (skuIds == null || skuIds.length != n || qtys == null || qtys.length != n)
            throw new IllegalArgumentException("Invalid data: array length mismatch");

        Set<String> allImeisSameSku = new HashSet<>();

        // Validation pass
        for (int i = 0; i < n; i++) {
            if (isBlank(productIds[i]) && isBlank(skuIds[i]) && isBlank(qtys[i])) continue;

            long productId = parseLongRequired(productIds[i], "Line " + (i+1) + ": product required");
            long skuId     = parseLongRequired(skuIds[i],    "Line " + (i+1) + ": SKU required");
            int  qty       = parseInt(qtys[i], 0);

            if (qty <= 0) throw new IllegalArgumentException("Line " + (i+1) + ": quantity must be > 0");
            if (!dao.skuBelongsToProduct(con, skuId, productId))
                throw new IllegalArgumentException("Line " + (i+1) + ": SKU does not belong to selected Product");

            int rowIdx = i + 1;
            for (int k = 1; k <= qty; k++) {
                String imeiValue = req.getParameter("imei_" + rowIdx + "_" + k);
                if (isBlank(imeiValue))
                    throw new IllegalArgumentException("Line " + (i+1) + ", IMEI " + k + ": IMEI is required");

                String imei = imeiValue.trim().replaceAll("\\D", "");
                if (!imei.matches("^\\d{15}$"))
                    throw new IllegalArgumentException("Line " + (i+1) + ", IMEI " + k + ": must be 15 digits. Got: " + imei);

                String err = dao.validateImeiForInsert(con, skuId, imei);
                if (err != null) throw new IllegalArgumentException(err);

                if (!allImeisSameSku.add(skuId + "|" + imei))
                    throw new IllegalArgumentException("Duplicate IMEI in this receipt: " + imei);
            }
        }

        // Insert pass
        long importId = dao.insertReceipt(con, importCode, supplierId, receiptDate, note, createdBy, status);
        int insertedLines = 0;

        for (int i = 0; i < n; i++) {
            if (isBlank(productIds[i]) && isBlank(skuIds[i]) && isBlank(qtys[i])) continue;

            long productId = parseLongRequired(productIds[i], "");
            long skuId     = parseLongRequired(skuIds[i], "");
            int  qty       = parseInt(qtys[i], 0);
            if (qty <= 0) continue;

            String itemNote = (itemNotes != null && i < itemNotes.length) ? itemNotes[i] : null;

            int rowIdx = i + 1;
            List<String> imeis = new ArrayList<>();
            for (int k = 1; k <= qty; k++) {
                imeis.add(req.getParameter("imei_" + rowIdx + "_" + k).trim().replaceAll("\\D", ""));
            }

            long lineId = dao.insertLine(con, importId, productId, skuId, qty, itemNote);
            dao.insertUnits(con, lineId, imeis);

            for (String imei : imeis) dao.insertOrActivateUnit(con, skuId, imei);
            dao.upsertInventoryBalance(con, skuId, qty);

            insertedLines++;
        }

        if (insertedLines == 0) throw new IllegalArgumentException("Please add at least 1 valid product line.");
    }

    // ─── Excel creation ─────────────────────────────────────────────────────

    private void createByExcel(Connection con, HttpServletRequest req, String status) throws Exception {
        ImportReceiptDAO dao = new ImportReceiptDAO();

        String importCode = req.getParameter("importCode");
        Long supplierId   = parseLongNullable(req.getParameter("supplierId"));
        if (supplierId == null) throw new IllegalArgumentException("Supplier is required");

        Timestamp receiptDate = Timestamp.valueOf(parseDT(req.getParameter("receiptDate")));
        String note = req.getParameter("note");

        int createdBy = getUserId(req);
        if (createdBy <= 0) throw new IllegalArgumentException("Missing session userId.");

        Part filePart = req.getPart("excelFile");
        if (filePart == null || filePart.getSize() == 0)
            throw new IllegalArgumentException("Excel file required.");

        List<ExcelRow> rows;
        try (InputStream is = filePart.getInputStream()) { rows = parseExcel(is); }
        if (rows.isEmpty()) throw new IllegalArgumentException("Excel has no data.");

        Set<String> allImeisSameSku = new HashSet<>();
        Map<String, List<String>> grouped = new LinkedHashMap<>();

        for (ExcelRow r : rows) {
            long productId = dao.findProductIdByCode(con, r.productCode);
            long skuId     = dao.findSkuIdByCode(con, r.skuCode);

            if (!dao.skuBelongsToProduct(con, skuId, productId))
                throw new IllegalArgumentException("SKU " + r.skuCode + " not belong to product " + r.productCode);
            if (!r.imei.matches("^\\d{15}$"))
                throw new IllegalArgumentException("Invalid IMEI (15 digits): " + r.imei);

            String err = dao.validateImeiForInsert(con, skuId, r.imei);
            if (err != null) throw new IllegalArgumentException(err);

            if (!allImeisSameSku.add(skuId + "|" + r.imei))
                throw new IllegalArgumentException("Duplicate IMEI in Excel: " + r.imei);

            grouped.computeIfAbsent(productId + "_" + skuId, k -> new ArrayList<>()).add(r.imei);
        }

        long importId = dao.insertReceipt(con, importCode, supplierId, receiptDate, note, createdBy, status);

        for (Map.Entry<String, List<String>> en : grouped.entrySet()) {
            String[] parts = en.getKey().split("_");
            long productId = Long.parseLong(parts[0]);
            long skuId     = Long.parseLong(parts[1]);
            List<String> imeis = en.getValue();

            long lineId = dao.insertLine(con, importId, productId, skuId, imeis.size(), null);
            dao.insertUnits(con, lineId, imeis);
            for (String imei : imeis) dao.insertOrActivateUnit(con, skuId, imei);
            dao.upsertInventoryBalance(con, skuId, imeis.size());
        }
    }

    // ─── Helpers ────────────────────────────────────────────────────────────

    private List<ExcelRow> parseExcel(InputStream is) throws Exception {
        List<ExcelRow> out = new ArrayList<>();
        try (Workbook wb = new XSSFWorkbook(is)) {
            Sheet sh = wb.getSheetAt(0);
            if (sh == null) return out;
            Iterator<Row> it = sh.rowIterator();
            if (!it.hasNext()) return out;
            Row header = it.next();
            Map<String, Integer> col = new HashMap<>();
            for (Cell c : header) {
                c.setCellType(CellType.STRING);
                col.put(c.getStringCellValue().trim().toLowerCase(), c.getColumnIndex());
            }
            if (!col.containsKey("product_code") || !col.containsKey("sku_code") || !col.containsKey("imei"))
                throw new IllegalArgumentException("Excel must have columns: product_code, sku_code, imei");
            int rowNum = 1;
            while (it.hasNext()) {
                Row r = it.next(); rowNum++;
                String p    = cellStr(r.getCell(col.get("product_code")));
                String s    = cellStr(r.getCell(col.get("sku_code")));
                String imei = cellStr(r.getCell(col.get("imei"))).replaceAll("\\D", "");
                if (isBlank(p) && isBlank(s) && isBlank(imei)) continue;
                if (isBlank(p) || isBlank(s) || isBlank(imei))
                    throw new IllegalArgumentException("Row " + rowNum + " missing data");
                out.add(new ExcelRow(p.trim(), s.trim(), imei.trim()));
            }
        }
        return out;
    }

    private String cellStr(Cell c) {
        if (c == null) return "";
        c.setCellType(CellType.STRING);
        return c.getStringCellValue() == null ? "" : c.getStringCellValue();
    }

    private static class ExcelRow {
        String productCode, skuCode, imei;
        ExcelRow(String p, String s, String i) { productCode = p; skuCode = s; imei = i; }
    }

    private String resolveSidebar(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return "sidebar_staff.jsp";
        String role = (String) session.getAttribute("roleName");
        if (role == null) return "sidebar_staff.jsp";
        switch (role.toUpperCase()) {
            case "ADMIN":   return "sidebar_admin.jsp";
            case "MANAGER": return "sidebar_manager.jsp";
            case "SALE":    return "sidebar_sales.jsp";
            default:        return "sidebar_staff.jsp";
        }
    }

    private LocalDateTime parseDT(String raw) {
        if (isBlank(raw)) return LocalDateTime.now().withSecond(0).withNano(0);
        return LocalDateTime.parse(raw, DTF_UI);
    }

    private String getFullName(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return "Staff";
        Object v = session.getAttribute("fullName");
        return v == null ? "Staff" : String.valueOf(v);
    }

    private int getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return -1;
        Object uid = session.getAttribute("userId");
        if (uid instanceof Integer) return (Integer) uid;
        if (uid instanceof Long) return ((Long) uid).intValue();
        if (uid instanceof String) { try { return Integer.parseInt((String) uid); } catch (Exception ignored) {} }
        return -1;
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private long parseLongRequired(String s, String msg) {
        if (isBlank(s)) throw new IllegalArgumentException(msg);
        return Long.parseLong(s.trim());
    }

    private Long parseLongNullable(String s) {
        if (isBlank(s)) return null;
        return Long.parseLong(s.trim());
    }

    private boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
}
