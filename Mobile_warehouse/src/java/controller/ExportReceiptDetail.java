/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.ExportReceiptDAO;
import model.ExportReceiptDetailHeader;
import model.ExportReceiptDetailLine;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 *
 * @author Admin
 */
@WebServlet(name = "ExportReceiptDetail", urlPatterns = {"/export-receipt-detail"})

public class ExportReceiptDetail extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/export-receipt-list?err=Missing+id");
            return;
        }

        long exportId;
        try {
            exportId = Long.parseLong(idRaw);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/export-receipt-list?err=Invalid+id");
            return;
        }

        ExportReceiptDAO dao = new ExportReceiptDAO();
        ExportReceiptDetailHeader receiptHeader = dao.getDetailHeader(exportId);
        List<ExportReceiptDetailLine> lines = dao.getDetailLines(exportId);

        req.setAttribute("receiptHeader", receiptHeader);
        req.setAttribute("lines", lines);

        req.getRequestDispatcher("/export_receipt_detail.jsp").forward(req, resp);
    }
}
