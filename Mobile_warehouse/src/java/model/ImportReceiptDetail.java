/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

public class ImportReceiptDetail {
    private long importId;
    private String importCode;
    private Timestamp receiptDate;
    private String supplierName;
    private String note;
    private String status;

    private String createdByName;

    public long getImportId() { return importId; }
    public void setImportId(long importId) { this.importId = importId; }

    public String getImportCode() { return importCode; }
    public void setImportCode(String importCode) { this.importCode = importCode; }

    public Timestamp getReceiptDate() { return receiptDate; }
    public void setReceiptDate(Timestamp receiptDate) { this.receiptDate = receiptDate; }

    public String getSupplierName() { return supplierName; }
    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
}