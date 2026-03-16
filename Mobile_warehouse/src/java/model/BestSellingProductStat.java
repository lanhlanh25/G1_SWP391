package model;

import java.util.Date;

public class BestSellingProductStat {

    private long productId;
    private String productCode;
    private String productName;
    private String brandName;
    private int unitsSold;
    private Date lastSold;

    public long getProductId() {
        return productId;
    }

    public void setProductId(long productId) {
        this.productId = productId;
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

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public int getUnitsSold() {
        return unitsSold;
    }

    public void setUnitsSold(int unitsSold) {
        this.unitsSold = unitsSold;
    }

    public Date getLastSold() {
        return lastSold;
    }

    public void setLastSold(Date lastSold) {
        this.lastSold = lastSold;
    }
}
