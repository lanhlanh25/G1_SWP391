package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.LowStockReportItem;
import model.LowStockSummaryDTO;

public class LowStockReportDAO {

    private static final int FIXED_THRESHOLD = 10;

    public List<LowStockReportItem> getLowStockReport(
            String q,
            Long supplierId,
            String stockStatus,
            Integer minStock,
            Integer maxStock,
            int page,
            int pageSize
    ) throws Exception {

        List<LowStockReportItem> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder();

        sql.append("""
            SELECT *
            FROM (
                SELECT
                    p.product_id,
                    p.product_code,
                    p.product_name,
                    COALESCE(MIN(ps.supplier_id), 0) AS supplier_id,
                    COALESCE(MIN(s.supplier_name), 'N/A') AS supplier_name,
                    COALESCE(MIN(b.brand_name), 'N/A') AS brand_name,
                    COALESCE(SUM(ib.qty_on_hand), 0) AS current_stock,
                    10 AS threshold,
                    CASE
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) = 0 THEN 'Out Of Stock'
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) < 10 THEN 'Reorder Needed'
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) = 10 THEN 'At Threshold'
                        ELSE 'OK'
                    END AS stock_status,
                    CASE
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) < 10
                        THEN 10 - COALESCE(SUM(ib.qty_on_hand), 0)
                        ELSE 0
                    END AS suggested_reorder_qty,
                    CASE
                        WHEN EXISTS (
                            SELECT 1
                            FROM import_request_lines irl
                            INNER JOIN import_requests ir ON ir.request_id = irl.request_id
                            WHERE irl.product_id = p.product_id
                              AND ir.status = 'NEW'
                        ) THEN 1
                        ELSE 0
                    END AS has_active_import_request
                FROM products p
                LEFT JOIN brands b ON b.brand_id = p.brand_id
                LEFT JOIN product_skus ps ON ps.product_id = p.product_id AND ps.status = 'ACTIVE'
                LEFT JOIN suppliers s ON s.supplier_id = ps.supplier_id AND s.is_active = 1
                LEFT JOIN inventory_balance ib ON ib.sku_id = ps.sku_id
                WHERE p.status = 'ACTIVE'
        """);

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ?) ");
            params.add("%" + q.trim() + "%");
            params.add("%" + q.trim() + "%");
        }

        if (supplierId != null) {
            sql.append(" AND ps.supplier_id = ? ");
            params.add(supplierId);
        }

        sql.append("""
                GROUP BY p.product_id, p.product_code, p.product_name
            ) x
            WHERE 1=1
        """);

        if (minStock != null) {
            sql.append(" AND x.current_stock >= ? ");
            params.add(minStock);
        }

        if (maxStock != null) {
            sql.append(" AND x.current_stock <= ? ");
            params.add(maxStock);
        }

        if (stockStatus != null && !stockStatus.isBlank() && !"All".equalsIgnoreCase(stockStatus)) {
            sql.append(" AND x.stock_status = ? ");
            params.add(stockStatus);
        } else {
            sql.append(" AND x.current_stock <= x.threshold ");
        }

        sql.append("""
            ORDER BY
                CASE
                    WHEN x.stock_status = 'Out Of Stock' THEN 1
                    WHEN x.stock_status = 'Reorder Needed' THEN 2
                    WHEN x.stock_status = 'At Threshold' THEN 3
                    ELSE 4
                END,
                x.current_stock ASC,
                x.product_name ASC
            LIMIT ? OFFSET ?
        """);

        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LowStockReportItem item = new LowStockReportItem();
                    item.setProductId(rs.getLong("product_id"));
                    item.setProductCode(rs.getString("product_code"));
                    item.setProductName(rs.getString("product_name"));
                    item.setSupplierId(rs.getLong("supplier_id"));
                    item.setSupplierName(rs.getString("supplier_name"));
                    item.setBrandName(rs.getString("brand_name"));
                    item.setCurrentStock(rs.getInt("current_stock"));
                    item.setThreshold(rs.getInt("threshold"));
                    item.setStockStatus(rs.getString("stock_status"));
                    item.setSuggestedReorderQty(rs.getInt("suggested_reorder_qty"));
                    item.setHasActiveImportRequest(rs.getInt("has_active_import_request") == 1);
                    list.add(item);
                }
            }
        }

        return list;
    }

    public int countLowStockReport(
            String q,
            Long supplierId,
            String stockStatus,
            Integer minStock,
            Integer maxStock
    ) throws Exception {

        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder();

        sql.append("""
            SELECT COUNT(*)
            FROM (
                SELECT
                    p.product_id,
                    COALESCE(SUM(ib.qty_on_hand), 0) AS current_stock,
                    10 AS threshold,
                    CASE
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) = 0 THEN 'Out Of Stock'
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) < 10 THEN 'Reorder Needed'
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) = 10 THEN 'At Threshold'
                        ELSE 'OK'
                    END AS stock_status
                FROM products p
                LEFT JOIN product_skus ps ON ps.product_id = p.product_id AND ps.status = 'ACTIVE'
                LEFT JOIN inventory_balance ib ON ib.sku_id = ps.sku_id
                WHERE p.status = 'ACTIVE'
        """);

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ?) ");
            params.add("%" + q.trim() + "%");
            params.add("%" + q.trim() + "%");
        }

        if (supplierId != null) {
            sql.append(" AND ps.supplier_id = ? ");
            params.add(supplierId);
        }

        sql.append("""
                GROUP BY p.product_id
            ) x
            WHERE 1=1
        """);

        if (minStock != null) {
            sql.append(" AND x.current_stock >= ? ");
            params.add(minStock);
        }

        if (maxStock != null) {
            sql.append(" AND x.current_stock <= ? ");
            params.add(maxStock);
        }

        if (stockStatus != null && !stockStatus.isBlank() && !"All".equalsIgnoreCase(stockStatus)) {
            sql.append(" AND x.stock_status = ? ");
            params.add(stockStatus);
        } else {
            sql.append(" AND x.current_stock <= x.threshold ");
        }

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    public LowStockSummaryDTO getSummary() throws Exception {
        String sql = """
            SELECT
                SUM(CASE WHEN x.current_stock <= x.threshold THEN 1 ELSE 0 END) AS at_or_below_threshold,
                SUM(CASE WHEN x.current_stock = 0 THEN 1 ELSE 0 END) AS out_of_stock,
                SUM(CASE WHEN x.current_stock > 0 AND x.current_stock < x.threshold THEN 1 ELSE 0 END) AS reorder_needed,
                COUNT(*) AS total_products
            FROM (
                SELECT
                    p.product_id,
                    COALESCE(SUM(ib.qty_on_hand), 0) AS current_stock,
                    10 AS threshold
                FROM products p
                LEFT JOIN product_skus ps ON ps.product_id = p.product_id AND ps.status = 'ACTIVE'
                LEFT JOIN inventory_balance ib ON ib.sku_id = ps.sku_id
                WHERE p.status = 'ACTIVE'
                GROUP BY p.product_id
            ) x
        """;

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                LowStockSummaryDTO dto = new LowStockSummaryDTO();
                dto.setProductsAtOrBelowThreshold(rs.getInt("at_or_below_threshold"));
                dto.setOutOfStock(rs.getInt("out_of_stock"));
                dto.setReorderNeeded(rs.getInt("reorder_needed"));
                dto.setTotalProducts(rs.getInt("total_products"));
                return dto;
            }
        }

        return null;
    }

    public LowStockReportItem getLowStockProductById(long productId) throws Exception {
        String sql = """
            SELECT *
            FROM (
                SELECT
                    p.product_id,
                    p.product_code,
                    p.product_name,
                    COALESCE(MIN(ps.supplier_id), 0) AS supplier_id,
                    COALESCE(MIN(s.supplier_name), 'N/A') AS supplier_name,
                    COALESCE(MIN(b.brand_name), 'N/A') AS brand_name,
                    COALESCE(SUM(ib.qty_on_hand), 0) AS current_stock,
                    10 AS threshold,
                    CASE
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) = 0 THEN 'Out Of Stock'
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) < 10 THEN 'Reorder Needed'
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) = 10 THEN 'At Threshold'
                        ELSE 'OK'
                    END AS stock_status,
                    CASE
                        WHEN COALESCE(SUM(ib.qty_on_hand), 0) < 10
                        THEN 10 - COALESCE(SUM(ib.qty_on_hand), 0)
                        ELSE 0
                    END AS suggested_reorder_qty,
                    CASE
                        WHEN EXISTS (
                            SELECT 1
                            FROM import_request_lines irl
                            INNER JOIN import_requests ir ON ir.request_id = irl.request_id
                            WHERE irl.product_id = p.product_id
                              AND ir.status = 'NEW'
                        ) THEN 1
                        ELSE 0
                    END AS has_active_import_request
                FROM products p
                LEFT JOIN brands b ON b.brand_id = p.brand_id
                LEFT JOIN product_skus ps ON ps.product_id = p.product_id AND ps.status = 'ACTIVE'
                LEFT JOIN suppliers s ON s.supplier_id = ps.supplier_id AND s.is_active = 1
                LEFT JOIN inventory_balance ib ON ib.sku_id = ps.sku_id
                WHERE p.status = 'ACTIVE'
                  AND p.product_id = ?
                GROUP BY p.product_id, p.product_code, p.product_name
            ) x
        """;

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LowStockReportItem item = new LowStockReportItem();
                    item.setProductId(rs.getLong("product_id"));
                    item.setProductCode(rs.getString("product_code"));
                    item.setProductName(rs.getString("product_name"));
                    item.setSupplierId(rs.getLong("supplier_id"));
                    item.setSupplierName(rs.getString("supplier_name"));
                    item.setBrandName(rs.getString("brand_name"));
                    item.setCurrentStock(rs.getInt("current_stock"));
                    item.setThreshold(rs.getInt("threshold"));
                    item.setStockStatus(rs.getString("stock_status"));
                    item.setSuggestedReorderQty(rs.getInt("suggested_reorder_qty"));
                    item.setHasActiveImportRequest(rs.getInt("has_active_import_request") == 1);
                    return item;
                }
            }
        }

        return null;
    }
}
