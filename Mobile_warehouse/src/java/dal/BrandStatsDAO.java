/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
/**
 *
 * @author ADMIN
 */
package dal;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.BrandStatsRow;
import model.BrandStatsSummary;
import model.ProductStatsRow;

public class BrandStatsDAO {

    private String orderBy(String sortBy) {
        if (sortBy == null) {
            sortBy = "stock";
        }
        switch (sortBy) {
            case "name":
                return "b.brand_name";
            case "products":
                return "COALESCE(prod.total_products, 0)";
            case "low":
                return "COALESCE(prod.low_stock_products, 0)";
            case "import":
                return "COALESCE(imp.imported_units, 0)";
            case "export":
                return "COALESCE(exp.exported_units, 0)";
            case "stock":
            default:
                return "COALESCE(prod.total_stock_units, 0)";
        }
    }

    private String orderDir(String sortOrder) {
        return "ASC".equalsIgnoreCase(sortOrder) ? "ASC" : "DESC";
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private void appendBrandFiltersOnBrandsAliasB(
            StringBuilder sql,
            List<Object> params,
            String q,
            String brandStatus,
            Long brandId
    ) {
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
    }

    public int countBrands(String q, String brandStatus, Long brandId, Date fromDate, Date toDate) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*)
            FROM brands b
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        appendBrandFiltersOnBrandsAliasB(sql, params, q, brandStatus, brandId);

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public BrandStatsSummary getSummary(
            String q,
            String brandStatus,
            Long brandId,
            int lowThreshold,
            Date fromDate,
            Date toDate
    ) throws Exception {

        BrandStatsSummary sum = new BrandStatsSummary();

        StringBuilder sql = new StringBuilder("""
            SELECT
              COUNT(DISTINCT b.brand_id) AS total_brands,
              COUNT(DISTINCT p.product_id) AS total_products,
              COALESCE(SUM(ib.qty_on_hand), 0) AS total_stock_units,
              COUNT(DISTINCT CASE
                  WHEN COALESCE(prod_qty.product_qty, 0) < 10 THEN p.product_id
              END) AS low_stock_products
            FROM brands b
            LEFT JOIN products p ON p.brand_id = b.brand_id
            LEFT JOIN product_skus s ON s.product_id = p.product_id
            LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id
            LEFT JOIN (
                SELECT
                    p2.product_id,
                    COALESCE(SUM(ib2.qty_on_hand), 0) AS product_qty
                FROM products p2
                LEFT JOIN product_skus s2 ON s2.product_id = p2.product_id
                LEFT JOIN inventory_balance ib2 ON ib2.sku_id = s2.sku_id
                GROUP BY p2.product_id
            ) prod_qty ON prod_qty.product_id = p.product_id
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        appendBrandFiltersOnBrandsAliasB(sql, params, q, brandStatus, brandId);

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    sum.setTotalBrands(rs.getInt("total_brands"));
                    sum.setTotalProducts(rs.getInt("total_products"));
                    sum.setTotalStockUnits(rs.getInt("total_stock_units"));
                    sum.setLowStockProducts(rs.getInt("low_stock_products"));
                }
            }
        }

        sum.setImportedUnitsInRange(sumImportedInRange(q, brandStatus, brandId, fromDate, toDate));
        sum.setExportedUnitsInRange(sumExportedInRange(q, brandStatus, brandId, fromDate, toDate));

        return sum;
    }

    private int sumImportedInRange(
            String q,
            String brandStatus,
            Long brandId,
            Date fromDate,
            Date toDate
    ) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT COALESCE(SUM(irl.qty), 0) AS total_import
            FROM import_receipts ir
            JOIN import_receipt_lines irl ON irl.import_id = ir.import_id
            JOIN product_skus s ON s.sku_id = irl.sku_id
            JOIN products p ON p.product_id = s.product_id
            JOIN brands b ON b.brand_id = p.brand_id
            WHERE ir.status = 'CONFIRMED'
              AND ir.receipt_date IS NOT NULL
        """);

        List<Object> params = new ArrayList<>();
        appendBrandFiltersOnBrandsAliasB(sql, params, q, brandStatus, brandId);

        if (fromDate != null) {
            sql.append(" AND DATE(ir.receipt_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ir.receipt_date) <= ? ");
            params.add(toDate);
        }

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private int sumExportedInRange(
            String q,
            String brandStatus,
            Long brandId,
            Date fromDate,
            Date toDate
    ) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT COALESCE(SUM(exl.qty), 0) AS total_export
            FROM export_receipts ex
            JOIN export_receipt_lines exl ON exl.export_id = ex.export_id
            JOIN product_skus s ON s.sku_id = exl.sku_id
            JOIN products p ON p.product_id = s.product_id
            JOIN brands b ON b.brand_id = p.brand_id
            WHERE ex.status = 'CONFIRMED'
              AND ex.export_date IS NOT NULL
        """);

        List<Object> params = new ArrayList<>();
        appendBrandFiltersOnBrandsAliasB(sql, params, q, brandStatus, brandId);

        if (fromDate != null) {
            sql.append(" AND DATE(ex.export_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ex.export_date) <= ? ");
            params.add(toDate);
        }

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<BrandStatsRow> listBrandStats(
            String q,
            String brandStatus,
            Long brandId,
            String sortBy,
            String sortOrder,
            int page,
            int pageSize,
            int lowThreshold,
            Date fromDate,
            Date toDate
    ) throws Exception {

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
              COALESCE(imp.imported_units, 0)      AS imported_units,
              COALESCE(exp.exported_units, 0)      AS exported_units
            FROM brands b

            LEFT JOIN (
                SELECT
                  p.brand_id,
                  COUNT(DISTINCT p.product_id) AS total_products,
                  COALESCE(SUM(ib.qty_on_hand), 0) AS total_stock_units,
                  COUNT(DISTINCT CASE
                      WHEN COALESCE(prod_qty.product_qty, 0) < 10 THEN p.product_id
                  END) AS low_stock_products
                FROM products p
                LEFT JOIN product_skus s ON s.product_id = p.product_id
                LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id
                LEFT JOIN (
                    SELECT
                        p2.product_id,
                        COALESCE(SUM(ib2.qty_on_hand), 0) AS product_qty
                    FROM products p2
                    LEFT JOIN product_skus s2 ON s2.product_id = p2.product_id
                    LEFT JOIN inventory_balance ib2 ON ib2.sku_id = s2.sku_id
                    GROUP BY p2.product_id
                ) prod_qty ON prod_qty.product_id = p.product_id
                GROUP BY p.brand_id
            ) prod ON prod.brand_id = b.brand_id

            LEFT JOIN (
                SELECT
                  p.brand_id,
                  COALESCE(SUM(irl.qty), 0) AS imported_units
                FROM import_receipts ir
                JOIN import_receipt_lines irl ON irl.import_id = ir.import_id
                JOIN product_skus s ON s.sku_id = irl.sku_id
                JOIN products p ON p.product_id = s.product_id
                WHERE ir.status = 'CONFIRMED'
                  AND ir.receipt_date IS NOT NULL
        """);

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

