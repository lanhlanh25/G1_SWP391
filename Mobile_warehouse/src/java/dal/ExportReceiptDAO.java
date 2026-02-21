package dal;

import model.ExportReceiptListItem;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExportReceiptDAO extends DBContext {

    public List<ExportReceiptListItem> searchExportReceipts(String searchCode, String status, String fromDate, String toDate, int offset, int limit) throws Exception {
        List<ExportReceiptListItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT er.export_id, er.export_code, er.export_date, er.status, " +
            "u.full_name AS created_by_name, " +
            "COALESCE(SUM(erl.qty), 0) AS total_quantity " +
            "FROM export_receipts er " +
            "LEFT JOIN users u ON er.created_by = u.user_id " +
            "LEFT JOIN export_receipt_lines erl ON er.export_id = erl.export_id " +
            "WHERE 1=1 "
        );

        if (searchCode != null && !searchCode.trim().isEmpty()) {
            sql.append(" AND er.export_code LIKE ? ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND er.status = ? ");
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND DATE(er.export_date) >= ? ");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND DATE(er.export_date) <= ? ");
        }

        sql.append(" GROUP BY er.export_id, er.export_code, er.export_date, er.status, u.full_name ");
        sql.append(" ORDER BY er.export_date DESC ");
        sql.append(" LIMIT ? OFFSET ? ");

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (searchCode != null && !searchCode.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + searchCode.trim() + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(paramIndex++, fromDate);
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(paramIndex++, toDate);
            }
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ExportReceiptListItem item = new ExportReceiptListItem();
                    item.setExportId(rs.getLong("export_id"));
                    item.setReceiptCode(rs.getString("export_code"));
                    item.setCustomerName("Unknown"); 
                    item.setCreatedByName(rs.getString("created_by_name"));
                    item.setExportDate(rs.getTimestamp("export_date"));
                    item.setStatus(rs.getString("status"));
                    item.setTotalQuantity(rs.getInt("total_quantity"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countTotalExportReceipts(String searchCode, String status, String fromDate, String toDate) throws Exception {
        int total = 0;
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT er.export_id) FROM export_receipts er WHERE 1=1 "
        );

        if (searchCode != null && !searchCode.trim().isEmpty()) {
            sql.append(" AND er.export_code LIKE ? ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND er.status = ? ");
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND DATE(er.export_date) >= ? ");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND DATE(er.export_date) <= ? ");
        }

        try (PreparedStatement ps = getConnection().prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (searchCode != null && !searchCode.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + searchCode.trim() + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(paramIndex++, fromDate);
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(paramIndex++, toDate);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }
}