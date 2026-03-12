package model;

public class ImportRequestItem {
    private int no;
    private long productId;
    private String productCode;
    private String productName;
    private long skuId;
    private String skuCode;
    private int requestQty;

    public int getNo() { return no; }
    public void setNo(int no) { this.no = no; }

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }

    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public long getSkuId() { return skuId; }
    public void setSkuId(long skuId) { this.skuId = skuId; }

    public String getSkuCode() { return skuCode; }
    public void setSkuCode(String skuCode) { this.skuCode = skuCode; }

    public int getRequestQty() { return requestQty; }
    public void setRequestQty(int requestQty) { this.requestQty = requestQty; }
}
