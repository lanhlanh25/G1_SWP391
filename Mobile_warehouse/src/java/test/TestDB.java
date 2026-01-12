package test;

import dal.DBContext;
import java.sql.Connection;

public class TestDB {

    public static void main(String[] args) {
        try {
            DBContext db = new DBContext();
            Connection con = db.getConnection();
            if (con != null) {
                System.out.println("✅ CONNECT DATABASE SUCCESS!");
            }
        } catch (Exception e) {
            System.out.println("❌ CONNECT DATABASE FAILED!");
            e.printStackTrace();
        }
    }
}
