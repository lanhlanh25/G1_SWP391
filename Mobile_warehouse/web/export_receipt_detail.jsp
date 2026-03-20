<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="role" value="${sessionScope.roleName}"/>

<div class="page-wrap-md">

  <div class="topbar">
    <div class="d-flex align-center gap-12">
      <h1 class="h1">Export Record Details</h1>
    </div>
    <div class="d-flex gap-8 align-center">
      <span class="badge badge-info uppercase fs-10 fw-600"><c:out value="${role}"/></span>
      <a class="btn btn-outline" href="${ctx}/home?p=export-receipt-list">← Back</a>
    </div>
  </div>

  <c:if test="${empty receiptHeader}">
    <div class="card"><div class="card-body small muted">No data (receipt not found).</div></div>
  </c:if>

  <c:if test="${not empty receiptHeader}">

    <div class="card mb-16">
      <div class="card-body">
        <div class="h2 mb-16">Receipt Information</div>
        <table class="table no-border-first">
          <tbody>
            <tr>
              <th style="width:180px;">Export Code</th>
              <td class="fw-600"><c:out value="${receiptHeader.exportCode}"/></td>
            </tr>
            <tr>
              <th>Transaction Time</th>
              <td class="text-muted"><c:out value="${receiptHeader.exportDateUi}"/></td>
            </tr>
            <tr>
              <th>Request Code</th>
              <td class="fw-600 text-primary">
                <c:choose>
                  <c:when test="${empty receiptHeader.requestCode}">
                    <span class="text-muted">—</span>
                  </c:when>
                  <c:otherwise><c:out value="${receiptHeader.requestCode}"/></c:otherwise>
                </c:choose>
              </td>
            </tr>
            <tr>
              <th>Note</th>
              <td class="text-muted fs-14">
                <c:choose>
                  <c:when test="${empty receiptHeader.note}">—</c:when>
                  <c:otherwise><c:out value="${receiptHeader.note}"/></c:otherwise>
                </c:choose>
              </td>
            </tr>
            <tr>
              <th>Status</th>
              <td>
                <span class="badge badge-active"><c:out value="${receiptHeader.status}"/></span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="h2 mb-16">Export Items</div>
        <table class="table">
          <thead>
            <tr>
              <th style="width:50px;" class="text-center">#</th>
              <th style="width:140px;">Code</th>
              <th>SKU</th>
              <th style="width:100px;" class="text-center">Qty</th>
              <th>IMEI Numbers</th>
              <th style="width:140px;">Note</th>
              <th style="width:120px;">Staff</th>
            </tr>
          </thead>
          <tbody>
            <c:if test="${empty lines}">
              <tr><td colspan="7" class="small muted" style="padding:20px;">No items</td></tr>
            </c:if>
            <c:forEach var="it" items="${lines}" varStatus="st">
              <tr>
                <td class="text-center text-muted fs-12"><c:out value="${st.index + 1}"/></td>
                <td class="mono-text fs-12"><c:out value="${it.productCode}"/></td>
                <td class="fw-600"><c:out value="${it.skuCode}"/></td>
                <td class="text-center fw-700"><c:out value="${it.qty}"/></td>
                <td class="fs-12">
                  <div class="d-flex flex-column gap-2">
                    <c:forEach var="im" items="${it.imeis}" varStatus="st2">
                      <span class="mono-text text-muted">#${st2.index + 1}: ${im}</span>
                    </c:forEach>
                  </div>
                </td>
                <td class="text-muted fs-12">
                  <c:choose>
                    <c:when test="${empty it.itemNote}">—</c:when>
                    <c:otherwise><c:out value="${it.itemNote}"/></c:otherwise>
                  </c:choose>
                </td>
                <td class="fs-12 text-muted"><c:out value="${it.createdByName}"/></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

  </c:if>
</div>
