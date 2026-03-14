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

        PreparedStatement ps = DBContext.getConnection().prepareStatement(sql);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            ProductSku s = new ProductSku();

            s.setSkuCode(rs.getString("sku_code"));
            s.setColor(rs.getString("color"));
            s.setStorageGb(rs.getInt("storage_gb"));
            s.setRamGb(rs.getInt("ram_gb"));
            s.setStatus(rs.getString("status"));

            list.add(s);
        }

        return list;
    }

    public List<ProductSku> filterVariants(Integer productId, String color, String storage, String ram, String status, String sku) throws Exception {

        List<ProductSku> list = new ArrayList<>();

        String sql = "SELECT * FROM product_skus WHERE 1=1";

        if (productId != null) {
            sql += " AND product_id = ?";
        }

        if (color != null && !color.isEmpty()) {
            sql += " AND color = ?";
        }

        if (storage != null && !storage.isEmpty()) {
            sql += " AND storage_gb = ?";
        }

        if (ram != null && !ram.isEmpty()) {
            sql += " AND ram_gb = ?";
        }

        if (status != null && !status.isEmpty()) {
            sql += " AND status = ?";
        }

        if (sku != null && !sku.isEmpty()) {
            sql += " AND sku_code LIKE ?";
        }

        PreparedStatement ps = DBContext.getConnection().prepareStatement(sql);

        int index = 1;

        if (productId != null) {
            ps.setInt(index++, productId);
        }

        if (color != null && !color.isEmpty()) {
            ps.setString(index++, color);
        }

        if (storage != null && !storage.isEmpty()) {
            ps.setInt(index++, Integer.parseInt(storage));
        }

        if (ram != null && !ram.isEmpty()) {
            ps.setInt(index++, Integer.parseInt(ram));
        }

        if (status != null && !status.isEmpty()) {
            ps.setString(index++, status);
        }

        if (sku != null && !sku.isEmpty()) {
            ps.setString(index++, "%" + sku + "%");
        }

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            ProductSku s = new ProductSku();

            s.setSkuCode(rs.getString("sku_code"));
            s.setColor(rs.getString("color"));
            s.setStorageGb(rs.getInt("storage_gb"));
            s.setRamGb(rs.getInt("ram_gb"));
            s.setStatus(rs.getString("status"));

            list.add(s);
        }

        return list;
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
        String sql = "SELECT 1 FROM product_skus WHERE sku_code=? LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, skuCode == null ? "" : skuCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsVariant(long productId, String color, int ramGb, int storageGb) throws Exception {
        String sql = "SELECT 1 FROM product_skus WHERE product_id=? AND color=? AND ram_gb=? AND storage_gb=? LIMIT 1";
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

        String sql = """
        SELECT
            ps.sku_id,
            ps.product_id,
            ps.sku_code,
            ps.color,
            ps.ram_gb,
            ps.storage_gb,
            ps.supplier_id,
            ps.status,
            ps.created_at,
            ps.updated_at,
            COALESCE(s.supplier_name, 'N/A') AS supplier_name,
            COALESCE(ib.qty_on_hand, 0) AS stock
        FROM product_skus ps
        LEFT JOIN suppliers s ON s.supplier_id = ps.supplier_id
        LEFT JOIN inventory_balance ib ON ib.sku_id = ps.sku_id
        WHERE ps.product_id = ?
          AND ps.status = 'ACTIVE'
        ORDER BY ps.sku_code ASC
    """;

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
                    } else if (stock <= 3) {
                        item.setStockStatus("Low Stock");
                    } else {
                        item.setStockStatus("In Stock");
                    }

                    list.add(item);
                }
            }
        }

        return list;
    }

}
