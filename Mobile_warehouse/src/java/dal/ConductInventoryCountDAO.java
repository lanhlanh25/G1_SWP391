/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */


import model.IdName;
import model.InventoryCountRow;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;



import java.util.List;

public class ConductInventoryCountDAO {

    private Connection getConn() throws Exception {
        return DBContext.getConnection();
    }

    public List<IdName> getActiveBrands() {
        List<IdName> list = new ArrayList<>();
        String sql = "SELECT brand_id, brand_name " +
                     "FROM brands " +
                     "WHERE is_active = 1 " +
                     "ORDER BY brand_name";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new IdName(rs.getLong("brand_id"), rs.getString("brand_name")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countRows(String q, String brandId) {
        StringBuilder where = new StringBuilder(" WHERE s.status = 'ACTIVE' AND p.status = 'ACTIVE' ");
        List<Object> params = new ArrayList<>();
        appendFilters(where, params, q, brandId);

        String sql = "SELECT COUNT(*) " +
                     "FROM product_skus s " +
                     "JOIN products p ON p.product_id = s.product_id " +
                     where;

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<InventoryCountRow> listRows(int userId, String q, String brandId, int page, int pageSize) {
        List<InventoryCountRow> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder where = new StringBuilder(" WHERE s.status = 'ACTIVE' AND p.status = 'ACTIVE' ");
        List<Object> params = new ArrayList<>();
        appendFilters(where, params, q, brandId);

        String sql =
            "SELECT " +
            "    s.sku_id, " +
            "    s.sku_code, " +
            "    p.product_name, " +
            "    s.color, " +
            "    s.ram_gb, " +
            "    s.storage_gb, " +
            "    (" +
            "        SELECT COUNT(*) " +
            "        FROM product_units pu " +
            "        WHERE pu.sku_id = s.sku_id " +
            "          AND pu.unit_status = 'ACTIVE'" +
            "    ) AS system_qty, " +
            "    (" +
            "        SELECT scl.counted_qty " +
            "        FROM stock_count_lines scl " +
            "        JOIN stock_counts sc ON sc.count_id = scl.count_id " +
            "        WHERE scl.sku_id = s.sku_id " +
            "          AND sc.created_by = ? " +
            "          AND sc.status = 'DRAFT' " +
            "        ORDER BY sc.count_id DESC " +
            "        LIMIT 1" +
            "    ) AS counted_qty " +
            "FROM product_skus s " +
            "JOIN products p ON p.product_id = s.product_id " +
            where +
            "ORDER BY s.sku_code " +
            "LIMIT ? OFFSET ?";

        try (Connection con = getConn();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int idx = 1;
            ps.setInt(idx++, userId);

            for (Object o : params) {
                if (o instanceof String) {
                    ps.setString(idx++, (String) o);
                } else if (o instanceof Long) {
                    ps.setLong(idx++, (Long) o);
                } else {
                    ps.setObject(idx++, o);
                }
            }

            ps.setInt(idx++, pageSize);
            ps.setInt(idx, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InventoryCountRow r = new InventoryCountRow();

                    r.setSkuId(rs.getLong("sku_id"));
                    r.setSkuCode(rs.getString("sku_code"));
                    r.setProductName(rs.getString("product_name"));
                    r.setColor(rs.getString("color"));
                    r.setRamGb(rs.getInt("ram_gb"));
                    r.setStorageGb(rs.getInt("storage_gb"));

                    int systemQty = rs.getInt("system_qty");
                    Object countedObj = rs.getObject("counted_qty");
                    int countedQty = (countedObj == null) ? systemQty : rs.getInt("counted_qty");

                    r.setSystemQty(systemQty);
                    r.setCountedQty(countedQty);

                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean saveCountedQty(int createdBy, Map<Long, Integer> skuToCountedQty) {
        if (skuToCountedQty == null || skuToCountedQty.isEmpty()) {
            return false;
        }

        String findDraftSql =
            "SELECT count_id " +
            "FROM stock_counts " +
            "WHERE created_by = ? AND status = 'DRAFT' " +
            "ORDER BY count_id DESC " +
            "LIMIT 1";

        String insertDraftSql =
            "INSERT INTO stock_counts (count_code, status, count_date, created_by) " +
            "VALUES (?, 'DRAFT', NOW(), ?)";

        String getSystemQtySql =
            "SELECT COUNT(*) " +
            "FROM product_units " +
            "WHERE sku_id = ? AND unit_status = 'ACTIVE'";

        String upsertLineSql =
            "INSERT INTO stock_count_lines (count_id, sku_id, system_qty, counted_qty, difference, result) " +
            "VALUES (?, ?, ?, ?, ?, ?) " +
            "ON DUPLICATE KEY UPDATE " +
            "    system_qty = VALUES(system_qty), " +
            "    counted_qty = VALUES(counted_qty), " +
            "    difference = VALUES(difference), " +
            "    result = VALUES(result)";

        Connection con = null;

        try {
            con = getConn();
            con.setAutoCommit(false);

            long countId = findLatestDraftCountId(con, createdBy);

            if (countId <= 0) {
                countId = createNewDraft(con, insertDraftSql, createdBy);
            }

            try (PreparedStatement psSystemQty = con.prepareStatement(getSystemQtySql);
                 PreparedStatement psUpsertLine = con.prepareStatement(upsertLineSql)) {

                for (Map.Entry<Long, Integer> entry : skuToCountedQty.entrySet()) {
                    long skuId = entry.getKey();
                    int countedQty = entry.getValue();

                    if (countedQty < 0) {
                        countedQty = 0;
                    }

                    int systemQty = 0;

                    psSystemQty.setLong(1, skuId);
                    try (ResultSet rs = psSystemQty.executeQuery()) {
                        if (rs.next()) {
                            systemQty = rs.getInt(1);
                        }
                    }

                    int difference = systemQty - countedQty;
                    String result = (countedQty == systemQty) ? "ENOUGH" : "MISSING";

                    psUpsertLine.setLong(1, countId);
                    psUpsertLine.setLong(2, skuId);
                    psUpsertLine.setInt(3, systemQty);
                    psUpsertLine.setInt(4, countedQty);
                    psUpsertLine.setInt(5, difference);
                    psUpsertLine.setString(6, result);
                    psUpsertLine.addBatch();
                }

                psUpsertLine.executeBatch();
            }

            con.commit();
            return true;

        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (Exception ignore) {
                }
            }
            e.printStackTrace();
            return false;

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (Exception ignore) {
                }
            }
        }
    }

    private long findLatestDraftCountId(Connection con, int createdBy) throws Exception {
        String sql =
            "SELECT count_id " +
            "FROM stock_counts " +
            "WHERE created_by = ? AND status = 'DRAFT' " +
            "ORDER BY count_id DESC " +
            "LIMIT 1";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, createdBy);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("count_id");
                }
            }
        }

        return -1;
    }

