/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author ADMIN
 */
public class BrandStatsSummary {
    private int totalBrands;
    private int totalProducts;
    private int totalStockUnits;
    private int lowStockProducts;
    private int importedUnitsInRange;
private int exportedUnitsInRange;

    public int getImportedUnitsInRange() {
        return importedUnitsInRange;
    }

    public void setImportedUnitsInRange(int importedUnitsInRange) {
        this.importedUnitsInRange = importedUnitsInRange;
    }

    public int getExportedUnitsInRange() {
        return exportedUnitsInRange;
    }

    public void setExportedUnitsInRange(int exportedUnitsInRange) {
        this.exportedUnitsInRange = exportedUnitsInRange;
    }

    public int getTotalBrands() {
        return totalBrands;
    }

    public void setTotalBrands(int totalBrands) {
        this.totalBrands = totalBrands;
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
