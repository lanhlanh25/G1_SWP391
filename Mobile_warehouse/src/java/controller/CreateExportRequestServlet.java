package controller;

import dal.ExportRequestCreateDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ExportRequestItemCreate;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CreateExportRequestServlet", urlPatterns = {"/create-export-request"})
public class CreateExportRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Role check
        String roleName = (String) request.getSession().getAttribute("roleName");
        if (roleName == null || !"SALE".equalsIgnoreCase(roleName)) {
            response.sendError(403, "Forbidden");
            return;
        }

        // user id (bạn đổi theo session của bạn)
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String status = "PENDING";
        Date expected = parseSqlDate(request.getParameter("expected_export_date"));
        String note = request.getParameter("note");

        String[] productIds = request.getParameterValues("productId");
        String[] skuIds = request.getParameterValues("skuId");
        String[] qtys = request.getParameterValues("qty");

        List<String> errs = new ArrayList<>();
        List<ExportRequestItemCreate> items = new ArrayList<>();

        if (expected == null) {
            errs.add("Expected Export Date is required.");
        }

        if (productIds == null || qtys == null || productIds.length == 0) {
            errs.add("Please add at least 1 item.");
        } else {
            for (int i = 0; i < productIds.length; i++) {
                long pid = parseLong(productIds[i], -1);
                int q = parseInt(qtys[i], -1);

                if (pid <= 0) {
                    errs.add("Item #" + (i + 1) + ": Product is required.");
                    continue;
                }
                if (q <= 0) {
                    errs.add("Item #" + (i + 1) + ": Qty must be > 0.");
                    continue;
                }

                String skuRaw = (skuIds != null && skuIds.length > i) ? skuIds[i] : null;
                long sidVal = parseLong(skuRaw, -1);

                if (sidVal <= 0) {
                    errs.add("Item #" + (i + 1) + ": SKU is required.");
                    continue;
                }

                Long sid = sidVal; // now always not null
                items.add(new ExportRequestItemCreate(pid, sid, q));
            }
        }

        if (!errs.isEmpty()) {
            String msg = String.join(" | ", errs); // gộp lỗi
            String url = request.getContextPath() + "/home?p=create-export-request"
                    + "&err=1"
                    + "&errMsg=" + safe(msg)
                    + "&expected_export_date=" + safe(expected == null ? "" : expected.toString())
                    + "&note=" + safe(note == null ? "" : note);
            response.sendRedirect(url);
            return;
        }

        try {
            ExportRequestCreateDAO dao = new ExportRequestCreateDAO();
            long newId = dao.createRequest(userId, expected, note, status, items);

            // sau khi tạo xong, có thể redirect sang detail (manager) hoặc list (sale)
            response.sendRedirect(request.getContextPath()
                    + "/home?p=export-request-list&msg=Created");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private Date parseSqlDate(String s) {
        try {
            if (s == null || s.trim().isEmpty()) {
                return null;
            }
            return Date.valueOf(s.trim()); // yyyy-MM-dd
        } catch (Exception e) {
            return null;
        }
    }

    private long parseLong(String s, long def) {
        try {
            return Long.parseLong(s);
        } catch (Exception e) {
            return def;
        }
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private String safe(String s) {
        try {
            return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8.toString());
        } catch (Exception e) {
            return "";
        }
    }
}
