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

        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String status = "NEW";
        Date expected = parseSqlDate(request.getParameter("expected_export_date"));
        Date today = Date.valueOf(java.time.LocalDate.now());
        String note = request.getParameter("note");

        String[] productIds = request.getParameterValues("productId");
        String[] skuIds = request.getParameterValues("skuId");
        String[] qtys = request.getParameterValues("qty");

        List<String> errs = new ArrayList<>();
        List<ExportRequestItemCreate> items = new ArrayList<>();

        if (expected == null) {
            errs.add("Expected Export Date is required.");
        } else if (expected.before(today)) {
            errs.add("Expected Export Date cannot be in the past.");
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

                Long sid = sidVal;
                items.add(new ExportRequestItemCreate(pid, sid, q));
            }
        }

        if (!errs.isEmpty()) {
            String msg = String.join(" | ", errs);

            StringBuilder url = new StringBuilder();
            url.append(request.getContextPath())
                    .append("/home?p=create-export-request")
                    .append("&err=1")
                    .append("&errMsg=").append(safe(msg))
                    .append("&expected_export_date=").append(safe(expected == null ? "" : expected.toString()))
                    .append("&note=").append(safe(note == null ? "" : note));

            if (productIds != null) {
                for (String pid : productIds) {
                    url.append("&productId=").append(safe(pid == null ? "" : pid));
                }
            }

            if (skuIds != null) {
                for (String sid : skuIds) {
                    url.append("&skuId=").append(safe(sid == null ? "" : sid));
                }
            }

            if (qtys != null) {
                for (String q : qtys) {
                    url.append("&qty=").append(safe(q == null ? "" : q));
                }
            }

            response.sendRedirect(url.toString());
            return;
        }

        try {
            ExportRequestCreateDAO dao = new ExportRequestCreateDAO();
            long newId = dao.createRequest(userId, expected, note, status, items);

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
