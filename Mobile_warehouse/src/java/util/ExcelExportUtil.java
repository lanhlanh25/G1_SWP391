/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.OutputStream;
import java.util.List;
import java.util.Map;

public class ExcelExportUtil {

    public static void export(
            OutputStream os,
            String title,
            Map<String, String> filters,
            Map<String, String> summary,
            List<String> headers,
            List<List<String>> rows
    ) throws Exception {

        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet(buildSafeSheetName(title));

            // ===== Fonts =====
            Font titleFont = wb.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 16);

            Font sectionFont = wb.createFont();
            sectionFont.setBold(true);
            sectionFont.setFontHeightInPoints((short) 11);

            Font labelFont = wb.createFont();
            labelFont.setBold(true);

            Font headerFont = wb.createFont();
            headerFont.setBold(true);

            Font normalFont = wb.createFont();
            normalFont.setFontHeightInPoints((short) 10);

            // ===== Data formats =====
            DataFormat dataFormat = wb.createDataFormat();

            // ===== Styles =====
            CellStyle titleStyle = wb.createCellStyle();
            titleStyle.setFont(titleFont);
            titleStyle.setAlignment(HorizontalAlignment.CENTER);
            titleStyle.setVerticalAlignment(VerticalAlignment.CENTER);

            CellStyle sectionStyle = wb.createCellStyle();
            sectionStyle.setFont(sectionFont);
            sectionStyle.setAlignment(HorizontalAlignment.LEFT);
            sectionStyle.setVerticalAlignment(VerticalAlignment.CENTER);

            CellStyle metaLabelStyle = wb.createCellStyle();
            metaLabelStyle.setFont(labelFont);
            metaLabelStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            setAllBorders(metaLabelStyle, BorderStyle.THIN);
            metaLabelStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            metaLabelStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            CellStyle metaValueStyle = wb.createCellStyle();
            metaValueStyle.setFont(normalFont);
            metaValueStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            setAllBorders(metaValueStyle, BorderStyle.THIN);
            metaValueStyle.setWrapText(true);

            CellStyle tableHeaderStyle = wb.createCellStyle();
            tableHeaderStyle.setFont(headerFont);
            tableHeaderStyle.setAlignment(HorizontalAlignment.CENTER);
            tableHeaderStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            tableHeaderStyle.setWrapText(true);
            setAllBorders(tableHeaderStyle, BorderStyle.THIN);
            tableHeaderStyle.setFillForegroundColor(IndexedColors.LIGHT_CORNFLOWER_BLUE.getIndex());
            tableHeaderStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            CellStyle textCellStyle = wb.createCellStyle();
            textCellStyle.setFont(normalFont);
            textCellStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            textCellStyle.setAlignment(HorizontalAlignment.LEFT);
            setAllBorders(textCellStyle, BorderStyle.THIN);

            CellStyle centerCellStyle = wb.createCellStyle();
            centerCellStyle.cloneStyleFrom(textCellStyle);
            centerCellStyle.setAlignment(HorizontalAlignment.CENTER);

            CellStyle numberCellStyle = wb.createCellStyle();
            numberCellStyle.cloneStyleFrom(textCellStyle);
            numberCellStyle.setAlignment(HorizontalAlignment.RIGHT);
            numberCellStyle.setDataFormat(dataFormat.getFormat("#,##0"));

            CellStyle decimalCellStyle = wb.createCellStyle();
            decimalCellStyle.cloneStyleFrom(textCellStyle);
            decimalCellStyle.setAlignment(HorizontalAlignment.RIGHT);
            decimalCellStyle.setDataFormat(dataFormat.getFormat("#,##0.00"));

            int rowIdx = 0;
            int totalCols = Math.max(headers == null ? 0 : headers.size(), 6);
            if (totalCols < 2) totalCols = 2;

