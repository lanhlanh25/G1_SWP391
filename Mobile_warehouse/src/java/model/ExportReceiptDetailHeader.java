/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */


public class ExportReceiptDetailHeader {
    private long exportId;
    private String exportCode;
    private String exportDateUi;
    private String requestCode;
    private String note;
    private String status;
    private String createdByName;

    public long getExportId() { return exportId; }
    public void setExportId(long exportId) { this.exportId = exportId; }

    public String getExportCode() { return exportCode; }
    public void setExportCode(String exportCode) { this.exportCode = exportCode; }

    public String getExportDateUi() { return exportDateUi; }
    public void setExportDateUi(String exportDateUi) { this.exportDateUi = exportDateUi; }

    public String getRequestCode() { return requestCode; }
    public void setRequestCode(String requestCode) { this.requestCode = requestCode; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
}
