/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class ImportReceiptLine {
    private long lineId;
    private long importId;
    private long productId;
    private long skuId;
    private int qty;
    private double unitPrice;

    public long getLineId() { return lineId; }
    public void setLineId(long lineId) { this.lineId = lineId; }

    public long getImportId() { return importId; }
    public void setImportId(long importId) { this.importId = importId; }

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }

    public long getSkuId() { return skuId; }
    public void setSkuId(long skuId) { this.skuId = skuId; }

    public int getQty() { return qty; }
    public void setQty(int qty) { this.qty = qty; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
}