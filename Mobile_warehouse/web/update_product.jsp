<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
<%-- Internal styles moved to app.css --%>

<div class="up-wrapper">

    <div class="up-header">
        <h1>Update Product</h1>
        <div class="product-title">
            <span class="product-name">${product.productName}</span>
            <span class="badge-code">${product.productCode}</span>
            <span class="badge-status ${product.status == 'ACTIVE' ? 'active' : 'inactive'}">
                ${product.status}
            </span>
        </div>
        <p class="subtitle">Update product information &amp; SKU</p>
    </div>

    <div class="up-body">
        <form action="${pageContext.request.contextPath}/manager/product/update" method="post" novalidate>
            <input type="hidden" name="id" value="${product.productId}">


            <div class="section-title">Product Information</div>


            <div class="field ${not empty errors['productName'] ? 'has-error' : ''}">
                <label>Product Name <span class="req">*</span></label>
                <input type="text" name="productName"
                       value="${not empty param.productName ? param.productName : product.productName}"
                       placeholder="Enter product name">
                <c:if test="${not empty errors['productName']}">
                    <div class="error-msg">⚠ ${errors['productName']}</div>
                </c:if>
            </div>


            <div class="field">
                <label>Brand</label>
                <div class="readonly-val">${product.brandName}</div>
            </div>


            <div class="field">
                <label>Description</label>
                <textarea name="description" placeholder="Enter product description">${not empty param.description ? param.description : product.description}</textarea>
            </div>

            <div class="field">
                <label>Status</label>
                <div class="radio-group">
                    <div class="radio-option">
                        <input type="radio" name="status" id="statusActive" value="ACTIVE"
                               <c:if test="${product.status == 'ACTIVE'}">checked</c:if>>
                               <label for="statusActive">
                                   <span class="dot"></span> Active
                               </label>
                        </div>
                        <div class="radio-option inactive">
                            <input type="radio" name="status" id="statusInactive" value="INACTIVE"
                            <c:if test="${product.status == 'INACTIVE'}">checked</c:if>>
                            <label for="statusInactive">
                                <span class="dot"></span> Inactive
                            </label>
                        </div>
                    </div>
                </div>

                <div class="divider"></div>


                <div class="sku-header">
                    <div class="section-title" style="margin:0;flex:1;">SKU Current</div>
                    <a href="${pageContext.request.contextPath}/home?p=sku-add&productId=${product.productId}"
                   class="sku-add-link">
                    ＋ Add SKU
                </a>
            </div>

            <div class="sku-list">
                <c:choose>
                    <c:when test="${empty skuList}">
                        <div class="sku-empty">No SKU variants found for this product.</div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${skuList}" var="sku">
                            <div class="sku-item">
                                <span class="sku-code">${sku.skuCode}</span>
                                <span class="sku-sep">|</span>
                                <span class="sku-attr">${sku.color}</span>
                                <span class="sku-sep">|</span>
                                <span class="sku-attr">${sku.storageGb} GB</span>
                                <span class="sku-sep">|</span>
                                <span class="sku-attr">${sku.ramGb} GB RAM</span>
                                <span class="sku-status ${sku.status == 'ACTIVE' ? 'active' : 'inactive'}">
                                    ${sku.status}
                                </span>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>


            <div class="up-actions">
                <button type="submit" class="btn-save">Save Changes</button>
                <a href="${pageContext.request.contextPath}/home?p=product-list" class="btn-cancel">Cancel</a>
            </div>

        </form>
    </div>

</div>
