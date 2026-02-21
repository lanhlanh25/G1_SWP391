/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */

public class ExportReceiptListItem {
    private long exportId;
    private String exportCode;
    private String requestCode;
    private String createdByName;
    private String exportDateUi;
    private int totalQty;
    private String status;
    private int totalQuantity;

    public int getTotalQuantity() {
        return totalQuantity;
    }

    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }
    public long getExportId() { return exportId; }
    public void setExportId(long exportId) { this.exportId = exportId; }

    public String getExportCode() { return exportCode; }
    public void setExportCode(String exportCode) { this.exportCode = exportCode; }

    public String getRequestCode() { return requestCode; }
    public void setRequestCode(String requestCode) { this.requestCode = requestCode; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getExportDateUi() { return exportDateUi; }
    public void setExportDateUi(String exportDateUi) { this.exportDateUi = exportDateUi; }

    public int getTotalQty() { return totalQty; }
    public void setTotalQty(int totalQty) { this.totalQty = totalQty; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
