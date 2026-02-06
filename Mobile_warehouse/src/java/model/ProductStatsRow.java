/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

/**
 *
 * @author ADMIN
 */
public class ProductStatsRow {

    private long productId;
    private String productCode;
    private String productName;
    private int totalStockUnits;
    private String stockStatus;
    private int importedUnits;
    private int exportedUnits;
    // ProductStatsRow.java
    private Timestamp lastImportAt;
    private Timestamp lastExportAt;

    public Timestamp getLastImportAt() {
        return lastImportAt;
    }

    public void setLastImportAt(Timestamp lastImportAt) {
        this.lastImportAt = lastImportAt;
    }

    public Timestamp getLastExportAt() {
        return lastExportAt;
    }

    public void setLastExportAt(Timestamp lastExportAt) {
        this.lastExportAt = lastExportAt;
    }

    public int getImportedUnits() {
        return importedUnits;
    }

    public void setImportedUnits(int importedUnits) {
        this.importedUnits = importedUnits;
    }

    public int getExportedUnits() {
        return exportedUnits;
    }

    public void setExportedUnits(int exportedUnits) {
        this.exportedUnits = exportedUnits;
    }

    public long getProductId() {
        return productId;
    }

    public void setProductId(long productId) {
        this.productId = productId;
    }

    public String getProductCode() {
        return productCode;
    }

    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getTotalStockUnits() {
        return totalStockUnits;
    }

    public void setTotalStockUnits(int totalStockUnits) {
        this.totalStockUnits = totalStockUnits;
    }

    public String getStockStatus() {
        return stockStatus;
    }

    public void setStockStatus(String stockStatus) {
        this.stockStatus = stockStatus;
    }

}