            LEFT JOIN (
                SELECT
                  p.brand_id,
                  COALESCE(SUM(exl.qty), 0) AS exported_units
                FROM export_receipts ex
                JOIN export_receipt_lines exl ON exl.export_id = ex.export_id
                JOIN product_skus s ON s.sku_id = exl.sku_id
                JOIN products p ON p.product_id = s.product_id
                WHERE ex.status = 'CONFIRMED'
                  AND ex.export_date IS NOT NULL
        """);

        if (fromDate != null) {
            sql.append(" AND DATE(ex.export_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ex.export_date) <= ? ");
            params.add(toDate);
        }

        sql.append("""
                GROUP BY p.brand_id
            ) exp ON exp.brand_id = b.brand_id

            WHERE 1=1
        """);

        appendBrandFiltersOnBrandsAliasB(sql, params, q, brandStatus, brandId);

        sql.append(" ORDER BY ")
           .append(orderBy(sortBy))
           .append(" ")
           .append(orderDir(sortOrder))
           .append(", b.brand_name ASC, b.brand_id ASC ");

        sql.append(" LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add(offset);

        List<BrandStatsRow> list = new ArrayList<>();

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

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
                    r.setExportedUnits(rs.getInt("exported_units"));
                    list.add(r);
                }
            }
        }

        return list;
    }

    public List<ProductStatsRow> listBrandDetail(
            long brandId,
            int lowThreshold,
            Date fromDate,
            Date toDate,
            String dSortBy,
            String dSortOrder
    ) throws Exception {

        String orderCol;
        if ("import".equalsIgnoreCase(dSortBy)) {
            orderCol = "imported_units";
        } else if ("export".equalsIgnoreCase(dSortBy)) {
            orderCol = "exported_units";
        } else if ("name".equalsIgnoreCase(dSortBy)) {
            orderCol = "product_name";
        } else {
            orderCol = "total_stock_units";
        }

        String orderDir = "ASC".equalsIgnoreCase(dSortOrder) ? "ASC" : "DESC";

        StringBuilder sql = new StringBuilder("""
            SELECT
              p.product_id,
              p.product_code,
              p.product_name,
              COALESCE(stock.total_stock_units, 0) AS total_stock_units,
              COALESCE(imp.imported_units, 0) AS imported_units,
              COALESCE(exp.exported_units, 0) AS exported_units,
              imp.last_import_at,
              exp.last_export_at,
              0 AS avg_daily_sales,
              0 AS lead_time_days,
              0 AS safety_stock
            FROM products p

