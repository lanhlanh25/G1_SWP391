package dal;

import model.ImeiRow;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ViewImeiDAO {

    public static class SkuHeader {
        public long skuId;
        public String skuCode;
        public String productCode;
        public String productName;
        public String color;
        public int ramGb;
        public int storageGb;
    }

    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }

    public SkuHeader getSkuHeader(long skuId) {
        String sql =
                "SELECT s.sku_id, s.sku_code, p.product_code, p.product_name, s.color, s.ram_gb, s.storage_gb " +
                "FROM product_skus s " +
                "JOIN products p ON p.product_id = s.product_id " +
                "WHERE s.sku_id = ?";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, skuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SkuHeader h = new SkuHeader();
                    h.skuId = rs.getLong("sku_id");
                    h.skuCode = rs.getString("sku_code");
                    h.productCode = rs.getString("product_code");
                    h.productName = rs.getString("product_name");
                    h.color = rs.getString("color");
                    h.ramGb = rs.getInt("ram_gb");
                    h.storageGb = rs.getInt("storage_gb");
                    return h;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int countImeis(long skuId, String q) {
        String sql =
            "SELECT COUNT(DISTINCT iru.imei) " +
            "FROM import_receipt_units iru " +
            "JOIN import_receipt_lines irl ON irl.line_id = iru.line_id " +
            "JOIN import_receipts ir ON ir.import_id = irl.import_id " +
            "WHERE irl.sku_id = ? " +
            "  AND ir.status = 'CONFIRMED' " +  // Only count confirmed imports
            (q != null && !q.trim().isEmpty() ? "  AND iru.imei LIKE ? " : "");

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, skuId);
            if (q != null && !q.trim().isEmpty()) {
                ps.setString(2, "%" + q.trim() + "%");
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<ImeiRow> listImeis(long skuId, String q, int page, int pageSize) {
        List<ImeiRow> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        String sql =
            "SELECT " +
            "  iru.imei, " +
            "  ir.receipt_date AS import_date, " +
            "  er.export_date AS export_date " +
            "FROM import_receipt_units iru " +
            "JOIN import_receipt_lines irl ON irl.line_id = iru.line_id " +
            "JOIN import_receipts ir ON ir.import_id = irl.import_id " +
            
            "LEFT JOIN export_receipt_units eru ON eru.imei = iru.imei " +
            "LEFT JOIN export_receipt_lines erl ON erl.line_id = eru.line_id " +
            "LEFT JOIN export_receipts er ON er.export_id = erl.export_id " +
            
            "WHERE irl.sku_id = ? " +
            "  AND ir.status = 'CONFIRMED' " +  
            (q != null && !q.trim().isEmpty() ? "  AND iru.imei LIKE ? " : "") +
            "GROUP BY iru.imei, ir.receipt_date, er.export_date " +  
            "ORDER BY iru.imei " +
            "LIMIT ? OFFSET ?";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int idx = 1;
            ps.setLong(idx++, skuId);
            
            if (q != null && !q.trim().isEmpty()) {
                ps.setString(idx++, "%" + q.trim() + "%");
            }
            
            ps.setInt(idx++, pageSize);
            ps.setInt(idx, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ImeiRow r = new ImeiRow();
                    r.setImei(rs.getString("imei"));
                    r.setImportDate(rs.getTimestamp("import_date"));
                    r.setExportDate(rs.getTimestamp("export_date"));  
                    list.add(r);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
