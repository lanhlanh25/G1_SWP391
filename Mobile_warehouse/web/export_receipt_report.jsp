<%-- 
    Document   : export_receipt_report
    Created on : Mar 6, 2026, 1:09:56 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<link rel="stylesheet" href="${ctx}/app.css"/>

<style>
  /* Export Receipt Report: make From/To same width */
  .export-report-filters{
    grid-template-columns: 1fr 1fr auto !important;
  }
  @media (max-width: 980px){
    .export-report-filters{
      grid-template-columns: 1fr 1fr !important;
    }
    .export-report-filters .apply-wrap{
      grid-column: 1 / -1;
      display:flex;
      justify-content:flex-end;
    }
    .export-report-filters .apply-wrap .btn{
      width: 140px;
    }
  }
  @media (max-width: 560px){
    .export-report-filters{
      grid-template-columns: 1fr !important;
    }
    .export-report-filters .apply-wrap{
      justify-content:stretch;
    }
    .export-report-filters .apply-wrap .btn{
      width: 100%;
    }
  }
</style>

<div class="page-wrap">

  <div class="topbar">
    <div style="display:flex; align-items:center; gap:12px;">
      <a class="btn btn-outline" href="${ctx}/home">Back</a>
      <div class="title">Export Receipt Report</div>
    </div>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err">${fn:escapeXml(err)}</div>
  </c:if>

  <!-- Filters -->
  <form method="get" action="${ctx}/export-receipt-report" class="filters export-report-filters">
    <div class="field">
      <label>From</label>
      <input class="input" type="date" name="from" value="${from}" />
    </div>

    <div class="field">
      <label>To</label>
      <input class="input" type="date" name="to" value="${to}" />
    </div>

    <div class="apply-wrap" style="display:flex; align-items:end; justify-content:flex-end;">
      <button class="btn btn-primary" type="submit">Apply</button>
    </div>
  </form>

  <!-- Stats cards -->
  <div class="stat-cards" style="margin-top:10px;">
    <div class="card stat-card-item">
      <div class="muted-label">Total Export Receipts</div>
      <div class="stat-value">
        <c:out value="${reportSummary.totalExportReceipts}" default="0"/>
      </div>
    </div>

    <div class="card stat-card-item" style="border-color: var(--primary-border); background: var(--primary-light);">
      <div class="muted-label">Total Phone Quantity</div>
      <div class="stat-value">
        <c:out value="${reportSummary.totalPhoneQuantity}" default="0"/> Phones
      </div>
    </div>
  </div>

  <div style="height:10px;"></div>

  <div class="h2" style="margin:12px 0 10px;">Export History</div>

  <table class="table">
    <thead>
      <tr>
        <th>RECEIPT CODE</th>
        <th>CREATED DATE</th>
        <th>CREATED BY</th>
        <th>TOTAL QUANTITY</th>
        <th>STATUS</th>
      </tr>
    </thead>
    <tbody>
      <c:choose>
        <c:when test="${empty rows}">
          <tr>
            <td colspan="5" style="text-align:center; color:#64748b; font-weight:700;">
              No export receipts found
            </td>
          </tr>
        </c:when>

        <c:otherwise>
          <c:forEach var="r" items="${rows}">
            <tr>
              <td><c:out value="${r.exportCode}"/></td>
              <td><c:out value="${r.exportDateUi}"/></td>
              <td><c:out value="${r.createdByName}"/></td>
              <td><c:out value="${r.totalQuantity}"/> Phone</td>
              <td><c:out value="${r.status}"/></td>
            </tr>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </tbody>
  </table>

  <!-- Paging -->
  <div class="paging">
    <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}" />

    <c:choose>
      <c:when test="${page > 1}">
        <a class="paging-btn" href="${ctx}/export-receipt-report?${qsBase}&page=${page-1}">Prev</a>
      </c:when>
      <c:otherwise>
        <span class="paging-btn disabled">Prev</span>
      </c:otherwise>
    </c:choose>

    <c:forEach var="p" begin="1" end="${totalPages}">
      <c:choose>
        <c:when test="${p == page}">
          <b>${p}</b>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/export-receipt-report?${qsBase}&page=${p}">${p}</a>
        </c:otherwise>
      </c:choose>
    </c:forEach>

    <c:choose>
      <c:when test="${page < totalPages}">
        <a class="paging-btn" href="${ctx}/export-receipt-report?${qsBase}&page=${page+1}">Next</a>
      </c:when>
      <c:otherwise>
        <span class="paging-btn disabled">Next</span>
      </c:otherwise>
    </c:choose>
  </div>

</div>