            LEFT JOIN (
                SELECT
                    s.product_id,
                    COALESCE(SUM(ib.qty_on_hand), 0) AS total_stock_units
                FROM product_skus s
                LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id
                GROUP BY s.product_id
            ) stock ON stock.product_id = p.product_id

            LEFT JOIN (
                SELECT
                  s.product_id,
                  COALESCE(SUM(irl.qty), 0) AS imported_units,
                  MAX(ir.receipt_date) AS last_import_at
                FROM import_receipts ir
                JOIN import_receipt_lines irl ON irl.import_id = ir.import_id
                JOIN product_skus s ON s.sku_id = irl.sku_id
                WHERE ir.status = 'CONFIRMED'
                  AND ir.receipt_date IS NOT NULL
        """);

        List<Object> params = new ArrayList<>();

        if (fromDate != null) {
            sql.append(" AND DATE(ir.receipt_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ir.receipt_date) <= ? ");
            params.add(toDate);
        }

        sql.append("""
                GROUP BY s.product_id
            ) imp ON imp.product_id = p.product_id

            LEFT JOIN (
                SELECT
                  s.product_id,
                  COALESCE(SUM(exl.qty), 0) AS exported_units,
                  MAX(ex.export_date) AS last_export_at
                FROM export_receipts ex
                JOIN export_receipt_lines exl ON exl.export_id = ex.export_id
                JOIN product_skus s ON s.sku_id = exl.sku_id
                WHERE ex.status = 'CONFIRMED'
                  AND ex.export_date IS NOT NULL
        """);

        if (fromDate != null) {
            sql.append(" AND DATE(ex.export_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ex.export_date) <= ? ");
            params.add(toDate);
        }

        sql.append("""
                GROUP BY s.product_id
            ) exp ON exp.product_id = p.product_id

