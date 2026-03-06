/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import java.sql.*;
import java.util.*;
import model.ImportReceiptListItem;
import model.ImportReceiptReportSummary;

public class ImportReceiptReportDAO {

    private void appendFilters(StringBuilder sql, List<Object> params,
                               java.sql.Date from, java.sql.Date to,
                               Long supplierId, String status) {

        if (from != null) {
            sql.append(" AND ir.receipt_date >= ? ");
            params.add(from);
        }
        if (to != null) {
            sql.append(" AND ir.receipt_date <= ? ");
            params.add(to);
        }
        if (supplierId != null) {
            sql.append(" AND ir.supplier_id = ? ");
            params.add(supplierId);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND UPPER(ir.status) = UPPER(?) ");
            params.add(status.trim());
        }
    }

    public ImportReceiptReportSummary getSummary(java.sql.Date from, java.sql.Date to,
                                                 Long supplierId, String status) throws Exception {

        StringBuilder sql = new StringBuilder(
            "SELECT " +
            "  COUNT(*) AS total_receipts, " +
            "  COALESCE(SUM(x.total_qty),0) AS total_phone_qty, " +
            "  SUM(CASE WHEN UPPER(ir.status) = 'CONFIRMED' THEN 1 ELSE 0 END) AS completed_count, " +
            "  SUM(CASE WHEN UPPER(ir.status) IN ('CANCELED','CANCELLED') THEN 1 ELSE 0 END) AS cancelled_count " +
            "FROM import_receipts ir " +
            "LEFT JOIN (SELECT import_id, SUM(qty) AS total_qty FROM import_receipt_lines GROUP BY import_id) x " +
            "  ON x.import_id = ir.import_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, from, to, supplierId, status);

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object p : params) ps.setObject(idx++, p);

            try (ResultSet rs = ps.executeQuery()) {
                ImportReceiptReportSummary s = new ImportReceiptReportSummary();
                if (rs.next()) {
                    s.setTotalReceipts(rs.getInt("total_receipts"));
                    s.setTotalPhoneQty(rs.getInt("total_phone_qty"));
                    s.setCompletedCount(rs.getInt("completed_count"));
                    s.setCancelledCount(rs.getInt("cancelled_count"));
                }
                return s;
            }
        }
    }

    public int count(java.sql.Date from, java.sql.Date to,
                     Long supplierId, String status) throws Exception {

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM import_receipts ir WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, from, to, supplierId, status);

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object p : params) ps.setObject(idx++, p);

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    public List<ImportReceiptListItem> list(java.sql.Date from, java.sql.Date to,
                                           Long supplierId, String status,
                                           int page, int pageSize) throws Exception {

        StringBuilder sql = new StringBuilder(
            "SELECT " +
            "  ir.import_id, ir.import_code, ir.receipt_date, ir.status, " +
            "  s.supplier_name, u.full_name AS created_by_name, " +
            "  COALESCE(x.total_qty,0) AS total_qty " +
            "FROM import_receipts ir " +
            "JOIN suppliers s ON s.supplier_id = ir.supplier_id " +
            "JOIN users u ON u.user_id = ir.created_by " +
            "LEFT JOIN (SELECT import_id, SUM(qty) AS total_qty FROM import_receipt_lines GROUP BY import_id) x " +
            "  ON x.import_id = ir.import_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, from, to, supplierId, status);

        sql.append(" ORDER BY ir.receipt_date DESC, ir.import_id DESC LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int idx = 1;
            for (Object p : params) ps.setObject(idx++, p);

            try (ResultSet rs = ps.executeQuery()) {
                List<ImportReceiptListItem> out = new ArrayList<>();
                while (rs.next()) {
                    ImportReceiptListItem it = new ImportReceiptListItem();
                    it.setImportId(rs.getLong("import_id"));
                    it.setImportCode(rs.getString("import_code"));
                    it.setReceiptDate(rs.getTimestamp("receipt_date"));
                    it.setSupplierName(rs.getString("supplier_name"));
                    it.setCreatedByName(rs.getString("created_by_name"));
                    it.setTotalQuantity(rs.getInt("total_qty"));
                    it.setStatus(rs.getString("status"));
                    out.add(it);
                }
                return out;
            }
        }
    }
}

