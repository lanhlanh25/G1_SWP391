/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Lanhlanh
 */


public class Product {
    private long productId;
    private String productCode;
    private String productName;
    private long brandId;
    private String model;
    private String description;
    private String status;

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }

    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public long getBrandId() { return brandId; }
    public void setBrandId(long brandId) { this.brandId = brandId; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
