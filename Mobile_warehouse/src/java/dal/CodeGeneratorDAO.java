/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CodeGeneratorDAO {

    public String generateDailyCode(Connection con, String tableName, String columnName, String prefixCode) throws SQLException {
        String day = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
        String prefix = prefixCode + "-" + day + "-";

        String sql = "SELECT COUNT(*) FROM " + tableName + " WHERE " + columnName + " LIKE ?";
        int count = 0;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        }

        return prefix + String.format("%04d", count + 1);
    }

    public String generateImportRequestCode(Connection con) throws SQLException {
        return generateDailyCode(con, "import_requests", "request_code", "IMR");
    }

    public String generateExportRequestCode(Connection con) throws SQLException {
        return generateDailyCode(con, "export_requests", "request_code", "EXR");
    }

    public String generateImportReceiptCode(Connection con) throws SQLException {
        return generateDailyCode(con, "import_receipts", "import_code", "IR");
    }

    public String generateExportReceiptCode(Connection con) throws SQLException {
        return generateDailyCode(con, "export_receipts", "export_code", "ER");
    }

    public String generateReportCode(Connection con) throws SQLException {
        return generateDailyCode(con, "report_requests", "report_code", "RPT");
    }
}
