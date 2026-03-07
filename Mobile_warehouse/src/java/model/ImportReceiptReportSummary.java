/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */

public class ImportReceiptReportSummary {
    private int totalReceipts;
    private int totalPhoneQty;
    private int completedCount;
    private int cancelledCount;

    public int getTotalReceipts() { return totalReceipts; }
    public void setTotalReceipts(int totalReceipts) { this.totalReceipts = totalReceipts; }

    public int getTotalPhoneQty() { return totalPhoneQty; }
    public void setTotalPhoneQty(int totalPhoneQty) { this.totalPhoneQty = totalPhoneQty; }

    public int getCompletedCount() { return completedCount; }
    public void setCompletedCount(int completedCount) { this.completedCount = completedCount; }

    public int getCancelledCount() { return cancelledCount; }
    public void setCancelledCount(int cancelledCount) { this.cancelledCount = cancelledCount; }
}
