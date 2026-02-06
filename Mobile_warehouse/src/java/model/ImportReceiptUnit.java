/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class ImportReceiptUnit {
    private long unitId;
    private long lineId;
    private String imei; 

    public long getUnitId() { return unitId; }
    public void setUnitId(long unitId) { this.unitId = unitId; }

    public long getLineId() { return lineId; }
    public void setLineId(long lineId) { this.lineId = lineId; }

    public String getImei() { return imei; }
    public void setImei(String imei) { this.imei = imei; }
}