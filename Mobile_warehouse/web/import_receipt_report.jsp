<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<link rel="stylesheet" href="${ctx}/app.css"/>

  <%-- Internal styles moved to app.css --%>

<div class="page-wrap">
  <div class="topbar">
    <div style="display:flex; align-items:center; gap:10px;">
      <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
      <h1 class="h1">Import Receipt Report</h1>
    </div>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err">${fn:escapeXml(err)}</div>
  </c:if>

  <!-- Filters -->
  <form method="get" action="${ctx}/import-receipt-report" class="filters import-report-filters mb-20">
    <div class="filter-group">
      <label>From</label>
      <input class="input" type="date" name="from" value="${fn:escapeXml(from)}" />
    </div>
    <div class="filter-group">
      <label>To</label>
      <input class="input" type="date" name="to" value="${fn:escapeXml(to)}" />
    </div>
    <div class="filter-group">
      <label>Supplier</label>
      <select class="select" name="supplierId">
        <option value="">All suppliers</option>
        <c:forEach var="s" items="${suppliers}">
          <option value="${s.id}" ${supplierId == s.id ? 'selected' : ''}>
            ${fn:escapeXml(s.name)}
          </option>
        </c:forEach>
      </select>
    </div>
    <div class="filter-actions d-flex align-end">
      <button class="btn btn-primary h-38" type="submit">Apply</button>
    </div>
  </form>

  <!-- Stats -->
  <div class="stat-cards mb-20">
    <div class="stat-card">
      <div class="stat-label">Total Import Receipts</div>
      <div class="stat-value">
        <c:out value="${reportSummary.totalReceipts}" default="0"/>
      </div>
    </div>

    <div class="stat-card border-primary bg-primary-light">
      <div class="stat-label text-primary">Total Phone Quantity</div>
      <div class="stat-value text-primary">
        <c:out value="${reportSummary.totalPhoneQty}" default="0"/> <span class="font-md fw-600">Phones</span>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-body">
      <div class="h2" style="margin-bottom:14px;">Import History</div>
      
      <table class="table">
        <thead>
          <tr>
            <th>Receipt Code</th>
            <th>Created Date</th>
            <th>Supplier</th>
            <th style="text-align:center;">Total Quantity</th>
            <th style="width:120px;">Status</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty rows}">
              <tr>
                <td colspan="5" style="text-align:center; padding:32px; color:var(--muted);">
                  No import receipts found
                </td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="r" items="${rows}">
                <tr>
                  <td style="font-weight:600;"><c:out value="${r.importCode}"/></td>
                  <td style="color:var(--muted);">
                    <c:choose>
                      <c:when test="${not empty r.receiptDate}">
                        <fmt:formatDate value="${r.receiptDate}" pattern="yyyy-MM-dd HH:mm"/>
                      </c:when>
                      <c:otherwise>—</c:otherwise>
                    </c:choose>
                  </td>
                  <td><c:out value="${r.supplierName}"/></td>
                  <td style="font-weight:700; text-align:center;"><c:out value="${r.totalQuantity}"/> Phone</td>
                  <td><span class="badge badge-active">Completed</span></td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>

      <c:if test="${totalPages > 1}">
        <div class="paging-footer">
          <div class="paging-info">Page <b>${page}</b> of <b>${totalPages}</b></div>
          <div class="paging">
            <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}&supplierId=${supplierId}" />

            <c:choose>
              <c:when test="${page > 1}">
                <a class="paging-btn" href="${ctx}/import-receipt-report?${qsBase}&page=${page - 1}">← Prev</a>
              </c:when>
              <c:otherwise>
                <span class="paging-btn disabled">← Prev</span>
              </c:otherwise>
            </c:choose>

            <c:forEach var="pg" begin="1" end="${totalPages}">
              <c:choose>
                <c:when test="${pg == page}">
                  <span class="paging-btn active">${pg}</span>
                </c:when>
                <c:otherwise>
                  <a class="paging-btn" href="${ctx}/import-receipt-report?${qsBase}&page=${pg}">${pg}</a>
                </c:otherwise>
              </c:choose>
            </c:forEach>

            <c:choose>
              <c:when test="${page < totalPages}">
                <a class="paging-btn" href="${ctx}/import-receipt-report?${qsBase}&page=${page + 1}">Next →</a>
              </c:when>
              <c:otherwise>
                <span class="paging-btn disabled">Next →</span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</div>
