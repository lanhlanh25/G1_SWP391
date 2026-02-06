/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;
import java.sql.Types; 


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

    // ✅ supplierId dùng Long (nullable)
    public long insertDraftReceipt(Connection con, String importCode, Long supplierId,
                                  Timestamp receiptDate, String note, int createdBy) throws SQLException {

        String sql = "INSERT INTO import_receipts(import_code, supplier_id, status, receipt_date, note, created_by) " +
                     "VALUES(?, ?, 'DRAFT', ?, ?, ?)";

        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, importCode);

            if (supplierId == null) ps.setNull(2, Types.BIGINT);
else ps.setLong(2, supplierId);


            ps.setTimestamp(3, receiptDate);
            ps.setString(4, (note == null || note.isBlank()) ? null : note.trim());
            ps.setInt(5, createdBy);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        throw new SQLException("Cannot insert import_receipts");
    }

    public long insertLine(Connection con, long importId, long productId, long skuId, int qty) throws SQLException {
        String sql = "INSERT INTO import_receipt_lines(import_id, product_id, sku_id, qty, unit_price) VALUES(?, ?, ?, ?, 0)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, importId);
            ps.setLong(2, productId);
            ps.setLong(3, skuId);
            ps.setInt(4, qty);
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
}