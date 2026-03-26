package dal;

import model.ImportRequest;
import model.ImportRequestItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ImportRequestDAO {

    public int count(String q, java.sql.Date reqDate, java.sql.Date expDate, Long requestedBy) throws Exception {
        return count(q, null, reqDate, expDate, requestedBy);
    }

    public int count(String q, String status, java.sql.Date reqDate, java.sql.Date expDate, Long requestedBy) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*)
            FROM import_requests ir
            WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND ir.request_code LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND ir.status = ? ");
            params.add(status.trim());
        }
        if (reqDate != null) {
            sql.append(" AND DATE(ir.requested_at) = ? ");
            params.add(reqDate);
        }
        if (expDate != null) {
            sql.append(" AND ir.expected_import_date = ? ");
            params.add(expDate);
        }
        if (requestedBy != null) {
            sql.append(" AND ir.requested_by = ? ");
            params.add(requestedBy);
        }
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<ImportRequest> list(String q, java.sql.Date reqDate, java.sql.Date expDate, Long requestedBy,
            int offset, int limit) throws Exception {
        return list(q, null, reqDate, expDate, requestedBy, offset, limit);
    }

    public List<ImportRequest> list(String q, String status, java.sql.Date reqDate, java.sql.Date expDate,
            Long requestedBy, int offset, int limit) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT
              ir.request_id,
              ir.request_code,
              ir.requested_by,
              u.full_name AS created_by_name,
              ir.requested_at,
              ir.expected_import_date,
              COALESCE(x.total_items,0) AS total_items,
              COALESCE(x.total_qty,0) AS total_qty,
              ir.status
            FROM import_requests ir
            LEFT JOIN users u ON u.user_id = ir.requested_by
            LEFT JOIN (
              SELECT request_id, COUNT(*) total_items, COALESCE(SUM(qty),0) total_qty
              FROM import_request_lines
              GROUP BY request_id
            ) x ON x.request_id = ir.request_id
            WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND ir.request_code LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND ir.status = ? ");
            params.add(status.trim());
        }
        if (reqDate != null) {
            sql.append(" AND DATE(ir.requested_at) = ? ");
            params.add(reqDate);
        }
        if (expDate != null) {
            sql.append(" AND ir.expected_import_date = ? ");
            params.add(expDate);
        }
        if (requestedBy != null) {
            sql.append(" AND ir.requested_by = ? ");
            params.add(requestedBy);
        }
        sql.append(" ORDER BY ir.requested_at DESC, ir.request_id DESC ");
        sql.append(" LIMIT ? OFFSET ? ");
        params.add(limit);
        params.add(offset);
        List<ImportRequest> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportRequest r = new ImportRequest();
                    r.setRequestId(rs.getLong("request_id"));
                    r.setRequestCode(rs.getString("request_code"));
                    r.setCreatedBy(rs.getLong("requested_by"));
                    r.setCreatedByName(rs.getString("created_by_name"));
                    r.setRequestDate(rs.getTimestamp("requested_at"));
                    r.setExpectedImportDate(rs.getDate("expected_import_date"));
                    r.setTotalItems(rs.getInt("total_items"));
                    r.setTotalQty(rs.getInt("total_qty"));
                    r.setStatus(rs.getString("status"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public ImportRequest getHeader(long requestId) throws Exception {
        String sql = """
            SELECT
              ir.request_id, ir.request_code, ir.requested_by,
              u.full_name AS created_by_name,
              ir.requested_at, ir.expected_import_date, ir.status, ir.note
            FROM import_requests ir
            LEFT JOIN users u ON u.user_id = ir.requested_by
            WHERE ir.request_id = ?
        """;
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ImportRequest r = new ImportRequest();
                r.setRequestId(rs.getLong("request_id"));
                r.setRequestCode(rs.getString("request_code"));
                r.setCreatedBy(rs.getLong("requested_by"));
                r.setCreatedByName(rs.getString("created_by_name"));
                r.setRequestDate(rs.getTimestamp("requested_at"));
                r.setExpectedImportDate(rs.getDate("expected_import_date"));
                r.setStatus(rs.getString("status"));
                return r;
            }
        }
    }

    /**
     * Used in Import Request Detail page — display only
     */
    public List<ImportRequestItem> listItems(long requestId) throws Exception {
        String sql = """
            SELECT 
                        p.product_id,
                        p.product_name,
                        p.product_code,
                        s.sku_id,
                        s.sku_code,
                        irl.qty
                    FROM import_request_lines irl
                    JOIN products p ON p.product_id = irl.product_id
                    JOIN product_skus s ON s.sku_id = irl.sku_id
                    WHERE irl.request_id = ?
                    ORDER BY irl.line_id ASC
        """;
        List<ImportRequestItem> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                int no = 1;
                while (rs.next()) {
                    ImportRequestItem it = new ImportRequestItem();
                    it.setNo(no++);
                    it.setProductId(rs.getLong("product_id"));
                    it.setProductName(rs.getString("product_name")); // ⭐ thêm dòng này
                    it.setProductCode(rs.getString("product_code"));
                    it.setSkuId(rs.getLong("sku_id"));
                    it.setSkuCode(rs.getString("sku_code"));
                    it.setRequestQty(rs.getInt("qty"));
                    list.add(it);
                }
            }
        }
        return list;
    }

    /**
     * Used when STAFF clicks "Create" on Import Request List. Returns full data
     * (productId, skuId, productName, productCode, skuCode, qty) so the Create
     * Import Receipt page can be pre-filled.
     */
    public List<ImportRequestItem> listItemsForReceipt(long requestId) throws Exception {
        String sql = """
            SELECT
              p.product_id,
              p.product_code,
              p.product_name,
              s.sku_id,
              s.sku_code,
              irl.qty
            FROM import_request_lines irl
            JOIN products p ON p.product_id = irl.product_id
            JOIN product_skus s ON s.sku_id = irl.sku_id
            WHERE irl.request_id = ?
            ORDER BY irl.line_id ASC
        """;
        List<ImportRequestItem> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                int no = 1;
                while (rs.next()) {
                    ImportRequestItem it = new ImportRequestItem();
                    it.setNo(no++);
                    it.setProductId(rs.getLong("product_id"));
                    it.setProductCode(rs.getString("product_code"));
                    it.setProductName(rs.getString("product_name"));
                    it.setSkuId(rs.getLong("sku_id"));
                    it.setSkuCode(rs.getString("sku_code"));
                    it.setRequestQty(rs.getInt("qty"));
                    list.add(it);
                }
            }
        }
        return list;
    }

    /**
     * Get status of a single import request
     */
    public String getImportRequestStatus(Connection con, long requestId) throws SQLException {
        String sql = "SELECT status FROM import_requests WHERE request_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    /**
     * Check if an import receipt already exists for this request
     */
    public boolean existsReceiptByRequestId(Connection con, long requestId) throws SQLException {
        String sql = "SELECT 1 FROM import_receipts WHERE request_id = ? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Mark import request as COMPLETE after receipt is created
     */
    public void updateImportRequestStatus(Connection con, long requestId, String status) throws SQLException {
        String sql = "UPDATE import_requests SET status = ? WHERE request_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, requestId);
            ps.executeUpdate();
        }
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object v = params.get(i);
            int idx = i + 1;
            if (v instanceof java.sql.Date d) {
                ps.setDate(idx, d);
            } else if (v instanceof Integer n) {
                ps.setInt(idx, n);
            } else if (v instanceof Long n) {
                ps.setLong(idx, n);
            } else {
                ps.setObject(idx, v);
            }
        }
    }
