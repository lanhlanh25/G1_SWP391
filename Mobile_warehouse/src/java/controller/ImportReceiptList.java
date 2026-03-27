package controller;


import dal.ImportReceiptListDAO;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import model.ImportReceiptListItem;

public class ImportReceiptList {

    public static void handle(HttpServletRequest request) throws Exception {
        ImportReceiptListDAO dao = new ImportReceiptListDAO();

        // ✅ Lấy và trim tất cả input
        String q       = request.getParameter("q");
        String status  = request.getParameter("status");
        String fromRaw = request.getParameter("from");
        String toRaw   = request.getParameter("to");

        q       = (q       != null) ? q.trim()       : null;
        status  = (status  != null) ? status.trim()  : null;
        fromRaw = (fromRaw != null) ? fromRaw.trim() : null;
        toRaw   = (toRaw   != null) ? toRaw.trim()   : null;

        // ✅ Normalize blank → null / default
        if (q      != null && q.isEmpty())      q      = null;
        if (fromRaw != null && fromRaw.isEmpty()) fromRaw = null;
        if (toRaw   != null && toRaw.isEmpty())   toRaw   = null;
        if (status == null  || status.isEmpty()) status = "all";

        // Parse date
        LocalDate from = null, to = null;
        try {
            if (fromRaw != null) from = LocalDate.parse(fromRaw);
        } catch (Exception ignore) {}
        try {
            if (toRaw != null) to = LocalDate.parse(toRaw);
        } catch (Exception ignore) {}

        // Pagination
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (Exception ignore) {}

        int pageSize   = 10;
        int totalItems = dao.count(q, status, from, to);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems * 1.0 / pageSize));
        if (page > totalPages) page = totalPages;

        List<ImportReceiptListItem> rows      = dao.list(q, status, from, to, page, pageSize);
        Map<String, Integer>        tabCounts = dao.countByUiStatus(q, from, to);

        // Set attributes — dùng empty string thay vì null cho JSP
        request.setAttribute("rows",       rows);
        request.setAttribute("tabCounts",  tabCounts);
        request.setAttribute("q",          q      != null ? q      : "");
        request.setAttribute("status",     status);
        request.setAttribute("from",       fromRaw != null ? fromRaw : "");
        request.setAttribute("to",         toRaw   != null ? toRaw   : "");
        request.setAttribute("page",       page);
        request.setAttribute("pageSize",   pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
    }
}