/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class ImportReceiptLineDetail {
    private long lineId;
    private String productCode;
    private String skuCode;
    private int qty;
    private String imeiText;       // already formatted with new lines
    private String itemNote;
    private String createdByName;
    private int inStock;

    public int getInStock() {
        return inStock;
    }

    public void setInStock(int inStock) {
        this.inStock = inStock;
    }


    public long getLineId() { return lineId; }
    public void setLineId(long lineId) { this.lineId = lineId; }

    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }

    public String getSkuCode() { return skuCode; }
    public void setSkuCode(String skuCode) { this.skuCode = skuCode; }

    public int getQty() { return qty; }
    public void setQty(int qty) { this.qty = qty; }

    public String getImeiText() { return imeiText; }
    public void setImeiText(String imeiText) { this.imeiText = imeiText; }

    public String getItemNote() { return itemNote; }
    public void setItemNote(String itemNote) { this.itemNote = itemNote; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
}