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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
    // MANUAL MODE
    // =========================
    private void handleManual(HttpServletRequest req, HttpServletResponse resp,
            ExportReceiptDAO dao,
            long createdBy, Timestamp exportDate, String note)
            throws IOException, ServletException {

        //  rowKey có nhiều value (mỗi dòng 1 hidden rowKey)
        String[] rowKeys = req.getParameterValues("rowKey");
        if (rowKeys == null || rowKeys.length == 0) {
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=Please+add+at+least+1+product+line");
            return;
        }

        // Validate + parse hết rows ra memory trước (đỡ insert dở)
        List<RowInput> rows = new ArrayList<>();

        for (String rk : rowKeys) {
            String rowIdx = nvl(rk).trim();
            if (rowIdx.isEmpty()) {
                continue;
            }

            long productId = parseLong(req.getParameter("productId_" + rowIdx), -1);
            long skuId = parseLong(req.getParameter("skuId_" + rowIdx), -1);
            int qty = parseInt(req.getParameter("qty_" + rowIdx), 0);

            if (productId <= 0 || skuId <= 0 || qty <= 0) {
                resp.sendRedirect(req.getContextPath()
                        + "/home?p=create-export-receipt&err=Invalid+line+(product/sku/qty)+at+row+" + rowIdx);
                return;
            }

            // IMEIs: imei_{rowIdx}_{i} i = 1..qty
            List<String> imeis = new ArrayList<>();
            for (int i = 1; i <= qty; i++) {
                String imei = nvl(req.getParameter("imei_" + rowIdx + "_" + i)).trim();
                if (!isValidImei15(imei)) {
                    resp.sendRedirect(req.getContextPath()
                            + "/home?p=create-export-receipt&err=Invalid+IMEI+at+row+" + rowIdx + "+index+" + i);
                    return;
                }
                imeis.add(imei);
            }

            // optional note per line (chưa lưu DB nếu schema chưa có)
            String itemNote = nvl(req.getParameter("itemNote_" + rowIdx)).trim();

            rows.add(new RowInput(productId, skuId, qty, imeis, itemNote));
        }

        if (rows.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=No+valid+rows");
            return;
        }

        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            String status = "CONFIRMED";
            long exportId = dao.createReceipt(con, null, createdBy, exportDate, note, status);

            for (RowInput r : rows) {
                long lineId = dao.createLine(con, exportId, r.productId, r.skuId, r.qty, r.itemNote);
                dao.insertUnitImeis(con, lineId, r.imeis);
            }

            con.commit();
            resp.sendRedirect(req.getContextPath() + "/home?p=export-receipt-list&msg=Created+export+receipt");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception ignore) {
            }
            resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=Create+failed");
        } finally {
            try {
                if (con != null) {
                    con.close();
                }
            } catch (Exception ignore) {
            }
        }

    }

    // =========================
    // EXCEL MODE (stub)
    // =========================
    private void handleExcel(HttpServletRequest req, HttpServletResponse resp,
            ExportReceiptDAO dao,
            long createdBy, Timestamp exportDate, String note)
            throws IOException, ServletException {

        Part part = null;
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

        // ✅ TODO: bạn cần đọc xlsx và map ra rows: product_code, sku_code, imei
        // Ở đây mình chỉ để khung + báo lỗi rõ để bạn nối tiếp.
        try (InputStream is = part.getInputStream()) {
            // parseExcel(is) -> Map<(productId, skuId), List<imei>>
            // rồi insert transaction giống manual
        }

        resp.sendRedirect(req.getContextPath() + "/home?p=create-export-receipt&err=Excel+mode+not+implemented+yet");
    }

    // =========================
    // HELPERS
    // =========================
    private static String nvl(String s) {
        return s == null ? "" : s;
    }

    private static int parseInt(String raw, int def) {
        try {
            if (raw == null || raw.isBlank()) {
                return def;
            }
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private static long parseLong(String raw, long def) {
        try {
            if (raw == null || raw.isBlank()) {
                return def;
            }
            return Long.parseLong(raw.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private static Timestamp parseDatetimeLocalToTs(String raw) {
        // raw: yyyy-MM-ddTHH:mm
        if (raw == null || raw.isBlank()) {
            throw new IllegalArgumentException("empty");
        }
        LocalDateTime ldt = LocalDateTime.parse(raw.trim());
        return Timestamp.valueOf(ldt);
    }

    private static boolean isValidImei15(String imei) {
        if (imei == null) {
            return false;
        }
        if (imei.length() != 15) {
            return false;
        }
        for (int i = 0; i < imei.length(); i++) {
            if (!Character.isDigit(imei.charAt(i))) {
                return false;
            }
        }
        return true;
    }

    // DTO nội bộ cho 1 dòng
    private static class RowInput {

        long productId;
        long skuId;
        int qty;
        List<String> imeis;
        String itemNote;

        RowInput(long productId, long skuId, int qty, List<String> imeis, String itemNote) {
            this.productId = productId;
            this.skuId = skuId;
            this.qty = qty;
            this.imeis = imeis;
            this.itemNote = itemNote;
        }
    }
}
