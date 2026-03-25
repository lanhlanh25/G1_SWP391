<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap-sm">

    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Add New SKU</h1>
            <span class="badge info fs-11">Variant Creation</span>
        </div>
        <div class="actions">
            <a href="${pageContext.request.contextPath}/home?p=product-list" class="btn btn-outline">← Back</a>
        </div>
    </div>

    <c:if test="${not empty errors}">
        <div class="msg-err mb-16">Please check the required fields and fix any errors below.</div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <div class="h2">SKU Specifications</div>
            <div class="fs-13 text-muted">Define the hardware variant and base properties.</div>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/manager/sku/add" method="post" novalidate autocomplete="off">
                
                <div class="form-group mb-20">
                    <label class="form-label">Product <span class="text-danger">*</span></label>
                    <select class="select ${not empty errors.productId ? 'border-danger' : ''}" id="productId" name="productId" required>
                        <option value="">-- Select Product --</option>
                        <c:forEach var="p" items="${products}">
                            <option value="${p.productId}" data-code="${p.productCode}" ${param.productId == (''+p.productId) ? 'selected' : ''}>
                                ${p.productName}
                            </option>
                        </c:forEach>
                    </select>
                    <c:if test="${not empty errors.productId}">
                        <div class="fs-12 text-danger mt-4">⚠ ${errors.productId}</div>
                    </c:if>
                </div>

                <div class="grid-2 gap-16 mb-20">
                    <div class="form-group">
                        <label class="form-label">Product Code</label>
                        <input id="productCode" class="input" type="text" name="productCodeView" readonly style="background-color: var(--bg-2); opacity: 0.8;">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select class="select" name="status">
                            <option value="ACTIVE" ${param.status == 'ACTIVE' || param.status == null ? 'selected' : ''}>Active</option>
                            <option value="INACTIVE" ${param.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="form-group mb-20">
                    <label class="form-label">Color <span class="text-danger">*</span></label>
                    <input id="color" class="input ${not empty errors.color ? 'border-danger' : ''}" type="text" name="color" value="${param.color}" placeholder="e.g. Phantom Black" required>
                    <c:if test="${not empty errors.color}">
                        <div class="fs-12 text-danger mt-4">⚠ ${errors.color}</div>
                    </c:if>
                </div>

                <div class="grid-2 gap-16 mb-20">
                    <div class="form-group">
                        <label class="form-label">Storage <span class="text-danger">*</span></label>
                        <select class="select ${not empty errors.storageGb ? 'border-danger' : ''}" id="storageSelect" name="storageGb" onchange="toggleStorage(); generateSku();" required>
                            <option value="">-- Select Storage --</option>
                            <option value="16">16GB</option>
                            <option value="32">32GB</option>
                            <option value="64">64GB</option>
                            <option value="128">128GB</option>
                            <option value="256">256GB</option>
                            <option value="512">512GB</option>
                            <option value="1024">1TB</option>
                            <option value="custom">Other...</option>
                        </select>
                        <input id="storageCustom" class="input mt-8" type="number" placeholder="Enter GB (e.g. 2048)" style="display:none;">
                        <c:if test="${not empty errors.storageGb}">
                            <div class="fs-12 text-danger mt-4">⚠ ${errors.storageGb}</div>
                        </c:if>
                    </div>
                    <div class="form-group">
                        <label class="form-label">RAM <span class="text-danger">*</span></label>
                        <select class="select ${not empty errors.ramGb ? 'border-danger' : ''}" id="ramSelect" name="ramGb" onchange="toggleRam(); generateSku();" required>
                            <option value="">-- Select RAM --</option>
                            <option value="4">4GB</option>
                            <option value="6">6GB</option>
                            <option value="8">8GB</option>
                            <option value="12">12GB</option>
                            <option value="16">16GB</option>
                            <option value="custom">Other...</option>
                        </select>
                        <input id="ramCustom" class="input mt-8" type="number" placeholder="Enter GB (e.g. 32)" style="display:none;">
                        <c:if test="${not empty errors.ramGb}">
                            <div class="fs-12 text-danger mt-4">⚠ ${errors.ramGb}</div>
                        </c:if>
                    </div>
                </div>

                <div class="form-group mb-24">
                    <label class="form-label">SKU Code <span class="text-danger">*</span></label>
                    <input id="skuCode" class="input ${not empty errors.skuCode ? 'border-danger' : ''}" type="text" name="skuCode" value="${param.skuCode}" readonly style="background-color: var(--bg-2); opacity: 0.8; font-family: var(--font-mono);">

                    <c:if test="${not empty errors.skuCode}">
                        <div class="fs-12 text-danger mt-4 fw-600">⚠ ${errors.skuCode}</div>
                    </c:if>
             
                </div>

                <div class="d-flex gap-12 pt-16 border-t mt-16">
                    <button class="btn btn-primary px-32" type="submit">Create SKU</button>
                    <a href="${pageContext.request.contextPath}/home?p=product-list" class="btn btn-outline px-24">Cancel</a>
                    <button class="btn btn-outline" type="button" onclick="window.location.href = '${pageContext.request.contextPath}/manager/sku/add'">Reset</button>
                </div>

            </form>
        </div>
    </div>

</div>

<script>
    const productSelect = document.getElementById('productId');
    const productCodeInput = document.getElementById('productCode');

    function syncProductCode() {
        const opt = productSelect.options[productSelect.selectedIndex];
        const code = opt ? (opt.getAttribute('data-code') || '') : '';
        productCodeInput.value = code;
    }

    productSelect.addEventListener('change', function () {
        syncProductCode();
        generateSku();
    });

    syncProductCode();

    function toggleStorage() {
        const select = document.getElementById("storageSelect");
        const input = document.getElementById("storageCustom");
        if (select.value === "custom") {
            input.style.display = "block";
            select.removeAttribute("name");
            input.setAttribute("name", "storageGb");
        } else {
            input.style.display = "none";
            input.removeAttribute("name");
            select.setAttribute("name", "storageGb");
        }
    }

    function toggleRam() {
        const select = document.getElementById("ramSelect");
        const input = document.getElementById("ramCustom");
        if (select.value === "custom") {
            input.style.display = "block";
            select.removeAttribute("name");
            input.setAttribute("name", "ramGb");
        } else {
            input.style.display = "none";
            input.removeAttribute("name");
            select.setAttribute("name", "ramGb");
        }
    }

    function generateSku() {
        const productCode = document.getElementById("productCode").value;
        const color = document.getElementById("color").value;
        const storage = document.getElementById("storageSelect").value;
        const ram = document.getElementById("ramSelect").value;
        
        let storageVal = storage;
        if (storage === "custom") {
            storageVal = document.getElementById("storageCustom").value;
        }
        
        let ramVal = ram;
        if (ram === "custom") {
            ramVal = document.getElementById("ramCustom").value;
        }

        if (productCode && color && storageVal && ramVal) {
            const sku = productCode.trim() + "-" + color.trim().toUpperCase().replace(/\s+/g, '') + "-" + storageVal + "-" + ramVal;
            document.getElementById("skuCode").value = sku;
        }
    }

    document.getElementById("color").addEventListener("keyup", generateSku);
    document.getElementById("storageSelect").addEventListener("change", generateSku);
    document.getElementById("ramSelect").addEventListener("change", generateSku);
    document.getElementById("storageCustom").addEventListener("keyup", generateSku);
    document.getElementById("ramCustom").addEventListener("keyup", generateSku);
</script>
