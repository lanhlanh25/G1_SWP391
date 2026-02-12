<%-- 
    Document   : upload_export_imeis
    Created on : Feb 12, 2026, 12:48:05 PM
    Author     : Admin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  :root{ --line:#2e3f95; --bg:#f4f4f4; }
  *{ box-sizing:border-box; }
  .wrap{ padding:10px; background:var(--bg); font-family:Arial, Helvetica, sans-serif; }
  .frame{ border:2px solid var(--line); background:#fff; padding:14px; }
  .topbar{ display:flex; justify-content:space-between; align-items:center; gap:10px; margin-bottom:12px; }
  .title{ font-size:18px; font-weight:700; }
  .btn{ padding:8px 14px; border:1px solid #333; background:#f6f6f6; text-decoration:none; color:#111; cursor:pointer; display:inline-block; }
  .btn.primary{ background:#e9f0ff; }
  .btn.danger{ background:#ffecec; border-color:#c33; }

  .grid3{ display:grid; grid-template-columns: 1fr 1fr 1fr; gap:10px; }
  .grid2{ display:grid; grid-template-columns: 1fr 1fr; gap:10px; }
  .field label{ display:block; font-size:12px; margin-bottom:4px; }
  .field input, .field select, .field textarea{
    width:100%; padding:8px; border:1px solid #999; border-radius:4px;
  }
  textarea{ min-height:70px; resize:vertical; }
  .hint{ font-size:12px; color:#666; margin-top:6px; line-height:1.35; }
  .hr{ height:1px; background:#ddd; margin:12px 0; }
  .actions{ display:flex; gap:10px; flex-wrap:wrap; margin-top:12px; }

  @media(max-width:900px){
    .grid3{ grid-template-columns:1fr; }
    .grid2{ grid-template-columns:1fr; }
  }
</style>

<div class="wrap">
  <div class="frame">

    <div class="topbar">
      <div class="title">Create Export Receipt - Upload Excel (Sale)</div>
      <div style="display:flex; gap:10px; flex-wrap:wrap;">
        <a class="btn" href="${ctx}/home?p=create-export">Switch Method</a>
        <a class="btn" href="${ctx}/home?p=dashboard">Back</a>
      </div>
    </div>

    <c:if test="${not empty err}">
      <div style="background:#ffecec;border:1px solid #c33;padding:10px;border-radius:6px;margin-bottom:10px;">
        <b>Error:</b> <c:out value="${err}"/>
      </div>
    </c:if>

    <form method="post" action="${ctx}/sale/export-receipt-upload" enctype="multipart/form-data">

      <div class="grid3">
        <div class="field">
          <label>Export code</label>
          <input name="exportCode" value="<c:out value='${exportCode}'/>" readonly placeholder="Auto-generated"/>
        </div>

        <div class="field">
          <label>Export date</label>
          <input type="datetime-local" name="exportDate"
                 value="<c:out value='${receiptDateDefault}'/>"
                 required />
        </div>

        <div class="field">
          <label>Created by (Sale)</label>
          <input name="createdByName" value="<c:out value='${createdByName}'/>" readonly />
        </div>
      </div>

      <div class="hr"></div>

      <div class="grid2">
        <div class="field">
          <label>Product</label>
          <select id="productId" name="productId" required>
            <option value="">-- Select product --</option>

            <!-- FIX: chỉ dùng productId + productCode (ProductLite) -->
            <c:forEach var="p" items="${products}">
              <option value="${p.productId}">
                <c:out value="${p.productCode}"/>
              </option>
            </c:forEach>

          </select>
        </div>

        <div class="field">
          <label>SKU</label>
          <select id="skuId" name="skuId" required>
            <option value="">-- Select SKU --</option>
            <c:forEach var="s" items="${skus}">
              <option value="${s.skuId}" data-product="${s.productId}">
                <c:out value="${s.skuCode}"/>
              </option>
            </c:forEach>
          </select>
          <div class="hint">SKU list will be filtered by Product (frontend demo).</div>
        </div>
      </div>

      <div class="field" style="margin-top:10px;">
        <label>Note (optional)</label>
        <textarea name="note" placeholder="Optional note for warehouse staff..."></textarea>
      </div>

      <div class="hr"></div>

      <div class="grid2">
        <div class="field">
          <label>Excel file (.xlsx)</label>
          <input type="file" name="file" accept=".xlsx" required />
          <div class="hint">
            Expected columns (example):<br/>
            - <b>IMEI</b> (optional) | if empty, system can use Qty.<br/>
            - You can also support <b>QTY</b> column if needed.
          </div>
        </div>

        <div class="field">
          <label>Qty (optional)</label>
          <input type="number" name="qty" min="1" placeholder="If file has no IMEI rows, use this qty" />
          <div class="hint">
            If your system exports by IMEI list, then qty = number of IMEIs.
          </div>
        </div>
      </div>

      <div class="actions">
        <button class="btn primary" type="submit" name="action" value="create_send">Create &amp; Send to Warehouse</button>
        <button class="btn" type="submit" name="action" value="save_draft">Save Draft</button>
        <a class="btn danger" href="${ctx}/home?p=create-export">Cancel</a>
      </div>

    </form>
  </div>
</div>

<script>
  (function(){
    const productSel = document.getElementById('productId');
    const skuSel = document.getElementById('skuId');

    function filterSku(){
      const pid = productSel.value;
      skuSel.value = "";

      const opts = skuSel.querySelectorAll('option');
      opts.forEach((op, idx) => {
        if(idx === 0) return;
        const opPid = op.getAttribute('data-product');
        op.style.display = (!pid || opPid === pid) ? '' : 'none';
      });
    }

    productSel.addEventListener('change', filterSku);
    filterSku();
  })();
</script>
