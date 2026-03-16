<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
  @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=DM+Mono:wght@400;500&display=swap');

  .up-wrapper {
    font-family: 'DM Sans', sans-serif;
    max-width: 640px;
    margin: 36px auto;
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 4px 32px rgba(0,0,0,0.08), 0 1px 4px rgba(0,0,0,0.04);
    overflow: hidden;
  }

  /* ── Header banner ── */
  .up-header {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 60%, #0f3460 100%);
    padding: 28px 32px 24px;
    position: relative;
    overflow: hidden;
  }
  .up-header::after {
    content: '';
    position: absolute;
    right: -40px; top: -40px;
    width: 160px; height: 160px;
    border-radius: 50%;
    background: rgba(255,255,255,0.04);
  }
  .up-header h1 {
    margin: 0 0 10px;
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    color: rgba(255,255,255,0.5);
  }
  .up-header .product-title {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 6px;
  }
  .up-header .product-name {
    font-size: 22px;
    font-weight: 700;
    color: #fff;
    letter-spacing: -0.01em;
  }
  .up-header .badge-code {
    font-family: 'DM Mono', monospace;
    font-size: 12px;
    font-weight: 500;
    background: rgba(255,255,255,0.12);
    color: rgba(255,255,255,0.75);
    padding: 3px 10px;
    border-radius: 6px;
    border: 1px solid rgba(255,255,255,0.15);
  }
  .up-header .badge-status {
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    padding: 3px 10px;
    border-radius: 6px;
  }
  .up-header .badge-status.active {
    background: rgba(74, 222, 128, 0.2);
    color: #4ade80;
    border: 1px solid rgba(74, 222, 128, 0.3);
  }
  .up-header .badge-status.inactive {
    background: rgba(248, 113, 113, 0.2);
    color: #f87171;
    border: 1px solid rgba(248, 113, 113, 0.3);
  }
  .up-header .subtitle {
    font-size: 13px;
    color: rgba(255,255,255,0.4);
    margin: 0;
  }

  /* ── Body ── */
  .up-body {
    padding: 28px 32px 32px;
  }

  /* ── Section title ── */
  .section-title {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: #94a3b8;
    margin: 0 0 16px;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .section-title::after {
    content: '';
    flex: 1;
    height: 1px;
    background: #f1f5f9;
  }

  /* ── Form fields ── */
  .field {
    margin-bottom: 18px;
  }
  .field label {
    display: block;
    font-size: 12px;
    font-weight: 600;
    color: #64748b;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    margin-bottom: 6px;
  }
  .field label span.req {
    color: #f43f5e;
    margin-left: 2px;
  }
  .field input[type="text"],
  .field textarea {
    width: 100%;
    box-sizing: border-box;
    padding: 10px 14px;
    font-family: 'DM Sans', sans-serif;
    font-size: 14px;
    color: #1e293b;
    background: #f8fafc;
    border: 1.5px solid #e2e8f0;
    border-radius: 10px;
    outline: none;
    transition: border-color 0.18s, box-shadow 0.18s, background 0.18s;
    resize: vertical;
  }
  .field input[type="text"]:focus,
  .field textarea:focus {
    border-color: #6366f1;
    background: #fff;
    box-shadow: 0 0 0 3px rgba(99,102,241,0.12);
  }
  .field textarea {
    min-height: 80px;
  }

  /* error */
  .field.has-error input,
  .field.has-error textarea {
    border-color: #f43f5e;
    background: #fff5f7;
  }
  .error-msg {
    font-size: 12px;
    color: #f43f5e;
    margin-top: 4px;
    display: flex;
    align-items: center;
    gap: 4px;
  }

  /* ── Brand (read-only) ── */
  .field .readonly-val {
    display: inline-block;
    padding: 9px 14px;
    font-size: 14px;
    color: #475569;
    background: #f1f5f9;
    border: 1.5px solid #e2e8f0;
    border-radius: 10px;
    width: 100%;
    box-sizing: border-box;
  }

  /* ── Status radio ── */
  .radio-group {
    display: flex;
    gap: 12px;
  }
  .radio-option {
    flex: 1;
    position: relative;
  }
  .radio-option input[type="radio"] {
    position: absolute;
    opacity: 0;
    width: 0; height: 0;
  }
  .radio-option label {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    padding: 9px 16px;
    background: #f8fafc;
    border: 1.5px solid #e2e8f0;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
    color: #64748b;
    cursor: pointer;
    transition: all 0.15s;
    text-transform: none;
    letter-spacing: 0;
  }
  .radio-option label .dot {
    width: 8px; height: 8px;
    border-radius: 50%;
    background: #cbd5e1;
    transition: background 0.15s;
  }
  .radio-option input[type="radio"]:checked + label {
    border-color: #6366f1;
    background: #eef2ff;
    color: #4338ca;
  }
  .radio-option input[type="radio"]:checked + label .dot {
    background: #6366f1;
    box-shadow: 0 0 0 3px rgba(99,102,241,0.2);
  }
  .radio-option.inactive input[type="radio"]:checked + label {
    border-color: #f43f5e;
    background: #fff5f7;
    color: #e11d48;
  }
  .radio-option.inactive input[type="radio"]:checked + label .dot {
    background: #f43f5e;
    box-shadow: 0 0 0 3px rgba(244,63,94,0.2);
  }

  /* ── Divider ── */
  .divider {
    height: 1px;
    background: #f1f5f9;
    margin: 24px 0;
  }

  /* ── SKU section header ── */
  .sku-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
  }
  .sku-add-link {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-size: 12px;
    font-weight: 700;
    color: #6366f1;
    text-decoration: none;
    background: #eef2ff;
    padding: 5px 12px;
    border-radius: 8px;
    border: 1.5px solid #c7d2fe;
    transition: all 0.15s;
    letter-spacing: 0.02em;
  }
  .sku-add-link:hover {
    background: #6366f1;
    color: #fff;
    border-color: #6366f1;
  }

  /* ── SKU list ── */
  .sku-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .sku-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 14px;
    background: #f8fafc;
    border: 1.5px solid #e2e8f0;
    border-radius: 10px;
    transition: border-color 0.15s;
  }
  .sku-item:hover {
    border-color: #c7d2fe;
    background: #fafafe;
  }
  .sku-code {
    font-family: 'DM Mono', monospace;
    font-size: 12px;
    font-weight: 500;
    color: #4338ca;
    background: #eef2ff;
    padding: 2px 8px;
    border-radius: 5px;
    white-space: nowrap;
  }
  .sku-sep {
    color: #cbd5e1;
    font-size: 12px;
  }
  .sku-attr {
    font-size: 13px;
    color: #475569;
    font-weight: 500;
  }
  .sku-status {
    margin-left: auto;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    padding: 2px 8px;
    border-radius: 5px;
  }
  .sku-status.active {
    background: #dcfce7;
    color: #15803d;
  }
  .sku-status.inactive {
    background: #fee2e2;
    color: #b91c1c;
  }
  .sku-empty {
    text-align: center;
    padding: 20px;
    color: #94a3b8;
    font-size: 13px;
    background: #f8fafc;
    border-radius: 10px;
    border: 1.5px dashed #e2e8f0;
  }

  /* ── Actions ── */
  .up-actions {
    display: flex;
    gap: 12px;
    margin-top: 28px;
  }
  .btn-save {
    flex: 1;
    padding: 12px 24px;
    font-family: 'DM Sans', sans-serif;
    font-size: 14px;
    font-weight: 700;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    color: #fff;
    background: linear-gradient(135deg, #6366f1, #4338ca);
    border: none;
    border-radius: 11px;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(99,102,241,0.35);
    transition: all 0.18s;
  }
  .btn-save:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 20px rgba(99,102,241,0.45);
  }
  .btn-save:active {
    transform: translateY(0);
  }
  .btn-cancel {
    padding: 12px 24px;
    font-family: 'DM Sans', sans-serif;
    font-size: 14px;
    font-weight: 600;
    color: #64748b;
    background: #f1f5f9;
    border: 1.5px solid #e2e8f0;
    border-radius: 11px;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: all 0.18s;
  }
  .btn-cancel:hover {
    background: #e2e8f0;
    color: #1e293b;
    border-color: #cbd5e1;
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
