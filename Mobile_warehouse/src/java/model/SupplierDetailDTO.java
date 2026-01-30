package model;

import java.sql.Timestamp;

public class SupplierDetailDTO {

    private long supplierId;
    private String supplierName;
    private String phone;
    private String email;
    private String address;
    private int isActive;

    private Double avgRating;          // null nếu chưa có
    private int totalImportReceipts;   // count
    private Timestamp lastTransaction; // null nếu chưa có
    private long totalQtyImported;     // sum qty

    public long getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(long supplierId) {
        this.supplierId = supplierId;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getIsActive() {
        return isActive;
    }

    public void setIsActive(int isActive) {
        this.isActive = isActive;
    }

    public Double getAvgRating() {
        return avgRating;
    }

    public void setAvgRating(Double avgRating) {
        this.avgRating = avgRating;
    }

    public int getTotalImportReceipts() {
        return totalImportReceipts;
    }

    public void setTotalImportReceipts(int totalImportReceipts) {
        this.totalImportReceipts = totalImportReceipts;
    }

    public Timestamp getLastTransaction() {
        return lastTransaction;
    }

    public void setLastTransaction(Timestamp lastTransaction) {
        this.lastTransaction = lastTransaction;
    }

    public long getTotalQtyImported() {
        return totalQtyImported;
    }

    public void setTotalQtyImported(long totalQtyImported) {
        this.totalQtyImported = totalQtyImported;
    }
}
