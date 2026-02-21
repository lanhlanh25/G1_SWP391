/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */

import java.util.List;

public class ExportReceiptDetailLine {
    private long lineId;
    private String productCode;
    private String skuCode;
    private int qty;
    private List<String> imeis;

    // optional (nếu bạn add cột export_receipt_lines.item_note sau)
    private String itemNote;

    private String createdByName;

    public long getLineId() { return lineId; }
    public void setLineId(long lineId) { this.lineId = lineId; }

    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }

    public String getSkuCode() { return skuCode; }
    public void setSkuCode(String skuCode) { this.skuCode = skuCode; }

    public int getQty() { return qty; }
    public void setQty(int qty) { this.qty = qty; }

    public List<String> getImeis() { return imeis; }
    public void setImeis(List<String> imeis) { this.imeis = imeis; }

    public String getItemNote() { return itemNote; }
    public void setItemNote(String itemNote) { this.itemNote = itemNote; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
}
