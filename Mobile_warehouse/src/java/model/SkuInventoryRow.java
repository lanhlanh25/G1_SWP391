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
    private long   skuId;
    private String skuCode;
    private String color;
    private int    ramGb;
    private int    storageGb;
    private int    qty;
    private int    rop;           // Reorder Point (product-level)
    private String stockStatus;   // OK / LOW / OUT
    private String lastUpdated;

    public long   getSkuId()        { return skuId; }
    public void   setSkuId(long v)  { this.skuId = v; }

    public String getSkuCode()           { return skuCode; }
    public void   setSkuCode(String v)   { this.skuCode = v; }

    public String getColor()             { return color; }
    public void   setColor(String v)     { this.color = v; }

    public int    getRamGb()             { return ramGb; }
    public void   setRamGb(int v)        { this.ramGb = v; }

    public int    getStorageGb()         { return storageGb; }
    public void   setStorageGb(int v)    { this.storageGb = v; }

    public int    getQty()               { return qty; }
    public void   setQty(int v)          { this.qty = v; }

    public int    getRop()               { return rop; }
    public void   setRop(int v)          { this.rop = v; }

    public String getStockStatus()            { return stockStatus; }
    public void   setStockStatus(String v)    { this.stockStatus = v; }

    public String getLastUpdated()            { return lastUpdated; }
    public void   setLastUpdated(String v)    { this.lastUpdated = v; }
}
