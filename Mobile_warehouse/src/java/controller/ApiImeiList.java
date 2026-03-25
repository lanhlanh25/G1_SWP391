package controller;

import dal.ViewImeiDAO;
import model.ImeiRow;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;


@WebServlet(name = "ApiImeiList", urlPatterns = {"/api/imei-list"})
public class ApiImeiList extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String skuIdRaw = req.getParameter("skuId");
        if (skuIdRaw == null || skuIdRaw.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Missing skuId\"}");
            return;
        }

        long skuId;
        try {
            skuId = Long.parseLong(skuIdRaw);
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Invalid skuId\"}");
            return;
        }

        ViewImeiDAO dao = new ViewImeiDAO();
        try {
            // Fetch first 500 IMEIs for the modal
            List<ImeiRow> rows = dao.listImeis(skuId, null, 1, 500);
            
            System.out.println("[API] Fetching IMEIs for skuId: " + skuId + " | Found: " + (rows != null ? rows.size() : 0));

            resp.setContentType("application/json;charset=UTF-8");
            StringBuilder sb = new StringBuilder();
            sb.append("[");
            for (int i = 0; i < rows.size(); i++) {
                ImeiRow r = rows.get(i);
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"imei\":\"").append(r.getImei()).append("\",");
                sb.append("\"status\":\"").append(r.getStatus()).append("\"");
                sb.append("}");
            }
            sb.append("]");
            resp.getWriter().write(sb.toString());
        } catch (Exception ex) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"Server error: " + ex.getMessage() + "\"}");
        }
    }
}
