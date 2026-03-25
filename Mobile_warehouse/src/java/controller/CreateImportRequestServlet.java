package controller;

import dal.ImportRequestCreateDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ImportRequestItemCreate;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "CreateImportRequestServlet", urlPatterns = {"/create-import-request"})
public class CreateImportRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String roleName = (session == null) ? null : (String) session.getAttribute("roleName");

        if (roleName == null || !("SALE".equalsIgnoreCase(roleName) || "MANAGER".equalsIgnoreCase(roleName))) {
            response.sendError(403, "Forbidden");
            return;
        }

        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String status = "NEW";

        Date expected = parseSqlDate(request.getParameter("expected_import_date"));
        Date today = Date.valueOf(java.time.LocalDate.now());
        String note = request.getParameter("note");

        String sourcePage = request.getParameter("sourcePage");
        String sourceProductIdRaw = request.getParameter("sourceProductId");
        boolean fromLowStock = "low-stock-report".equalsIgnoreCase(sourcePage);

        String[] productIds = request.getParameterValues("productId");
        String[] skuIds = request.getParameterValues("skuId");
        String[] qtys = request.getParameterValues("qty");

        List<String> errs = new ArrayList<>();
        List<ImportRequestItemCreate> items = new ArrayList<>();

        try {
            ImportRequestCreateDAO dao = new ImportRequestCreateDAO();

            if (expected == null) {
                errs.add("Expected Import Date is required.");
            } else if (expected.before(today)) {
                errs.add("Expected Import Date cannot be in the past.");
            }

            Long sourceProductId = null;
            if (fromLowStock) {
                sourceProductId = parseLongObj(sourceProductIdRaw);

                if (sourceProductId == null || sourceProductId <= 0) {
                    errs.add("Invalid source product from Low Stock Report.");
                } else if (!dao.isProductExists(sourceProductId)) {
                    errs.add("Source product does not exist.");
                } else if (dao.hasActiveImportRequestForProduct(sourceProductId)) {
                    errs.add("An active import request already exists for this product.");
                }
            }

            if (productIds == null || skuIds == null || qtys == null
                    || productIds.length == 0 || skuIds.length == 0 || qtys.length == 0) {
                errs.add("Please add at least 1 item.");
            } else if (!(productIds.length == skuIds.length && skuIds.length == qtys.length)) {
                errs.add("Invalid item data.");
            } else {

                Set<Long> productSet = new LinkedHashSet<>();
                Set<Long> uniqueSkuSet = new LinkedHashSet<>();

                for (int i = 0; i < productIds.length; i++) {
                    String productIdRaw = productIds[i] == null ? "" : productIds[i].trim();
                    String skuIdRaw = (skuIds.length > i && skuIds[i] != null) ? skuIds[i].trim() : "";
                    String qtyRaw = qtys[i] == null ? "" : qtys[i].trim();

                    long pid = parseLong(productIdRaw, -1);
                    long sid = parseLong(skuIdRaw, -1);
                    int q = parseInt(qtyRaw, -1);

                    if (pid <= 0) {
                        errs.add("Item #" + (i + 1) + ": Product is required.");
                        continue;
                    }

                    if (!dao.isProductExists(pid)) {
                        errs.add("Item #" + (i + 1) + ": Product does not exist.");
                        continue;
                    }

                    if (fromLowStock && sourceProductId != null && pid != sourceProductId.longValue()) {
                        errs.add("Item #" + (i + 1) + ": Product must match the selected low stock product.");
                        continue;
                    }

                    if (sid <= 0) {
                        errs.add("Item #" + (i + 1) + ": SKU is required.");
                        continue;
                    }

                    if (!dao.isSkuExists(sid)) {
                        errs.add("Item #" + (i + 1) + ": SKU does not exist.");
                        continue;
                    }

                    if (!dao.isSkuBelongsToProduct(sid, pid)) {
                        errs.add("Item #" + (i + 1) + ": SKU does not belong to selected product.");
                        continue;
                    }

                    if (q <= 0) {
                        errs.add("Item #" + (i + 1) + ": Qty must be > 0.");
                        continue;
                    }

                    if (uniqueSkuSet.contains(sid)) {
                        errs.add("Item #" + (i + 1) + ": Duplicate SKU is not allowed.");
                        continue;
                    }

                    productSet.add(pid);
                    uniqueSkuSet.add(sid);
                    items.add(new ImportRequestItemCreate(pid, sid, q));
                }

                if (fromLowStock && sourceProductId != null) {
                    if (productSet.isEmpty()) {
                        errs.add("Import request from Low Stock Report must contain at least 1 SKU.");
                    } else if (productSet.size() != 1 || !productSet.contains(sourceProductId)) {
                        errs.add("Import request from Low Stock Report must contain only the selected product.");
                    }
                }
            }

            if (!errs.isEmpty()) {
                String msg = String.join(" | ", errs);

                StringBuilder url = new StringBuilder();
                url.append(request.getContextPath())
                        .append("/home?p=create-import-request")
                        .append("&err=1")
                        .append("&errMsg=").append(safe(msg))
                        .append("&expected_import_date=").append(safe(expected == null ? "" : expected.toString()))
                        .append("&note=").append(safe(note == null ? "" : note));

                if (fromLowStock && sourceProductIdRaw != null && !sourceProductIdRaw.isBlank()) {
                    url.append("&productId=").append(safe(sourceProductIdRaw));
                }

                response.sendRedirect(url.toString());
                return;
            }

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

    private Long parseLongObj(String s) {
        try {
            if (s == null || s.trim().isEmpty()) {
                return null;
            }
            return Long.parseLong(s.trim());
        } catch (Exception e) {
            return null;
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