            WHERE p.brand_id = ?
            ORDER BY
        """);

        params.add(brandId);
        sql.append(orderCol).append(" ").append(orderDir).append(", p.product_id ASC");

        List<ProductStatsRow> list = new ArrayList<>();

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStatsRow r = new ProductStatsRow();
                    r.setProductId(rs.getLong("product_id"));
                    r.setProductCode(rs.getString("product_code"));
                    r.setProductName(rs.getString("product_name"));

                    int stock = rs.getInt("total_stock_units");
                    r.setTotalStockUnits(stock);
                    r.setImportedUnits(rs.getInt("imported_units"));
                    r.setExportedUnits(rs.getInt("exported_units"));
                    r.setLastImportAt(rs.getTimestamp("last_import_at"));
                    r.setLastExportAt(rs.getTimestamp("last_export_at"));

                    int threshold = 10;

                    String status;
                    if (stock == 0) {
                        status = "Out Of Stock";
                    } else if (stock < threshold) {
                        status = "Reorder Needed";
                    } else if (stock == threshold) {
                        status = "At Threshold";
                    } else {
                        status = "OK";
                    }

                    r.setStockStatus(status);
                    list.add(r);
                }
            }
        }

        return list;
    }

    public List<ProductStatsRow> listBrandDetailWithMovement(
            long brandId,
            int lowThreshold,
            Date fromDate,
            Date toDate,
            String sortBy,
            String sortOrder
    ) throws Exception {

        if (sortBy == null || sortBy.isBlank()) {
            sortBy = "stock";
        }
        if (sortOrder == null || sortOrder.isBlank()) {
            sortOrder = "DESC";
        }

        String orderCol;
        switch (sortBy) {
            case "name":
                orderCol = "product_name";
                break;
            case "import":
                orderCol = "imported_units";
                break;
            case "export":
                orderCol = "exported_units";
                break;
            default:
                orderCol = "total_stock_units";
                break;
        }

        String dir = "ASC".equalsIgnoreCase(sortOrder) ? "ASC" : "DESC";

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();

        sql.append("""
            SELECT
              p.product_id,
              p.product_code,
              p.product_name,
              COALESCE(stock.total_stock_units, 0) AS total_stock_units,
              COALESCE(imp.imported_units, 0)      AS imported_units,
              COALESCE(exp.exported_units, 0)      AS exported_units,
              0       AS avg_daily_sales,
              0        AS lead_time_days,
              0          AS safety_stock
            FROM products p

            LEFT JOIN (
                SELECT
                    s.product_id,
                    COALESCE(SUM(ib.qty_on_hand), 0) AS total_stock_units
                FROM product_skus s
                LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id
                GROUP BY s.product_id
            ) stock ON stock.product_id = p.product_id

            LEFT JOIN (
                SELECT
                    s.product_id,
                    COALESCE(SUM(irl.qty), 0) AS imported_units
                FROM import_receipts ir
                JOIN import_receipt_lines irl ON irl.import_id = ir.import_id
                JOIN product_skus s ON s.sku_id = irl.sku_id
                WHERE ir.status = 'CONFIRMED'
                  AND ir.receipt_date IS NOT NULL
        """);

        if (fromDate != null) {
            sql.append(" AND DATE(ir.receipt_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ir.receipt_date) <= ? ");
            params.add(toDate);
        }

        sql.append("""
                GROUP BY s.product_id
            ) imp ON imp.product_id = p.product_id

            LEFT JOIN (
                SELECT
                    s.product_id,
                    COALESCE(SUM(exl.qty), 0) AS exported_units
                FROM export_receipts ex
                JOIN export_receipt_lines exl ON exl.export_id = ex.export_id
                JOIN product_skus s ON s.sku_id = exl.sku_id
                WHERE ex.status = 'CONFIRMED'
                  AND ex.export_date IS NOT NULL
        """);

        if (fromDate != null) {
            sql.append(" AND DATE(ex.export_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ex.export_date) <= ? ");
            params.add(toDate);
        }

        sql.append("""
                GROUP BY s.product_id
            ) exp ON exp.product_id = p.product_id

