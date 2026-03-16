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

public class ImportReceiptLineDetail {

    private long   lineId;
    private String productCode;
    private String productName;
    private String skuCode;
    private int    qty;
    private List<String> imeis;   // danh sách IMEI để JSP dùng c:forEach
    private String imeiText;      // chuỗi phân cách \n, giữ backward compat
    private String itemNote;
    private String createdByName;
    private int    inStock;

    public long   getLineId()                      { return lineId; }
    public void   setLineId(long lineId)           { this.lineId = lineId; }

    public String getProductCode()                 { return productCode; }
    public void   setProductCode(String v)         { this.productCode = v; }

    public String getProductName()                 { return productName; }
    public void   setProductName(String v)         { this.productName = v; }

    public String getSkuCode()                     { return skuCode; }
    public void   setSkuCode(String v)             { this.skuCode = v; }

    public int    getQty()                         { return qty; }
    public void   setQty(int qty)                  { this.qty = qty; }

    public List<String> getImeis()                 { return imeis; }
    public void         setImeis(List<String> v)   { this.imeis = v; }

    public String getImeiText()                    { return imeiText; }
    public void   setImeiText(String v)            { this.imeiText = v; }

    public String getItemNote()                    { return itemNote; }
    public void   setItemNote(String v)            { this.itemNote = v; }

    public String getCreatedByName()               { return createdByName; }
    public void   setCreatedByName(String v)       { this.createdByName = v; }

    public int    getInStock()                     { return inStock; }
    public void   setInStock(int inStock)          { this.inStock = inStock; }
}
