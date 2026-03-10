package controller;

import dal.ProductSkuDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import model.ProductSku;

public class ViewVariantMatrix {

    public static void handle(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String color = request.getParameter("color");
        String storage = request.getParameter("storage");
        String ram = request.getParameter("ram");
        String sku = request.getParameter("sku");
        String status = request.getParameter("status");
        String productIdRaw = request.getParameter("productId");
        Integer productId = null;

        if (productIdRaw != null && !productIdRaw.isEmpty()) {
            productId = Integer.parseInt(productIdRaw);
        }
        ProductSkuDAO dao = new ProductSkuDAO();

        List<ProductSku> skus = dao.filterVariants(productId, color, storage, ram, status, sku);
        request.setAttribute("skus", skus);

        List<ProductSku> allSkus = dao.getAllSkus();

        Set<String> colors = new LinkedHashSet<>();
        Set<Integer> storages = new LinkedHashSet<>();
        Set<Integer> rams = new LinkedHashSet<>();

        for (ProductSku s : allSkus) {
            colors.add(s.getColor());
            storages.add(s.getStorageGb());
            rams.add(s.getRamGb());
        }

        request.setAttribute("colors", colors);
        request.setAttribute("storages", storages);
        request.setAttribute("rams", rams);
    }
}
