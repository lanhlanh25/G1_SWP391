<%-- 
    Document   : create_export_receipt
    Created on : Feb 12, 2026, 12:47:26 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  :root{ --line:#2e3f95; --bg:#f4f4f4; --th:#d9d9d9; }
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

  table{ width:100%; border-collapse:collapse; }
  th, td{ border:1px solid #aaa; padding:8px; font-size:13px; }
  th{ background:var(--th); text-align:left; }

  .actions{ display:flex; gap:10px; flex-wrap:wrap; margin-top:12px; }

  @media(max-width:900px){
    .grid3{ grid-template-columns:1fr; }
    .grid2{ grid-template-columns:1fr; }
  }
</style>

<div class="wrap">
  <div class="frame">

    <div class="topbar">
      <div class="title">Create Export Receipt - Manual Entry (Sale)</div>
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

    <form method="post" action="${ctx}/sale/export-receipt-create">
      <!-- Top info -->
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

      <!-- Select product + sku -->
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
          <div class="hint">If you want show product name too, load List&lt;Product&gt; instead of ProductLite in HomeServlet.</div>
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
          <div class="hint">Select Product first, SKU list will be filtered by product.</div>
        </div>
      </div>

      <div class="field" style="margin-top:10px;">
        <label>Note (optional)</label>
        <textarea name="note" placeholder="Optional note for warehouse staff..."></textarea>
      </div>

      <div class="hr"></div>

      <div class="hint" style="margin-bottom:8px;">
        UI demo for manual entry. Backend can collect: productId, skuId, qty, and IMEI list.
      </div>

      <table>
        <thead>
          <tr>
            <th style="width:35%;">SKU</th>
            <th style="width:15%;">Qty</th>
            <th>IMEI / Serial numbers (one per line)</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><input id="skuText" type="text" placeholder="Auto from SKU select" readonly /></td>
            <td><input name="qty" type="number" min="1" value="1" required /></td>
            <td>
              <textarea name="serials" placeholder="Example:
3567...
3567...
"></textarea>
              <div class="hint">If you use IMEI list, qty = number of IMEIs.</div>
            </td>
          </tr>
        </tbody>
      </table>

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
    const skuText = document.getElementById('skuText');

    function filterSku(){
      const pid = productSel.value;
      skuSel.value = "";
      skuText.value = "";

      const opts = skuSel.querySelectorAll('option');
      opts.forEach((op, idx) => {
        if(idx === 0) return;
        const opPid = op.getAttribute('data-product');
        op.style.display = (!pid || opPid === pid) ? '' : 'none';
      });
    }

    function syncSkuText(){
      const op = skuSel.options[skuSel.selectedIndex];
      skuText.value = op && op.value ? op.text : "";
    }

    productSel.addEventListener('change', filterSku);
    skuSel.addEventListener('change', syncSkuText);

    filterSku();
  })();
</script>
