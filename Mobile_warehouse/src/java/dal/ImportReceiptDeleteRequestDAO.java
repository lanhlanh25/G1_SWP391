/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */
import model.ImportReceiptDeleteRequest;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ImportReceiptDeleteRequestDAO {
    
    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }
    
    public boolean createRequest(long importId, String importCode, String note, int requestedBy) throws SQLException {
        String sql = "INSERT INTO import_receipt_delete_requests(import_id, import_code, note, requested_by) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setLong(1, importId);
            ps.setString(2, importCode);
            ps.setString(3, note);
            ps.setInt(4, requestedBy);
            
            return ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new SQLException("Failed to create delete request", e);
        }
    }
    
    // Get import receipt info for request form
    public ImportReceiptDeleteRequest getImportInfoForRequest(long importId) throws SQLException {
        String sql = "SELECT ir.import_id, ir.import_code, ir.receipt_date, u.full_name " +
                     "FROM import_receipts ir " +
                     "JOIN users u ON u.user_id = ir.created_by " +
                     "WHERE ir.import_id = ?";
        
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setLong(1, importId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ImportReceiptDeleteRequest req = new ImportReceiptDeleteRequest();
                    req.setImportId(rs.getLong("import_id"));
                    req.setImportCode(rs.getString("import_code"));
                    req.setTransactionTime(rs.getTimestamp("receipt_date"));
                    req.setRequestedByName(rs.getString("full_name"));
                    return req;
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new SQLException("Failed to get import info", e);
        }
        
        return null;
    }
    
    public int countRequests(String importCodeSearch, java.sql.Date searchDate) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM import_receipt_delete_requests irdr " +
            "JOIN import_receipts ir ON ir.import_id = irdr.import_id " +
            "WHERE irdr.status = 'PENDING'"
        );
        
        List<Object> params = new ArrayList<>();
        
        if (importCodeSearch != null && !importCodeSearch.trim().isEmpty()) {
            sql.append(" AND irdr.import_code LIKE ?");
            params.add("%" + importCodeSearch.trim() + "%");
        }
        
        if (searchDate != null) {
            sql.append(" AND DATE(ir.receipt_date) = ?");
            params.add(searchDate);
        }
        
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    public List<ImportReceiptDeleteRequest> listRequests(String importCodeSearch, java.sql.Date searchDate, 
                                                         int page, int pageSize) throws SQLException {
        List<ImportReceiptDeleteRequest> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        
        StringBuilder sql = new StringBuilder(
            "SELECT irdr.request_id, irdr.import_id, irdr.import_code, irdr.note, " +
            "       irdr.requested_by, u.full_name AS requested_by_name, " +
            "       irdr.requested_at, ir.receipt_date AS transaction_time, " +
            "       irdr.status, irdr.decided_by, irdr.decided_at " +
            "FROM import_receipt_delete_requests irdr " +
            "JOIN users u ON u.user_id = irdr.requested_by " +
            "JOIN import_receipts ir ON ir.import_id = irdr.import_id " +
            "WHERE irdr.status = 'PENDING'"
        );
        
        List<Object> params = new ArrayList<>();
        
        if (importCodeSearch != null && !importCodeSearch.trim().isEmpty()) {
            sql.append(" AND irdr.import_code LIKE ?");
            params.add("%" + importCodeSearch.trim() + "%");
        }
        
        if (searchDate != null) {
            sql.append(" AND DATE(ir.receipt_date) = ?");
            params.add(searchDate);
        }
        
        sql.append(" ORDER BY irdr.requested_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(offset);
        
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportReceiptDeleteRequest req = new ImportReceiptDeleteRequest();
                    req.setRequestId(rs.getLong("request_id"));
                    req.setImportId(rs.getLong("import_id"));
                    req.setImportCode(rs.getString("import_code"));
                    req.setNote(rs.getString("note"));
                    req.setRequestedBy(rs.getInt("requested_by"));
                    req.setRequestedByName(rs.getString("requested_by_name"));
                    req.setRequestedAt(rs.getTimestamp("requested_at"));
                    req.setTransactionTime(rs.getTimestamp("transaction_time"));
                    req.setStatus(rs.getString("status"));
                    list.add(req);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return list;
    }
    
    public boolean approveRequest(long requestId, int managerId) throws SQLException {
        Connection con = null;
        try {
            con = getConn();
            con.setAutoCommit(false);
            
            String getSql = "SELECT import_id FROM import_receipt_delete_requests WHERE request_id = ?";
            long importId;
            
            try (PreparedStatement ps = con.prepareStatement(getSql)) {
                ps.setLong(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                    importId = rs.getLong("import_id");
                }
            }
            
            ImportReceiptListDAO dao = new ImportReceiptListDAO();
            
            String updateSql = "UPDATE import_receipt_delete_requests " +
                              "SET status = 'APPROVED', decided_by = ?, decided_at = NOW() " +
                              "WHERE request_id = ?";
            
            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setInt(1, managerId);
                ps.setLong(2, requestId);
                ps.executeUpdate();
            }
            
            con.commit();
            return true;
            
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ignored) {}
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }
    }
    
    public boolean rejectRequest(long requestId, int managerId) throws SQLException {
        String sql = "UPDATE import_receipt_delete_requests " +
                     "SET status = 'REJECTED', decided_by = ?, decided_at = NOW() " +
                     "WHERE request_id = ?";
        
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, managerId);
            ps.setLong(2, requestId);
            
            return ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}

