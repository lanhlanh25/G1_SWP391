<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap-md">

    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Update Product</h1>
            <span class="badge-status info fs-11">${product.productCode}</span>
        </div>
        <div class="actions">
            <a href="${pageContext.request.contextPath}/home?p=product-list" class="btn btn-outline">← Back to List</a>
        </div>
    </div>

    <c:if test="${not empty errors}">
        <div class="msg-err mb-16">Please fix the errors below before saving.</div>
    </c:if>

    <div class="card mb-20">
        <div class="card-header">
            <div class="h2">${product.productName}</div>
            <div class="fs-13 text-muted">Core product identification and description.</div>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/manager/product/update" method="post" novalidate>
                <input type="hidden" name="id" value="${product.productId}">

                <div class="form-group mb-16">
                    <label class="form-label">Product Name <span class="text-danger">*</span></label>
                    <input type="text" name="productName" class="input ${not empty errors['productName'] ? 'border-danger' : ''}"
                           value="${not empty param.productName ? param.productName : product.productName}"
                           placeholder="Enter product name">
                    <c:if test="${not empty errors['productName']}">
                        <div class="fs-12 text-danger mt-4">⚠ ${errors['productName']}</div>
                    </c:if>
                </div>

                <div class="grid-2 gap-16 mb-16">
                    <div class="form-group">
                        <label class="form-label">Brand</label>
                        <input type="text" class="input" value="${product.brandName}" readonly style="background-color: var(--bg-2); opacity: 0.8;">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <div class="d-flex gap-16 mt-8">
                            <label class="d-flex align-center gap-8 pointer">
                                <input type="radio" name="status" value="ACTIVE" <c:if test="${product.status == 'ACTIVE'}">checked</c:if>>
                                <span class="badge badge-active">Active</span>
                            </label>
                            <label class="d-flex align-center gap-8 pointer">
                                <input type="radio" name="status" value="INACTIVE" <c:if test="${product.status == 'INACTIVE'}">checked</c:if>>
                                <span class="badge badge-inactive">Inactive</span>
                            </label>
                        </div>
                    </div>
                </div>

                <div class="form-group mb-20">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="textarea" placeholder="Enter product description">${not empty param.description ? param.description : product.description}</textarea>
                </div>

                <div class="divider mb-20"></div>

                <div class="d-flex justify-between align-center mb-16">
                    <div class="h2 m-0">SKU Master Items</div>
                    <a href="${pageContext.request.contextPath}/home?p=sku-add&productId=${product.productId}" class="btn btn-sm btn-primary">＋ Add New SKU</a>
                </div>

                <div class="table-wrap mb-24">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>SKU Code</th>
                                <th>Specs</th>
                                <th class="text-center">Status</th>
                                <th class="text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty skuList}">
                                    <tr>
                                        <td colspan="4" class="text-center py-20 text-muted italic">No SKU variants found for this product.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${skuList}" var="sku">
                                        <tr>
                                            <td class="fw-700 mono-text text-primary">${sku.skuCode}</td>
                                            <td class="fs-13 text-muted">
                                                ${sku.color} <span class="text-border mx-4">|</span> 
                                                ${sku.storageGb} GB <span class="text-border mx-4">|</span> 
                                                ${sku.ramGb} GB RAM
                                            </td>
                                            <td class="text-center">
                                                <span class="badge ${sku.status == 'ACTIVE' ? 'badge-active' : 'badge-inactive'}">
                                                    ${sku.status}
                                                </span>
                                            </td>
                                            <td class="text-right">
                                                <a href="${pageContext.request.contextPath}/manager/sku/update?id=${sku.skuId}" class="text-muted fs-12">Edit SKU</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="up-actions d-flex gap-12 pt-16 border-t">
                    <button type="submit" class="btn btn-primary px-32">Save All Changes</button>
                    <a href="${pageContext.request.contextPath}/home?p=product-list" class="btn btn-outline px-24">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

