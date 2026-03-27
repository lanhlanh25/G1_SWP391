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
import model.ProductQuantitySummary;
 
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
 
public class ExportReceiptReportDAO {
 
    public int count(Date from, Date to) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM export_receipts er WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        if (from != null) { sql.append(" AND DATE(er.export_date) >= ? "); params.add(from); }
        if (to   != null) { sql.append(" AND DATE(er.export_date) <= ? "); params.add(to);   }
 
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }
 
    public ExportReceiptReportSummary getSummary(Date from, Date to) {
        StringBuilder sql = new StringBuilder(
            "SELECT "
            + "  COUNT(DISTINCT er.export_id) AS total_receipts, "
            + "  COALESCE(SUM(erl.qty), 0) AS total_qty "
            + "FROM export_receipts er "
            + "LEFT JOIN export_receipt_lines erl ON erl.export_id = er.export_id "
            + "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        if (from != null) { sql.append(" AND DATE(er.export_date) >= ? "); params.add(from); }
        if (to   != null) { sql.append(" AND DATE(er.export_date) <= ? "); params.add(to);   }
 
        ExportReceiptReportSummary s = new ExportReceiptReportSummary();
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    s.setTotalExportReceipts(rs.getInt("total_receipts"));
                    s.setTotalItemQty(rs.getInt("total_qty"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return s;
    }
 
    public List<ExportReceiptListItem> list(Date from, Date to, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(
            "SELECT "
            + "  er.export_id, er.export_code, er.export_date, er.status, "
            + "  COALESCE(u.full_name, '-') AS created_by_name, "
            + "  COALESCE(SUM(erl.qty), 0) AS total_qty "
            + "FROM export_receipts er "
            + "LEFT JOIN users u ON u.user_id = er.created_by "
            + "LEFT JOIN export_receipt_lines erl ON erl.export_id = er.export_id "
            + "WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        if (from != null) { sql.append(" AND DATE(er.export_date) >= ? "); params.add(from); }
        if (to   != null) { sql.append(" AND DATE(er.export_date) <= ? "); params.add(to);   }
 
        sql.append(
            "GROUP BY er.export_id, er.export_code, er.export_date, er.status, u.full_name "
            + "ORDER BY er.export_id DESC "
            + "LIMIT ? OFFSET ? "
        );
        params.add(pageSize);
        params.add((page - 1) * pageSize);
 
        List<ExportReceiptListItem> out = new ArrayList<>();
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                while (rs.next()) {
                    ExportReceiptListItem it = new ExportReceiptListItem();
                    it.setExportId(rs.getLong("export_id"));
                    it.setExportCode(rs.getString("export_code"));
                    it.setCreatedByName(rs.getString("created_by_name"));
                    it.setStatus(rs.getString("status"));
                    int qty = rs.getInt("total_qty");
                    it.setTotalQuantity(qty);
                    it.setTotalQty(qty);
                    Timestamp ts = rs.getTimestamp("export_date");
                    it.setExportDate(ts);
                    it.setExportDateUi(ts == null ? "" : sdf.format(ts));
                    out.add(it);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }
 
    /**
     * Count distinct products exported in the given date range (CONFIRMED receipts only).
     */
    public int countByProduct(Date from, Date to) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT p.product_id) "
            + "FROM export_receipts er "
            + "JOIN export_receipt_lines erl ON erl.export_id = er.export_id "
            + "JOIN products p ON p.product_id = erl.product_id "
            + "WHERE UPPER(er.status) = 'CONFIRMED' "
        );
        List<Object> params = new ArrayList<>();
        if (from != null) { sql.append(" AND DATE(er.export_date) >= ? "); params.add(from); }
        if (to   != null) { sql.append(" AND DATE(er.export_date) <= ? "); params.add(to);   }
 
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }
 
    /**
     * Returns aggregated quantity per product from confirmed export receipts
     * filtered by date range. Used for the new Export Receipt Report table.
     */
    public List<ProductQuantitySummary> listByProduct(Date from, Date to, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(
            "SELECT p.product_id, p.product_code, p.product_name, SUM(erl.qty) AS total_qty "
            + "FROM export_receipts er "
            + "JOIN export_receipt_lines erl ON erl.export_id = er.export_id "
            + "JOIN products p ON p.product_id = erl.product_id "
            + "WHERE UPPER(er.status) = 'CONFIRMED' "
        );
        List<Object> params = new ArrayList<>();
        if (from != null) { sql.append(" AND DATE(er.export_date) >= ? "); params.add(from); }
        if (to   != null) { sql.append(" AND DATE(er.export_date) <= ? "); params.add(to);   }
 
        sql.append(" GROUP BY p.product_id, p.product_code, p.product_name ");
        sql.append(" ORDER BY total_qty DESC, p.product_name ASC ");
        sql.append(" LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add((page - 1) * pageSize);
 
        List<ProductQuantitySummary> out = new ArrayList<>();
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductQuantitySummary item = new ProductQuantitySummary();
                    item.setProductId(rs.getLong("product_id"));
                    item.setProductCode(rs.getString("product_code"));
                    item.setProductName(rs.getString("product_name"));
                    item.setTotalQuantity(rs.getInt("total_qty"));
                    out.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }
 
    /**
     * Returns total phone quantity (sum of all lines) from confirmed export receipts.
     */
    public int getTotalPhoneQty(Date from, Date to) {
        StringBuilder sql = new StringBuilder(
            "SELECT COALESCE(SUM(erl.qty), 0) "
            + "FROM export_receipts er "
            + "JOIN export_receipt_lines erl ON erl.export_id = er.export_id "
            + "WHERE UPPER(er.status) = 'CONFIRMED' "
        );
        List<Object> params = new ArrayList<>();
        if (from != null) { sql.append(" AND DATE(er.export_date) >= ? "); params.add(from); }
        if (to   != null) { sql.append(" AND DATE(er.export_date) <= ? "); params.add(to);   }
 
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }
}