//DASHBOARD

    public int countByStatus(String status) throws Exception {
        String sql = """
        SELECT COUNT(*)
        FROM import_requests
        WHERE status = ?
    """;

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<ImportRequest> listByStatus(String status, int limit) throws Exception {
        String sql = """
        SELECT
          ir.request_id,
          ir.request_code,
          ir.requested_by,
          u.full_name AS created_by_name,
          ir.requested_at,
          ir.expected_import_date,
          COALESCE(x.total_items,0) AS total_items,
          COALESCE(x.total_qty,0) AS total_qty,
          ir.status
        FROM import_requests ir
        LEFT JOIN users u ON u.user_id = ir.requested_by
        LEFT JOIN (
          SELECT request_id, COUNT(*) total_items, COALESCE(SUM(qty),0) total_qty
          FROM import_request_lines
          GROUP BY request_id
        ) x ON x.request_id = ir.request_id
        WHERE ir.status = ?
        ORDER BY ir.requested_at DESC, ir.request_id DESC
        LIMIT ?
    """;

        List<ImportRequest> list = new ArrayList<>();

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportRequest r = new ImportRequest();
                    r.setRequestId(rs.getLong("request_id"));
                    r.setRequestCode(rs.getString("request_code"));
                    r.setCreatedBy(rs.getLong("requested_by"));
                    r.setCreatedByName(rs.getString("created_by_name"));
                    r.setRequestDate(rs.getTimestamp("requested_at"));
                    r.setExpectedImportDate(rs.getDate("expected_import_date"));
                    r.setTotalItems(rs.getInt("total_items"));
                    r.setTotalQty(rs.getInt("total_qty"));
                    r.setStatus(rs.getString("status"));
                    list.add(r);
                }
            }
        }

        return list;
    }
}
