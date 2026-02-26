package dal;

import model.ImportRequestItemCreate;

import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class ImportRequestCreateDAO {

    public String generateRequestCode(Connection con) throws SQLException {
        String datePart = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE); // yyyyMMdd
        String prefix = "IR-" + datePart + "-";

        String sql = """
            SELECT request_code
            FROM import_requests
            WHERE request_code LIKE ?
            ORDER BY request_code DESC
            LIMIT 1
        """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return prefix + "0001";
                }

                String last = rs.getString(1);
                int seq = Integer.parseInt(last.substring(last.length() - 4)) + 1;
                return prefix + String.format("%04d", seq);
            }
        }
    }

    public long createRequest(long requestedBy, Date expectedImportDate, String note, String status,
            List<ImportRequestItemCreate> items) throws Exception {

        String insertHeader = """
            INSERT INTO import_requests
              (request_code, requested_by, requested_at, expected_import_date, status, note, decided_by, decided_at)
            VALUES (?, ?, NOW(), ?, ?, ?, NULL, NULL)
        """;

        String insertLine = """
            INSERT INTO import_request_lines (request_id, product_id, sku_id, qty)
            VALUES (?, ?, ?, ?)
        """;

        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            String code = generateRequestCode(con);

            long requestId;
            try (PreparedStatement ps = con.prepareStatement(insertHeader, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, code);
                ps.setLong(2, requestedBy);

                if (expectedImportDate != null) {
                    ps.setDate(3, expectedImportDate);
                } else {
                    ps.setNull(3, Types.DATE);
                }

                ps.setString(4, status);

                if (note != null && !note.trim().isEmpty()) {
                    ps.setString(5, note.trim());
                } else {
                    ps.setNull(5, Types.VARCHAR);
                }

                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) {
                        throw new SQLException("Cannot get generated request_id");
                    }
                    requestId = rs.getLong(1);
                }
            }

            try (PreparedStatement ps = con.prepareStatement(insertLine)) {
                for (ImportRequestItemCreate it : items) {
                    ps.setLong(1, requestId);
                    ps.setLong(2, it.getProductId());
                    ps.setLong(3, it.getSkuId()); // NOT NULL
                    ps.setInt(4, it.getRequestQty());
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            con.commit();
            return requestId;

        } catch (Exception e) {
            if (con != null) try {
                con.rollback();
            } catch (Exception ignore) {
            }
            throw e;
        } finally {
            if (con != null) try {
                con.setAutoCommit(true);
                con.close();
            } catch (Exception ignore) {
            }
        }
    }
}
