<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Create Export Receipt — Upload Excel</div>
    <div style="display:flex; gap:8px;">
      <a class="btn btn-outline" href="${ctx}/home?p=create-export">Switch to Manual Entry</a>
      <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
    </div>
  </div>

  <c:if test="${not empty err}">
    <p class="msg-err"><b>Error:</b> <c:out value="${err}"/></p>
  </c:if>

  <div class="card">
    <div class="card-header"><span class="h2">Receipt Info & File Upload</span></div>
    <div class="card-body">
      <form class="form" method="post" action="${ctx}/sale/export-receipt-upload" enctype="multipart/form-data">

        <div class="form-grid-4">
          <div>
            <label class="label">Export Code</label>
            <input class="input readonly" name="exportCode" value="<c:out value='${exportCode}'/>" readonly placeholder="Auto-generated"/>
          </div>
          <div>
            <label class="label">Export Date <span class="req">*</span></label>
            <input class="input" type="datetime-local" name="exportDate" value="<c:out value='${receiptDateDefault}'/>" required/>
          </div>
          <div>
            <label class="label">Created By</label>
            <input class="input readonly" name="createdByName" value="<c:out value='${createdByName}'/>" readonly/>
          </div>
          <div></div>

          <div>
            <label class="label">Product <span class="req">*</span></label>
            <select class="select" id="productId" name="productId" required>
              <option value="">-- Select product --</option>
              <c:forEach var="p" items="${products}">
                <option value="${p.productId}"><c:out value="${p.productCode}"/></option>
              </c:forEach>
            </select>
          </div>
          <div>
            <label class="label">SKU <span class="req">*</span></label>
            <select class="select" id="skuId" name="skuId" required>
              <option value="">-- Select SKU --</option>
              <c:forEach var="s" items="${skus}">
                <option value="${s.skuId}" data-product="${s.productId}"><c:out value="${s.skuCode}"/></option>
              </c:forEach>
            </select>
            <div class="field-hint">SKU list filtered by selected product.</div>
          </div>
          <div class="span-4">
            <label class="label">Note <span class="muted-label">(optional)</span></label>
            <textarea class="textarea" name="note" placeholder="Optional note for warehouse staff..."></textarea>
          </div>
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-top:14px;">
          <div>
            <label class="label">Excel File (.xlsx) <span class="req">*</span></label>
            <input class="input" type="file" name="file" accept=".xlsx" required/>
            <div class="field-hint">
              Expected columns: <b>IMEI</b> (optional) or <b>QTY</b> column.
            </div>
          </div>
          <div>
            <label class="label">Qty <span class="muted-label">(optional)</span></label>
            <input class="input" type="number" name="qty" min="1" placeholder="Use if file has no IMEI rows"/>
            <div class="field-hint">If exporting by IMEI list, qty = number of IMEIs.</div>
          </div>
        </div>

        <div class="form-actions" style="justify-content:flex-start; margin-top:18px;">
          <button class="btn btn-primary" type="submit" name="action" value="create_send">Create &amp; Send to Warehouse</button>
          <button class="btn btn-outline" type="submit" name="action" value="save_draft">Save Draft</button>
          <a class="btn btn-danger" href="${ctx}/home?p=create-export">Cancel</a>
        </div>

      </form>
    </div>
  </div>

</div>

<script>
  (function(){
    const productSel = document.getElementById('productId');
    const skuSel     = document.getElementById('skuId');
    function filterSku(){
      const pid = productSel.value;
      skuSel.value = "";
      skuSel.querySelectorAll('option').forEach((op, i) => {
        if (i === 0) return;
        op.style.display = (!pid || op.dataset.product === pid) ? '' : 'none';
      });
    }
    productSel.addEventListener('change', filterSku);
    filterSku();
  })();
</script>