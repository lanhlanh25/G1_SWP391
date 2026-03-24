package model;

public class LowStockSummaryDTO {

    private int productsAtOrBelowThreshold;
    private int outOfStock;
    private int reorderNeeded;
    private int totalProducts;

    public int getProductsAtOrBelowThreshold() {
        return productsAtOrBelowThreshold;
    }

    public void setProductsAtOrBelowThreshold(int productsAtOrBelowThreshold) {
        this.productsAtOrBelowThreshold = productsAtOrBelowThreshold;
    }

    public int getOutOfStock() {
        return outOfStock;
    }

    public void setOutOfStock(int outOfStock) {
        this.outOfStock = outOfStock;
    }

    public int getReorderNeeded() {
        return reorderNeeded;
    }

    public void setReorderNeeded(int reorderNeeded) {
        this.reorderNeeded = reorderNeeded;
    }

    public int getTotalProducts() {
        return totalProducts;
    }

    public void setTotalProducts(int totalProducts) {
        this.totalProducts = totalProducts;
    }
}
