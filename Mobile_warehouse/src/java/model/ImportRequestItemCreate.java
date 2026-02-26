package model;

public class ImportRequestItemCreate {

    private long productId;
    private long skuId;
    private int requestQty;

    public ImportRequestItemCreate(long productId, long skuId, int requestQty) {
        this.productId = productId;
        this.skuId = skuId;
        this.requestQty = requestQty;
    }

    public long getProductId() {
        return productId;
    }

    public long getSkuId() {
        return skuId;
    }

    public int getRequestQty() {
        return requestQty;
    }
}