            // ===== Title =====
            Row titleRow = sheet.createRow(rowIdx++);
            titleRow.setHeightInPoints(24f);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue(title == null ? "Report" : title);
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, totalCols - 1));

            rowIdx++;

            // ===== Filters section =====
            Row filterSectionRow = sheet.createRow(rowIdx++);
            Cell filterSectionCell = filterSectionRow.createCell(0);
            filterSectionCell.setCellValue("Filters");
            filterSectionCell.setCellStyle(sectionStyle);

            rowIdx = writeKeyValueBlock(sheet, rowIdx, filters, metaLabelStyle, metaValueStyle);

            rowIdx++;

            // ===== Summary section =====
            Row summarySectionRow = sheet.createRow(rowIdx++);
            Cell summarySectionCell = summarySectionRow.createCell(0);
            summarySectionCell.setCellValue("Summary");
            summarySectionCell.setCellStyle(sectionStyle);

            rowIdx = writeKeyValueBlock(sheet, rowIdx, summary, metaLabelStyle, metaValueStyle);

            rowIdx++;

            // ===== Data section =====
            Row dataSectionRow = sheet.createRow(rowIdx++);
            Cell dataSectionCell = dataSectionRow.createCell(0);
            dataSectionCell.setCellValue("Data");
            dataSectionCell.setCellStyle(sectionStyle);

            int headerRowIndex = rowIdx;
            Row headerRow = sheet.createRow(rowIdx++);
            headerRow.setHeightInPoints(22f);

            for (int i = 0; i < headers.size(); i++) {
                Cell c = headerRow.createCell(i);
                c.setCellValue(headers.get(i));
                c.setCellStyle(tableHeaderStyle);
            }

            // ===== Body rows =====
            if (rows != null) {
                for (List<String> rowData : rows) {
                    Row r = sheet.createRow(rowIdx++);
                    r.setHeightInPoints(20f);

                    for (int i = 0; i < headers.size(); i++) {
                        String val = (rowData != null && i < rowData.size() && rowData.get(i) != null)
                                ? rowData.get(i).trim()
                                : "";

                        Cell c = r.createCell(i);
                        writeTypedCell(c, val, headers.get(i), textCellStyle, centerCellStyle, numberCellStyle, decimalCellStyle);
                    }
                }
            }

            int lastDataRow = Math.max(headerRowIndex, rowIdx - 1);
            if (!headers.isEmpty()) {
                sheet.setAutoFilter(new CellRangeAddress(headerRowIndex, lastDataRow, 0, headers.size() - 1));
                sheet.createFreezePane(0, headerRowIndex + 1);
            }

            // ===== Column widths =====
            applyColumnWidths(sheet, headers);

            wb.write(os);
        }
    }

    private static int writeKeyValueBlock(
            Sheet sheet,
            int rowIdx,
            Map<String, String> data,
            CellStyle labelStyle,
            CellStyle valueStyle
    ) {
        if (data == null || data.isEmpty()) {
            return rowIdx;
        }

        for (Map.Entry<String, String> e : data.entrySet()) {
            Row r = sheet.createRow(rowIdx++);
            r.setHeightInPoints(19f);

            Cell c0 = r.createCell(0);
            c0.setCellValue(e.getKey());
            c0.setCellStyle(labelStyle);

            Cell c1 = r.createCell(1);
            c1.setCellValue(e.getValue() == null ? "" : e.getValue());
            c1.setCellStyle(valueStyle);
        }

        return rowIdx;
    }

    private static void writeTypedCell(
            Cell cell,
            String value,
            String header,
            CellStyle textStyle,
            CellStyle centerStyle,
            CellStyle numberStyle,
            CellStyle decimalStyle
    ) {
        if (isDecimalHeader(header) && isDecimal(value)) {
            cell.setCellValue(Double.parseDouble(value.replace(",", "")));
            cell.setCellStyle(decimalStyle);
            return;
        }

        if (isNumericHeader(header) && isInteger(value)) {
            cell.setCellValue(Long.parseLong(value.replace(",", "")));
            cell.setCellStyle(numberStyle);
            return;
        }

        if (isCenterHeader(header)) {
            cell.setCellValue(value);
            cell.setCellStyle(centerStyle);
            return;
        }

        cell.setCellValue(value);
        cell.setCellStyle(textStyle);
    }

    private static boolean isNumericHeader(String header) {
        String h = safe(header).toLowerCase();
        return h.contains("qty")
                || h.contains("quantity")
                || h.contains("stock")
                || h.contains("import")
                || h.contains("export")
                || h.contains("variance")
                || h.contains("products")
                || h.contains("units")
                || h.contains("count")
                || h.contains("rop")
                || h.contains("lead time")
                || h.contains("safety");
    }

    private static boolean isDecimalHeader(String header) {
        String h = safe(header).toLowerCase();
        return h.contains("avg daily sales") || h.contains("average");
    }

    private static boolean isCenterHeader(String header) {
        String h = safe(header).toLowerCase();
        return h.contains("status")
                || h.equals("#")
                || h.contains("date")
                || h.contains("unit");
    }

    private static boolean isInteger(String value) {
        if (value == null || value.isBlank()) return false;
        String v = value.replace(",", "").trim();
        return v.matches("-?\\d+");
    }

    private static boolean isDecimal(String value) {
        if (value == null || value.isBlank()) return false;
        String v = value.replace(",", "").trim();
        return v.matches("-?\\d+(\\.\\d+)?");
    }

    private static void applyColumnWidths(Sheet sheet, List<String> headers) {
        if (headers == null || headers.isEmpty()) return;

        for (int i = 0; i < headers.size(); i++) {
            String h = safe(headers.get(i)).toLowerCase();

            if (h.contains("product name")) {
                sheet.setColumnWidth(i, 28 * 256);
            } else if (h.contains("brand name") || h.equals("brand")) {
                sheet.setColumnWidth(i, 18 * 256);
            } else if (h.contains("product code") || h.contains("receipt code") || h.contains("sku")) {
                sheet.setColumnWidth(i, 18 * 256);
            } else if (h.contains("status")) {
                sheet.setColumnWidth(i, 16 * 256);
            } else if (h.contains("date")) {
                sheet.setColumnWidth(i, 20 * 256);
            } else if (h.contains("note")) {
                sheet.setColumnWidth(i, 30 * 256);
            } else {
                sheet.setColumnWidth(i, 14 * 256);
            }
        }
    }

    private static void setAllBorders(CellStyle style, BorderStyle borderStyle) {
        style.setBorderTop(borderStyle);
        style.setBorderBottom(borderStyle);
        style.setBorderLeft(borderStyle);
        style.setBorderRight(borderStyle);
    }

    private static String buildSafeSheetName(String title) {
        String s = safe(title).trim();
        if (s.isEmpty()) s = "Report";
        s = s.replaceAll("[\\\\/?*\\[\\]:]", "_");
        return s.length() > 31 ? s.substring(0, 31) : s;
    }

    private static String safe(String s) {
        return s == null ? "" : s;
    }
}