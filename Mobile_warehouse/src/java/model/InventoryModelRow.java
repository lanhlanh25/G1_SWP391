/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class InventoryModelRow {
    private String productCode;
    private String productName;
    private String brandName;
    private int totalQty;
    private String status;       
    private String lastUpdated;  

    public InventoryModelRow() {}

    public InventoryModelRow(String productCode, String productName, String brandName,
                             int totalQty, String status, String lastUpdated) {
        this.productCode = productCode;
        this.productName = productName;
        this.brandName = brandName;
        this.totalQty = totalQty;
        this.status = status;
        this.lastUpdated = lastUpdated;
    }

    public String getProductCode() { return productCode; }
    public String getProductName() { return productName; }
    public String getBrandName() { return brandName; }
    public int getTotalQty() { return totalQty; }
    public String getStatus() { return status; }
    public String getLastUpdated() { return lastUpdated; }

    public void setProductCode(String productCode) { this.productCode = productCode; }
    public void setProductName(String productName) { this.productName = productName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }
    public void setTotalQty(int totalQty) { this.totalQty = totalQty; }
    public void setStatus(String status) { this.status = status; }
    public void setLastUpdated(String lastUpdated) { this.lastUpdated = lastUpdated; }
}