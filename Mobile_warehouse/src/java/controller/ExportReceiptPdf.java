/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
/**
 *
 * @author Admin
 */
package controller;

import dal.ExportReceiptDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ExportReceiptDetailHeader;
import model.ExportReceiptDetailLine;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.openpdf.text.*;
import org.openpdf.text.pdf.*;
import org.openpdf.text.pdf.draw.LineSeparator;

@WebServlet(name = "ExportReceiptPdf", urlPatterns = {"/export-receipt-pdf"})
public class ExportReceiptPdf extends HttpServlet {

    private static final Font H1 = new Font(Font.HELVETICA, 20, Font.BOLD);
    private static final Font H2 = new Font(Font.HELVETICA, 14, Font.BOLD);
    private static final Font B = new Font(Font.HELVETICA, 11, Font.BOLD);
    private static final Font N = new Font(Font.HELVETICA, 11, Font.NORMAL);
    private static final Font SMALL = new Font(Font.HELVETICA, 9, Font.NORMAL);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            resp.sendError(400, "Missing id");
            return;
        }

        long exportId;
        try {
            exportId = Long.parseLong(idRaw.trim());
        } catch (Exception e) {
            resp.sendError(400, "Invalid id");
            return;
        }

        ExportReceiptDAO dao = new ExportReceiptDAO();
        ExportReceiptDetailHeader header = dao.getDetailHeader(exportId);
        List<ExportReceiptDetailLine> lines = dao.getDetailLines(exportId);

        if (header == null) {
            resp.sendError(404, "Export receipt not found");
            return;
        }

        String fileName = "export-receipt-" + safe(header.getExportCode()) + ".pdf";
        String encoded = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");

        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encoded);

        Document doc = new Document(PageSize.A4, 48, 48, 42, 42);

        try {
            PdfWriter.getInstance(doc, resp.getOutputStream());
            doc.open();

            addHeader(doc, header);
            addItemsTable(doc, lines);
            addSummary(doc, lines);
            addSignatures(doc);
            addFooter(doc);

        } catch (Exception e) {
            throw new ServletException(e);
        } finally {
            if (doc.isOpen()) {
                doc.close();
            }
        }
    }

    private void addHeader(Document doc, ExportReceiptDetailHeader h) throws DocumentException {
        PdfPTable top = new PdfPTable(new float[]{70, 30});
        top.setWidthPercentage(100);

        PdfPCell left = cellNoBorder(new Phrase("Mobile Warehouse Management", H1));
        left.setPaddingBottom(6);
        top.addCell(left);

        PdfPCell right = cellNoBorder(new Phrase(
                "Receipt No: " + safe(h.getExportCode()) + "\n"
                + "Date: " + safe(h.getExportDateUi()), B));
        right.setHorizontalAlignment(Element.ALIGN_RIGHT);
        top.addCell(right);

        PdfPCell sub = cellNoBorder(new Phrase("[Address | Phone | Email]", SMALL));
        sub.setColspan(2);
        sub.setPaddingBottom(10);
        top.addCell(sub);

        doc.add(top);

        Paragraph title = new Paragraph("EXPORT RECEIPT", new Font(Font.HELVETICA, 16, Font.BOLD));
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingBefore(6);
        title.setSpacingAfter(6);
        doc.add(title);

        doc.add(lineSeparator());

        PdfPTable info = new PdfPTable(new float[]{55, 45});
        info.setWidthPercentage(100);

        String reqCode = (h.getRequestCode() == null || h.getRequestCode().isBlank()) ? "N/A" : h.getRequestCode();
        String createdBy = "";
        try { // phòng trường hợp model chưa có field createdByName
            createdBy = safe((String) ExportReceiptDetailHeader.class.getMethod("getCreatedByName").invoke(h));
        } catch (Exception ignore) {
        }

        info.addCell(cellNoBorder(new Phrase("Request code: " + reqCode, N)));
        info.addCell(cellNoBorder(new Phrase("Created by: " + createdBy, N)));

        info.addCell(cellNoBorder(new Phrase("Status: " + safe(h.getStatus()), N)));
        info.addCell(cellNoBorder(new Phrase("", N)));

        PdfPCell noteLabel = cellNoBorder(new Phrase("Note:", N));
        noteLabel.setColspan(2);
        noteLabel.setPaddingTop(6);
        info.addCell(noteLabel);

        PdfPCell noteVal = cellNoBorder(new Phrase(safe(h.getNote()), N));
        noteVal.setColspan(2);
        noteVal.setPaddingLeft(28);
        noteVal.setPaddingBottom(6);
        info.addCell(noteVal);

        doc.add(info);
        doc.add(lineSeparator());
    }

    private void addItemsTable(Document doc, List<ExportReceiptDetailLine> lines) throws DocumentException {
        Paragraph items = new Paragraph("ITEMS", H2);
        items.setSpacingBefore(6);
        items.setSpacingAfter(8);
        doc.add(items);

        PdfPTable t = new PdfPTable(new float[]{6, 22, 30, 10, 32});
        t.setWidthPercentage(100);

        t.addCell(th("#"));
        t.addCell(th("Product"));
        t.addCell(th("SKU"));
        t.addCell(th("Quantity"));
        t.addCell(th("IMEI List (optional)"));

        int idx = 1;
        if (lines != null) {
            for (ExportReceiptDetailLine it : lines) {
                t.addCell(td(String.valueOf(idx++), Element.ALIGN_LEFT));
                t.addCell(td(safe(it.getProductCode()), Element.ALIGN_LEFT));
                t.addCell(td(safe(it.getSkuCode()), Element.ALIGN_LEFT));
                t.addCell(td(String.valueOf(it.getQty()), Element.ALIGN_LEFT));

                String imeiText = formatImeis(it.getImeis(), 2); // 2 IMEI / dòng cho chắc chắn
                Phrase ph = new Phrase(imeiText, new Font(Font.HELVETICA, 10));
                PdfPCell imeiCell = new PdfPCell(ph);
                imeiCell.setPadding(6);
                imeiCell.setNoWrap(false);
                imeiCell.setLeading(0, 1.2f); // xuống dòng đẹp
                t.addCell(imeiCell);
            }
        }

        doc.add(t);
    }

    private void addSummary(Document doc, List<ExportReceiptDetailLine> lines) throws DocumentException {
        int totalLines = (lines == null) ? 0 : lines.size();
        int totalQty = 0;
        if (lines != null) {
            for (ExportReceiptDetailLine it : lines) {
                totalQty += it.getQty();
            }
        }

        Paragraph sumTitle = new Paragraph("Summary", B);
        sumTitle.setAlignment(Element.ALIGN_CENTER);
        sumTitle.setSpacingBefore(10);
        doc.add(sumTitle);

        Paragraph sum = new Paragraph(
                "Total lines: " + totalLines + "\n"
                + "Total qty: " + totalQty, N);
        sum.setAlignment(Element.ALIGN_CENTER);
        sum.setSpacingAfter(10);
        doc.add(sum);

        doc.add(lineSeparator());
    }

    private void addSignatures(Document doc) throws DocumentException {
        Paragraph sigTitle = new Paragraph("Signatures", B);
        sigTitle.setSpacingBefore(6);
        sigTitle.setSpacingAfter(8);
        doc.add(sigTitle);

        PdfPTable sig = new PdfPTable(new float[]{33, 34, 33});
        sig.setWidthPercentage(100);

        sig.addCell(sigBox("Warehouse staff"));
        sig.addCell(sigBox("Receiver"));
        sig.addCell(sigBox("Manager"));

        doc.add(sig);
    }

    private void addFooter(Document doc) throws DocumentException {
        doc.add(new Paragraph(" ", SMALL));
        String ts = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        Paragraph f = new Paragraph("Footer: Generated by Mobile WMS - " + ts, SMALL);
        f.setAlignment(Element.ALIGN_CENTER);
        f.setSpacingBefore(18);
        doc.add(f);
    }

    // ===== helpers =====
    private static PdfPCell th(String s) {
        PdfPCell c = new PdfPCell(new Phrase(s, B));
        c.setPadding(6);
        return c;
    }

    private static PdfPCell td(String s, int align) {
        PdfPCell c = new PdfPCell(new Phrase(s, N));
        c.setPadding(6);
        c.setHorizontalAlignment(align);
        c.setNoWrap(false);
        return c;
    }

    private static PdfPCell cellNoBorder(Phrase p) {
        PdfPCell c = new PdfPCell(p);
        c.setBorder(Rectangle.NO_BORDER);
        c.setPadding(0);
        return c;
    }

    private static LineSeparator lineSeparator() {
        LineSeparator ls = new LineSeparator();
        ls.setLineWidth(1f);
        ls.setPercentage(100);
        return ls;
    }

    private static PdfPCell sigBox(String title) {
        PdfPCell c = new PdfPCell();
        c.setBorder(Rectangle.NO_BORDER);

        Paragraph p1 = new Paragraph(title, B);
        p1.setSpacingAfter(4);
        c.addElement(p1);

        c.addElement(new Paragraph("(Full name + sign)", N));
        c.addElement(new Paragraph("Date: ____/____/______", N));
        c.setPaddingRight(10);

        return c;
    }

    private static String safe(String s) {
        return (s == null) ? "" : s;
    }

    private static String formatImeis(List<String> imeis, int perLine) {
        if (imeis == null || imeis.isEmpty()) {
            return "";
        }

        List<String> cleaned = new ArrayList<>();
        for (String s : imeis) {
            if (s == null) {
                continue;
            }
            s = s.trim();
            if (!s.isEmpty()) {
                cleaned.add(s);
            }
        }
        if (cleaned.isEmpty()) {
            return "";
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < cleaned.size(); i += perLine) {
            int end = Math.min(i + perLine, cleaned.size());
            if (sb.length() > 0) {
                sb.append("\n");           // xuống dòng giữa các group
            }
            sb.append(String.join(" ", cleaned.subList(i, end)));
        }
        return sb.toString();
    }

}
