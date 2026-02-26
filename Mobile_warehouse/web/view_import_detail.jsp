<%-- 
    Document   : view_import_detail
    Created on : Feb 13, 2026, 5:15:20 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<style>
  .box {
    border: 2px solid #555;
    background: #fff;
    padding: 12px;
  }
  .head {
    font-weight: 700;
    margin-bottom: 8px;
  }
  .meta {
    display: grid;
    grid-template-columns: 160px 1fr;
    row-gap: 6px;
    column-gap: 12px;
    margin: 10px 0 14px;
    max-width: 720px;
  }
  .meta .k { color:#111; }
  .meta .v { color:#111; }
  .tbl {
    width: 100%;
    border-collapse: collapse;
    margin-top: 8px;
  }
  .tbl th, .tbl td {
    border: 1px solid #333;
    padding: 6px 8px;
    vertical-align: top;
  }
  .tbl th { background: #f0f0f0; }
  .btnbar { margin-top: 14px; display:flex; gap:10px; }
  .btn {
    border: 1px solid #333;
    background: #f6f6f6;
    padding: 6px 14px;
    cursor: pointer;
  }
  .btn.primary { background:#e7f0ff; }
  .msg { margin: 8px 0; color: green; }
  .err { margin: 8px 0; color: red; }
  .tab {
    display: inline-block;
    border: 1px solid #333;
    padding: 6px 10px;
    margin-right: 8px;
    background: #f6f6f6;
    font-weight: 600;
  }
</style>

<div class="box">
   <div style="display:flex; gap:10px; align-items:center;">
      <c:set var="ctx" value="${pageContext.request.contextPath}" />
<a class="btn" href="${ctx}/import-receipt-list">← Back</a>
        <div class="title">View Import Receipt Detail</div>
    </div>

  <c:if test="${not empty param.msg}">
    <div class="msg">${param.msg}</div>
  </c:if>
  <c:if test="${not empty err}">
    <div class="err">${err}</div>
  </c:if>

  <div>
    <span class="tab">Import Form</span>
    <span class="tab">Role: ${role}</span>
  </div>

  <c:if test="${not empty receipt}">
    <div class="meta">
      <div class="k">Import Code</div>
      <div class="v">${receipt.importCode}</div>

      <div class="k">Transaction time</div>
      <div class="v">
        <c:choose>
          <c:when test="${not empty receipt.receiptDate}">
            <fmt:formatDate value="${receipt.receiptDate}" pattern="dd/MM/yyyy hh:mm a"/>
          </c:when>
          <c:otherwise>-</c:otherwise>
        </c:choose>
      </div>

      <div class="k">Supplier</div>
      <div class="v">${receipt.supplierName}</div>

      <div class="k">Note</div>
      <div class="v">${receipt.note}</div>

      <div class="k">Status</div>
      <div class="v">${receipt.status}</div>
    </div>

    <div style="font-weight:700; margin-top:10px;">Import Items</div>

    <table class="tbl">
      <thead>
        <tr>
          <th style="width:50px;">#</th>
          <th style="width:140px;">Product Code</th>
          <th style="width:200px;">SKU</th>
          <th style="width:120px;">Quantity</th>
          <th>Imei Numbers</th>
          <th style="width:140px;">Item note</th>
          <th style="width:120px;">Create By</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="it" items="${lines}" varStatus="st">
          <tr>
            <td>${st.index + 1}</td>
            <td>${it.productCode}</td>
            <td>${it.skuCode}</td>
            <td>Products: ${it.qty}</td>
<td style="white-space:pre-line;">
  <c:choose>
    <c:when test="${not empty it.imeiText}">
      <c:out value="${it.imeiText}"/>
    </c:when>
    <c:otherwise>-</c:otherwise>
  </c:choose>
</td>
            <td>${it.itemNote}</td>
            <td>${it.createdByName}</td>
          </tr>
        </c:forEach>

        <c:if test="${empty lines}">
          <tr><td colspan="7">No items</td></tr>
        </c:if>
      </tbody>
    </table>

    <%-- ✅ UPDATED: Show buttons for both DRAFT and PENDING status --%>
    <c:if test="${role eq 'MANAGER' && receipt.status ne null}">
      <c:set var="statusUpper" value="${fn:toUpperCase(receipt.status)}" />
      
      <%-- ✅ Show Approve/Cancel buttons for DRAFT or PENDING --%>
      <c:if test="${statusUpper eq 'DRAFT' || statusUpper eq 'PENDING'}">
        <div class="btnbar">
          <form method="post" action="${pageContext.request.contextPath}/import-receipt-detail" style="margin:0;">
            <input type="hidden" name="id" value="${receipt.importId}"/>
            <input type="hidden" name="action" value="approve"/>
            <button class="btn primary" type="submit"
                    onclick="return confirm('Approve this receipt? This will add stock to inventory and change status to CONFIRMED.');">
              Approve
            </button>
          </form>

          <form method="post" action="${pageContext.request.contextPath}/import-receipt-detail" style="margin:0;">
            <input type="hidden" name="id" value="${receipt.importId}"/>
            <input type="hidden" name="action" value="cancel"/>
            <button class="btn" type="submit"
                    onclick="return confirm('Cancel this receipt? Products will NOT be added to inventory.');">
              Cancel
            </button>
          </form>
        </div>
      </c:if>
    </c:if>

  </c:if>
</div>