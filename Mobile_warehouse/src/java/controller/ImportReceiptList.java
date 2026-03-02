package controller;

import dal.ImportReceiptDAO;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;

import model.ImportReceiptListItem;

public class ImportReceiptList {

public static void handle(HttpServletRequest request) throws Exception{
        ImportReceiptDAO dao = new ImportReceiptDAO();

        String q = request.getParameter("q");
        String fromRaw = request.getParameter("from");
        String toRaw = request.getParameter("to");

        java.sql.Date fromDate = null;
        java.sql.Date toDate = null;

        try {
            if (fromRaw != null && !fromRaw.isBlank()) {
                fromDate = java.sql.Date.valueOf(fromRaw.trim());
            }
        } catch (Exception ignore) {}

        try {
            if (toRaw != null && !toRaw.isBlank()) {
                toDate = java.sql.Date.valueOf(toRaw.trim());
            }
        } catch (Exception ignore) {}

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (Exception ignore) {}

        int pageSize = 10;

        int totalItems = dao.countList(q, fromDate, toDate);
        int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);

        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<ImportReceiptListItem> rows =
                dao.list(q, fromDate, toDate, page, pageSize);

        request.setAttribute("rows", rows);

        request.setAttribute("q", q);
        request.setAttribute("from", fromRaw);
        request.setAttribute("to", toRaw);

        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
    }
}