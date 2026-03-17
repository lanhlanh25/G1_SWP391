package model;

import java.sql.Timestamp;

public class StockMovementHistoryItem {

    private Timestamp movementTime;
    private long referenceId;
    private String productCode;
    private String productName;
    private String movementType;   // IMPORT / EXPORT
    private int qtyChange;         // +qty / -qty
    private String referenceCode;
    private String performedBy;
    private String headerNote;
    private String lineNote;

    public StockMovementHistoryItem() {
    }

    public Timestamp getMovementTime() {
        return movementTime;
    }

    public void setMovementTime(Timestamp movementTime) {
        this.movementTime = movementTime;
    }

    public long getReferenceId() {
        return referenceId;
    }

    public void setReferenceId(long referenceId) {
        this.referenceId = referenceId;
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

    public String getMovementType() {
        return movementType;
    }

    public void setMovementType(String movementType) {
        this.movementType = movementType;
    }

    public int getQtyChange() {
        return qtyChange;
    }

    public void setQtyChange(int qtyChange) {
        this.qtyChange = qtyChange;
    }

    public String getReferenceCode() {
        return referenceCode;
    }

    public void setReferenceCode(String referenceCode) {
        this.referenceCode = referenceCode;
    }

    public String getPerformedBy() {
        return performedBy;
    }

    public void setPerformedBy(String performedBy) {
        this.performedBy = performedBy;
    }

    public String getHeaderNote() {
        return headerNote;
    }

    public void setHeaderNote(String headerNote) {
        this.headerNote = headerNote;
    }

    public String getLineNote() {
        return lineNote;
    }

    public void setLineNote(String lineNote) {
        this.lineNote = lineNote;
    }
}
