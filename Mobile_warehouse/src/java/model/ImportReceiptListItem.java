/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
import java.sql.Timestamp;

public class ImportReceiptListItem {
    private long importId;
    private String importCode;
    private String supplierName;
    private String createdByName;
    private Timestamp receiptDate;
    private String status;          
    private int totalQuantity;
    
    public ImportReceiptListItem() {}
    
    public long getImportId() {
        return importId;
    }
    
    public void setImportId(long importId) {
        this.importId = importId;
    }
    
    public String getImportCode() {
        return importCode;
    }
    
    public void setImportCode(String importCode) {
        this.importCode = importCode;
    }
    
    public String getSupplierName() {
        return supplierName;
    }
    
    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }
    
    public String getCreatedByName() {
        return createdByName;
    }
    
    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }
    
    public Timestamp getReceiptDate() {
        return receiptDate;
    }
    
    public void setReceiptDate(Timestamp receiptDate) {
        this.receiptDate = receiptDate;
    }
    
    public String getStatus() { 
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public int getTotalQuantity() {
        return totalQuantity;
    }
    
    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }
    
    public String getStatusUi() {
        if (status == null) return "";
        switch (status.toUpperCase()) {
            case "DRAFT":
            case "PENDING": 
                return "Pending";
            case "CONFIRMED": 
                return "Completed";
            case "CANCELED":
            case "CANCELLED": 
                return "Cancelled";
            default: 
                return status;
        }
    }
    
    public boolean isPending() {
        return status != null && 
               ("PENDING".equalsIgnoreCase(status) || "DRAFT".equalsIgnoreCase(status));
    }
}
