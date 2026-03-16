<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<link rel="stylesheet" href="${ctx}/app.css"/>

<style>
  .import-report-filters{ grid-template-columns: 1fr 1fr 1fr auto !important; }
  @media (max-width: 980px){
    .import-report-filters{ grid-template-columns: 1fr 1fr !important; }
    .import-report-filters .apply-wrap{ grid-column: 1 / -1; display:flex; justify-content:flex-end; }
    .import-report-filters .apply-wrap .btn{ width:140px; }
  }
  @media (max-width: 560px){
    .import-report-filters{ grid-template-columns: 1fr !important; }
    .import-report-filters .apply-wrap{ justify-content:stretch; }
    .import-report-filters .apply-wrap .btn{ width:100%; }
  }
</style>

<div class="page-wrap">

  <div class="topbar">
    <div style="display:flex; align-items:center; gap:12px;">
      <a class="btn btn-outline" href="${ctx}/home?p=import-receipt-list">Back</a>
      <div class="title">Import Receipt Report</div>
    </div>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err">${fn:escapeXml(err)}</div>
  </c:if>

  <!-- Filters -->
  <form method="get" action="${ctx}/import-receipt-report" class="filters import-report-filters">
    <div class="field">
      <label>From</label>
      <input class="input" type="date" name="from" value="${fn:escapeXml(from)}" />
    </div>
    <div class="field">
      <label>To</label>
      <input class="input" type="date" name="to" value="${fn:escapeXml(to)}" />
    </div>
    <div class="field">
      <label>Supplier</label>
      <select class="input" name="supplierId">
        <option value="">All suppliers</option>
        <c:forEach var="s" items="${suppliers}">
          <option value="${s.id}" ${supplierId == s.id ? 'selected' : ''}>
            ${fn:escapeXml(s.name)}
          </option>
        </c:forEach>
      </select>
    </div>
    <div class="apply-wrap" style="display:flex; align-items:end; justify-content:flex-end;">
      <button class="btn btn-primary" type="submit">Apply</button>
    </div>
  </form>

  <!-- Stats -->
  <div class="stat-cards" style="margin-top:10px;">
    <div class="card stat-card-item">
      <div class="muted-label">Total Import Receipts</div>
      <div class="stat-value">
        <c:out value="${reportSummary.totalReceipts}" default="0"/>
      </div>
    </div>

    <div class="card stat-card-item" style="border-color: var(--primary-border); background: var(--primary-light);">
      <div class="muted-label">Total Phone Quantity</div>
      <div class="stat-value">
        <c:out value="${reportSummary.totalPhoneQty}" default="0"/> Phones
      </div>
    </div>
  </div>

  <div style="height:10px;"></div>
  <div class="h2" style="margin:12px 0 10px;">Import History</div>

  <table class="table">
    <thead>
      <tr>
        <th>RECEIPT CODE</th>
        <th>CREATED DATE</th>
        <th>SUPPLIER</th>
        <th>TOTAL QUANTITY</th>
        <th>STATUS</th>
      </tr>
    </thead>
    <tbody>
      <c:choose>
        <c:when test="${empty rows}">
          <tr>
            <td colspan="5" style="text-align:center; color:#64748b; font-weight:700;">
              No import receipts found
            </td>
          </tr>
        </c:when>
        <c:otherwise>
          <c:forEach var="r" items="${rows}">
            <tr>
              <td><c:out value="${r.importCode}"/></td>
              <td>
                <c:choose>
                  <c:when test="${not empty r.receiptDate}">
                    <fmt:formatDate value="${r.receiptDate}" pattern="yyyy-MM-dd HH:mm"/>
                  </c:when>
                  <c:otherwise>—</c:otherwise>
                </c:choose>
              </td>
              <td><c:out value="${r.supplierName}"/></td>
              <td><c:out value="${r.totalQuantity}"/> Phone</td>
              <td>Completed</td>
            </tr>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </tbody>
  </table>

  <!-- Paging -->
  <div class="paging">
    <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}&supplierId=${supplierId}" />

    <c:choose>
      <c:when test="${page > 1}">
        <a class="paging-btn" href="${ctx}/import-receipt-report?${qsBase}&page=${page - 1}">Prev</a>
      </c:when>
      <c:otherwise>
        <span class="paging-btn disabled">Prev</span>
      </c:otherwise>
    </c:choose>

    <c:forEach var="pg" begin="1" end="${totalPages}">
      <c:choose>
        <c:when test="${pg == page}">
          <b>${pg}</b>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/import-receipt-report?${qsBase}&page=${pg}">${pg}</a>
        </c:otherwise>
      </c:choose>
    </c:forEach>

    <c:choose>
      <c:when test="${page < totalPages}">
        <a class="paging-btn" href="${ctx}/import-receipt-report?${qsBase}&page=${page + 1}">Next</a>
      </c:when>
      <c:otherwise>
        <span class="paging-btn disabled">Next</span>
      </c:otherwise>
    </c:choose>
  </div>

</div>
