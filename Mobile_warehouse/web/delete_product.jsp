<%-- Document : delete_product Created on : Feb 5, 2026, 3:13:32 PM Author : Lanhlanh --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <title>Delete Product</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
    <%-- Internal styles moved to app.css --%>
</head>

<body>
    <div class="dp-wrap">
        <div class="dp-head">
            <h1>Delete Product</h1>
            <div class="dp-sub">(soft delete).</div>
        </div>

                    <c:if test="${empty product}">
                        <div class="alert alert-danger mb-14">Product not found.</div>
                        <div class="dp-btns">
                            <button class="btn btn-outline" type="button"
                                onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-list'">
                                Back
                            </button>
                        </div>
                    </c:if>

                    <c:if test="${not empty product}">

                        <c:if test="${not empty blockReason}">
                            <div class="alert alert-warning mb-14">
                                Cannot delete this product because: ${blockReason}
                            </div>
                        </c:if>
                        <div class="dp-card">
                            <div class="dp-grid">
                                <div class="dp-lb">Product Code</div>
                                <div class="dp-val">${product.productCode}</div>

                                <div class="dp-lb">Brand</div>
                                <div class="dp-val">${product.brandName}</div>

                                <div class="dp-lb">Model</div>
                                <div class="dp-val">${product.model}</div>

                                <div class="dp-lb">Status</div>
                                <div class="dp-val">${product.status}</div>

                                <div class="dp-lb">SKU Count</div>
                                <div class="dp-val">${skuCount}</div>
                            </div>

                            <div class="d-flex align-center gap-12 mt-12">
                                <div class="dp-lb" style="min-width:220px;">Created At</div>
                                <div class="dp-val flex-1">${createdAt}</div>
                            </div>

                        </div>

                        <c:if test="${not empty errors}">
                            <div class="alert alert-danger mb-14">${errors}</div>
                        </c:if>

                        <c:if test="${not empty message}">
                            <div class="alert alert-success mt-14 text-center">${message}</div>
                        </c:if>

                        <div class="dp-btns">
                            <c:choose>
                                <c:when test="${empty blockReason}">
                                    <form action="${pageContext.request.contextPath}/manager/product/delete"
                                        method="post" style="margin:0;">
                                        <input type="hidden" name="id" value="${product.productId}">
                                        <button class="btn btn-danger" type="submit"
                                            onclick="return confirm('Set this product to INACTIVE?');">
                                            Inactivate
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <button class="btn btn-danger" type="button" disabled>Inactivate</button>
                                </c:otherwise>
                            </c:choose>

                            <button class="btn btn-outline" type="button"
                                onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-list'">
                                Cancel
                            </button>
                        </div>
                    </c:if>
                </div>
            </body>

            </html>