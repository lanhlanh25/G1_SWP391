package dal;

import java.sql.*;

public class ReportRequestDAO {

    public long createGeneratedReport(Connection con,
                                      String reportCode,
                                      String reportType,
                                      Date fromDate,
                                      Date toDate,
                                      long requestedBy,
                                      String filePath,
                                      String note) throws SQLException {

        String sql = """
            INSERT INTO report_requests
                (report_code, report_type, from_date, to_date, status,
                 requested_by, requested_at, generated_at, file_path, note)
            VALUES
                (?, ?, ?, ?, 'GENERATED', ?, NOW(), NOW(), ?, ?)
        """;

        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, reportCode);
            ps.setString(2, reportType);

            if (fromDate != null) {
                ps.setDate(3, fromDate);
            } else {
                ps.setNull(3, Types.DATE);
            }

            if (toDate != null) {
                ps.setDate(4, toDate);
            } else {
                ps.setNull(4, Types.DATE);
            }

            ps.setLong(5, requestedBy);
            ps.setString(6, filePath);
            ps.setString(7, note);

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }

        throw new SQLException("Cannot insert report_requests");
    }

    public String getReportCodeById(Connection con, long reportId) throws SQLException {
        String sql = "SELECT report_code FROM report_requests WHERE report_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, reportId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("report_code");
                }
            }
        }
        return null;
    }
}