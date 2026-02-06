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

public class ImportReceipt {
    private long importId;
    private String importCode;
    private long supplierId;
    private String status;
    private Timestamp receiptDate;
    private String note;
    private int createdBy;

    public long getImportId() { return importId; }
    public void setImportId(long importId) { this.importId = importId; }

    public String getImportCode() { return importCode; }
    public void setImportCode(String importCode) { this.importCode = importCode; }

    public long getSupplierId() { return supplierId; }
    public void setSupplierId(long supplierId) { this.supplierId = supplierId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getReceiptDate() { return receiptDate; }
    public void setReceiptDate(Timestamp receiptDate) { this.receiptDate = receiptDate; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
}