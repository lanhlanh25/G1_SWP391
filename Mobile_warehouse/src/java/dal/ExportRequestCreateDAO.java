package dal;

import java.sql.*;
import java.util.List;
import model.ExportRequestItemCreate;

public class ExportRequestCreateDAO {

    public long createRequest(long requestedBy, Date expectedExportDate, String note, String status,
            List<ExportRequestItemCreate> items) throws Exception {

        String insertHeader = """
            INSERT INTO export_requests
              (request_code, requested_by, requested_at, expected_export_date, status, note, decided_by, decided_at)
            VALUES (?, ?, NOW(), ?, ?, ?, NULL, NULL)
        """;

        String insertLine = """
            INSERT INTO export_request_lines (request_id, product_id, sku_id, qty)
            VALUES (?, ?, ?, ?)
        """;

        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            CodeGeneratorDAO codeDAO = new CodeGeneratorDAO();
            String code = codeDAO.generateExportRequestCode(con);

            long requestId;
            try (PreparedStatement ps = con.prepareStatement(insertHeader, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, code);
                ps.setLong(2, requestedBy);

                if (expectedExportDate != null) {
                    ps.setDate(3, expectedExportDate);
                } else {
                    ps.setNull(3, Types.DATE);
                }

                ps.setString(4, (status == null || status.isBlank()) ? "NEW" : status.trim());

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
                for (ExportRequestItemCreate it : items) {
                    ps.setLong(1, requestId);
                    ps.setLong(2, it.getProductId());

                    if (it.getSkuId() == null) {
                        ps.setNull(3, Types.BIGINT);
                    } else {
                        ps.setLong(3, it.getSkuId());
                    }

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