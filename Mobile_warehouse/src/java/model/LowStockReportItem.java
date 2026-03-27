package model;

public class LowStockReportItem {

    private long productId;
    private String productCode;
    private String productName;
    private long supplierId;
    private String supplierName;
    private String brandName;

    private int currentStock;
    private int threshold;
    private String stockStatus;
    private int suggestedReorderQty;
    private boolean hasActiveImportRequest;

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public long getProductId() {
        return productId;
    }

    public void setProductId(long productId) {
        this.productId = productId;
    }

    public String getProductCode() {
        return productCode;
    }

    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public long getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(long supplierId) {
        this.supplierId = supplierId;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public int getCurrentStock() {
        return currentStock;
    }

    public void setCurrentStock(int currentStock) {
        this.currentStock = currentStock;
    }

    public int getThreshold() {
        return threshold;
    }

    public void setThreshold(int threshold) {
        this.threshold = threshold;
    }

    public String getStockStatus() {
        return stockStatus;
    }

    public void setStockStatus(String stockStatus) {
        this.stockStatus = stockStatus;
    }

    public int getSuggestedReorderQty() {
        return suggestedReorderQty;
    }

    public void setSuggestedReorderQty(int suggestedReorderQty) {
        this.suggestedReorderQty = suggestedReorderQty;
    }

    public boolean isHasActiveImportRequest() {
        return hasActiveImportRequest;
    }

    public void setHasActiveImportRequest(boolean hasActiveImportRequest) {
        this.hasActiveImportRequest = hasActiveImportRequest;
    }
}
