package controller;

import dal.ProductSkuDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import model.ProductSku;

public class ViewVariantMatrix {

    private static final int PAGE_SIZE = 10;

    public static void handle(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String color = request.getParameter("color");
        String storage = request.getParameter("storage");
        String ram = request.getParameter("ram");
        String sku = request.getParameter("sku");
        String q = request.getParameter("q"); // Product search
        String status = request.getParameter("status");
        String productIdRaw = request.getParameter("productId");
        Integer productId = null;

        if (productIdRaw != null && !productIdRaw.isEmpty()) {
            productId = Integer.parseInt(productIdRaw);
        }
        ProductSkuDAO dao = new ProductSkuDAO();

        List<ProductSku> allFiltered = dao.filterVariants(productId, color, storage, ram, status, sku, q);

        // --- Pagination ---
        int totalItems = allFiltered.size();
        int totalPages = (int) Math.ceil(totalItems * 1.0 / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;

        int page = 1;
        String pageRaw = request.getParameter("page");
        if (pageRaw != null && !pageRaw.isEmpty()) {
            try { page = Integer.parseInt(pageRaw); } catch (NumberFormatException ignored) {}
        }
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * PAGE_SIZE;
        int toIndex = Math.min(fromIndex + PAGE_SIZE, totalItems);
        List<ProductSku> skus = allFiltered.subList(fromIndex, toIndex);

        request.setAttribute("skus", skus);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", PAGE_SIZE);
        long activeSkus = allFiltered.stream().filter(s -> "ACTIVE".equalsIgnoreCase(s.getStatus())).count();
        request.setAttribute("activeSkus", activeSkus);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);

        // --- Filter dropdowns ---
        List<ProductSku> allSkus = dao.getAllSkus();

        // Use TreeSet for automatic sorting and case-insensitive uniqueness
        Set<String> colors = new java.util.TreeSet<>(String.CASE_INSENSITIVE_ORDER);
        Set<Integer> storages = new java.util.TreeSet<>();
        Set<Integer> rams = new java.util.TreeSet<>();

        for (ProductSku s : allSkus) {
            if (s.getColor() != null && !s.getColor().trim().isEmpty()) {
                colors.add(s.getColor().trim());
            }
            storages.add(s.getStorageGb());
            rams.add(s.getRamGb());
        }

        request.setAttribute("colors", colors);
        request.setAttribute("storages", storages);
        request.setAttribute("rams", rams);

        // Pass back filters for pagination links
        request.setAttribute("color", color);
        request.setAttribute("storage", storage);
        request.setAttribute("ram", ram);
        request.setAttribute("sku", sku);
        request.setAttribute("q", q);
        request.setAttribute("status", status);
        request.setAttribute("productId", productId);
    }
}
