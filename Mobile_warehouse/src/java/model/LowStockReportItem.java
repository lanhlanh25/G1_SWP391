package model;

public class LowStockReportItem {

    private long productId;
    private String productCode;
    private String productName;
    private long supplierId;
    private String supplierName;
    private String brandName;
    

    private int currentStock;
    private double avgDailySales;
    private int leadTimeDays;
    private int safetyStock;
    private int rop;

    private String ropStatus;
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

    public double getAvgDailySales() {
        return avgDailySales;
    }

    public void setAvgDailySales(double avgDailySales) {
        this.avgDailySales = avgDailySales;
    }

    public int getLeadTimeDays() {
        return leadTimeDays;
    }

    public void setLeadTimeDays(int leadTimeDays) {
        this.leadTimeDays = leadTimeDays;
    }

    public int getSafetyStock() {
        return safetyStock;
    }

    public void setSafetyStock(int safetyStock) {
        this.safetyStock = safetyStock;
    }

    public int getRop() {
        return rop;
    }

    public void setRop(int rop) {
        this.rop = rop;
    }

    public String getRopStatus() {
        return ropStatus;
    }

    public void setRopStatus(String ropStatus) {
        this.ropStatus = ropStatus;
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
