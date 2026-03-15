package model;

public class InventoryReportRow {

    private String productCode;
    private String productName;
    private String brandName;
    private String unit;

    private int openingQty;
    private int importQty;
    private int exportQty;
    private int closingQty;
    private int variance;

    public InventoryReportRow() {
    }

    public InventoryReportRow(String productCode, String productName, String brandName,
            int openingQty, int importQty, int exportQty,
            int closingQty) {
        this.productCode = productCode;
        this.productName = productName;
        this.brandName = brandName;
        this.unit = "Phone";
        this.openingQty = openingQty;
        this.importQty = importQty;
        this.exportQty = exportQty;
        this.closingQty = closingQty;
        this.variance = closingQty - (openingQty + importQty - exportQty);
    }

    public String getProductCode() {
        return productCode;
    }

    public String getProductName() {
        return productName;
    }

    public String getBrandName() {
        return brandName;
    }

    public String getUnit() {
        return unit;
    }

    public int getOpeningQty() {
        return openingQty;
    }

    public int getImportQty() {
        return importQty;
    }

    public int getExportQty() {
        return exportQty;
    }

    public int getClosingQty() {
        return closingQty;
    }

    public int getVariance() {
        return variance;
    }

    public void setProductCode(String v) {
        this.productCode = v;
    }

    public void setProductName(String v) {
        this.productName = v;
    }

    public void setBrandName(String v) {
        this.brandName = v;
    }

    public void setUnit(String v) {
        this.unit = v;
    }

    public void setOpeningQty(int v) {
        this.openingQty = v;
    }

    public void setImportQty(int v) {
        this.importQty = v;
    }

    public void setExportQty(int v) {
        this.exportQty = v;
    }

    public void setClosingQty(int v) {
        this.closingQty = v;
    }

    public void setVariance(int v) {
        this.variance = v;
    }
}
