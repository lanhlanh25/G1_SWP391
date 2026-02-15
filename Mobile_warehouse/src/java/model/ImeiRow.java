package model;

import java.sql.Timestamp;

public class ImeiRow {
    private String imei;
    private Timestamp importDate;   // From import_receipts.receipt_date
    private Timestamp exportDate;   // From export_receipts.export_date (null if not exported)
    
    public ImeiRow() {}
    
    public ImeiRow(String imei, Timestamp importDate, Timestamp exportDate) {
        this.imei = imei;
        this.importDate = importDate;
        this.exportDate = exportDate;
    }
    
    public String getImei() {
        return imei;
    }
    
    public void setImei(String imei) {
        this.imei = imei;
    }
    
    public Timestamp getImportDate() {
        return importDate;
    }
    
    public void setImportDate(Timestamp importDate) {
        this.importDate = importDate;
    }
    
    public Timestamp getExportDate() {
        return exportDate;
    }
    
    public void setExportDate(Timestamp exportDate) {
        this.exportDate = exportDate;
    }
}
