<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="page-wrap">
  <div class="topbar">
    <div class="title">Create Export Request</div>
    <button class="btn btn-primary" type="submit" form="frm" name="action" value="submit">Submit Request</button>
  </div>

  <c:if test="${param.err == '1'}">
    <p class="msg-err">Submit failed. Please check inputs. <c:out value="${param.errMsg}"/></p>
  </c:if>

  <form id="frm" method="post" action="${ctx}/create-export-request">
    <div class="card" style="margin-bottom:14px;">
      <div class="card-header"><span class="h2">Request Information</span></div>
      <div class="card-body">
        <div class="form-grid">
          <label class="label">Request Code</label>
          <input class="input readonly" type="text" value="${erCreateCode}" readonly/>

          <label class="label">Request Date</label>
          <input class="input readonly" type="text" value="${erRequestDateDefault}" readonly/>

          <label class="label">Created By</label>
          <input class="input readonly" type="text" value="${erCreatedByName}" readonly/>

          <label class="label">Expected Export Date</label>
          <input class="input" type="date" name="expected_export_date" min="${today}" value="${param.expected_export_date}"/>

          <label class="label">Note</label>
          <textarea class="textarea" name="note">${fn:escapeXml(param.note)}</textarea>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <span class="h2">Items</span>
        <div style="display:flex; gap:8px;">
          <button class="btn btn-outline" type="button" onclick="addRow()">+ Add Item</button>
          <button class="btn" type="button" onclick="clearRows()">Clear</button>
        </div>
      </div>
      <div class="card-body" style="padding:0;">
        <table class="table">
          <thead>
            <tr>
              <th style="text-align:center; width:60px;">No</th>
              <th>Product Code</th>
              <th>SKU (optional)</th>
              <th style="width:140px; text-align:center;">Request Qty</th>
              <th style="width:100px; text-align:center;">Remove</th>
            </tr>
          </thead>
          <tbody id="tbody"></tbody>
        </table>
        <div style="padding:10px 16px;" class="small">
          Total quantity: <b id="totalQty">0</b>
        </div>
      </div>
    </div>
  </form>

  <%-- Hidden templates --%>
  <select id="tplProductOptions" style="display:none">
    <option value="">Select Product Code</option>
    <c:forEach var="p" items="${erProducts}">
      <option value="${p.productId}">${fn:escapeXml(p.productCode)}</option>
    </c:forEach>
  </select>
  <select id="tplSkuOptions" style="display:none">
    <option value="">Select SKU</option>
    <c:forEach var="s" items="${erSkus}">
      <option value="${s.skuId}" data-product="${s.productId}">${fn:escapeXml(s.skuCode)}</option>
    </c:forEach>
  </select>
</div>

<script>
  function productOptionsHtml(){return document.getElementById("tplProductOptions").innerHTML;}
  function skuOptionsHtml(productId){
    let html='<option value="">Select SKU</option>';if(!productId)return html;
    document.getElementById("tplSkuOptions").querySelectorAll("option[data-product]").forEach(o=>{if(o.getAttribute("data-product")===String(productId))html+=o.outerHTML;});return html;
  }
  function addRow(){
    const tb=document.getElementById("tbody");const tr=document.createElement("tr");
    tr.innerHTML='<td class="no" style="text-align:center;"></td>'+
      '<td><select class="select" name="productId" onchange="onProductChange(this)">'+productOptionsHtml()+'</select></td>'+
      '<td><select class="select" name="skuId"><option value="">Select SKU</option></select></td>'+
      '<td><input class="input" name="qty" value="1" style="text-align:center;" oninput="recalcTotal()"/></td>'+
      '<td style="text-align:center;"><button type="button" class="btn btn-danger btn-sm" onclick="removeRow(this)">✕</button></td>';
    tb.appendChild(tr);renumber();recalcTotal();
    onProductChange(tr.querySelector('select[name="productId"]'));
  }
  function onProductChange(sel){sel.closest("tr").querySelector('select[name="skuId"]').innerHTML=skuOptionsHtml(sel.value);}
  function removeRow(btn){btn.closest("tr").remove();renumber();recalcTotal();}
  function clearRows(){document.getElementById("tbody").innerHTML="";addRow();}
  function renumber(){let i=1;document.querySelectorAll("#tbody tr").forEach(r=>r.querySelector(".no").innerText=i++);}
  function recalcTotal(){let t=0;document.querySelectorAll('input[name="qty"]').forEach(i=>{const v=parseInt(i.value||"0",10);if(!isNaN(v))t+=v;});document.getElementById("totalQty").innerText=t;}
  addRow();
</script>