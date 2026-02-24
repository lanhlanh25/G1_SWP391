package dal;

import model.ImportReceiptDetail;
import model.ImportReceiptLineDetail;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ImportReceiptDetailDAO {

    public static final String ST_DRAFT = "DRAFT";
    public static final String ST_PENDING = "PENDING";
    public static final String ST_CONFIRMED = "CONFIRMED";
    public static final String ST_CANCELED = "CANCELED";

    private Connection openConn() throws SQLException {
        try {
            return DBContext.getConnection();
        } catch (Exception e) {
            throw new SQLException("Cannot open DB connection", e);
        }
    }

    public ImportReceiptDetail getReceipt(long importId) throws SQLException {
        String sql =
            "SELECT ir.import_id, ir.import_code, ir.receipt_date, ir.note, ir.status, " +
            "       s.supplier_name, u.full_name AS created_by_name " +
            "FROM import_receipts ir " +
            "LEFT JOIN suppliers s ON s.supplier_id = ir.supplier_id " +
            "LEFT JOIN users u ON u.user_id = ir.created_by " +
            "WHERE ir.import_id = ?";

        try (Connection con = openConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, importId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                ImportReceiptDetail d = new ImportReceiptDetail();
                d.setImportId(rs.getLong("import_id"));
                d.setImportCode(rs.getString("import_code"));
                d.setReceiptDate(rs.getTimestamp("receipt_date"));
                d.setNote(rs.getString("note"));
                d.setStatus(rs.getString("status"));
                d.setSupplierName(rs.getString("supplier_name"));
                d.setCreatedByName(rs.getString("created_by_name"));
                return d;
            }
        }
    }

    public List<ImportReceiptLineDetail> getLines(long importId) throws SQLException {

        String sql =
            "SELECT " +
            "  irl.line_id, " +
            "  p.product_code, " +
            "  ps.sku_code, " +
            "  irl.qty, " +
            "  irl.item_note, " +
            "  u.full_name AS created_by_name, " +
            "  COALESCE(GROUP_CONCAT(iru.imei ORDER BY iru.imei SEPARATOR '\n'), '') AS imeis " +
            "FROM import_receipt_lines irl " +
            "JOIN import_receipts ir ON ir.import_id = irl.import_id " +
            "JOIN products p ON p.product_id = irl.product_id " +
            "JOIN product_skus ps ON ps.sku_id = irl.sku_id " +
            "LEFT JOIN users u ON u.user_id = ir.created_by " +
            "LEFT JOIN import_receipt_units iru ON iru.line_id = irl.line_id " +
            "WHERE irl.import_id = ? " +
            "GROUP BY irl.line_id, p.product_code, ps.sku_code, irl.qty, irl.item_note, u.full_name " +
            "ORDER BY irl.line_id ASC";

        List<ImportReceiptLineDetail> out = new ArrayList<>();

        try (Connection con = openConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, importId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImportReceiptLineDetail it = new ImportReceiptLineDetail();
                    it.setLineId(rs.getLong("line_id"));
                    it.setProductCode(rs.getString("product_code"));
                    it.setSkuCode(rs.getString("sku_code"));
                    it.setQty(rs.getInt("qty"));

                    String rawImeis = rs.getString("imeis");
                    it.setImeiText(formatImeisWithIndex(rawImeis));

                    String itemNote = rs.getString("item_note");
                    it.setItemNote(itemNote == null ? "" : itemNote);
                    
                    String createdByName = rs.getString("created_by_name");
                    it.setCreatedByName(createdByName == null ? "Unknown" : createdByName);

                    out.add(it);
                }
            }
        }
        return out;
    }

    private String formatImeisWithIndex(String raw) {
        if (raw == null) return "";
        raw = raw.replace("\r", "").trim();
        if (raw.isEmpty()) return "";

        String[] arr = raw.split("\n");
        StringBuilder sb = new StringBuilder();

        int idx = 1;
        for (String s : arr) {
            if (s == null) continue;
            s = s.trim();
            if (s.isEmpty()) continue;

            sb.append("Imei ").append(idx).append(": ").append(s);
            sb.append("\n");
            idx++;
        }

        if (sb.length() > 0) sb.setLength(sb.length() - 1);
        return sb.toString();
    }

    // ✅ APPROVE - Updated to insert IMEIs into product_units
    public boolean approve(long importId) throws SQLException {
        String lockSql = "SELECT status FROM import_receipts WHERE import_id=? FOR UPDATE";
        String updSql  = "UPDATE import_receipts SET status=? WHERE import_id=?";

        try (Connection con = openConn()) {
            con.setAutoCommit(false);

            String curStatus;
            try (PreparedStatement ps = con.prepareStatement(lockSql)) {
                ps.setLong(1, importId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) { 
                        con.rollback(); 
                        return false; 
                    }
                    curStatus = rs.getString(1);
                }
            }

            if (curStatus == null) {
                con.rollback();
                return false;
            }
            
            String statusUpper = curStatus.toUpperCase();
            if (!ST_DRAFT.equals(statusUpper) && !ST_PENDING.equals(statusUpper)) {
                con.rollback();
                return false;
            }

            // ✅ Add stock to inventory
            applyStockOnApprove(con, importId);
            
            // ✅ Insert IMEIs into product_units
            insertImeisToProductUnits(con, importId);

            // Update status to CONFIRMED
            int affected;
            try (PreparedStatement ps = con.prepareStatement(updSql)) {
                ps.setString(1, ST_CONFIRMED);
                ps.setLong(2, importId);
                affected = ps.executeUpdate();
            }

            con.commit();
            return affected > 0;
        }
    }

    public boolean cancel(long importId) throws SQLException {
        String lockSql = "SELECT status FROM import_receipts WHERE import_id=? FOR UPDATE";
        String updSql = "UPDATE import_receipts SET status=? WHERE import_id=?";

        try (Connection con = openConn()) {
            con.setAutoCommit(false);

            String curStatus;
            try (PreparedStatement ps = con.prepareStatement(lockSql)) {
                ps.setLong(1, importId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                    curStatus = rs.getString(1);
                }
            }

            if (curStatus == null) {
                con.rollback();
                return false;
            }

            String statusUpper = curStatus.toUpperCase();
            if (!ST_DRAFT.equals(statusUpper) && !ST_PENDING.equals(statusUpper)) {
                con.rollback();
                return false;
            }

            int affected;
            try (PreparedStatement ps = con.prepareStatement(updSql)) {
                ps.setString(1, ST_CANCELED);
                ps.setLong(2, importId);
                affected = ps.executeUpdate();
            }

            con.commit();
            return affected > 0;
        }
    }

    private void applyStockOnApprove(Connection con, long importId) throws SQLException {
        String readLines = "SELECT sku_id, qty FROM import_receipt_lines WHERE import_id=?";
        String upsertInv =
            "INSERT INTO inventory_balance(sku_id, qty_on_hand) VALUES (?, ?) " +
            "ON DUPLICATE KEY UPDATE qty_on_hand = qty_on_hand + VALUES(qty_on_hand)";

        try (PreparedStatement psRead = con.prepareStatement(readLines);
             PreparedStatement psUpsert = con.prepareStatement(upsertInv)) {

            psRead.setLong(1, importId);

            try (ResultSet rs = psRead.executeQuery()) {
                while (rs.next()) {
                    long skuId = rs.getLong("sku_id");
                    int qty = rs.getInt("qty");

                    psUpsert.setLong(1, skuId);
                    psUpsert.setInt(2, qty);
                    psUpsert.addBatch();
                }
                psUpsert.executeBatch();
            }
        }
    }

    // ✅ NEW: Insert IMEIs from import_receipt_units to product_units
    private void insertImeisToProductUnits(Connection con, long importId) throws SQLException {
        String readImeis = 
            "SELECT irl.sku_id, iru.imei " +
            "FROM import_receipt_lines irl " +
            "JOIN import_receipt_units iru ON iru.line_id = irl.line_id " +
            "WHERE irl.import_id = ?";
        
        String insertUnit = 
            "INSERT INTO product_units(sku_id, imei, unit_status) VALUES (?, ?, 'INACTIVE') " +
            "ON DUPLICATE KEY UPDATE sku_id=sku_id"; // Ignore if IMEI already exists

        try (PreparedStatement psRead = con.prepareStatement(readImeis);
             PreparedStatement psInsert = con.prepareStatement(insertUnit)) {

            psRead.setLong(1, importId);

            try (ResultSet rs = psRead.executeQuery()) {
                while (rs.next()) {
                    long skuId = rs.getLong("sku_id");
                    String imei = rs.getString("imei");

                    psInsert.setLong(1, skuId);
                    psInsert.setString(2, imei);
                    psInsert.addBatch();
                }
                psInsert.executeBatch();
            }
        }
    }
}