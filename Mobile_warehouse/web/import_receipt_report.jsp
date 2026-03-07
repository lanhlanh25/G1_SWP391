<%-- 
    Document   : import_receipt_report
    Created on : Mar 6, 2026, 12:37:25 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<link rel="stylesheet" href="${ctx}/app.css"/>

<div class="page-wrap">

  <a class="btn btn-outline btn-sm" href="${ctx}/home?p=import-receipt-list" style="margin-bottom:10px;">Back</a>

  <div class="title" style="margin-bottom:10px;">Import Receipt Report</div>

  <form method="get" action="${ctx}/import-receipt-report" class="filters"
        style="grid-template-columns: 1fr 1fr 1fr 1fr auto;">
    <div class="field">
      <label>From</label>
      <input class="input" type="date" name="from" value="${from}"/>
    </div>

    <div class="field">
      <label>To</label>
      <input class="input" type="date" name="to" value="${to}"/>
    </div>

    <div class="field">
      <label>Supplier</label>
   <select class="select" name="supplierId">
  <option value="" <c:if test="${empty supplierId}">selected</c:if>>All suppliers</option>

  <c:forEach var="s" items="${suppliers}">
    <option value="${s.id}" <c:if test="${not empty supplierId and supplierId == s.id}">selected</c:if>>
      ${s.name}
    </option>
  </c:forEach>
</select>
    </div>

    <div class="field">
      <label>Status</label>
      <select class="select" name="status">
        <option value="all" ${status=='all'?'selected':''}>All</option>
        <option value="CONFIRMED" ${status=='CONFIRMED'?'selected':''}>Completed</option>
        <option value="CANCELED" ${status=='CANCELED'?'selected':''}>Cancelled</option>
        <option value="PENDING" ${status=='PENDING'?'selected':''}>Pending</option>
        <option value="DRAFT" ${status=='DRAFT'?'selected':''}>Draft</option>
      </select>
    </div>

    <button class="btn btn-primary" type="submit" style="align-self:end;">Apply</button>
  </form>

  <c:set var="sum" value="${reportSummary}" />
  <div style="display:grid; grid-template-columns: repeat(4, 1fr); gap:14px; margin: 12px 0 12px;">
    <div class="card" style="padding:14px; border:2px solid #2e3f95;">
      <div style="font-weight:900; font-size:18px;">Total Import Receipts</div>
      <div style="font-weight:900; font-size:20px; margin-top:6px;">${sum.totalReceipts}</div>
    </div>

    <div class="card" style="padding:14px; background:#3b82f6; color:#fff; border:2px solid #2e3f95;">
      <div style="font-weight:900; font-size:18px;">Total Phone Quantity</div>
      <div style="font-weight:900; font-size:20px; margin-top:6px;">${sum.totalPhoneQty} Phones</div>
    </div>

    <div class="card" style="padding:14px; background:#22c55e; color:#0b1220; border:2px solid #2e3f95;">
      <div style="font-weight:900; font-size:18px;">Completed</div>
      <div style="font-weight:900; font-size:20px; margin-top:6px;">${sum.completedCount}</div>
    </div>

    <div class="card" style="padding:14px; background:#ef4444; color:#0b1220; border:2px solid #2e3f95;">
      <div style="font-weight:900; font-size:18px;">Cancelled</div>
      <div style="font-weight:900; font-size:20px; margin-top:6px;">${sum.cancelledCount}</div>
    </div>
  </div>

  <div style="font-weight:900; font-size:20px; margin: 8px 0;">Import History</div>

  <table class="table">
    <thead>
      <tr>
        <th>Receipt Code</th>
        <th>Created Date</th>
        <th>Supplier</th>
        <th>Total Quantity</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
      <c:if test="${empty rows}">
        <tr><td colspan="5" class="muted" style="text-align:center;">No data</td></tr>
      </c:if>

      <c:forEach var="r" items="${rows}">
        <tr>
          <td>${r.importCode}</td>
          <td><fmt:formatDate value="${r.receiptDate}" pattern="yyyy-MM-dd HH:mm:ss"/></td>
          <td>${r.supplierName}</td>
          <td>${r.totalQuantity} Phone</td>
          <td>${r.statusUi}</td>
        </tr>
      </c:forEach>
    </tbody>
  </table>

  <c:if test="${totalPages > 1}">
    <div class="paging">
      <c:set var="base" value="${ctx}/import-receipt-report?from=${from}&to=${to}&supplierId=${supplierId}&status=${status}" />

      <c:choose>
        <c:when test="${page > 1}">
          <a href="${base}&page=${page-1}">Prev</a>
        </c:when>
        <c:otherwise>
          <span class="paging-btn disabled">Prev</span>
        </c:otherwise>
      </c:choose>

      <c:forEach var="i" begin="1" end="${totalPages}">
        <c:choose>
          <c:when test="${i == page}">
            <b>${i}</b>
          </c:when>
          <c:otherwise>
            <a href="${base}&page=${i}">${i}</a>
          </c:otherwise>
        </c:choose>
      </c:forEach>

      <c:choose>
        <c:when test="${page < totalPages}">
          <a href="${base}&page=${page+1}">Next</a>
        </c:when>
        <c:otherwise>
          <span class="paging-btn disabled">Next</span>
        </c:otherwise>
      </c:choose>
    </div>
  </c:if>

</div>
