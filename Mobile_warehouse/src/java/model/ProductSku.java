/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class ProductSku {
    private long skuId;
    private String skuCode;
    private long productId;

    public long getSkuId() { return skuId; }
    public void setSkuId(long skuId) { this.skuId = skuId; }

    public String getSkuCode() { return skuCode; }
    public void setSkuCode(String skuCode) { this.skuCode = skuCode; }

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }
}