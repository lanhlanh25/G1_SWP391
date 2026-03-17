package dal;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.BestSellingProductStat;

public class BestSellingProductStatisticsDAO extends DBContext {

    public List<BestSellingProductStat> getBestSellingProducts(
            Date fromDate,
            Date toDate,
            int topN,
            String sortOrder
    ) throws Exception {

        List<BestSellingProductStat> list = new ArrayList<>();

        String order = "DESC";
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            order = "ASC";
        }

        String sql
                = "SELECT "
                + "    p.product_id, "
                + "    p.product_code, "
                + "    p.product_name, "
                + "    b.brand_name, "
                + "    SUM(erl.qty) AS units_sold, "
                + "    MAX(er.export_date) AS last_sold "
                + "FROM export_receipts er "
                + "JOIN export_receipt_lines erl ON er.export_id = erl.export_id "
                + "JOIN products p ON erl.product_id = p.product_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE er.status = 'CONFIRMED' "
                + "  AND DATE(er.export_date) BETWEEN ? AND ? "
                + "GROUP BY p.product_id, p.product_code, p.product_name, b.brand_name "
                + "ORDER BY units_sold " + order + ", last_sold DESC "
                + "LIMIT ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);
            ps.setInt(3, topN);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BestSellingProductStat x = new BestSellingProductStat();
                    x.setProductId(rs.getLong("product_id"));
                    x.setProductCode(rs.getString("product_code"));
                    x.setProductName(rs.getString("product_name"));
                    x.setBrandName(rs.getString("brand_name"));
                    x.setUnitsSold(rs.getInt("units_sold"));
                    x.setLastSold(rs.getTimestamp("last_sold"));
                    list.add(x);
                }
            }
        }

        return list;
    }

    public int getTotalUnitsSold(Date fromDate, Date toDate) throws Exception {
        String sql
                = "SELECT COALESCE(SUM(erl.qty), 0) AS total_units "
                + "FROM export_receipts er "
                + "JOIN export_receipt_lines erl ON er.export_id = erl.export_id "
                + "WHERE er.status = 'CONFIRMED' "
                + "  AND DATE(er.export_date) BETWEEN ? AND ?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_units");
                }
            }
        }

        return 0;
    }

    public BestSellingProductStat getBestProduct(Date fromDate, Date toDate) throws Exception {
        String sql
                = "SELECT "
                + "    p.product_id, "
                + "    p.product_code, "
                + "    p.product_name, "
                + "    b.brand_name, "
                + "    SUM(erl.qty) AS units_sold, "
                + "    MAX(er.export_date) AS last_sold "
                + "FROM export_receipts er "
                + "JOIN export_receipt_lines erl ON er.export_id = erl.export_id "
                + "JOIN products p ON erl.product_id = p.product_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE er.status = 'CONFIRMED' "
                + "  AND DATE(er.export_date) BETWEEN ? AND ? "
                + "GROUP BY p.product_id, p.product_code, p.product_name, b.brand_name "
                + "ORDER BY units_sold DESC, last_sold DESC "
                + "LIMIT 1";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, fromDate);
            ps.setDate(2, toDate);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BestSellingProductStat x = new BestSellingProductStat();
                    x.setProductId(rs.getLong("product_id"));
                    x.setProductCode(rs.getString("product_code"));
                    x.setProductName(rs.getString("product_name"));
                    x.setBrandName(rs.getString("brand_name"));
                    x.setUnitsSold(rs.getInt("units_sold"));
                    x.setLastSold(rs.getTimestamp("last_sold"));
                    return x;
                }
            }
        }

        return null;
    }
}
