/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.ExportReceiptDAO;
import jakarta.servlet.http.HttpServletRequest;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import model.ExportReceiptListItem;

public class ExportReceiptList {

    public static void handle(HttpServletRequest request) throws Exception {

        ExportReceiptDAO dao = new ExportReceiptDAO();

        String q = request.getParameter("q");
        String status = request.getParameter("status");
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

        if (status == null || status.isBlank()) {
            status = "all";
        }

        status = status.trim().toLowerCase();

        String statusForDao = status;
        if (!"all".equals(status)) {
            statusForDao = status.toUpperCase();
        }

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (Exception ignore) {}

        int pageSize = 10;

        int totalItems = dao.countList(q, statusForDao, fromDate, toDate);
        int totalPages = (int) Math.ceil(totalItems * 1.0 / pageSize);

        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<ExportReceiptListItem> rows =
                dao.list(q, statusForDao, fromDate, toDate, page, pageSize);

        Map<String, Integer> tabCounts = new HashMap<>();
        tabCounts.put("all", dao.countList(q, "ALL", fromDate, toDate));
        tabCounts.put("pending", dao.countList(q, "PENDING", fromDate, toDate));
        tabCounts.put("completed", dao.countList(q, "COMPLETED", fromDate, toDate));
        tabCounts.put("cancelled", dao.countList(q, "CANCELLED", fromDate, toDate));

        request.setAttribute("tabCounts", tabCounts);
        request.setAttribute("rows", rows);

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