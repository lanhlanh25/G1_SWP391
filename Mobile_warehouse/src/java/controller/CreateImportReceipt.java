/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.DBContext;
import dal.ImportReceiptDAO;
import dal.ProductDAO;
import dal.ProductSkuDAO;
import dal.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

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
        Connection con = null;
        try {
            con = DBContext.getConnection();

            SupplierDAO sdao = new SupplierDAO();
            ProductDAO pdao = new ProductDAO();
            ProductSkuDAO skdao = new ProductSkuDAO();
            ImportReceiptDAO irDao = new ImportReceiptDAO();

            req.setAttribute("suppliers", sdao.listActive());
            req.setAttribute("products", pdao.listActive());
            req.setAttribute("skus", skdao.listActive());

            String importCode = irDao.generateImportCode(con);
            String receiptDateDefault = LocalDateTime.now().withSecond(0).withNano(0).format(DTF_UI);

            req.setAttribute("importCode", importCode);
            req.setAttribute("receiptDateDefault", receiptDateDefault);
            req.setAttribute("createdByName", getFullName(req));

            if (req.getAttribute("mode") == null) {
                req.setAttribute("mode", "manual");
            }
 

            req.getRequestDispatcher("/create_import_receipt.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("err", "Load page failed: " + e.getMessage());
            req.getRequestDispatcher("/create_import_receipt.jsp").forward(req, resp);
        } finally {
            if (con != null) try {
                con.close();
            } catch (Exception ignored) {
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String mode = Optional.ofNullable(req.getParameter("mode")).orElse("manual");

        // ✅ Always create as PENDING
        String status = "PENDING";

        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            if ("excel".equalsIgnoreCase(mode)) {
                createByExcel(con, req, status);
            } else {
                createByManual(con, req, status);
            }

            con.commit();
            resp.sendRedirect(req.getContextPath() + "/import-receipt-list?msg=Created");
        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) try {
                con.rollback();
            } catch (Exception ignored) {
            }

            req.setAttribute("err", "Create failed: " + e.getMessage());
            req.setAttribute("mode", mode);

            doGet(req, resp);
        } finally {
            if (con != null) try {
                con.close();
            } catch (Exception ignored) {
            }
        }
    }

    // ✅ MANUAL MODE
    private void createByManual(Connection con, HttpServletRequest req, String status) throws Exception {
        ImportReceiptDAO dao = new ImportReceiptDAO();

        String importCode = req.getParameter("importCode");
        Long supplierId = parseLongNullable(req.getParameter("supplierId"));
        Timestamp receiptDate = Timestamp.valueOf(parseDT(req.getParameter("receiptDate")));
        String note = req.getParameter("note");

        int createdBy = getUserId(req);
        if (createdBy <= 0) {
            throw new IllegalArgumentException("Missing session userId.");
        }

        String[] productIds = req.getParameterValues("productId");
        String[] skuIds = req.getParameterValues("skuId");
        String[] qtys = req.getParameterValues("qty");
        String[] itemNotes = req.getParameterValues("itemNote");

        if (productIds == null || productIds.length == 0) {
            throw new IllegalArgumentException("Please add at least 1 product line.");
        }

        int n = productIds.length;

        if (skuIds == null || skuIds.length != n || qtys == null || qtys.length != n) {
            throw new IllegalArgumentException("Invalid data: array length mismatch");
        }

        long importId = dao.insertReceipt(con, importCode, supplierId, receiptDate, note, createdBy, status);

        int insertedLines = 0;

        for (int i = 0; i < n; i++) {
            String productIdRaw = productIds[i];
            String skuIdRaw = skuIds[i];
            String qtyRaw = qtys[i];

            if (isBlank(productIdRaw) && isBlank(skuIdRaw) && isBlank(qtyRaw)) {
                continue;
            }

            long productId = parseLongRequired(productIdRaw, "Line " + (i + 1) + ": product required");
            long skuId = parseLongRequired(skuIdRaw, "Line " + (i + 1) + ": sku required");
            int qty = parseInt(qtyRaw, 0);

            if (qty <= 0) {
                throw new IllegalArgumentException("Line " + (i + 1) + ": qty must be > 0");
            }

            if (!dao.skuBelongsToProduct(con, skuId, productId)) {
                throw new IllegalArgumentException("Line " + (i + 1) + ": SKU not belong to Product");
            }

            String itemNote = (itemNotes != null && i < itemNotes.length) ? itemNotes[i] : null;

            int rowIdx = i + 1;
            List<String> imeis = new ArrayList<>();

            for (int k = 1; k <= qty; k++) {
                String paramName = "imei_" + rowIdx + "_" + k;
                String imeiValue = req.getParameter(paramName);

                if (isBlank(imeiValue)) {
                    throw new IllegalArgumentException(
                            "Line " + (i + 1) + ", IMEI " + k + ": IMEI is required"
                    );
                }

                String imei = imeiValue.trim().replaceAll("\\D", "");

                if (!imei.matches("^\\d{15}$")) {
                    throw new IllegalArgumentException(
                            "Line " + (i + 1) + ", IMEI " + k + ": must be 15 digits. Got: " + imei
                    );
                }

                imeis.add(imei);
            }

            if (imeis.size() != qty) {
                throw new IllegalArgumentException(
                        "Line " + (i + 1) + ": IMEI count (" + imeis.size()
                        + ") must equal quantity (" + qty + ")"
                );
            }

            Set<String> uniqueImeis = new HashSet<>(imeis);
            if (uniqueImeis.size() != imeis.size()) {
                throw new IllegalArgumentException("Line " + (i + 1) + ": Duplicate IMEIs found");
            }

            long lineId = dao.insertLine(con, importId, productId, skuId, qty, itemNote);
            dao.insertUnits(con, lineId, imeis);

            insertedLines++;
        }

        if (insertedLines == 0) {
            throw new IllegalArgumentException("Please add at least 1 valid product line.");
        }
    }

    // ✅ EXCEL MODE
    private void createByExcel(Connection con, HttpServletRequest req, String status) throws Exception {
        ImportReceiptDAO dao = new ImportReceiptDAO();

        String importCode = req.getParameter("importCode");
        Long supplierId = parseLongNullable(req.getParameter("supplierId"));
        Timestamp receiptDate = Timestamp.valueOf(parseDT(req.getParameter("receiptDate")));
        String note = req.getParameter("note");

        int createdBy = getUserId(req);
        if (createdBy <= 0) {
            throw new IllegalArgumentException("Missing session userId.");
        }

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
        long importId = dao.insertReceipt(con, importCode, supplierId, receiptDate, note, createdBy, status);

        Map<String, List<String>> grouped = new LinkedHashMap<>();
        Set<String> allImeis = new HashSet<>();

        for (ExcelRow r : rows) {
            long productId = dao.findProductIdByCode(con, r.productCode);
            long skuId = dao.findSkuIdByCode(con, r.skuCode);

            if (!dao.skuBelongsToProduct(con, skuId, productId)) {
                throw new IllegalArgumentException(
                        "SKU " + r.skuCode + " not belong to product " + r.productCode
                );
            }

            if (!r.imei.matches("^\\d{15}$")) {
                throw new IllegalArgumentException("Invalid IMEI (15 digits): " + r.imei);
            }

            if (!allImeis.add(r.imei)) {
                throw new IllegalArgumentException("Duplicate IMEI found: " + r.imei);
            }

            String key = productId + "_" + skuId;
            grouped.computeIfAbsent(key, k -> new ArrayList<>()).add(r.imei);
        }

        for (Map.Entry<String, List<String>> en : grouped.entrySet()) {
            String[] parts = en.getKey().split("_");
            long productId = Long.parseLong(parts[0]);
            long skuId = Long.parseLong(parts[1]);

            List<String> imeis = en.getValue();

            long lineId = dao.insertLine(con, importId, productId, skuId, imeis.size(), null);
            dao.insertUnits(con, lineId, imeis);
        }
    }

    // ===================== Excel parsing =====================
    private List<ExcelRow> parseExcel(InputStream is) throws Exception {
        List<ExcelRow> out = new ArrayList<>();
        try (Workbook wb = new XSSFWorkbook(is)) {
            Sheet sh = wb.getSheetAt(0);
            if (sh == null) {
                return out;
            }

            Iterator<Row> it = sh.rowIterator();
            if (!it.hasNext()) {
                return out;
            }

            Row header = it.next();
            Map<String, Integer> col = new HashMap<>();
            for (Cell c : header) {
                c.setCellType(CellType.STRING);
                col.put(c.getStringCellValue().trim().toLowerCase(), c.getColumnIndex());
            }

            if (!col.containsKey("product_code") || !col.containsKey("sku_code") || !col.containsKey("imei")) {
                throw new IllegalArgumentException(
                        "Excel must have 3 columns: product_code, sku_code, imei"
                );
            }

            int rowNum = 1;
            while (it.hasNext()) {
                Row r = it.next();
                rowNum++;

                String p = cellStr(r.getCell(col.get("product_code")));
                String s = cellStr(r.getCell(col.get("sku_code")));
                String imei = cellStr(r.getCell(col.get("imei"))).replaceAll("\\D", "");

                if (isBlank(p) && isBlank(s) && isBlank(imei)) {
                    continue;
                }
                if (isBlank(p) || isBlank(s) || isBlank(imei)) {
                    throw new IllegalArgumentException("Row " + rowNum + " missing data");
                }

                out.add(new ExcelRow(p.trim(), s.trim(), imei.trim()));
            }
        }
        return out;
    }

    private String cellStr(Cell c) {
        if (c == null) {
            return "";
        }
        c.setCellType(CellType.STRING);
        return c.getStringCellValue() == null ? "" : c.getStringCellValue();
    }

    private static class ExcelRow {

        String productCode, skuCode, imei;

        ExcelRow(String p, String s, String i) {
            productCode = p;
            skuCode = s;
            imei = i;
        }
    }

    // ===================== Helpers =====================
    private LocalDateTime parseDT(String raw) {
        if (isBlank(raw)) {
            return LocalDateTime.now().withSecond(0).withNano(0);
        }
        return LocalDateTime.parse(raw, DTF_UI);
    }

    private String getFullName(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return "Staff";
        }
        Object fullName = session.getAttribute("fullName");
        return fullName == null ? "Staff" : String.valueOf(fullName);
    }

    private int getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return -1;
        }

        Object uid = session.getAttribute("userId");
        if (uid instanceof Integer) {
            return (Integer) uid;
        }
        if (uid instanceof Long) {
            return ((Long) uid).intValue();
        }
        if (uid instanceof String) {
            try {
                return Integer.parseInt((String) uid);
            } catch (Exception ignored) {
            }
        }
        return -1;
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private long parseLongRequired(String s, String msg) {
        if (isBlank(s)) {
            throw new IllegalArgumentException(msg);
        }
        return Long.parseLong(s.trim());
    }

    private Long parseLongNullable(String s) {
        if (isBlank(s)) {
            return null;
        }
        return Long.parseLong(s.trim());
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}