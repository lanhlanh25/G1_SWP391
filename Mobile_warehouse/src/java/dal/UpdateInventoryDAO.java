/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */

import model.SkuInventoryRow;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class UpdateInventoryDAO {

    private static final int LOW_STOCK_THRESHOLD = 10;

    public static class ProductBrief {
        public long productId;
        public String productCode;
        public String productName;

        public ProductBrief(long productId, String productCode, String productName) {
            this.productId = productId;
            this.productCode = productCode;
            this.productName = productName;
        }
    }

    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }

    public ProductBrief getProductByCode(String productCode) {
        String sql = "SELECT product_id, product_code, product_name " +
                     "FROM products WHERE product_code = ? AND status='ACTIVE'";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, productCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ProductBrief(
                            rs.getLong("product_id"),
                            rs.getString("product_code"),
                            rs.getString("product_name")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int sumQtyByProduct(long productId) {
        String sql =
                "SELECT COALESCE(SUM(COALESCE(ib.qty_on_hand,0)),0) AS total_qty " +
                "FROM product_skus s " +
                "LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id " +
                "WHERE s.product_id = ? AND s.status='ACTIVE'";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("total_qty");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countSkus(long productId) {
        String sql = "SELECT COUNT(*) FROM product_skus WHERE product_id=? AND status='ACTIVE'";
        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

   public List<SkuInventoryRow> listSkuRows(long productId, int page, int pageSize) {
    List<SkuInventoryRow> list = new ArrayList<>();
    int offset = (page - 1) * pageSize;

    String sql =
            "SELECT " +
            "  s.sku_id, s.sku_code, s.color, s.ram_gb, s.storage_gb, " +
            "  COALESCE((" +
            "    SELECT COUNT(*) FROM product_units pu " +
            "    WHERE pu.sku_id = s.sku_id AND pu.unit_status = 'ACTIVE'" +
            "  ), 0) AS qty, " +
            "  DATE_FORMAT(s.updated_at, '%Y-%m-%d') AS last_updated " +
            "FROM product_skus s " +
            "WHERE s.product_id = ? AND s.status = 'ACTIVE' " +
            "ORDER BY s.sku_code " +
            "LIMIT ? OFFSET ?";

    try (Connection con = getConn();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setLong(1, productId);
        ps.setInt(2, pageSize);
        ps.setInt(3, offset);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SkuInventoryRow row = new SkuInventoryRow();
                row.setSkuId(rs.getLong("sku_id"));
                row.setSkuCode(rs.getString("sku_code"));
                row.setColor(rs.getString("color"));
                row.setRamGb(rs.getInt("ram_gb"));
                row.setStorageGb(rs.getInt("storage_gb"));

                int qty = rs.getInt("qty");
                row.setQty(qty);

             
                if (qty == 0) {
                    row.setStockStatus("OUT");
                } else if (qty <= 10) {
                    row.setStockStatus("LOW");
                } else {
                    row.setStockStatus("OK");
                }

                row.setLastUpdated(rs.getString("last_updated"));
                list.add(row);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}

    public boolean saveQuantities(Map<Long, Integer> updates) {
        String sql =
                "INSERT INTO inventory_balance (sku_id, qty_on_hand, updated_at) " +
                "VALUES (?, ?, NOW()) " +
                "ON DUPLICATE KEY UPDATE qty_on_hand = VALUES(qty_on_hand), updated_at = NOW()";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            con.setAutoCommit(false);

            for (Map.Entry<Long, Integer> e : updates.entrySet()) {
                ps.setLong(1, e.getKey());
                ps.setInt(2, e.getValue());
                ps.addBatch();
            }

            ps.executeBatch();
            con.commit();
            return true;

        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }
}