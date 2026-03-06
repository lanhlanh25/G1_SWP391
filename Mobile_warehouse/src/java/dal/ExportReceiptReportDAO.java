/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import model.ExportReceiptListItem;
import model.ExportReceiptReportSummary;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

/**
 * Export Receipt Report DAO: filter by date range, summary + list + paging.
 */
public class ExportReceiptReportDAO {

    public ExportReceiptReportSummary getSummary(Date from, Date to) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT " +
            "  COUNT(DISTINCT er.export_id) AS total_receipts, " +
            "  COALESCE(SUM(erl.qty), 0) AS total_qty " +
            "FROM export_receipts er " +
            "LEFT JOIN export_receipt_lines erl ON erl.export_id = er.export_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (from != null) {
            sql.append(" AND DATE(er.export_date) >= ? ");
            params.add(from);
        }
        if (to != null) {
            sql.append(" AND DATE(er.export_date) <= ? ");
            params.add(to);
        }

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                ExportReceiptReportSummary s = new ExportReceiptReportSummary();
                if (rs.next()) {
                    s.setTotalExportReceipts(rs.getInt("total_receipts"));
                    s.setTotalPhoneQuantity(rs.getInt("total_qty"));
                }
                return s;
            }
        }
    }

    public int count(Date from, Date to) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT er.export_id) " +
            "FROM export_receipts er " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (from != null) {
            sql.append(" AND DATE(er.export_date) >= ? ");
            params.add(from);
        }
        if (to != null) {
            sql.append(" AND DATE(er.export_date) <= ? ");
            params.add(to);
        }

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    public List<ExportReceiptListItem> list(Date from, Date to, int page, int pageSize) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT er.export_id, er.export_code, er.export_date, er.status, " +
            "       COALESCE(req.request_code, '-') AS request_code, " +
            "       COALESCE(SUM(erl.qty), 0) AS total_qty " +
            "FROM export_receipts er " +
            "LEFT JOIN export_requests req ON req.request_id = er.request_id " +
            "LEFT JOIN export_receipt_lines erl ON erl.export_id = er.export_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (from != null) {
            sql.append(" AND DATE(er.export_date) >= ? ");
            params.add(from);
        }
        if (to != null) {
            sql.append(" AND DATE(er.export_date) <= ? ");
            params.add(to);
        }

        sql.append(
            " GROUP BY er.export_id, er.export_code, er.export_date, er.status, req.request_code " +
            " ORDER BY er.export_id DESC " +
            " LIMIT ? OFFSET ? "
        );

        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<ExportReceiptListItem> out = new ArrayList<>();

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                while (rs.next()) {
                    ExportReceiptListItem it = new ExportReceiptListItem();
                    it.setExportId(rs.getLong("export_id"));
                    it.setExportCode(rs.getString("export_code"));
                    it.setRequestCode(rs.getString("request_code"));
                    it.setStatus(rs.getString("status"));
                    it.setTotalQty(rs.getInt("total_qty"));

                    Timestamp ts = rs.getTimestamp("export_date");
                    it.setExportDateUi(ts == null ? "" : sdf.format(ts));

                    out.add(it);
                }
            }
        }

        return out;
    }
}

