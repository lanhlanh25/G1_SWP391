package dal;

import java.sql.*;
import java.util.*;
import model.ImportReceiptDetail;
import model.ImportReceiptLineDetail;

public class ImportReceiptDAO {

    public String generateImportCode(Connection con) throws SQLException {
        String day = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
        String prefix = "IR-" + day + "-";
        String sql = "SELECT COUNT(*) FROM import_receipts WHERE import_code LIKE ?";
        int count = 0;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, prefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) count = rs.getInt(1);
            }
        }
        return prefix + String.format("%04d", count + 1);
    }

    public long insertReceipt(Connection con,
                          String importCode,
                          Long supplierId,
                          Timestamp receiptDate,
                          String note,
                          int createdBy,
                          String status) throws Exception {

    String sql = "INSERT INTO import_receipts(import_code, supplier_id, status, receipt_date, note, created_by) "
               + "VALUES(?, ?, ?, ?, ?, ?)";

    try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        ps.setString(1, importCode);

        if (supplierId == null) ps.setNull(2, java.sql.Types.BIGINT);
        else ps.setLong(2, supplierId);

        ps.setString(3, status);
        ps.setTimestamp(4, receiptDate);
        ps.setString(5, (note == null || note.isBlank()) ? null : note.trim());
        ps.setInt(6, createdBy);

        ps.executeUpdate();
        try (ResultSet rs = ps.getGeneratedKeys()) {
            if (rs.next()) return rs.getLong(1);
        }
    }
    throw new Exception("Cannot insert import_receipts");
}

    public long insertLine(Connection con, long importId, long productId, long skuId, int qty, String itemNote) throws SQLException {
        String sql = "INSERT INTO import_receipt_lines(import_id, product_id, sku_id, qty, unit_price, item_note) "
                   + "VALUES(?, ?, ?, ?, 0, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, importId);
            ps.setLong(2, productId);
            ps.setLong(3, skuId);
            ps.setInt(4, qty);
            ps.setString(5, (itemNote == null || itemNote.isBlank()) ? null : itemNote.trim());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        throw new SQLException("Cannot insert import_receipt_lines");
    }

    public void insertUnits(Connection con, long lineId, List<String> imeis) throws SQLException {
        String sql = "INSERT INTO import_receipt_units(line_id, imei) VALUES(?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (String imei : imeis) {
                ps.setLong(1, lineId);
                ps.setString(2, imei);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    public boolean skuBelongsToProduct(Connection con, long skuId, long productId) throws SQLException {
        String sql = "SELECT 1 FROM product_skus WHERE sku_id=? AND product_id=? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, skuId);
            ps.setLong(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long findProductIdByCode(Connection con, String productCode) throws SQLException {
        String sql = "SELECT product_id FROM products WHERE product_code=? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, productCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        throw new SQLException("Product not found: " + productCode);
    }

    public long findSkuIdByCode(Connection con, String skuCode) throws SQLException {
        String sql = "SELECT sku_id FROM product_skus WHERE sku_code=? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, skuCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        throw new SQLException("SKU not found: " + skuCode);
    }
    // ===== PDF/DETAIL QUERIES =====
public ImportReceiptDetail getDetailHeader(Connection con, long importId) throws SQLException {
    String sql = """
        SELECT ir.import_id, ir.import_code, ir.receipt_date, ir.note, ir.status,
               s.supplier_name,
               u.full_name AS created_by_name
        FROM import_receipts ir
        JOIN suppliers s ON s.supplier_id = ir.supplier_id
        JOIN users u ON u.user_id = ir.created_by
        WHERE ir.import_id = ?
    """;

    try (PreparedStatement ps = con.prepareStatement(sql)) {
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
    }
}

public List<ImportReceiptLineDetail> getDetailLines(Connection con, long importId) throws SQLException {
    String sql = """
        SELECT irl.line_id, irl.qty, irl.item_note,
               p.product_code,
               sk.sku_code,
               sk.sku_id
        FROM import_receipt_lines irl
        JOIN products p ON p.product_id = irl.product_id
        JOIN product_skus sk ON sk.sku_id = irl.sku_id
        WHERE irl.import_id = ?
        ORDER BY irl.line_id ASC
    """;

    List<ImportReceiptLineDetail> out = new ArrayList<>();

    try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setLong(1, importId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                long lineId = rs.getLong("line_id");
                long skuId = rs.getLong("sku_id");

                ImportReceiptLineDetail it = new ImportReceiptLineDetail();
                it.setLineId(lineId);
                it.setQty(rs.getInt("qty"));
                it.setItemNote(rs.getString("item_note"));
                it.setProductCode(rs.getString("product_code"));
                it.setSkuCode(rs.getString("sku_code"));

                // ✅ In Stock = inventory_balance.qty_on_hand
                it.setInStock(getInStockBySku(con, skuId));

                // ✅ IMEI text (2 imei / line)
                List<String> imeis = getImeisByLine(con, lineId);
                it.setImeiText(formatImeis(imeis, 2));

                out.add(it);
            }
        }
    }
    return out;
}

private int getInStockBySku(Connection con, long skuId) throws SQLException {
    String sql = "SELECT qty_on_hand FROM inventory_balance WHERE sku_id=? LIMIT 1";
    try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setLong(1, skuId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("qty_on_hand");
        }
    }
    return 0;
}

private List<String> getImeisByLine(Connection con, long lineId) throws SQLException {
    String sql = """
        SELECT imei
        FROM import_receipt_units
        WHERE line_id = ?
        ORDER BY iru_id ASC
    """;
    List<String> out = new ArrayList<>();
    try (PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setLong(1, lineId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getString("imei"));
        }
    }
    return out;
}

private static String formatImeis(List<String> imeis, int perLine) {
    if (imeis == null || imeis.isEmpty()) return "";

    List<String> cleaned = new ArrayList<>();
    for (String s : imeis) {
        if (s == null) continue;
        s = s.trim();
        if (!s.isEmpty()) cleaned.add(s);
    }
    if (cleaned.isEmpty()) return "";

    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < cleaned.size(); i += perLine) {
        int end = Math.min(i + perLine, cleaned.size());
        if (sb.length() > 0) sb.append("\n");
        sb.append(String.join(", ", cleaned.subList(i, end)));
    }
    return sb.toString();
}
}