    private long createNewDraft(Connection con, String insertDraftSql, int createdBy) throws Exception {
        String countCode = generateCountCode();

        try (PreparedStatement ps = con.prepareStatement(insertDraftSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, countCode);
            ps.setInt(2, createdBy);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }

        throw new SQLException("Cannot create stock count draft");
    }

    private String generateCountCode() {
        return "SC-" +
               java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.BASIC_ISO_DATE) +
               "-" + (System.currentTimeMillis() % 100000);
    }

    private void appendFilters(StringBuilder where, List<Object> params, String q, String brandId) {
        if (q != null && !q.trim().isEmpty()) {
            where.append(" AND (p.product_name LIKE ? OR s.sku_code LIKE ? OR p.product_code LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (brandId != null && !brandId.trim().isEmpty()) {
            long brandLong = parseLongSafe(brandId);
            if (brandLong > 0) {
                where.append(" AND p.brand_id = ? ");
                params.add(brandLong);
            }
        }
    }

    private int bind(PreparedStatement ps, List<Object> params) throws Exception {
        int idx = 1;
        for (Object o : params) {
            if (o instanceof String) {
                ps.setString(idx++, (String) o);
            } else if (o instanceof Long) {
                ps.setLong(idx++, (Long) o);
            } else {
                ps.setObject(idx++, o);
            }
        }
        return idx;
    }

    private long parseLongSafe(String s) {
        try {
            return Long.parseLong(s.trim());
        } catch (Exception e) {
            return -1;
        }
    }
}