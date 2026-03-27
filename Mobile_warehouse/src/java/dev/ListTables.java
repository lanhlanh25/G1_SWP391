package dev;

import dal.DBContext;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.DatabaseMetaData;

public class ListTables {
    public static void main(String[] args) {
        try (Connection con = DBContext.getConnection()) {
            DatabaseMetaData md = con.getMetaData();
            ResultSet rs = md.getTables(null, null, "%", new String[] {"TABLE"});
            while (rs.next()) {
                System.out.println("Table: " + rs.getString(3));
            }
            
            // Also check columns of product_units
            System.out.println("\nColumns of product_units:");
            ResultSet rs2 = md.getColumns(null, null, "product_units", "%");
            while (rs2.next()) {
                System.out.println(rs2.getString(4) + " (" + rs2.getString(6) + ")");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
