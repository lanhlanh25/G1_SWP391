<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<div class="page-wrap-md">

    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Product Particulars</h1>
        </div>
        <div class="d-flex gap-8 align-center">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/home?p=variant-matrix&productId=${product.productId}">Manage Variants</a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=product-list">← List</a>
        </div>
    </div>

    <c:if test="${product == null}">
        <div class="card">
            <div class="card-body"><p class="msg-err">Product not found.</p></div>
        </div>
    </c:if>

    <c:if test="${product != null}">

        <div class="card mb-16">
            <div class="card-body">
                <table class="table no-border-first">
                    <tbody>
                        <tr>
                            <th style="width:180px;">Product Code</th>
                            <td class="fw-600">${product.productCode}</td>
                        </tr>
                        <tr>
                            <th>Product Name</th>
                            <td class="fw-700">${product.productName}</td>
                        </tr>
                        <tr>
                            <th>Brand</th>
                            <td class="text-primary">${product.brandName}</td>
                        </tr>
                        <tr>
                            <th>Model</th>
                            <td class="text-muted fs-14">${product.model}</td>
                        </tr>
                        <tr>
                            <th>Status</th>
                            <td>
                                <c:choose>
                                    <c:when test="${product.status == 'ACTIVE'}">
                                        <span class="badge badge-active">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-inactive">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Description</th>
                            <td class="text-muted fs-14">${product.description}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <div class="h2 mb-12">SKU Inventory</div>
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width:140px;">SKU Code</th>
                            <th>Color</th>
                            <th style="width:100px;">RAM</th>
                            <th style="width:100px;">Storage</th>
                            <th>Supplier</th>
                            <th style="width:100px;" class="text-center">Stock</th>
                            <th style="width:140px;" class="text-center">Status</th>
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
                                            <td class="fw-700 mono-text text-primary">${s.skuCode}</td>
                                            <td>${s.color}</td>
                                            <td class="text-muted">${s.ramGb} GB</td>
                                            <td class="text-muted">${s.storageGb} GB</td>
                                            <td class="fs-12">${s.supplierName}</td>
                                            <td class="text-center fw-700">${s.stock}</td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${s.stockStatus == 'Out Of Stock'}">
                                                        <span class="badge badge-inactive">Out of Stock</span>
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
    </c:if>
</div>