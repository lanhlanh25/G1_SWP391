/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class InventoryCountRow {
    private long skuId;
    private String skuCode;
    private String productName;
    private String color;
    private int ramGb;
    private int storageGb;
    private int systemQty;
    private int countedQty;

    public long getSkuId() { return skuId; }
    public void setSkuId(long skuId) { this.skuId = skuId; }

    public String getSkuCode() { return skuCode; }
    public void setSkuCode(String skuCode) { this.skuCode = skuCode; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public int getRamGb() { return ramGb; }
    public void setRamGb(int ramGb) { this.ramGb = ramGb; }

    public int getStorageGb() { return storageGb; }
    public void setStorageGb(int storageGb) { this.storageGb = storageGb; }

    public int getSystemQty() { return systemQty; }
    public void setSystemQty(int systemQty) { this.systemQty = systemQty; }

    public int getCountedQty() { return countedQty; }
    public void setCountedQty(int countedQty) { this.countedQty = countedQty; }
}