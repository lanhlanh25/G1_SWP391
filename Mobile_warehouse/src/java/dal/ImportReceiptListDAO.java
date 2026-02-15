package dal;

import model.ImportReceiptListItem;

import java.sql.*;
import java.time.LocalDate;
import java.util.*;

public class ImportReceiptListDAO {

    private Connection openConn() throws SQLException {
        try {
            return DBContext.getConnection();
        } catch (Exception e) {
            throw new SQLException("Cannot open DB connection", e);
        }
    }

    // ✅ CASCADING DELETE - Reject all delete requests first, then delete receipt
    public boolean deleteDraft(long importId) throws SQLException {
        String checkSql = "SELECT status FROM import_receipts WHERE import_id=? FOR UPDATE";
        
        // ✅ Update delete requests to REJECTED (preserve history)
        String rejectRequests = "UPDATE import_receipt_delete_requests " +
                               "SET status='REJECTED', decided_by=NULL, decided_at=NOW() " +
                               "WHERE import_id=? AND status='PENDING'";
        
        // ✅ Delete in correct order: units -> lines -> receipt
        String delUnits = "DELETE FROM import_receipt_units WHERE line_id IN " +
                         "(SELECT line_id FROM import_receipt_lines WHERE import_id=?)";
        String delLines = "DELETE FROM import_receipt_lines WHERE import_id=?";
        String delReceipt = "DELETE FROM import_receipts WHERE import_id=?";

        try (Connection con = openConn()) {
            con.setAutoCommit(false);

            // Check status
            String curStatus;
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setLong(1, importId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                    curStatus = rs.getString(1);
                }
            }

            // ✅ Only allow delete DRAFT or PENDING
            if (curStatus == null) {
                con.rollback();
                return false;
            }

            String statusUpper = curStatus.toUpperCase();
            if (!"DRAFT".equals(statusUpper) && !"PENDING".equals(statusUpper)) {
                con.rollback();
                return false;
            }

            // ✅ Step 0: Reject all pending delete requests (preserve history)
            try (PreparedStatement ps = con.prepareStatement(rejectRequests)) {
                ps.setLong(1, importId);
                ps.executeUpdate();
            }

            // ✅ Step 1: Delete units (IMEIs)
            try (PreparedStatement ps = con.prepareStatement(delUnits)) {
                ps.setLong(1, importId);
                ps.executeUpdate();
            }

            // ✅ Step 2: Delete lines
            try (PreparedStatement ps = con.prepareStatement(delLines)) {
                ps.setLong(1, importId);
                ps.executeUpdate();
            }

            // ✅ Step 3: Delete receipt
            int affected;
            try (PreparedStatement ps = con.prepareStatement(delReceipt)) {
                ps.setLong(1, importId);
                affected = ps.executeUpdate();
            }

            con.commit();
            return affected > 0;
        }
    }

    // Count by UI status (for tabs)
    public Map<String, Integer> countByUiStatus(String q, LocalDate from, LocalDate to) throws SQLException {
        Map<String, Integer> m = new LinkedHashMap<>();
        m.put("all", 0);
        m.put("pending", 0);
        m.put("completed", 0);
        m.put("cancelled", 0);

        String sql = "SELECT status, COUNT(*) AS cnt FROM import_receipts ir " +
                     "WHERE 1=1 " +
                     (q != null && !q.isBlank() ? " AND ir.import_code LIKE ? " : "") +
                     (from != null ? " AND DATE(ir.receipt_date) >= ? " : "") +
                     (to != null ? " AND DATE(ir.receipt_date) <= ? " : "") +
                     "GROUP BY status";

        try (Connection con = openConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int idx = 1;
            if (q != null && !q.isBlank()) ps.setString(idx++, "%" + q + "%");
            if (from != null) ps.setDate(idx++, java.sql.Date.valueOf(from));
            if (to != null) ps.setDate(idx++, java.sql.Date.valueOf(to));

            int total = 0;
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String st = rs.getString("status");
                    int cnt = rs.getInt("cnt");
                    total += cnt;

                    if (st == null) continue;
                    String uiStatus = mapDbToUiStatus(st);
                    m.put(uiStatus, m.getOrDefault(uiStatus, 0) + cnt);
                }
            }
            m.put("all", total);
        }
        return m;
    }

    // Count items
    public int count(String q, String uiStatus, LocalDate from, LocalDate to) throws SQLException {
        String sql = "SELECT COUNT(*) FROM import_receipts ir WHERE 1=1 " +
                     buildWhere(q, uiStatus, from, to);

        try (Connection con = openConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            setParams(ps, q, uiStatus, from, to);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // List items with pagination
    public List<ImportReceiptListItem> list(String q, String uiStatus, LocalDate from, LocalDate to,
                                           int page, int pageSize) throws SQLException {
        String sql =
            "SELECT ir.import_id, ir.import_code, s.supplier_name, " +
            "       u.full_name AS created_by_name, ir.receipt_date, ir.status, " +
            "       COALESCE(SUM(irl.qty), 0) AS total_qty " +
            "FROM import_receipts ir " +
            "LEFT JOIN suppliers s ON s.supplier_id = ir.supplier_id " +
            "LEFT JOIN users u ON u.user_id = ir.created_by " +
            "LEFT JOIN import_receipt_lines irl ON irl.import_id = ir.import_id " +
            "WHERE 1=1 " +
            buildWhere(q, uiStatus, from, to) +
            "GROUP BY ir.import_id, ir.import_code, s.supplier_name, u.full_name, ir.receipt_date, ir.status " +
            "ORDER BY ir.receipt_date DESC " +
            "LIMIT ? OFFSET ?";

        List<ImportReceiptListItem> out = new ArrayList<>();
        try (Connection con = openConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int idx = setParams(ps, q, uiStatus, from, to);
            ps.setInt(idx++, pageSize);
            ps.setInt(idx, (page - 1) * pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportReceiptListItem it = new ImportReceiptListItem();
                    it.setImportId(rs.getLong("import_id"));
                    it.setImportCode(rs.getString("import_code"));
                    it.setSupplierName(rs.getString("supplier_name"));
                    it.setCreatedByName(rs.getString("created_by_name"));
                    it.setReceiptDate(rs.getTimestamp("receipt_date"));
                    it.setStatus(rs.getString("status"));
                    it.setTotalQuantity(rs.getInt("total_qty"));
                    out.add(it);
                }
            }
        }
        return out;
    }

    // Build WHERE clause
    private String buildWhere(String q, String uiStatus, LocalDate from, LocalDate to) {
        StringBuilder sb = new StringBuilder();
        if (q != null && !q.isBlank()) sb.append(" AND ir.import_code LIKE ? ");
        if (from != null) sb.append(" AND DATE(ir.receipt_date) >= ? ");
        if (to != null) sb.append(" AND DATE(ir.receipt_date) <= ? ");
        if (uiStatus != null && !"all".equalsIgnoreCase(uiStatus)) {
            sb.append(" AND ").append(mapUiStatusToDbCondition(uiStatus));
        }
        return sb.toString();
    }

    // Set parameters
    private int setParams(PreparedStatement ps, String q, String uiStatus,
                         LocalDate from, LocalDate to) throws SQLException {
        int idx = 1;
        if (q != null && !q.isBlank()) ps.setString(idx++, "%" + q + "%");
        if (from != null) ps.setDate(idx++, java.sql.Date.valueOf(from));
        if (to != null) ps.setDate(idx++, java.sql.Date.valueOf(to));
        return idx;
    }

    // Map DB status to UI status
    private String mapDbToUiStatus(String dbStatus) {
        if (dbStatus == null) return "pending";
        switch (dbStatus.toUpperCase()) {
            case "DRAFT":
            case "PENDING":
                return "pending";
            case "CONFIRMED":
                return "completed";
            case "CANCELED":
            case "CANCELLED":
                return "cancelled";
            default:
                return "pending";
        }
    }

    // Map UI status to DB condition
    private String mapUiStatusToDbCondition(String uiStatus) {
        if (uiStatus == null) return "1=1";
        switch (uiStatus.toLowerCase()) {
            case "pending":
                return "(ir.status IN ('DRAFT','PENDING'))";
            case "completed":
                return "(ir.status='CONFIRMED')";
            case "cancelled":
                return "(ir.status IN ('CANCELED','CANCELLED'))";
            default:
                return "1=1";
        }
    }
}
