package controller;

import dal.ImportRequestCreateDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ImportRequestItemCreate;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CreateImportRequestServlet", urlPatterns = {"/create-import-request"})
public class CreateImportRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String roleName = (String) request.getSession().getAttribute("roleName");
        if (roleName == null || !"SALE".equalsIgnoreCase(roleName)) {
            response.sendError(403, "Forbidden");
            return;
        }

        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String status = "PENDING";

        Date expected = parseSqlDate(request.getParameter("expected_import_date"));
        String note = request.getParameter("note");

        String[] productIds = request.getParameterValues("productId");
        String[] skuIds = request.getParameterValues("skuId");
        String[] qtys = request.getParameterValues("qty");

        List<String> errs = new ArrayList<>();
        List<ImportRequestItemCreate> items = new ArrayList<>();

        if (expected == null) {
            errs.add("Expected Import Date is required.");
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

                long sid = parseLong((skuIds != null && skuIds.length > i) ? skuIds[i] : null, -1);
                if (sid <= 0) {
                    errs.add("Item #" + (i + 1) + ": SKU is required.");
                    continue;
                }

                items.add(new ImportRequestItemCreate(pid, sid, q));
            }
        }

        if (!errs.isEmpty()) {
            String msg = String.join(" | ", errs);
            String url = request.getContextPath() + "/home?p=create-import-request"
                    + "&err=1"
                    + "&errMsg=" + safe(msg)
                    + "&expected_import_date=" + safe(expected == null ? "" : expected.toString())
                    + "&note=" + safe(note == null ? "" : note);
            response.sendRedirect(url);
            return;
        }

        try {
            ImportRequestCreateDAO dao = new ImportRequestCreateDAO();
            dao.createRequest(userId, expected, note, status, items);

            response.sendRedirect(request.getContextPath()
                    + "/home?p=import-request-list&msg=Created");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private Date parseSqlDate(String s) {
        try {
            if (s == null || s.trim().isEmpty()) {
                return null;
            }
            return Date.valueOf(s.trim());
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
