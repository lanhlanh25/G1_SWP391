/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */

public class SkuInventoryRow {
    private long skuId;
    private String skuCode;
    private String color;
    private int ramGb;
    private int storageGb;
    private int qty;
    private String stockStatus;   
    private String lastUpdated;   

    public long getSkuId() { return skuId; }
    public void setSkuId(long skuId) { this.skuId = skuId; }

    public String getSkuCode() { return skuCode; }
    public void setSkuCode(String skuCode) { this.skuCode = skuCode; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public int getRamGb() { return ramGb; }
    public void setRamGb(int ramGb) { this.ramGb = ramGb; }

    public int getStorageGb() { return storageGb; }
    public void setStorageGb(int storageGb) { this.storageGb = storageGb; }

    public int getQty() { return qty; }
    public void setQty(int qty) { this.qty = qty; }

    public String getStockStatus() { return stockStatus; }
    public void setStockStatus(String stockStatus) { this.stockStatus = stockStatus; }

    public String getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(String lastUpdated) { this.lastUpdated = lastUpdated; }
}