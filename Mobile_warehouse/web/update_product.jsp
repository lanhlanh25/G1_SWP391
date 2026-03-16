<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
    .up-wrapper {
        font-family: 'Inter', sans-serif;
        max-width: 640px;
        margin: 36px auto;
        background: var(--surface);
        border-radius: var(--radius);
        box-shadow: var(--shadow-md);
        overflow: hidden;
        border: 1px solid var(--border);
    }
    .up-header {
        background: linear-gradient(135deg, var(--sidebar) 0%, var(--sidebar-2) 100%);
        padding: 28px 32px 24px;
        position: relative;
        overflow: hidden;
    }
    .up-header::after {
        content:'';
        position:absolute;
        right:-40px;
        top:-40px;
        width:160px;
        height:160px;
        border-radius:50%;
        background:rgba(255,255,255,.04);
    }
    .up-header h1 {
        margin:0 0 10px;
        font-size:13px;
        font-weight:600;
        letter-spacing:.18em;
        text-transform:uppercase;
        color:rgba(255,255,255,.5);
    }
    .up-header .product-title {
        display:flex;
        align-items:center;
        flex-wrap:wrap;
        gap:10px;
        margin-bottom:6px;
    }
    .up-header .product-name {
        font-size:22px;
        font-weight:700;
        color:#fff;
    }
    .up-header .badge-code {
        font-family:monospace;
        font-size:12px;
        font-weight:500;
        background:rgba(255,255,255,.12);
        color:rgba(255,255,255,.75);
        padding:3px 10px;
        border-radius:var(--radius-sm);
        border:1px solid rgba(255,255,255,.15);
    }
    .up-header .badge-status {
        font-size:11px;
        font-weight:600;
        letter-spacing:.06em;
        text-transform:uppercase;
        padding:3px 10px;
        border-radius:var(--radius-sm);
    }
    .up-header .badge-status.active {
        background:rgba(46,184,92,.2);
        color:#2eb85c;
        border:1px solid rgba(46,184,92,.3);
    }
    .up-header .badge-status.inactive {
        background:rgba(229,83,83,.2);
        color:#e55353;
        border:1px solid rgba(229,83,83,.3);
    }
    .up-header .subtitle {
        font-size:13px;
        color:rgba(255,255,255,.4);
        margin:0;
    }
    .up-body {
        padding:28px 32px 32px;
    }
    .up-wrapper .section-title {
        font-size:11px;
        font-weight:700;
        letter-spacing:.12em;
        text-transform:uppercase;
        color:var(--muted);
        margin:0 0 16px;
        display:flex;
        align-items:center;
        gap:8px;
    }
    .up-wrapper .section-title::after {
        content:'';
        flex:1;
        height:1px;
        background:var(--border);
    }
    .field {
        margin-bottom:18px;
    }
    .field label {
        display:block;
        font-size:12px;
        font-weight:600;
        color:var(--text-2);
        letter-spacing:.04em;
        text-transform:uppercase;
        margin-bottom:6px;
    }
    .field label span.req {
        color:var(--danger);
        margin-left:2px;
    }
    .field input[type="text"], .field textarea {
        width:100%;
        box-sizing:border-box;
        padding:7px 12px;
        font-family:'Inter',sans-serif;
        font-size:14px;
        color:var(--text);
        background:var(--surface-2);
        border:1px solid var(--border);
        border-radius:var(--radius-sm);
        outline:none;
        transition:border-color .15s, box-shadow .15s;
        resize:vertical;
    }
    .field input[type="text"]:focus, .field textarea:focus {
        border-color:var(--primary);
        background:var(--surface);
        box-shadow:0 0 0 3px rgba(50,31,219,.12);
    }
    .field textarea {
        min-height:80px;
    }
    .field.has-error input, .field.has-error textarea {
        border-color:var(--danger);
        background:#fdf0f0;
    }
    .error-msg {
        font-size:12px;
        color:var(--danger);
        margin-top:4px;
        display:flex;
        align-items:center;
        gap:4px;
        font-weight:600;
    }
    .field .readonly-val {
        display:inline-block;
        padding:7px 12px;
        font-size:14px;
        color:var(--text-2);
        background:var(--surface-2);
        border:1px solid var(--border);
        border-radius:var(--radius-sm);
        width:100%;
        box-sizing:border-box;
    }
    .radio-group {
        display:flex;
        gap:12px;
    }
    .radio-option {
        flex:1;
        position:relative;
    }
    .radio-option input[type="radio"] {
        position:absolute;
        opacity:0;
        width:0;
        height:0;
    }
    .radio-option label {
        display:flex;
        align-items:center;
        justify-content:center;
        gap:7px;
        padding:7px 16px;
        background:var(--surface-2);
        border:1px solid var(--border);
        border-radius:var(--radius-sm);
        font-size:13px;
        font-weight:600;
        color:var(--text-2);
        cursor:pointer;
        transition:all .15s;
        text-transform:none;
        letter-spacing:0;
    }
    .radio-option label .dot {
        width:8px;
        height:8px;
        border-radius:50%;
        background:var(--border);
        transition:background .15s;
    }
    .radio-option input[type="radio"]:checked + label {
        border-color:var(--primary);
        background:var(--primary-light);
        color:var(--primary);
    }
    .radio-option input[type="radio"]:checked + label .dot {
        background:var(--primary);
        box-shadow:0 0 0 3px rgba(50,31,219,.15);
    }
    .radio-option.inactive input[type="radio"]:checked + label {
        border-color:var(--danger);
        background:#fdf0f0;
        color:var(--danger);
    }
    .radio-option.inactive input[type="radio"]:checked + label .dot {
        background:var(--danger);
        box-shadow:0 0 0 3px rgba(229,83,83,.15);
    }
    .divider {
        height:1px;
        background:var(--border);
        margin:24px 0;
    }
    .sku-header {
        display:flex;
        align-items:center;
        justify-content:space-between;
        margin-bottom:12px;
    }
    .sku-add-link {
        display:inline-flex;
        align-items:center;
        gap:5px;
        font-size:12px;
        font-weight:700;
        color:var(--primary);
        text-decoration:none;
        background:var(--primary-light);
        padding:5px 12px;
        border-radius:var(--radius-sm);
        border:1px solid var(--primary-border);
        transition:all .15s;
    }
    .sku-add-link:hover {
        background:var(--primary);
        color:#fff;
        border-color:var(--primary);
        text-decoration:none;
    }
    .sku-list {
        display:flex;
        flex-direction:column;
        gap:8px;
    }
    .sku-item {
        display:flex;
        align-items:center;
        gap:8px;
        padding:10px 14px;
        background:var(--surface-2);
        border:1px solid var(--border);
        border-radius:var(--radius-sm);
        transition:border-color .15s;
    }
    .sku-item:hover {
        border-color:var(--primary-border);
    }
    .sku-code {
        font-family:monospace;
        font-size:12px;
        font-weight:500;
        color:var(--primary);
        background:var(--primary-light);
        padding:2px 8px;
        border-radius:var(--radius-xs);
        white-space:nowrap;
    }
    .sku-sep {
        color:var(--border);
        font-size:12px;
    }
    .sku-attr {
        font-size:13px;
        color:var(--text-2);
        font-weight:500;
    }
    .sku-status {
        margin-left:auto;
        font-size:11px;
        font-weight:700;
        letter-spacing:.06em;
        text-transform:uppercase;
        padding:2px 8px;
        border-radius:var(--radius-xs);
    }
    .sku-status.active {
        background:#e6f9ed;
        color:#0d6832;
    }
    .sku-status.inactive {
        background:#fdf0f0;
        color:#b91c1c;
    }
    .sku-empty {
        text-align:center;
        padding:20px;
        color:var(--muted);
        font-size:13px;
        background:var(--surface-2);
        border-radius:var(--radius-sm);
        border:1px dashed var(--border);
    }
    .up-actions {
        display:flex;
        gap:12px;
        margin-top:28px;
    }
    .btn-save {
        flex:1;
        padding:10px 24px;
        font-family:'Inter',sans-serif;
        font-size:14px;
        font-weight:700;
        color:#fff;
        background:var(--primary);
        border:none;
        border-radius:var(--radius-sm);
        cursor:pointer;
        transition:all .15s;
    }
    .btn-save:hover {
        background:var(--primary-2);
    }
    .btn-cancel {
        padding:10px 24px;
        font-family:'Inter',sans-serif;
        font-size:14px;
        font-weight:600;
        color:var(--text-2);
        background:var(--surface-2);
        border:1px solid var(--border);
        border-radius:var(--radius-sm);
        text-decoration:none;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        transition:all .15s;
    }
    .btn-cancel:hover {
        background:#e9ecef;
        color:var(--text);
        text-decoration:none;
    }
</style>

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
