<%-- 
    Document   : export_receipt_report
    Created on : Mar 6, 2026, 1:09:56 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- No internal styles needed here anymore --%>

<div class="page-wrap">
  <div class="topbar">
    <div class="d-flex align-center gap-12">
      <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
      <h1 class="h1">Export Receipt Report</h1>
    </div>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err">${fn:escapeXml(err)}</div>
  </c:if>

  <!-- Filters -->
  <form method="get" action="${ctx}/export-receipt-report" class="filters mb-20">
    <div class="filter-group">
      <label>From</label>
      <input class="input" type="date" name="from" value="${from}" />
    </div>
    <div class="filter-group">
      <label>To</label>
      <input class="input" type="date" name="to" value="${to}" />
    </div>
    <div class="filter-actions h-38">
      <button class="btn btn-primary" type="submit">Apply</button>
    </div>
  </form>

  <!-- Stats -->
  <div class="grid-2 mb-20">
    <div class="card mb-0">
      <div class="card-body p-20">
        <div class="muted mb-4">Total Export Receipts</div>
        <div class="h1 fw-800 text-primary">
          <c:out value="${reportSummary.totalExportReceipts}" default="0"/>
        </div>
      </div>
    </div>

    <div class="card mb-0 bg-primary-light">
      <div class="card-body p-20">
        <div class="text-primary fw-600 mb-4">Total Phone Quantity</div>
        <div class="h1 fw-800 text-primary">
          <c:out value="${reportSummary.totalPhoneQuantity}" default="0"/> 
          <span class="small fw-600 opacity-75">Phones</span>
        </div>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-body">
      <div class="h2 mb-16">Export History</div>
      
      <table class="table">
        <thead>
          <tr>
            <th>Receipt Code</th>
            <th>Created Date</th>
            <th>Created By</th>
            <th style="text-align:center;">Total Quantity</th>
            <th style="width:120px;">Status</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty rows}">
              <tr>
                <td colspan="5" style="text-align:center; padding:32px; color:var(--muted);">
                  No export receipts found
                </td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="r" items="${rows}">
                <tr>
                  <td style="font-weight:600;"><c:out value="${r.exportCode}"/></td>
                  <td style="color:var(--muted);"><c:out value="${r.exportDateUi}"/></td>
                  <td><c:out value="${r.createdByName}"/></td>
                  <td style="font-weight:700; text-align:center;"><c:out value="${r.totalQuantity}"/> Phone</td>
                  <td><span class="badge badge-active"><c:out value="${r.status}"/></span></td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>

      <c:if test="${totalPages > 1}">
        <div class="paging-footer mt-20 justify-end">
          <div class="paging">
            <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}" />

            <c:choose>
              <c:when test="${page > 1}">
                <a class="paging-btn" href="${ctx}/export-receipt-report?${qsBase}&page=${page-1}">← Prev</a>
              </c:when>
              <c:otherwise>
                <span class="paging-btn disabled">← Prev</span>
              </c:otherwise>
            </c:choose>

            <c:forEach var="p" begin="1" end="${totalPages}">
              <c:choose>
                <c:when test="${p == page}">
                  <span class="paging-btn active">${p}</span>
                </c:when>
                <c:otherwise>
                  <a class="paging-btn" href="${ctx}/export-receipt-report?${qsBase}&page=${p}">${p}</a>
                </c:otherwise>
              </c:choose>
            </c:forEach>

            <c:choose>
              <c:when test="${page < totalPages}">
                <a class="paging-btn" href="${ctx}/export-receipt-report?${qsBase}&page=${page+1}">Next →</a>
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