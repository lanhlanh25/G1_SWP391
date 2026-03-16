package dal;

import java.sql.*;
import java.util.*;
import model.ImportReceiptDetail;
import model.ImportReceiptLineDetail;

public class ImportReceiptDetailDAO {

    public ImportReceiptDetail getReceipt(long importId) {
        String sql = """
            SELECT ir.import_id, ir.import_code, ir.receipt_date, ir.note, ir.status,
                   COALESCE(s.supplier_name, '-') AS supplier_name,
                   u.full_name AS created_by_name
            FROM import_receipts ir
            LEFT JOIN suppliers s ON s.supplier_id = ir.supplier_id
            JOIN users u ON u.user_id = ir.created_by
            WHERE ir.import_id = ?
        """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, importId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ImportReceiptDetail d = new ImportReceiptDetail();
                d.setImportId(rs.getLong("import_id"));
                d.setImportCode(rs.getString("import_code"));
                d.setReceiptDate(rs.getTimestamp("receipt_date"));
                d.setSupplierName(rs.getString("supplier_name"));
                d.setCreatedByName(rs.getString("created_by_name"));
                d.setNote(rs.getString("note"));
                d.setStatus(rs.getString("status"));
                return d;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public List<ImportReceiptLineDetail> getLines(long importId) {
        String sql = """
            SELECT irl.line_id, irl.qty, irl.item_note,
                   p.product_code, p.product_name,
                   sk.sku_code,
                   u.full_name AS created_by_name
            FROM import_receipt_lines irl
            JOIN products p ON p.product_id = irl.product_id
            JOIN product_skus sk ON sk.sku_id = irl.sku_id
            JOIN import_receipts ir ON ir.import_id = irl.import_id
            JOIN users u ON u.user_id = ir.created_by
            WHERE irl.import_id = ?
            ORDER BY irl.line_id ASC
        """;
        List<ImportReceiptLineDetail> out = new ArrayList<>();
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, importId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportReceiptLineDetail it = new ImportReceiptLineDetail();
                    it.setLineId(rs.getLong("line_id"));
                    it.setQty(rs.getInt("qty"));
                    it.setItemNote(rs.getString("item_note"));
                    it.setProductCode(rs.getString("product_code"));
                    it.setProductName(rs.getString("product_name"));
                    it.setSkuCode(rs.getString("sku_code"));
                    it.setCreatedByName(rs.getString("created_by_name"));
                    List<String> imeis = getImeisByLine(con, rs.getLong("line_id"));
                    it.setImeis(imeis);                    // ← set List trực tiếp
                    it.setImeiText(formatImeis(imeis));    // ← giữ lại cho backward compat
                    out.add(it);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }

    private List<String> getImeisByLine(Connection con, long lineId) throws SQLException {
        String sql = "SELECT imei FROM import_receipt_units WHERE line_id = ? ORDER BY iru_id ASC";
        List<String> out = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, lineId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(rs.getString("imei"));
            }
        }
        return out;
    }

    // Mỗi IMEI trên 1 dòng — để JSP parse đơn giản bằng \n
    private String formatImeis(List<String> imeis) {
        if (imeis == null || imeis.isEmpty()) return "";
        return String.join("\n", imeis);
    }
}
