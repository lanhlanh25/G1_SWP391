package model;

public class ExportRequestItemCreate {

    private long productId;
    private Long skuId; // nullable
    private int requestQty;

    public ExportRequestItemCreate(long productId, Long skuId, int requestQty) {
        this.productId = productId;
        this.skuId = skuId;
        this.requestQty = requestQty;
    }

    public long getProductId() {
        return productId;
    }

    public Long getSkuId() {
        return skuId;
    }

    public int getRequestQty() {
        return requestQty;
    }
}
