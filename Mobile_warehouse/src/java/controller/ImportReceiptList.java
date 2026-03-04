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

        String q = request.getParameter("q");
        String status = request.getParameter("status");
        String fromRaw = request.getParameter("from");
        String toRaw = request.getParameter("to");

        LocalDate from = null;
        LocalDate to = null;

        try {
            if (fromRaw != null && !fromRaw.isBlank()) {
                from = LocalDate.parse(fromRaw);
            }
        } catch (Exception ignore) {}

        try {
            if (toRaw != null && !toRaw.isBlank()) {
                to = LocalDate.parse(toRaw);
            }
        } catch (Exception ignore) {}

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (Exception ignore) {}

        int pageSize = 10;

        int totalItems = dao.count(q, status, from, to);
        int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);

        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<ImportReceiptListItem> rows =
                dao.list(q, status, from, to, page, pageSize);

        Map<String, Integer> tabCounts =
                dao.countByUiStatus(q, from, to);

        request.setAttribute("rows", rows);
        request.setAttribute("tabCounts", tabCounts);

        request.setAttribute("q", q);
        request.setAttribute("status", status);
        request.setAttribute("from", fromRaw);
        request.setAttribute("to", toRaw);

        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
    }
}