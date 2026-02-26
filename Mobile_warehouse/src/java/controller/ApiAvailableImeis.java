/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */


/**
 *
 * @author Admin
 */
package controller;

import dal.DBContext;
import dal.ExportReceiptDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet(name="ApiAvailableImeis", urlPatterns={"/api/available-imeis"})
public class ApiAvailableImeis extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String skuIdRaw = req.getParameter("skuId");
        long skuId;
        try {
            skuId = Long.parseLong(skuIdRaw);
        } catch (Exception e) {
            resp.setStatus(400);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Invalid skuId\"}");
            return;
        }

        ExportReceiptDAO dao = new ExportReceiptDAO();

        try (Connection con = DBContext.getConnection()) {
            List<String> imeis = dao.listAvailableImeisBySku(con, skuId);

            resp.setContentType("application/json;charset=UTF-8");
            StringBuilder sb = new StringBuilder();
            sb.append("[");
            for (int i = 0; i < imeis.size(); i++) {
                if (i > 0) sb.append(",");
                sb.append("\"").append(imeis.get(i).replace("\"", "\\\"")).append("\"");
            }
            sb.append("]");
            resp.getWriter().write(sb.toString());

        } catch (Exception ex) {
            resp.setStatus(500);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Server error\"}");
        }
    }
}