package controller;

import dal.ExportReceiptDAO;
import model.ExportReceiptListItem;
import model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "ExportReceiptListServlet", urlPatterns = {"/export-receipt-list"})
public class ExportReceiptListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        try {
            HttpSession session = request.getSession();
            User u = (User) session.getAttribute("authUser");
            if (u == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            String searchCode = request.getParameter("searchCode");
            String status = request.getParameter("status");
            String fromDate = request.getParameter("fromDate");
            String toDate = request.getParameter("toDate");
            
            int page = 1;
            int pageSize = 10;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            int offset = (page - 1) * pageSize;
            
            ExportReceiptDAO dao = new ExportReceiptDAO();
            List<ExportReceiptListItem> exportList = dao.searchExportReceipts(searchCode, status, fromDate, toDate, offset, pageSize);
            int totalRecords = dao.countTotalExportReceipts(searchCode, status, fromDate, toDate);
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            
            request.setAttribute("exportList", exportList);
            request.setAttribute("searchCode", searchCode);
            request.setAttribute("status", status);
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);
            
            // Đổi thành pageIndex để phân trang, trả lại currentPage dạng chuỗi cho menu
            request.setAttribute("pageIndex", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", "export-receipt-list");
            
            String role = (String) session.getAttribute("roleName");
            if (role == null) role = "STAFF";
            String sidebar = "sidebar_staff.jsp";
            if ("ADMIN".equals(role)) sidebar = "sidebar_admin.jsp";
            else if ("MANAGER".equals(role)) sidebar = "sidebar_manager.jsp";
            else if ("SALE".equals(role)) sidebar = "sidebar_sales.jsp";
            
            request.setAttribute("sidebarPage", sidebar);
            request.setAttribute("contentPage", "export_receipt_list.jsp");
            request.getRequestDispatcher("homepage.jsp").forward(request, response);
        } catch (Exception ex) {
            Logger.getLogger(ExportReceiptListServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}