/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Supplier;
import model.SupplierDetailDTO;
import model.SupplierListItem;

/**
 *
 * @author Admin
 */
public class SupplierDAO {

    public boolean existsByNameOrEmail(String name, String email) throws SQLException {
        String sql = "SELECT 1 FROM suppliers "
                + "WHERE deleted_at IS NULL AND (supplier_name = ? OR email = ?) "
                + "LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            throw new SQLException("Check supplier duplicate failed", e);
        }
    }

    public long insert(Supplier s) throws SQLException {
        String sql = "INSERT INTO suppliers (supplier_name, phone, email, address, is_active, created_by, updated_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, s.getSupplierName());
            ps.setString(2, s.getPhone());
            ps.setString(3, s.getEmail());
            ps.setString(4, s.getAddress());
            ps.setInt(5, s.getIsActive());

            if (s.getCreatedBy() == null) {
                ps.setNull(6, Types.BIGINT);
                ps.setNull(7, Types.BIGINT);
            } else {
                ps.setLong(6, s.getCreatedBy());
                ps.setLong(7, s.getCreatedBy()); 
            }

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
            return -1;

        } catch (Exception e) {
            throw new SQLException("Insert supplier failed", e);
        }
    }

    public int countSuppliers(String q, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM suppliers s "
                + "WHERE s.deleted_at IS NULL "
        );
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (s.supplier_name LIKE ? OR s.email LIKE ? OR s.phone LIKE ?)");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (status != null && !status.isBlank()) {
            if ("active".equalsIgnoreCase(status)) {
                sql.append(" AND s.is_active = 1");
            } else if ("inactive".equalsIgnoreCase(status)) {
                sql.append(" AND s.is_active = 0");
            }
        }

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            throw new SQLException("Count suppliers failed", e);
        }
    }

    public List<SupplierListItem> searchSuppliers(String q, String status,
            String sortBy, String sortOrder,
            int page, int pageSize) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT s.supplier_id, s.supplier_name, s.phone, s.email, s.is_active, s.created_at, "
                + "       r.avg_rating AS avg_rating, "
                + "       COALESCE(t.total_txn, 0) AS total_txn "
                + "FROM suppliers s "
                + "LEFT JOIN ( "
                + "   SELECT supplier_id, AVG(score) AS avg_rating "
                + 
                "   FROM supplier_ratings "
                + "   GROUP BY supplier_id "
                + ") r ON r.supplier_id = s.supplier_id "
                + "LEFT JOIN ( "
                + "   SELECT supplier_id, COUNT(*) AS total_txn "
                + "   FROM import_receipts "
                + "   GROUP BY supplier_id "
                + ") t ON t.supplier_id = s.supplier_id "
                + "WHERE s.deleted_at IS NULL "
        );

        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (s.supplier_name LIKE ? OR s.email LIKE ? OR s.phone LIKE ?)");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (status != null && !status.isBlank()) {
            if ("active".equalsIgnoreCase(status)) {
                sql.append(" AND s.is_active = 1");
            } else if ("inactive".equalsIgnoreCase(status)) {
                sql.append(" AND s.is_active = 0");
            }
        }

      
        String order = "DESC".equalsIgnoreCase(sortOrder) ? "DESC" : "ASC";
        String sortCol;
        if ("name".equalsIgnoreCase(sortBy)) {
            sortCol = "s.supplier_name";
        } else if ("rating".equalsIgnoreCase(sortBy)) {
            sortCol = "r.avg_rating";
        } else if ("transactions".equalsIgnoreCase(sortBy)) {
            sortCol = "total_txn";
        } else {
            sortCol = "s.created_at";
        }
       
        if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY (r.avg_rating IS NULL) ASC, ").append(sortCol).append(" ").append(order);
        } else {
            sql.append(" ORDER BY ").append(sortCol).append(" ").append(order);
        }

        sql.append(" LIMIT ? OFFSET ?");
        int offset = (page - 1) * pageSize;
        params.add(pageSize);
        params.add(offset);

        List<SupplierListItem> list = new ArrayList<>();

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupplierListItem it = new SupplierListItem();
                    it.setSupplierId(rs.getLong("supplier_id"));
                    it.setSupplierName(rs.getString("supplier_name"));
                    it.setPhone(rs.getString("phone"));
                    it.setEmail(rs.getString("email"));
                    it.setIsActive(rs.getInt("is_active"));
                    it.setCreatedAt(rs.getTimestamp("created_at"));

                    Object r = rs.getObject("avg_rating");
                    it.setAvgRating(r == null ? null : ((Number) r).doubleValue());

                    it.setTotalTransactions(rs.getInt("total_txn"));
                    list.add(it);
                }
            }
            return list;

        } catch (Exception e) {
            throw new SQLException("Search suppliers failed", e);
        }
    }

    public SupplierDetailDTO getSupplierDetail(long supplierId) throws SQLException {

        String sql
                = "SELECT s.supplier_id, s.supplier_name, s.phone, s.email, s.address, s.is_active, "
                + "  (SELECT AVG(sr.score) "
                + "     FROM supplier_ratings sr "
                + "    WHERE sr.supplier_id = s.supplier_id) AS avg_rating, "
                + "  (SELECT COUNT(*) "
                + "     FROM import_receipts ir "
                + "    WHERE ir.supplier_id = s.supplier_id) AS total_import_receipts, "
                + "  (SELECT MAX(ir.receipt_date) "
                + "     FROM import_receipts ir "
                + "    WHERE ir.supplier_id = s.supplier_id) AS last_transaction, "
                + "  (SELECT COALESCE(SUM(l.qty),0) "
                + 
                "     FROM import_receipt_lines l "
                + "     JOIN import_receipts ir2 ON ir2.import_id = l.import_id "
                + "    WHERE ir2.supplier_id = s.supplier_id) AS total_qty_imported "
                + "FROM suppliers s "
                + "WHERE s.deleted_at IS NULL AND s.supplier_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, supplierId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                SupplierDetailDTO dto = new SupplierDetailDTO();
                dto.setSupplierId(rs.getLong("supplier_id"));
                dto.setSupplierName(rs.getString("supplier_name"));
                dto.setPhone(rs.getString("phone"));
                dto.setEmail(rs.getString("email"));
                dto.setAddress(rs.getString("address"));
                dto.setIsActive(rs.getInt("is_active"));

                Object r = rs.getObject("avg_rating");
                dto.setAvgRating(r == null ? null : ((Number) r).doubleValue());

                dto.setTotalImportReceipts(rs.getInt("total_import_receipts"));
                dto.setLastTransaction(rs.getTimestamp("last_transaction"));
                dto.setTotalQtyImported(rs.getLong("total_qty_imported"));

                return dto;
            }

        } catch (Exception e) {
            throw new SQLException("Load supplier detail failed", e);
        }
    }

    public Supplier getById(long supplierId) throws SQLException {
        String sql = "SELECT supplier_id, supplier_name, phone, email, address, is_active "
                + "FROM suppliers "
                + "WHERE deleted_at IS NULL AND supplier_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, supplierId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                Supplier s = new Supplier();
                s.setSupplierId(rs.getLong("supplier_id"));
                s.setSupplierName(rs.getString("supplier_name"));
                s.setPhone(rs.getString("phone"));
                s.setEmail(rs.getString("email"));
                s.setAddress(rs.getString("address"));
                s.setIsActive(rs.getInt("is_active"));
                return s;
            }

        } catch (Exception e) {
            throw new SQLException("Get supplier by id failed", e);
        }
    }

    public boolean existsByNameOrEmailExceptId(long supplierId, String name, String email) throws SQLException {
        String sql = "SELECT 1 FROM suppliers "
                + "WHERE deleted_at IS NULL AND supplier_id <> ? "
                + "  AND (supplier_name = ? OR email = ?) "
                + "LIMIT 1";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, supplierId);
            ps.setString(2, name);
            ps.setString(3, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            throw new SQLException("Check duplicate except id failed", e);
        }
    }

    public boolean updateSupplierInfo(Supplier s) throws SQLException {
        String sql = "UPDATE suppliers "
                + "SET supplier_name = ?, phone = ?, email = ?, address = ?, "
                + "    updated_by = ?, updated_at = NOW() "
                + "WHERE deleted_at IS NULL AND supplier_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, s.getSupplierName());
            ps.setString(2, s.getPhone());
            ps.setString(3, s.getEmail());
            ps.setString(4, s.getAddress());

            if (s.getUpdatedBy() == null) {
                ps.setNull(5, java.sql.Types.BIGINT);
            } else {
                ps.setLong(5, s.getUpdatedBy());
            }

            ps.setLong(6, s.getSupplierId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new SQLException("Update supplier info failed", e);
        }
    }

    public int countImportReceiptsBySupplier(long supplierId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM import_receipts WHERE supplier_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
                return 0;
            }

        } catch (Exception e) {
            throw new SQLException("Count import receipts by supplier failed", e);
        }
    }

    public boolean setActive(long supplierId, int isActive, Long updatedBy) throws SQLException {
        String sql = "UPDATE suppliers "
                + "SET is_active = ?, updated_by = ?, updated_at = NOW() "
                + "WHERE deleted_at IS NULL AND supplier_id = ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, isActive);

            if (updatedBy == null) {
                ps.setNull(2, java.sql.Types.BIGINT);
            } else {
                ps.setLong(2, updatedBy);
            }

            ps.setLong(3, supplierId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new SQLException("Set supplier active/inactive failed", e);
        }
    }

}
