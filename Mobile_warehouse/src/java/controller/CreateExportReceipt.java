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
import dal.ExportRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

import model.ExportRequestItem;
import model.User;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@WebServlet(name = "CreateExportReceipt", urlPatterns = {"/create-export-receipt"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 20L * 1024 * 1024,
        maxRequestSize = 50L * 1024 * 1024
)
public class CreateExportReceipt extends HttpServlet {

    private static final DateTimeFormatter DTF_UI = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String mode = Optional.ofNullable(req.getParameter("mode")).orElse("manual");
        String status = "CONFIRMED";

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("authUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User authUser = (User) session.getAttribute("authUser");
        long createdBy = authUser.getUserId();

        String roleName = String.valueOf(session.getAttribute("roleName"));
        if (!"STAFF".equalsIgnoreCase(roleName)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden");
            return;
        }

        Long requestId = null;
        String requestIdRaw = req.getParameter("requestId");
        if (requestIdRaw != null && !requestIdRaw.isBlank()) {
            try {
                requestId = Long.parseLong(requestIdRaw.trim());
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/home?p=export-request-list&err=Invalid+request+id");
                return;
            }
        }

        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            if ("excel".equalsIgnoreCase(mode)) {
                createByExcel(con, req, status, requestId, createdBy);
            } else {
                createByManual(con, req, status, requestId, createdBy);
            }

            if (requestId != null) {
                ExportRequestDAO erDao = new ExportRequestDAO();
                erDao.updateStatus(con, requestId, "COMPLETE");
            }

            con.commit();
            req.getSession().setAttribute("flash_msg", "Export receipt created successfully");

            if (requestId != null) {
                resp.sendRedirect(req.getContextPath() + "/home?p=export-request-list");
            } else {
                resp.sendRedirect(req.getContextPath() + "/home?p=export-receipt-list");
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try {
                    con.rollback();
                } catch (Exception ignored) {}
            }

            req.getSession().setAttribute("flash_err", e.getMessage());
            req.getSession().setAttribute("flash_mode", mode);

            if (requestId != null) {
                resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&requestId=" + requestId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt");
            }

        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (Exception ignored) {}
            }
        }
    }

    // =========================
    // MANUAL MODE
    // =========================
    private void createByManual(Connection con, HttpServletRequest req, String status,
                                Long requestId, long createdBy) throws Exception {

        ExportReceiptDAO dao = new ExportReceiptDAO();

        Timestamp exportDate = Timestamp.valueOf(parseDT(req.getParameter("receiptDate")));
        String note = req.getParameter("note");

        String[] rowKeys = req.getParameterValues("rowKey");
        if (rowKeys == null || rowKeys.length == 0) {
            throw new IllegalArgumentException("Please add at least 1 product line.");
        }

        List<ManualRowInput> rows = new ArrayList<>();
        Set<String> allImeisSameSku = new HashSet<>();

        for (String rk : rowKeys) {
            String rowIdx = nvl(rk).trim();
            if (rowIdx.isEmpty()) continue;

            long productId = parseLongRequired(req.getParameter("productId_" + rowIdx),
                    "Row " + rowIdx + ": product required");
            long skuId = parseLongRequired(req.getParameter("skuId_" + rowIdx),
                    "Row " + rowIdx + ": SKU required");
            int qty = parseInt(req.getParameter("qty_" + rowIdx), 0);

            if (qty <= 0) {
                throw new IllegalArgumentException("Row " + rowIdx + ": quantity must be > 0");
            }

            if (!dao.skuBelongsToProduct(con, skuId, productId)) {
                throw new IllegalArgumentException("Row " + rowIdx + ": SKU does not belong to selected Product");
            }

            List<String> imeis = new ArrayList<>();
            Set<String> uniqueCheck = new HashSet<>();

            for (int i = 1; i <= qty; i++) {
                String imeiValue = req.getParameter("imei_" + rowIdx + "_" + i);
                if (isBlank(imeiValue)) {
                    throw new IllegalArgumentException("Row " + rowIdx + ", IMEI " + i + ": IMEI is required");
                }

                String imei = imeiValue.trim().replaceAll("\\D", "");
                if (!imei.matches("^\\d{15}$")) {
                    throw new IllegalArgumentException("Row " + rowIdx + ", IMEI " + i + ": must be 15 digits");
                }

                if (!uniqueCheck.add(imei)) {
                    throw new IllegalArgumentException("Duplicate IMEI in same row: " + imei);
                }

                if (!allImeisSameSku.add(skuId + "|" + imei)) {
                    throw new IllegalArgumentException("Duplicate IMEI in this receipt: " + imei);
                }

                imeis.add(imei);
            }

            String itemNote = nvl(req.getParameter("itemNote_" + rowIdx)).trim();
            rows.add(new ManualRowInput(productId, skuId, qty, imeis, itemNote));
        }

        if (rows.isEmpty()) {
            throw new IllegalArgumentException("Please add at least 1 valid product line.");
        }

        if (requestId != null) {
            ExportRequestDAO erDao = new ExportRequestDAO();
            List<ExportRequestItem> requestItems = erDao.listItemsForValidation(con, requestId);
            validateRowsMatchRequest(rows, requestItems);
        }

        if (requestId != null) {
            String reqStatus = dao.getExportRequestStatus(con, requestId);
            if (reqStatus == null) {
                throw new IllegalArgumentException("Export request not found");
            }
            if ("COMPLETE".equalsIgnoreCase(reqStatus)) {
                throw new IllegalArgumentException("This export request is already complete");
            }
            if (dao.existsReceiptByRequestId(con, requestId)) {
                throw new IllegalArgumentException("Export receipt already exists for this request");
            }
        }

        long exportId = dao.createReceipt(con, requestId, createdBy, exportDate, note, status);

        for (ManualRowInput r : rows) {
            long lineId = dao.createLine(con, exportId, r.productId, r.skuId, r.qty, r.itemNote);

            for (String imei : r.imeis) {
                boolean ok = dao.markUnitInactive(con, r.skuId, imei);
                if (!ok) {
                    throw new IllegalArgumentException("IMEI not available (already exported): " + imei);
                }
            }

            dao.insertUnitImeis(con, lineId, r.imeis);
        }

        if (requestId != null) {
            dao.updateExportRequestStatus(con, requestId, "COMPLETE");
        }
    }

    // =========================
    // EXCEL MODE
    // Excel headers: product_code, sku_code, imei, item_note(optional)
    // =========================
    private void createByExcel(Connection con, HttpServletRequest req, String status,
                               Long requestId, long createdBy) throws Exception {

        ExportReceiptDAO dao = new ExportReceiptDAO();

        Timestamp exportDate = Timestamp.valueOf(parseDT(req.getParameter("receiptDate")));
        String note = req.getParameter("note");

        Part filePart = req.getPart("excelFile");
        if (filePart == null || filePart.getSize() == 0) {
            throw new IllegalArgumentException("Excel file required.");
        }

        List<ExcelRow> rows;
        try (InputStream is = filePart.getInputStream()) {
            rows = parseExcel(is);
        }

        if (rows.isEmpty()) {
            throw new IllegalArgumentException("Excel has no data.");
        }

        if (requestId != null) {
            String reqStatus = dao.getExportRequestStatus(con, requestId);
            if (reqStatus == null) {
                throw new IllegalArgumentException("Export request not found");
            }
            if ("COMPLETE".equalsIgnoreCase(reqStatus)) {
                throw new IllegalArgumentException("This export request is already complete");
            }
            if (dao.existsReceiptByRequestId(con, requestId)) {
                throw new IllegalArgumentException("Export receipt already exists for this request");
            }
        }

        Map<String, Long> productCache = new HashMap<>();
        Map<String, Long> skuCache = new HashMap<>();
        Map<String, List<String>> grouped = new LinkedHashMap<>();
        Set<String> allImeisSameSku = new HashSet<>();

        for (ExcelRow r : rows) {
            Long productId = productCache.get(r.productCode);
            if (productId == null) {
                productId = dao.findProductIdByCode(con, r.productCode);
                if (productId == null) {
                    throw new IllegalArgumentException("Product not found: " + r.productCode);
                }
                productCache.put(r.productCode, productId);
            }

            Long skuId = skuCache.get(r.skuCode);
            if (skuId == null) {
                skuId = dao.findSkuIdByCode(con, r.skuCode);
                if (skuId == null) {
                    throw new IllegalArgumentException("SKU not found: " + r.skuCode);
                }
                skuCache.put(r.skuCode, skuId);
            }

            if (!dao.skuBelongsToProduct(con, skuId, productId)) {
                throw new IllegalArgumentException("SKU " + r.skuCode + " does not belong to product " + r.productCode);
            }

            if (!r.imei.matches("^\\d{15}$")) {
                throw new IllegalArgumentException("Invalid IMEI (15 digits): " + r.imei);
            }

            if (!allImeisSameSku.add(skuId + "|" + r.imei)) {
                throw new IllegalArgumentException("Duplicate IMEI in Excel: " + r.imei);
            }

            String key = productId + "_" + skuId + "_" + nvl(r.itemNote);
            grouped.computeIfAbsent(key, k -> new ArrayList<>()).add(r.imei);
        }

        long exportId = dao.createReceipt(con, requestId, createdBy, exportDate, note, status);

        for (Map.Entry<String, List<String>> en : grouped.entrySet()) {
            String[] parts = en.getKey().split("_", 3);
            long productId = Long.parseLong(parts[0]);
            long skuId = Long.parseLong(parts[1]);
            String itemNote = parts.length >= 3 ? parts[2] : "";
            List<String> imeis = en.getValue();

            for (String imei : imeis) {
                boolean ok = dao.markUnitInactive(con, skuId, imei);
                if (!ok) {
                    throw new IllegalArgumentException("IMEI not available: " + imei);
                }
            }

            long lineId = dao.createLine(con, exportId, productId, skuId, imeis.size(), itemNote);
            dao.insertUnitImeis(con, lineId, imeis);
        }

        if (requestId != null) {
            dao.updateExportRequestStatus(con, requestId, "COMPLETE");
        }
    }

    // =========================
    // HELPERS
    // =========================
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

            if (!col.containsKey("product_code") || !col.containsKey("sku_code") || !col.containsKey("imei")) {
                throw new IllegalArgumentException("Excel must have columns: product_code, sku_code, imei");
            }

            int rowNum = 1;
            while (it.hasNext()) {
                Row r = it.next();
                rowNum++;

                String p = cellStr(r.getCell(col.get("product_code")));
                String s = cellStr(r.getCell(col.get("sku_code")));
                String imei = cellStr(r.getCell(col.get("imei"))).replaceAll("\\D", "");
                String itemNote = col.containsKey("item_note")
                        ? cellStr(r.getCell(col.get("item_note")))
                        : "";

                if (isBlank(p) && isBlank(s) && isBlank(imei) && isBlank(itemNote)) continue;
                if (isBlank(p) || isBlank(s) || isBlank(imei)) {
                    throw new IllegalArgumentException("Row " + rowNum + " missing data");
                }

                out.add(new ExcelRow(p.trim(), s.trim(), imei.trim(), itemNote.trim()));
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
        String productCode, skuCode, imei, itemNote;

        ExcelRow(String productCode, String skuCode, String imei, String itemNote) {
            this.productCode = productCode;
            this.skuCode = skuCode;
            this.imei = imei;
            this.itemNote = itemNote;
        }
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

    private void validateRowsMatchRequest(List<ManualRowInput> rows, List<ExportRequestItem> requestItems) {
        if (rows == null || requestItems == null) {
            throw new IllegalArgumentException("Invalid request data");
        }

        if (rows.size() != requestItems.size()) {
            throw new IllegalArgumentException("Export lines do not match request lines");
        }

        for (int i = 0; i < rows.size(); i++) {
            ManualRowInput r = rows.get(i);
            ExportRequestItem reqItem = requestItems.get(i);

            if (r.productId != reqItem.getProductId()
                    || r.skuId != reqItem.getSkuId()
                    || r.qty != reqItem.getRequestQty()) {
                throw new IllegalArgumentException("Export lines do not match request data at line " + (i + 1));
            }
        }
    }

    private LocalDateTime parseDT(String raw) {
        if (isBlank(raw)) {
            return LocalDateTime.now().withSecond(0).withNano(0);
        }
        return LocalDateTime.parse(raw, DTF_UI);
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private long parseLongRequired(String s, String msg) {
        if (isBlank(s)) throw new IllegalArgumentException(msg);
        return Long.parseLong(s.trim());
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String nvl(String s) {
        return s == null ? "" : s;
    }
}