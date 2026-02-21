package model;

public class ImportReceiptLineDetail {
    private long lineId;
    private String productName; 
    private String color;      
    private int storageGb;      
    private int ramGb;         
    private int qty;
    private String imeiText;    
    private String itemNote;
    private String createdByName;

    public long getLineId() { return lineId; }
    public void setLineId(long lineId) { this.lineId = lineId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public int getStorageGb() { return storageGb; }
    public void setStorageGb(int storageGb) { this.storageGb = storageGb; }

    public int getRamGb() { return ramGb; }
    public void setRamGb(int ramGb) { this.ramGb = ramGb; }

    public int getQty() { return qty; }
    public void setQty(int qty) { this.qty = qty; }

    public String getImeiText() { return imeiText; }
    public void setImeiText(String imeiText) { this.imeiText = imeiText; }

    public String getItemNote() { return itemNote; }
    public void setItemNote(String itemNote) { this.itemNote = itemNote; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
}