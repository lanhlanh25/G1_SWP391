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

public class ImportReceiptDeleteRequest {
    private long requestId;
    private long importId;
    private String importCode;
    private String note;
    private int requestedBy;
    private String requestedByName;
    private Timestamp requestedAt;
    private Timestamp transactionTime; // From import_receipts.receipt_date
    private String status; // PENDING, APPROVED, REJECTED
    private Integer decidedBy;
    private Timestamp decidedAt;
    
    public ImportReceiptDeleteRequest() {}
    
    public long getRequestId() {
        return requestId;
    }
    
    public void setRequestId(long requestId) {
        this.requestId = requestId;
    }
    
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
    
    public String getNote() {
        return note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }
    
    public int getRequestedBy() {
        return requestedBy;
    }
    
    public void setRequestedBy(int requestedBy) {
        this.requestedBy = requestedBy;
    }
    
    public String getRequestedByName() {
        return requestedByName;
    }
    
    public void setRequestedByName(String requestedByName) {
        this.requestedByName = requestedByName;
    }
    
    public Timestamp getRequestedAt() {
        return requestedAt;
    }
    
    public void setRequestedAt(Timestamp requestedAt) {
        this.requestedAt = requestedAt;
    }
    
    public Timestamp getTransactionTime() {
        return transactionTime;
    }
    
    public void setTransactionTime(Timestamp transactionTime) {
        this.transactionTime = transactionTime;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Integer getDecidedBy() {
        return decidedBy;
    }
    
    public void setDecidedBy(Integer decidedBy) {
        this.decidedBy = decidedBy;
    }
    
    public Timestamp getDecidedAt() {
        return decidedAt;
    }
    
    public void setDecidedAt(Timestamp decidedAt) {
        this.decidedAt = decidedAt;
    }
}
