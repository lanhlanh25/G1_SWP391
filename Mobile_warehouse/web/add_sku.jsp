<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="container">
    <div class="topbar">
        <div>
            <div class="title">Add SKU</div>
            <div class="small">Create SKU information for warehouse operations</div>
        </div>
        <div class="actions">
            <button class="btn btn-outline" type="button"
                    onclick="window.location.href='${pageContext.request.contextPath}/home?p=product-list'">
                Back
            </button>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/manager/sku/add" method="post" autocomplete="off">
                <div class="form-grid">
                    <div class="label">Product <span class="req">*</span></div>
                    <div>
                        <select class="select" id="productId" name="productId" required>
                            <option value="">-- Select Product --</option>
                            <c:forEach var="p" items="${products}">
                                <option value="${p.productId}"
                                        data-code="${p.productCode}"
                                        ${param.productId == (''+p.productId) ? 'selected' : ''}>
                                    ${p.productName}
                                </option>
                            </c:forEach>
                        </select>
                        <c:if test="${not empty errors.productId}">
                            <div class="err">${errors.productId}</div>
                        </c:if>
                    </div>

                    <div class="label">Product Code</div>
                    <div>
                        <input id="productCode" class="input readonly" type="text" name="productCodeView"
                               value="${param.productCodeView != null ? param.productCodeView : ''}" readonly>
                    </div>

                    <div class="label">Color <span class="req">*</span></div>
                    <div>
                        <input class="input" type="text" name="color"
                               value="${param.color != null ? param.color : ''}" required>
                        <c:if test="${not empty errors.color}">
                            <div class="err">${errors.color}</div>
                        </c:if>
                    </div>

                    <div class="label">Storage <span class="req">*</span></div>
                    <div>
                        <select class="select" name="storageGb" required>
                            <option value="">-- Select Storage --</option>
                            <option value="16" ${param.storageGb == '16' ? 'selected' : ''}>16GB</option>
                            <option value="32" ${param.storageGb == '32' ? 'selected' : ''}>32GB</option>
                            <option value="64" ${param.storageGb == '64' ? 'selected' : ''}>64GB</option>
                            <option value="128" ${param.storageGb == '128' ? 'selected' : ''}>128GB</option>
                            <option value="256" ${param.storageGb == '256' ? 'selected' : ''}>256GB</option>
                            <option value="512" ${param.storageGb == '512' ? 'selected' : ''}>512GB</option>
                            <option value="1024" ${param.storageGb == '1024' ? 'selected' : ''}>1TB</option>
                        </select>
                        <c:if test="${not empty errors.storageGb}">
                            <div class="err">${errors.storageGb}</div>
                        </c:if>
                    </div>

                    <div class="label">RAM <span class="req">*</span></div>
                    <div>
                        <select class="select" name="ramGb" required>
                            <option value="">-- Select RAM --</option>
                            <option value="4" ${param.ramGb == '4' ? 'selected' : ''}>4GB</option>
                            <option value="6" ${param.ramGb == '6' ? 'selected' : ''}>6GB</option>
                            <option value="8" ${param.ramGb == '8' ? 'selected' : ''}>8GB</option>
                            <option value="12" ${param.ramGb == '12' ? 'selected' : ''}>12GB</option>
                            <option value="16" ${param.ramGb == '16' ? 'selected' : ''}>16GB</option>
                        </select>
                        <c:if test="${not empty errors.ramGb}">
                            <div class="err">${errors.ramGb}</div>
                        </c:if>
                    </div>

                    <div class="label">SKU Code <span class="req">*</span></div>
                    <div>
                        <input class="input" type="text" name="skuCode"
                               value="${param.skuCode != null ? param.skuCode : ''}" required>
                        <c:if test="${not empty errors.skuCode}">
                            <div class="err">${errors.skuCode}</div>
                        </c:if>
                    </div>

                    <div class="label">Status</div>
                    <div>
                        <select class="select" name="status">
                            <option value="ACTIVE" ${param.status == 'ACTIVE' || param.status == null ? 'selected' : ''}>ACTIVE</option>
                            <option value="INACTIVE" ${param.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                        </select>
                    </div>
                </div>

                <div class="form-actions">
                    <button class="btn btn-primary" type="submit">Save</button>
                    <button class="btn btn-outline" type="button"
                            onclick="window.location.href='${pageContext.request.contextPath}/home?p=product-list'">
                        Cancel
                    </button>
                    <button class="btn btn-outline" type="button"
                            onclick="window.location.href='${pageContext.request.contextPath}/manager/sku/add'">
                        Reset
                    </button>
                </div>

                <c:if test="${not empty message}">
                    <div class="ok" style="text-align:center;">${message}</div>
                </c:if>
            </form>
        </div>
    </div>
</div>

<script>
    const sel = document.getElementById('productId');
    const code = document.getElementById('productCode');

    function syncCode(){
        const opt = sel.options[sel.selectedIndex];
        const v = opt ? (opt.getAttribute('data-code') || '') : '';
        code.value = v;
    }

    sel.addEventListener('change', syncCode);
    syncCode();
</script>