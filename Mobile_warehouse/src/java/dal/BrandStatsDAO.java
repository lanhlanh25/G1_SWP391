/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.*;
import java.util.*;
import model.BrandStatsRow;
import model.BrandStatsSummary;
import model.ProductStatsRow;
import java.sql.Date;

/**
 *
 * @author ADMIN
 */
public class BrandStatsDAO {

    private String orderBy(String sortBy) {
        if (sortBy == null) {
            return "total_stock_units";
        }
        switch (sortBy) {
            case "products":
                return "total_products";
            case "low":
                return "low_stock_products";
            case "import":
                return "imported_units";

            default:
                return "total_stock_units"; 
        }
    }

    private String orderDir(String sortOrder) {
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            return "ASC";
        }
        return "DESC";
    }

 
    public int countBrands(String q, String brandStatus, Long brandId, Date fromDate, Date toDate) throws Exception {
        StringBuilder sql = new StringBuilder("""
        SELECT COUNT(*)
        FROM brands b
        WHERE 1=1
    """);

        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND b.brand_name LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if (brandId != null) {
            sql.append(" AND b.brand_id = ? ");
            params.add(brandId);
        }
        if (brandStatus != null && !brandStatus.isBlank()) {
            if ("active".equalsIgnoreCase(brandStatus)) {
                sql.append(" AND b.is_active=1 ");
            } else if ("inactive".equalsIgnoreCase(brandStatus)) {
                sql.append(" AND b.is_active=0 ");
            }
        }

       
        if (fromDate != null || toDate != null) {
            sql.append("""
            AND EXISTS (
                SELECT 1
                FROM import_receipts ir
                JOIN import_receipt_lines irl ON irl.import_id = ir.import_id
                JOIN product_skus s ON s.sku_id = irl.sku_id
                JOIN products p ON p.product_id = s.product_id
                WHERE ir.status='CONFIRMED'
                  AND ir.receipt_date IS NOT NULL
                  AND p.brand_id = b.brand_id
        """);
            if (fromDate != null) {
                sql.append(" AND DATE(ir.receipt_date) >= ? ");
                params.add(fromDate);
            }
            if (toDate != null) {
                sql.append(" AND DATE(ir.receipt_date) <= ? ");
                params.add(toDate);
            }
            sql.append(") ");
        }

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

   
    public BrandStatsSummary getSummary(String q, String brandStatus, Long brandId,
            int lowThreshold, Date fromDate, Date toDate) throws Exception {
        StringBuilder sql = new StringBuilder();
        sql.append("""
            SELECT
              COUNT(DISTINCT b.brand_id) AS total_brands,
              COUNT(DISTINCT p.product_id) AS total_products,
              COALESCE(SUM(ib.qty_on_hand),0) AS total_stock_units,
              COUNT(DISTINCT CASE WHEN COALESCE(prod_qty.product_qty,0) <= ? THEN p.product_id END) AS low_stock_products
            FROM brands b
            LEFT JOIN products p ON p.brand_id = b.brand_id
            LEFT JOIN product_skus s ON s.product_id = p.product_id
            LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id
            LEFT JOIN (
                SELECT p2.product_id, COALESCE(SUM(ib2.qty_on_hand),0) AS product_qty
                FROM products p2
                LEFT JOIN product_skus s2 ON s2.product_id = p2.product_id
                LEFT JOIN inventory_balance ib2 ON ib2.sku_id = s2.sku_id
                GROUP BY p2.product_id
            ) prod_qty ON prod_qty.product_id = p.product_id
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        params.add(lowThreshold);

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND b.brand_name LIKE ? ");
            params.add("%" + q.trim() + "%");
        }
        if (brandId != null) {
            sql.append(" AND b.brand_id = ? ");
            params.add(brandId);
        }
        if (brandStatus != null && !brandStatus.isBlank()) {
            if ("active".equalsIgnoreCase(brandStatus)) {
                sql.append(" AND b.is_active=1 ");
            } else if ("inactive".equalsIgnoreCase(brandStatus)) {
                sql.append(" AND b.is_active=0 ");
            }
        }
        if (fromDate != null || toDate != null) {
            sql.append("""
        AND EXISTS (
            SELECT 1
            FROM import_receipts ir
            JOIN import_receipt_lines irl ON irl.import_id = ir.import_id
            JOIN product_skus s3 ON s3.sku_id = irl.sku_id
            JOIN products p3 ON p3.product_id = s3.product_id
            WHERE ir.status='CONFIRMED'
              AND ir.receipt_date IS NOT NULL
              AND p3.brand_id = b.brand_id
        """);
            if (fromDate != null) {
                sql.append(" AND DATE(ir.receipt_date) >= ? ");
                params.add(fromDate);
            }
            if (toDate != null) {
                sql.append(" AND DATE(ir.receipt_date) <= ? ");
                params.add(toDate);
            }
            sql.append(") ");
        }

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();

            BrandStatsSummary s = new BrandStatsSummary();
            if (rs.next()) {
                s.setTotalBrands(rs.getInt("total_brands"));
                s.setTotalProducts(rs.getInt("total_products"));
                s.setTotalStockUnits(rs.getInt("total_stock_units"));
                s.setLowStockProducts(rs.getInt("low_stock_products"));
            }
            return s;
        }
    }

   
    public List<BrandStatsRow> listBrandStats(String q, String brandStatus, Long brandId,
        String sortBy, String sortOrder,
        int page, int pageSize, int lowThreshold, Date fromDate, Date toDate) throws Exception {

    int offset = (page - 1) * pageSize;

    StringBuilder sql = new StringBuilder();
    List<Object> params = new ArrayList<>();

    sql.append("""
        SELECT
          b.brand_id,
          b.brand_name,
          b.is_active,
          COALESCE(prod.total_products, 0)     AS total_products,
          COALESCE(prod.total_stock_units, 0)  AS total_stock_units,
          COALESCE(prod.low_stock_products, 0) AS low_stock_products,
          COALESCE(imp.imported_units, 0)      AS imported_units
        FROM brands b

        -- ====== product/stock stats per brand (all-time, independent of range) ======
        LEFT JOIN (
            SELECT
              p.brand_id,
              COUNT(DISTINCT p.product_id) AS total_products,
              COALESCE(SUM(ib.qty_on_hand),0) AS total_stock_units,
              COUNT(DISTINCT CASE WHEN COALESCE(prod_qty.product_qty,0) <= ? THEN p.product_id END) AS low_stock_products
            FROM products p
            LEFT JOIN product_skus s ON s.product_id = p.product_id
            LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id
            LEFT JOIN (
                SELECT p2.product_id, COALESCE(SUM(ib2.qty_on_hand),0) AS product_qty
                FROM products p2
                LEFT JOIN product_skus s2 ON s2.product_id = p2.product_id
                LEFT JOIN inventory_balance ib2 ON ib2.sku_id = s2.sku_id
                GROUP BY p2.product_id
            ) prod_qty ON prod_qty.product_id = p.product_id
            GROUP BY p.brand_id
        ) prod ON prod.brand_id = b.brand_id

        -- ====== imported units per brand (filtered by range) ======
        LEFT JOIN (
            SELECT
              p.brand_id,
              COALESCE(SUM(irl.qty),0) AS imported_units
            FROM import_receipts ir
            JOIN import_receipt_lines irl ON irl.import_id = ir.import_id
            JOIN product_skus s ON s.sku_id = irl.sku_id
            JOIN products p ON p.product_id = s.product_id
            WHERE ir.status='CONFIRMED'
              AND ir.receipt_date IS NOT NULL
    """);

   
    params.add(lowThreshold);

    
    if (fromDate != null) {
        sql.append(" AND DATE(ir.receipt_date) >= ? ");
        params.add(fromDate);
    }
    if (toDate != null) {
        sql.append(" AND DATE(ir.receipt_date) <= ? ");
        params.add(toDate);
    }

    sql.append("""
            GROUP BY p.brand_id
        ) imp ON imp.brand_id = b.brand_id

        WHERE 1=1
    """);

   
    if (q != null && !q.trim().isEmpty()) {
        sql.append(" AND b.brand_name LIKE ? ");
        params.add("%" + q.trim() + "%");
    }

    if (brandId != null) {
        sql.append(" AND b.brand_id = ? ");
        params.add(brandId);
    }

    if (brandStatus != null && !brandStatus.isBlank()) {
        if ("active".equalsIgnoreCase(brandStatus)) {
            sql.append(" AND b.is_active = 1 ");
        } else if ("inactive".equalsIgnoreCase(brandStatus)) {
            sql.append(" AND b.is_active = 0 ");
        }
    }

  
    if (fromDate != null || toDate != null) {
        sql.append("""
            AND EXISTS (
                SELECT 1
                FROM import_receipts ir2
                JOIN import_receipt_lines irl2 ON irl2.import_id = ir2.import_id
                JOIN product_skus s2 ON s2.sku_id = irl2.sku_id
                JOIN products p2 ON p2.product_id = s2.product_id
                WHERE ir2.status='CONFIRMED'
                  AND ir2.receipt_date IS NOT NULL
                  AND p2.brand_id = b.brand_id
        """);

        if (fromDate != null) {
            sql.append(" AND DATE(ir2.receipt_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ir2.receipt_date) <= ? ");
            params.add(toDate);
        }

        sql.append(") ");
    }

  
    sql.append(" ORDER BY ").append(orderBy(sortBy)).append(" ").append(orderDir(sortOrder))
       .append(", b.brand_id ASC ");
    sql.append(" LIMIT ? OFFSET ? ");
    params.add(pageSize);
    params.add(offset);

   
    List<BrandStatsRow> list = new ArrayList<>();
    try (Connection con = DBContext.getConnection();
         PreparedStatement ps = con.prepareStatement(sql.toString())) {

        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                BrandStatsRow r = new BrandStatsRow();
                r.setBrandId(rs.getLong("brand_id"));
                r.setBrandName(rs.getString("brand_name"));
                r.setActive(rs.getInt("is_active") == 1);

                r.setTotalProducts(rs.getInt("total_products"));
                r.setTotalStockUnits(rs.getInt("total_stock_units"));
                r.setLowStockProducts(rs.getInt("low_stock_products"));
                r.setImportedUnits(rs.getInt("imported_units"));

                list.add(r);
            }
        }
    }
    return list;
}


    // detail by brand: list products with stock
    public List<ProductStatsRow> listBrandDetail(long brandId, int lowThreshold) throws Exception {
        String sql = """
            SELECT
              p.product_id,
              p.product_code,
              p.product_name,
              p.status,
              COALESCE(SUM(ib.qty_on_hand),0) AS total_stock_units
            FROM products p
            LEFT JOIN product_skus s ON s.product_id = p.product_id
            LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id
            WHERE p.brand_id = ?
            GROUP BY p.product_id, p.product_code, p.product_name, p.status
            ORDER BY total_stock_units ASC
        """;

        List<ProductStatsRow> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, brandId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProductStatsRow r = new ProductStatsRow();
                r.setProductId(rs.getLong("product_id"));
                r.setProductCode(rs.getString("product_code"));
                r.setProductName(rs.getString("product_name"));
                r.setStockStatus(rs.getString("status"));
                int stock = rs.getInt("total_stock_units");
                r.setTotalStockUnits(stock);

                String status = (stock == 0) ? "OUT" : (stock <= lowThreshold ? "LOW" : "OK");
                r.setStockStatus(status);

                list.add(r);
            }
        }
        return list;
    }
}