            WHERE p.brand_id = ?
        """);

        params.add(brandId);

        sql.append(" ORDER BY ").append(orderCol).append(" ").append(dir).append(", p.product_id ASC ");

        List<ProductStatsRow> list = new ArrayList<>();

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductStatsRow r = new ProductStatsRow();
                    r.setProductId(rs.getLong("product_id"));
                    r.setProductCode(rs.getString("product_code"));
                    r.setProductName(rs.getString("product_name"));

                    int stock = rs.getInt("total_stock_units");
                    r.setTotalStockUnits(stock);
                    r.setImportedUnits(rs.getInt("imported_units"));
                    r.setExportedUnits(rs.getInt("exported_units"));

                    int threshold = 10;

                    String status;
                    if (stock == 0) {
                        status = "Out Of Stock";
                    } else if (stock < threshold) {
                        status = "Reorder Needed";
                    } else if (stock == threshold) {
                        status = "At Threshold";
                    } else {
                        status = "OK";
                    }

                    r.setStockStatus(status);
                    list.add(r);
                }
            }
        }

        return list;
    }

    public BrandStatsSummary getBrandDetailSummary(
            long brandId,
            int lowThreshold,
            Date fromDate,
            Date toDate
    ) throws Exception {

        StringBuilder sql = new StringBuilder("""
            SELECT
              COUNT(DISTINCT p.product_id) AS total_products,
              COALESCE(SUM(ib.qty_on_hand), 0) AS total_stock_units,
              COUNT(DISTINCT CASE
                  WHEN COALESCE(prod_qty.product_qty, 0) < 10 THEN p.product_id
              END) AS low_stock_products
            FROM products p
            LEFT JOIN product_skus s ON s.product_id = p.product_id
            LEFT JOIN inventory_balance ib ON ib.sku_id = s.sku_id
            LEFT JOIN (
                SELECT
                    p2.product_id,
                    COALESCE(SUM(ib2.qty_on_hand), 0) AS product_qty
                FROM products p2
                LEFT JOIN product_skus s2 ON s2.product_id = p2.product_id
                LEFT JOIN inventory_balance ib2 ON ib2.sku_id = s2.sku_id
                GROUP BY p2.product_id
            ) prod_qty ON prod_qty.product_id = p.product_id
            WHERE p.brand_id = ?
        """);

        List<Object> params = new ArrayList<>();
        params.add(brandId);

        BrandStatsSummary sum = new BrandStatsSummary();

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    sum.setTotalProducts(rs.getInt("total_products"));
                    sum.setTotalStockUnits(rs.getInt("total_stock_units"));
                    sum.setLowStockProducts(rs.getInt("low_stock_products"));
                }
            }
        }

        sum.setImportedUnitsInRange(sumImportedUnitsForBrandInRange(brandId, fromDate, toDate));
        sum.setExportedUnitsInRange(sumExportedUnitsForBrandInRange(brandId, fromDate, toDate));

        return sum;
    }

    private int sumImportedUnitsForBrandInRange(long brandId, Date fromDate, Date toDate) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT COALESCE(SUM(irl.qty), 0)
            FROM import_receipts ir
            JOIN import_receipt_lines irl ON irl.import_id = ir.import_id
            JOIN product_skus s ON s.sku_id = irl.sku_id
            JOIN products p ON p.product_id = s.product_id
            WHERE ir.status = 'CONFIRMED'
              AND ir.receipt_date IS NOT NULL
              AND p.brand_id = ?
        """);

        List<Object> params = new ArrayList<>();
        params.add(brandId);

        if (fromDate != null) {
            sql.append(" AND DATE(ir.receipt_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ir.receipt_date) <= ? ");
            params.add(toDate);
        }

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private int sumExportedUnitsForBrandInRange(long brandId, Date fromDate, Date toDate) throws Exception {
        StringBuilder sql = new StringBuilder("""
            SELECT COALESCE(SUM(exl.qty), 0)
            FROM export_receipts ex
            JOIN export_receipt_lines exl ON exl.export_id = ex.export_id
            JOIN product_skus s ON s.sku_id = exl.sku_id
            JOIN products p ON p.product_id = s.product_id
            WHERE ex.status = 'CONFIRMED'
              AND ex.export_date IS NOT NULL
              AND p.brand_id = ?
        """);

        List<Object> params = new ArrayList<>();
        params.add(brandId);

        if (fromDate != null) {
            sql.append(" AND DATE(ex.export_date) >= ? ");
            params.add(fromDate);
        }
        if (toDate != null) {
            sql.append(" AND DATE(ex.export_date) <= ? ");
            params.add(toDate);
        }

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}