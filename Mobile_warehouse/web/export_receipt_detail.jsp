<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="role" value="${sessionScope.roleName}"/>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Export Receipt Detail</div>
    <div style="display:flex; gap:8px; align-items:center;">
      <span class="badge badge-info"><c:out value="${role}"/></span>
      <a class="btn" href="${ctx}/home?p=export-receipt-list">← Back</a>
    </div>
  </div>

  <c:if test="${empty receiptHeader}">
    <div class="card"><div class="card-body small muted">No data (receipt not found).</div></div>
  </c:if>

  <c:if test="${not empty receiptHeader}">

    <div class="card" style="margin-bottom:16px;">
      <div class="card-header"><span class="h2">Receipt Info</span></div>
      <div class="card-body">
        <div class="info-grid">
          <span class="label">Export Code</span>
          <span><c:out value="${receiptHeader.exportCode}"/></span>

          <span class="label">Transaction time</span>
          <span><c:out value="${receiptHeader.exportDateUi}"/></span>

          <span class="label">Request Code</span>
          <span>
            <c:choose>
              <c:when test="${empty receiptHeader.requestCode}">
                <span class="muted">N/A</span>
              </c:when>
              <c:otherwise><c:out value="${receiptHeader.requestCode}"/></c:otherwise>
            </c:choose>
          </span>

          <span class="label">Note</span>
          <span>
            <c:choose>
              <c:when test="${empty receiptHeader.note}"><span class="muted">-</span></c:when>
              <c:otherwise><c:out value="${receiptHeader.note}"/></c:otherwise>
            </c:choose>
          </span>

          <span class="label">Status</span>
          <span><c:out value="${receiptHeader.status}"/></span>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header"><span class="h2">Export Items</span></div>
      <div class="card-body" style="padding:0;">
        <table class="table">
          <thead>
            <tr>
              <th style="width:50px; text-align:center;">#</th>
              <th>Product Code</th>
              <th>SKU</th>
              <th style="width:120px;">Quantity</th>
              <th>IMEI Numbers</th>
              <th>Item Note</th>
              <th>Created By</th>
            </tr>
          </thead>
          <tbody>
            <c:if test="${empty lines}">
              <tr><td colspan="7" class="small muted" style="padding:20px;">No items</td></tr>
            </c:if>
            <c:forEach var="it" items="${lines}" varStatus="st">
              <tr>
                <td style="text-align:center;"><c:out value="${st.index + 1}"/></td>
                <td><c:out value="${it.productCode}"/></td>
                <td><c:out value="${it.skuCode}"/></td>
                <td><c:out value="${it.qty}"/></td>
                <td>
                  <div style="white-space:pre-line; line-height:1.5;">
                    <c:forEach var="im" items="${it.imeis}" varStatus="st2">
                      IMEI <c:out value="${st2.index + 1}"/>: <c:out value="${im}"/><c:if test="${!st2.last}">&#10;</c:if>
                    </c:forEach>
                  </div>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${empty it.itemNote}"><span class="muted">-</span></c:when>
                    <c:otherwise><c:out value="${it.itemNote}"/></c:otherwise>
                  </c:choose>
                </td>
                <td><c:out value="${it.createdByName}"/></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

  </c:if>
</div>
