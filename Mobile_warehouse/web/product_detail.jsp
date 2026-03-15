<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<div class="page-wrap">

    <div class="topbar">
        <div class="title">Product Detail</div>
        <div>
            <a class="btn" href="${pageContext.request.contextPath}/home?p=variant-matrix&productId=${product.productId}">View Variants</a>
            <a class="btn" href="${pageContext.request.contextPath}/home?p=product-list">← Back to List</a>
        </div>
    </div>

    <c:if test="${product == null}">
        <div class="card">
            <div class="card-body"><p class="msg-err">Product not found.</p></div>
        </div>
    </c:if>

    <c:if test="${product != null}">

        <div class="card" style="margin-bottom:16px;">
            <div class="card-header"><span class="h2">Product Info</span></div>
            <div class="card-body">
                <div class="info-grid">
                    <span class="label">Product Code</span>
                    <span>${product.productCode}</span>

                    <span class="label">Product Name</span>
                    <span>${product.productName}</span>

                    <span class="label">Brand</span>
                    <span>${product.brandName}</span>

                    <span class="label">Model</span>
                    <span>${product.model}</span>

                    <span class="label">Status</span>
                    <span>
                        <c:choose>
                            <c:when test="${product.status == 'ACTIVE'}">
                                <span class="badge badge-active">Active</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-inactive">Inactive</span>
                            </c:otherwise>
                        </c:choose>
                    </span>

                    <span class="label">Description</span>
                    <span>${product.description}</span>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span class="h2">SKU Inventory</span>
            </div>

            <div class="card-body" style="padding:0;">
                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>SKU Code</th>
                                <th>Color</th>
                                <th>RAM</th>
                                <th>Storage</th>
                                <th>Supplier</th>
                                <th>Stock</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty skuList}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">No active SKU found for this product.</div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="s" items="${skuList}">
                                        <tr>
                                            <td><b>${s.skuCode}</b></td>
                                            <td>${s.color}</td>
                                            <td>${s.ramGb} GB</td>
                                            <td>${s.storageGb} GB</td>
                                            <td>${s.supplierName}</td>
                                            <td>${s.stock}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${s.stockStatus == 'Out Of Stock'}">
                                                        <span class="badge badge-danger">Out Of Stock</span>
                                                    </c:when>
                                                    <c:when test="${s.stockStatus == 'Low Stock'}">
                                                        <span class="badge badge-warning">Low Stock</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-active">In Stock</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </c:if>
</div>