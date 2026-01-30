/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author ADMIN
 */
public class BrandStatsRow {
    private long brandId;
    private String brandName;
    private int totalProducts;
    private int totalStockUnits;
    private int lowStockProducts;
    private int importedUnits;


     private boolean active;

    public boolean isActive() {
        return active;
    }

    public int getImportedUnits() {
        return importedUnits;
    }

    public void setImportedUnits(int importedUnits) {
        this.importedUnits = importedUnits;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
    public long getBrandId() {
        return brandId;
    }

    public void setBrandId(long brandId) {
        this.brandId = brandId;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public int getTotalProducts() {
        return totalProducts;
    }

    public void setTotalProducts(int totalProducts) {
        this.totalProducts = totalProducts;
    }

    public int getTotalStockUnits() {
        return totalStockUnits;
    }

    public void setTotalStockUnits(int totalStockUnits) {
        this.totalStockUnits = totalStockUnits;
    }

    public int getLowStockProducts() {
        return lowStockProducts;
    }

    public void setLowStockProducts(int lowStockProducts) {
        this.lowStockProducts = lowStockProducts;
    }
    
}
