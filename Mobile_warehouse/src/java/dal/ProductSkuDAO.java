/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Lanhlanh
 */
import java.sql.Statement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.ProductSku;

public class ProductSkuDAO {

    public List<ProductSku> getAllSkus() throws Exception {
        List<ProductSku> list = new ArrayList<>();
        String sql = "SELECT * FROM product_skus";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductSku s = new ProductSku();
                    s.setSkuId(rs.getInt("sku_id"));
                    s.setProductId(rs.getInt("product_id"));
                    s.setSkuCode(rs.getString("sku_code"));
                    s.setColor(rs.getString("color"));
                    s.setStorageGb(rs.getInt("storage_gb"));
                    s.setRamGb(rs.getInt("ram_gb"));
                    s.setStatus(rs.getString("status"));
                    list.add(s);
                }
            }
        }
        return list;
    }

    public List<ProductSku> filterVariants(Integer productId, String color, String storage, String ram, String status, String sku, String q) throws Exception {
        List<ProductSku> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, p.product_name " +
            "FROM product_skus s " +
            "JOIN products p ON s.product_id = p.product_id " +
            "WHERE 1=1"
        );

        if (productId != null) sql.append(" AND s.product_id = ?");
        if (color != null && !color.isEmpty()) sql.append(" AND s.color = ?");
        if (storage != null && !storage.isEmpty()) sql.append(" AND s.storage_gb = ?");
        if (ram != null && !ram.isEmpty()) sql.append(" AND s.ram_gb = ?");
        if (status != null && !status.isEmpty()) sql.append(" AND s.status = ?");
        if (sku != null && !sku.isEmpty()) sql.append(" AND s.sku_code LIKE ?");
        if (q != null && !q.isEmpty()) sql.append(" AND p.product_name LIKE ?");

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int index = 1;

            if (productId != null) ps.setInt(index++, productId);
            if (color != null && !color.isEmpty()) ps.setString(index++, color);
            if (storage != null && !storage.isEmpty()) ps.setInt(index++, Integer.parseInt(storage));
            if (ram != null && !ram.isEmpty()) ps.setInt(index++, Integer.parseInt(ram));
            if (status != null && !status.isEmpty()) ps.setString(index++, status);
            if (sku != null && !sku.isEmpty()) ps.setString(index++, "%" + sku + "%");
            if (q != null && !q.isEmpty()) ps.setString(index++, "%" + q + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductSku s = new ProductSku();
                    s.setSkuId(rs.getInt("sku_id"));
                    s.setProductId(rs.getInt("product_id"));
                    s.setSkuCode(rs.getString("sku_code"));
                    s.setProductName(rs.getString("product_name"));
                    s.setColor(rs.getString("color"));
                    s.setStorageGb(rs.getInt("storage_gb"));
                    s.setRamGb(rs.getInt("ram_gb"));
                    s.setStatus(rs.getString("status"));
                    list.add(s);
                }
            }
        }
        return list;
    }

    public ProductSku getSkuById(int skuId) {
        String sql = """
        SELECT sku_id, product_id, sku_code, color, ram_gb, storage_gb,
               price, supplier_id, status, created_at, updated_at
        FROM product_skus
        WHERE sku_id = ?
    """;

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, skuId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ProductSku sku = new ProductSku();
                sku.setSkuId(rs.getInt("sku_id"));
                sku.setProductId(rs.getInt("product_id"));
                sku.setSkuCode(rs.getString("sku_code"));
                sku.setColor(rs.getString("color"));
                sku.setRamGb(rs.getInt("ram_gb"));
                sku.setStorageGb(rs.getInt("storage_gb"));
                sku.setPrice(rs.getDouble("price"));
                sku.setSupplierId(rs.getInt("supplier_id"));
                sku.setStatus(rs.getString("status"));
                sku.setCreatedAt(rs.getTimestamp("created_at"));
                sku.setUpdatedAt(rs.getTimestamp("updated_at"));
                return sku;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ProductSku> getSkusByProductId(int productId) {
        List<ProductSku> list = new ArrayList<>();

        String sql = """
        SELECT sku_id, product_id, sku_code, color, ram_gb, storage_gb,
               price, supplier_id, status, created_at, updated_at
        FROM product_skus
        WHERE product_id = ?
    """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ProductSku sku = new ProductSku();
                sku.setSkuId(rs.getInt("sku_id"));
                sku.setProductId(rs.getInt("product_id"));
                sku.setSkuCode(rs.getString("sku_code"));
                sku.setColor(rs.getString("color"));
                sku.setRamGb(rs.getInt("ram_gb"));
                sku.setStorageGb(rs.getInt("storage_gb"));
                sku.setPrice(rs.getDouble("price"));
                sku.setSupplierId(rs.getInt("supplier_id"));
                sku.setStatus(rs.getString("status"));
                sku.setCreatedAt(rs.getTimestamp("created_at"));
                sku.setUpdatedAt(rs.getTimestamp("updated_at"));

                list.add(sku);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void inactivateSkusByProduct(int productId) throws Exception {
        String sql = "UPDATE product_skus SET status = 'INACTIVE' WHERE product_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
        // Đồng bộ xuống IMEI: Vô hiệu hóa tất cả IMEI thuộc các SKU của sản phẩm này
        String syncUnitsSql = "UPDATE product_units SET unit_status = 'INACTIVE' WHERE sku_id IN (SELECT sku_id FROM product_skus WHERE product_id = ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(syncUnitsSql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        }
    }

    public long insertSku(long productId, String skuCode, String color, int ramGb, int storageGb, String status) throws Exception {
        String st = "INACTIVE".equalsIgnoreCase(status) ? "INACTIVE" : "ACTIVE";

        String sql = "INSERT INTO product_skus(product_id, sku_code, color, ram_gb, storage_gb, status) VALUES(?,?,?,?,?,?)";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, productId);
            ps.setString(2, skuCode == null ? null : skuCode.trim());
            ps.setString(3, color == null ? null : color.trim());
            ps.setInt(4, ramGb);
            ps.setInt(5, storageGb);

            ps.setString(6, st);

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return -1;
    }

    public boolean existsSkuCode(String skuCode) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE LOWER(sku_code)=LOWER(?) LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, skuCode == null ? "" : skuCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsSkuCodeOther(String skuCode, int currentSkuId) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE LOWER(sku_code)=LOWER(?) AND sku_id <> ? LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, skuCode == null ? "" : skuCode.trim());
            ps.setInt(2, currentSkuId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void updateSku(int skuId, String skuCode, String color, int ramGb, int storageGb, String status) throws Exception {
        // Normalize status to upper case
        String normalizedStatus = (status == null) ? "ACTIVE" : status.trim().toUpperCase();

        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false); // Use transaction for data consistency

            try {
                // 1. Check block reason if trying to inactivate
                if ("INACTIVE".equals(normalizedStatus)) {
                    String blockReason = getBlockReasonForInactivateSku(con, skuId);
                    if (blockReason != null) {
                        throw new Exception("Không thể vô hiệu hóa: " + blockReason);
                    }
                }

                // 2. Perform the update
                String sql = "UPDATE product_skus SET sku_code = ?, color = ?, ram_gb = ?, storage_gb = ?, status = ?, updated_at = NOW() WHERE sku_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, skuCode);
                    ps.setString(2, color);
                    ps.setInt(3, ramGb);
                    ps.setInt(4, storageGb);
                    ps.setString(5, normalizedStatus);
                    ps.setInt(6, skuId);
                    ps.executeUpdate();
                }

                // 3. Get Product ID for synchronization
                int productId = -1;
                String sqlId = "SELECT product_id FROM product_skus WHERE sku_id = ?";
                try (PreparedStatement psId = con.prepareStatement(sqlId)) {
                    psId.setInt(1, skuId);
                    try (ResultSet rsId = psId.executeQuery()) {
                        if (rsId.next()) {
                            productId = rsId.getInt("product_id");
                        }
                    }
                }

                if (productId != -1) {
                    // 4. Synchronize status Upwards to Product
                    syncProductStatusBySku(con, productId, normalizedStatus);

                    // 5. Synchronize status Downwards to Units (IMEI)
                    syncUnitStatusBySku(con, skuId, normalizedStatus);
                }

                con.commit();
            } catch (Exception e) {
                con.rollback();
                throw e;
            }
        }
    }

    public String getBlockReasonForInactivateSku(Connection con, int skuId) throws Exception {
        // Check Export Requests
        String sqlExpReq = """
            SELECT er.request_code 
            FROM export_request_lines erl
            JOIN export_requests er ON erl.request_id = er.request_id
            WHERE erl.sku_id = ? 
              AND er.status NOT IN ('COMPLETED', 'CANCELLED', 'REJECTED')
            LIMIT 1
        """;
        try (PreparedStatement ps = con.prepareStatement(sqlExpReq)) {
            ps.setInt(1, skuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "SKU is part of a pending Export Request: " + rs.getString(1);
                }
            }
        }

        // Check Import Requests
        String sqlImpReq = """
            SELECT ir.request_code 
            FROM import_request_lines irl
            JOIN import_requests ir ON irl.request_id = ir.request_id
            WHERE irl.sku_id = ? 
              AND ir.status NOT IN ('COMPLETED', 'CANCELLED', 'REJECTED')
            LIMIT 1
        """;
        try (PreparedStatement ps = con.prepareStatement(sqlImpReq)) {
            ps.setInt(1, skuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "SKU is part of a pending Import Request: " + rs.getString(1);
                }
            }
        }

        // Check Export Receipts
        String sqlExpRec = "SELECT er.export_code " +
                         "FROM export_receipt_lines erl " +
                         "JOIN export_receipts er ON erl.export_id = er.export_id " +
                         "WHERE erl.sku_id = ? " +
                         "  AND er.status IN ('DRAFT', 'PENDING') " +
                         "LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sqlExpRec)) {
            ps.setInt(1, skuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "SKU is part of an incomplete Export Receipt: " + rs.getString(1);
                }
            }
        }

        // Check Import Receipts
        String sqlImpRec = "SELECT ir.import_code " +
                         "FROM import_receipt_lines irl " +
                         "JOIN import_receipts ir ON irl.import_id = ir.import_id " +
                         "WHERE irl.sku_id = ? " +
                         "  AND ir.status IN ('DRAFT', 'PENDING') " +
                         "LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sqlImpRec)) {
            ps.setInt(1, skuId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "SKU is part of an incomplete Import Receipt: " + rs.getString(1);
                }
            }
        }
        return null;
    }

    private void syncProductStatusBySku(Connection con, int productId, String status) throws Exception {
        if ("ACTIVE".equalsIgnoreCase(status)) {
            // If any variant is active, product must be active
            String sql = "UPDATE products SET status = 'ACTIVE' WHERE product_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, productId);
                ps.executeUpdate();
            }
        } else {
            // If variant is inactivated, check if any other variant of this product is still active
            String checkSql = "SELECT COUNT(*) FROM product_skus WHERE product_id = ? AND status = 'ACTIVE'";
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) == 0) {
                        // No more active variants, turn off product
                        String updateSql = "UPDATE products SET status = 'INACTIVE' WHERE product_id = ?";
                        try (PreparedStatement ps2 = con.prepareStatement(updateSql)) {
                            ps2.setInt(1, productId);
                            ps2.executeUpdate();
                        }
                    }
                }
            }
        }
    }

    private void syncUnitStatusBySku(Connection con, int skuId, String status) throws Exception {
        String unitStatus = "ACTIVE".equalsIgnoreCase(status) ? "ACTIVE" : "INACTIVE";
        String sql = "UPDATE product_units SET unit_status = ?, updated_at = NOW() WHERE sku_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, unitStatus);
            ps.setInt(2, skuId);
            ps.executeUpdate();
        }
    }

    public boolean existsVariant(long productId, String color, int ramGb, int storageGb) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE product_id=? AND LOWER(color)=LOWER(?) AND ram_gb=? AND storage_gb=? LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);
            ps.setString(2, color == null ? null : color.trim());
            ps.setInt(3, ramGb);
            ps.setInt(4, storageGb);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsVariantOther(long productId, String color, int ramGb, int storageGb, int currentSkuId) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE product_id=? AND LOWER(color)=LOWER(?) AND ram_gb=? AND storage_gb=? AND sku_id <> ? LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);
            ps.setString(2, color == null ? null : color.trim());
            ps.setInt(3, ramGb);
            ps.setInt(4, storageGb);
            ps.setInt(5, currentSkuId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public List<ProductSku> listActive() throws Exception {
        List<ProductSku> list = new ArrayList<>();

        String sql = "SELECT sku_id, sku_code, product_id "
                + "FROM product_skus "
                + "WHERE status = 'ACTIVE' "
                + "ORDER BY sku_code";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductSku k = new ProductSku();
                k.setSkuId(rs.getInt("sku_id"));
                k.setSkuCode(rs.getString("sku_code"));
                k.setProductId(rs.getInt("product_id"));
                list.add(k);
            }
        }
        return list;
    }

    public List<ProductSku> getSkuStockByProductId(long productId) throws Exception {
        List<ProductSku> list = new ArrayList<>();

        String sql = "SELECT " +
                    "    ps.sku_id, " +
                    "    ps.product_id, " +
                    "    ps.sku_code, " +
                    "    ps.color, " +
                    "    ps.ram_gb, " +
                    "    ps.storage_gb, " +
                    "    ps.supplier_id, " +
                    "    ps.status, " +
                    "    ps.created_at, " +
                    "    ps.updated_at, " +
                    "    COALESCE(s.supplier_name, 'N/A') AS supplier_name, " +
                    "    COALESCE(ib.qty_on_hand, 0) AS stock " +
                    "FROM product_skus ps " +
                    "LEFT JOIN suppliers s ON s.supplier_id = ps.supplier_id " +
                    "LEFT JOIN inventory_balance ib ON ib.sku_id = ps.sku_id " +
                    "WHERE ps.product_id = ? " +
                    "  AND ps.status = 'ACTIVE' " +
                    "ORDER BY ps.sku_code ASC";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductSku item = new ProductSku();

                    item.setSkuId(rs.getInt("sku_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setSkuCode(rs.getString("sku_code"));
                    item.setColor(rs.getString("color"));
                    item.setRamGb(rs.getInt("ram_gb"));
                    item.setStorageGb(rs.getInt("storage_gb"));
                    item.setSupplierId(rs.getInt("supplier_id"));
                    item.setStatus(rs.getString("status"));
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    item.setUpdatedAt(rs.getTimestamp("updated_at"));

                    item.setSupplierName(rs.getString("supplier_name"));

                    int stock = rs.getInt("stock");
                    item.setStock(stock);

                    if (stock == 0) {
                        item.setStockStatus("Out Of Stock");
                    } else if (stock <= 10) {
                        item.setStockStatus("Low Stock");
                    } else {
                        item.setStockStatus("OK");
                    }

                    list.add(item);
                }
            }
        }

        return list;
    }

}
