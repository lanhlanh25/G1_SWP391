package dev;

import dal.ViewImeiDAO;
import model.ImeiRow;
import java.util.List;

public class TestDAO {
    public static void main(String[] args) {
        try {
            ViewImeiDAO dao = new ViewImeiDAO();
            // Test with a few SKU IDs from 1 to 50
            for (long id = 1; id <= 50; id++) {
                List<ImeiRow> rows = dao.listImeis(id, null, 1, 100);
                if (!rows.isEmpty()) {
                    System.out.println("SKU ID " + id + " has " + rows.size() + " IMEIs");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
