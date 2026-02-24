package dal;

import model.ExportRequest;
import model.ExportRequestItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExportRequestDAO {

    public int count(String q, java.sql.Date reqFrom, java.sql.Date reqTo,
            java.sql.Date expFrom, java.sql.Date expTo) throws Exception {

        StringBuilder sql = new StringBuilder("""
        SELECT COUNT(*)
        FROM export_requests er
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND er.request_code LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if (reqFrom != null) {
            sql.append(" AND DATE(er.requested_at) >= ? ");
            params.add(reqFrom);
        }
        if (reqTo != null) {
            sql.append(" AND DATE(er.requested_at) <= ? ");
            params.add(reqTo);
        }
        if (expFrom != null) {
            sql.append(" AND er.expected_export_date >= ? ");
            params.add(expFrom);
        }
        if (expTo != null) {
            sql.append(" AND er.expected_export_date <= ? ");
            params.add(expTo);
        }

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<ExportRequest> list(String q, java.sql.Date reqFrom, java.sql.Date reqTo,
            java.sql.Date expFrom, java.sql.Date expTo,
            int offset, int limit) throws Exception {

        StringBuilder sql = new StringBuilder("""
        SELECT
          er.request_id,
          er.request_code,
          er.requested_by,
          u.full_name AS created_by_name,
          er.requested_at AS request_date,
          er.expected_export_date,
          COALESCE(x.total_items, 0) AS total_items,
          COALESCE(x.total_qty, 0)   AS total_qty,
          er.status
        FROM export_requests er
        LEFT JOIN users u ON u.user_id = er.requested_by
        LEFT JOIN (
            SELECT request_id,
                   COUNT(*) AS total_items,
                   COALESCE(SUM(qty),0) AS total_qty
            FROM export_request_lines
            GROUP BY request_id
        ) x ON x.request_id = er.request_id
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND er.request_code LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if (reqFrom != null) {
            sql.append(" AND DATE(er.requested_at) >= ? ");
            params.add(reqFrom);
        }
        if (reqTo != null) {
            sql.append(" AND DATE(er.requested_at) <= ? ");
            params.add(reqTo);
        }
        if (expFrom != null) {
            sql.append(" AND er.expected_export_date >= ? ");
            params.add(expFrom);
        }
        if (expTo != null) {
            sql.append(" AND er.expected_export_date <= ? ");
            params.add(expTo);
        }

        sql.append(" ORDER BY er.requested_at DESC, er.request_id DESC ");
        sql.append(" LIMIT ? OFFSET ? ");
        params.add(limit);
        params.add(offset);

        List<ExportRequest> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ExportRequest r = new ExportRequest();
                    r.setRequestId(rs.getLong("request_id"));
                    r.setRequestCode(rs.getString("request_code"));
                    r.setCreatedBy(rs.getLong("requested_by"));
                    r.setCreatedByName(rs.getString("created_by_name"));
                    r.setRequestDate(rs.getTimestamp("request_date"));            // requested_at
                    r.setExpectedExportDate(rs.getDate("expected_export_date"));  // ✅ new column
                    r.setTotalItems(rs.getInt("total_items"));
                    r.setTotalQty(rs.getInt("total_qty"));
                    r.setStatus(rs.getString("status"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public ExportRequest getHeader(long requestId) throws Exception {
        String sql = """
        SELECT
          er.request_id,
          er.request_code,
          er.requested_by,
          u.full_name AS created_by_name,
          er.requested_at AS request_date,
          er.expected_export_date,
          er.note,
          er.status
        FROM export_requests er
        LEFT JOIN users u ON u.user_id = er.requested_by
        WHERE er.request_id = ?
    """;

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                ExportRequest r = new ExportRequest();
                r.setRequestId(rs.getLong("request_id"));
                r.setRequestCode(rs.getString("request_code"));
                r.setCreatedBy(rs.getLong("requested_by"));
                r.setCreatedByName(rs.getString("created_by_name"));
                r.setRequestDate(rs.getTimestamp("request_date"));
                r.setExpectedExportDate(rs.getDate("expected_export_date")); // ✅
                r.setStatus(rs.getString("status"));
                return r;
            }
        }
    }

    public List<ExportRequestItem> listItems(long requestId) throws Exception {
        String sql = """
            SELECT
              p.product_code,
              s.sku_code,
              erl.qty
            FROM export_request_lines erl
            JOIN products p ON p.product_id = erl.product_id
            LEFT JOIN product_skus s ON s.sku_id = erl.sku_id
            WHERE erl.request_id = ?
            ORDER BY erl.line_id ASC
        """;

        List<ExportRequestItem> list = new ArrayList<>();

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                int no = 1;
                while (rs.next()) {
                    ExportRequestItem it = new ExportRequestItem();
                    it.setNo(no++);
                    it.setProductCode(rs.getString("product_code"));
                    it.setSkuCode(rs.getString("sku_code"));
                    it.setRequestQty(rs.getInt("qty"));
                    list.add(it);
                }
            }
        }
        return list;
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object val = params.get(i);
            int idx = i + 1;
            if (val instanceof java.util.Date d) {
                ps.setDate(idx, new java.sql.Date(d.getTime()));
            } else {
                ps.setObject(idx, val);
            }
        }
    }
}
