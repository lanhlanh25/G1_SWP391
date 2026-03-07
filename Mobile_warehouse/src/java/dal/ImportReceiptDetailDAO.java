package dal;



import java.sql.*;
import java.util.*;
import model.ImportReceiptDetail;
import model.ImportReceiptLineDetail;

public class ImportReceiptDetailDAO {

    // ✅ FIX: Remove throws SQLException, handle internally
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

    // ✅ FIX: Remove throws SQLException
    public List<ImportReceiptLineDetail> getLines(long importId) {
        String sql = """
            SELECT irl.line_id, irl.qty, irl.item_note,
                   p.product_code,
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
                    it.setSkuCode(rs.getString("sku_code"));
                    it.setCreatedByName(rs.getString("created_by_name"));

                    List<String> imeis = getImeisByLine(con, rs.getLong("line_id"));
                    it.setImeiText(formatImeis(imeis));

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
                while (rs.next()) {
                    out.add(rs.getString("imei"));
                }
            }
        }
        return out;
    }

    private String formatImeis(List<String> imeis) {
        if (imeis == null || imeis.isEmpty()) return "";
        
        StringBuilder sb = new StringBuilder();
        int perLine = 2;
        
        for (int i = 0; i < imeis.size(); i += perLine) {
            if (i > 0) sb.append("\n");
            int end = Math.min(i + perLine, imeis.size());
            sb.append(String.join(", ", imeis.subList(i, end)));
        }
        
        return sb.toString();
    }

    /**
     * ✅ APPROVE: Update status + handle IMEI re-import logic
     * Returns: true if successful, false if receipt cannot be approved
     */
    public boolean approve(long importId) {
        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            // Check current status
            String checkSql = "SELECT status FROM import_receipts WHERE import_id = ?";
            String currentStatus;
            
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setLong(1, importId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                    currentStatus = rs.getString("status");
                }
            }

            // Only PENDING or DRAFT can be approved
            if (!"PENDING".equalsIgnoreCase(currentStatus) && !"DRAFT".equalsIgnoreCase(currentStatus)) {
                con.rollback();
                return false;
            }

            // Update receipt status to CONFIRMED
            String updateSql = "UPDATE import_receipts SET status = 'CONFIRMED' WHERE import_id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setLong(1, importId);
                ps.executeUpdate();
            }

            // ✅ Handle IMEI logic: INSERT new or UPDATE existing INACTIVE
            handleImeiApproval(con, importId);

            con.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try { 
                    con.rollback(); 
                } catch (Exception ignore) {}
            }
            return false;
        } finally {
            if (con != null) {
                try { 
                    con.close(); 
                } catch (Exception ignore) {}
            }
        }
    }

    /**
     * ✅ Handle IMEI approval logic
     * - If IMEI not exists: INSERT into product_units
     * - If IMEI exists + INACTIVE: UPDATE to ACTIVE
     */
    private void handleImeiApproval(Connection con, long importId) throws SQLException {
        // Get all IMEIs from this import with SKU info
        String sql = """
            SELECT iru.imei, irl.sku_id
            FROM import_receipt_units iru
            JOIN import_receipt_lines irl ON irl.line_id = iru.line_id
            WHERE irl.import_id = ?
        """;

        List<ImeiToProcess> list = new ArrayList<>();

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, importId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ImeiToProcess(
                        rs.getString("imei"),
                        rs.getLong("sku_id")
                    ));
                }
            }
        }

        // Process each IMEI
        for (ImeiToProcess item : list) {
            processImei(con, item.imei, item.skuId);
        }

        // Update inventory balance
        updateInventoryBalance(con, importId);
    }

    private void processImei(Connection con, String imei, long skuId) throws SQLException {
    // Check if IMEI exists for THIS SKU
    String checkSql = "SELECT unit_id, unit_status FROM product_units WHERE sku_id = ? AND imei = ?";

    try (PreparedStatement ps = con.prepareStatement(checkSql)) {
        ps.setLong(1, skuId);
        ps.setString(2, imei);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String status = rs.getString("unit_status");

                if ("INACTIVE".equalsIgnoreCase(status)) {
                    // Re-import => UPDATE to ACTIVE (only for this SKU)
                    String updateSql = "UPDATE product_units "
                            + "SET unit_status = 'ACTIVE', updated_at = CURRENT_TIMESTAMP "
                            + "WHERE sku_id = ? AND imei = ?";

                    try (PreparedStatement psUpdate = con.prepareStatement(updateSql)) {
                        psUpdate.setLong(1, skuId);
                        psUpdate.setString(2, imei);
                        psUpdate.executeUpdate();
                    }
                }

                // If ACTIVE => should have been blocked at create stage
            } else {
                // Not exists for this SKU => INSERT new
                String insertSql = "INSERT INTO product_units(sku_id, imei, unit_status) VALUES(?, ?, 'ACTIVE')";
                try (PreparedStatement psInsert = con.prepareStatement(insertSql)) {
                    psInsert.setLong(1, skuId);
                    psInsert.setString(2, imei);
                    psInsert.executeUpdate();
                }
            }
        }
    }
}

    private void updateInventoryBalance(Connection con, long importId) throws SQLException {
        String sql = """
            SELECT sku_id, SUM(qty) AS total_qty
            FROM import_receipt_lines
            WHERE import_id = ?
            GROUP BY sku_id
        """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, importId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long skuId = rs.getLong("sku_id");
                    int qty = rs.getInt("total_qty");

                    // Insert or update inventory_balance
                    String upsertSql = """
                        INSERT INTO inventory_balance(sku_id, qty_on_hand)
                        VALUES(?, ?)
                        ON DUPLICATE KEY UPDATE qty_on_hand = qty_on_hand + VALUES(qty_on_hand)
                    """;

                    try (PreparedStatement psUpsert = con.prepareStatement(upsertSql)) {
                        psUpsert.setLong(1, skuId);
                        psUpsert.setInt(2, qty);
                        psUpsert.executeUpdate();
                    }
                }
            }
        }
    }

    /**
     * ✅ CANCEL: Update status to CANCELED
     */
    public boolean cancel(long importId) {
        String sql = """
            UPDATE import_receipts
            SET status = 'CANCELED'
            WHERE import_id = ?
            AND status IN ('PENDING', 'DRAFT')
        """;

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, importId);
            return ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ Inner class for IMEI processing
    private static class ImeiToProcess {
        String imei;
        long skuId;

        ImeiToProcess(String imei, long skuId) {
            this.imei = imei;
            this.skuId = skuId;
        }
    }
}