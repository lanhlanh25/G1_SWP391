<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<div class="page-wrap-sm">

    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Update SKU</h1>
            <span class="badge info fs-11">${sku.skuCode}</span>
        </div>
        <div class="actions">
            <a href="${pageContext.request.contextPath}/manager/product/update?id=${product.productId}" class="btn btn-outline">← Back</a>
        </div>
    </div>

    <c:if test="${not empty errors}">
        <div class="msg-err mb-16">Please fix the errors below before saving.</div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <div class="h2">${product.productName}</div>
            <div class="fs-13 text-muted">Core SKU specifications and status control.</div>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/manager/sku/update" method="post" novalidate>
                <input type="hidden" name="skuId" value="${sku.skuId}">
                <input type="hidden" name="productId" value="${product.productId}">

                <div class="form-group mb-16">
                    <label class="form-label">SKU Code <span class="text-danger">*</span></label>
                    <input type="text" name="skuCode" id="skuCodeInput" class="input ${not empty errors['skuCode'] ? 'border-danger' : ''}" 
                           value="${not empty param.skuCode ? param.skuCode : sku.skuCode}" readonly style="background-color: var(--bg-2); opacity: 0.8;">
                    <div class="fs-12 text-muted mt-4">SKU Code is regenerated automatically based on spec changes.</div>
                    <c:if test="${not empty errors['skuCode']}">
                        <div class="fs-12 text-danger mt-4">⚠ ${errors['skuCode']}</div>
                    </c:if>
                    <c:if test="${not empty errors['variant']}">
                        <div class="fs-12 text-danger mt-4 fw-600">⚠ ${errors['variant']}</div>
                    </c:if>
                </div>

                <div class="grid-2 gap-16 mb-20">
                    <div class="form-group">
                        <label class="form-label">Color <span class="text-danger">*</span></label>
                        <input type="text" name="color" id="color" class="input ${not empty errors['color'] ? 'border-danger' : ''}" 
                               value="${not empty param.color ? param.color : sku.color}" onkeyup="generateSku()">
                        <c:if test="${not empty errors['color']}">
                            <div class="fs-12 text-danger mt-4">⚠ ${errors['color']}</div>
                        </c:if>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select name="status" class="select">
                            <option value="ACTIVE" ${sku.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                            <option value="INACTIVE" ${sku.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="grid-2 gap-16 mb-24">
                    <div class="form-group">
                        <label class="form-label">RAM (GB) <span class="text-danger">*</span></label>
                        <select id="ramSelect" name="ramGb" class="select" onchange="generateSku()">
                            <option value="4" ${sku.ramGb == 4 ? 'selected' : ''}>4GB</option>
                            <option value="6" ${sku.ramGb == 6 ? 'selected' : ''}>6GB</option>
                            <option value="8" ${sku.ramGb == 8 ? 'selected' : ''}>8GB</option>
                            <option value="12" ${sku.ramGb == 12 ? 'selected' : ''}>12GB</option>
                            <option value="16" ${sku.ramGb == 16 ? 'selected' : ''}>16GB</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Storage (GB) <span class="text-danger">*</span></label>
                        <select id="storageSelect" name="storageGb" class="select" onchange="generateSku()">
                            <option value="16" ${sku.storageGb == 16 ? 'selected' : ''}>16GB</option>
                            <option value="32" ${sku.storageGb == 32 ? 'selected' : ''}>32GB</option>
                            <option value="64" ${sku.storageGb == 64 ? 'selected' : ''}>64GB</option>
                            <option value="128" ${sku.storageGb == 128 ? 'selected' : ''}>128GB</option>
                            <option value="256" ${sku.storageGb == 256 ? 'selected' : ''}>256GB</option>
                            <option value="512" ${sku.storageGb == 512 ? 'selected' : ''}>512GB</option>
                            <option value="1024" ${sku.storageGb == 1024 ? 'selected' : ''}>1TB</option>
                        </select>
                    </div>
                </div>

                <div class="d-flex gap-12 pt-16 border-t">
                    <button type="submit" class="btn btn-primary px-32">Save SKU Details</button>
                    <a href="${pageContext.request.contextPath}/manager/product/update?id=${product.productId}" class="btn btn-outline px-24">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function generateSku() {
        const productCode = "${product.productCode}";
        const color = document.getElementById("color").value;
        const storage = document.getElementById("storageSelect").value;
        const ram = document.getElementById("ramSelect").value;

        if (productCode && color && storage && ram) {
            const sku = productCode.trim() + "-" + color.trim().toUpperCase() + "-" + storage + "-" + ram;
            document.getElementById("skuCodeInput").value = sku;
        }
    }
</script>
