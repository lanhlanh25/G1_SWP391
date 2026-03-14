package model;

public class LowStockSummaryDTO {

    private int productsBelowRop;
    private int outOfStock;
    private int reorderNeeded;
    private int totalProducts;

    public int getProductsBelowRop() {
        return productsBelowRop;
    }

    public void setProductsBelowRop(int productsBelowRop) {
        this.productsBelowRop = productsBelowRop;
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
