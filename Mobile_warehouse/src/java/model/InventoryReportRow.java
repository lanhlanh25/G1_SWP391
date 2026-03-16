package model;

public class InventoryReportRow {

    private String productCode;
    private String productName;
    private String brandName;
    private String unit;

    private int openingQty;
    private int importQty;
    private int exportQty;
    private int closingQty;       // = currentStock from inventory_balance

    // ROP fields
    private double avgDailySales;
    private int leadTimeDays;
    private int safetyStock;
    private int rop;              // = CEIL(avgDailySales * leadTimeDays + safetyStock)
    private String ropStatus;     // OK / At ROP Level / Reorder Needed / Out Of Stock
    private int suggestedReorderQty;

    public InventoryReportRow() {
    }

    // Getters & Setters

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

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public int getOpeningQty() {
        return openingQty;
    }

    public void setOpeningQty(int openingQty) {
        this.openingQty = openingQty;
    }

    public int getImportQty() {
        return importQty;
    }

    public void setImportQty(int importQty) {
        this.importQty = importQty;
    }

    public int getExportQty() {
        return exportQty;
    }

    public void setExportQty(int exportQty) {
        this.exportQty = exportQty;
    }

    public int getClosingQty() {
        return closingQty;
    }

    public void setClosingQty(int closingQty) {
        this.closingQty = closingQty;
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
}
