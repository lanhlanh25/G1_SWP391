<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setTimeZone value="Asia/Ho_Chi_Minh"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap-md">

  <div class="topbar">
    <div class="d-flex align-center gap-12">
      <h1 class="h1">Export Request Detail</h1>
    </div>
    <div class="d-flex gap-8 align-center">
      <a class="btn btn-outline" href="${ctx}/home?p=export-request-list">← Back to List</a>
    </div>
  </div>

  <div class="card mb-16">
    <div class="card-body">
      <div class="h2 mb-16">Request Information</div>
      <table class="table no-border-first">
        <tbody>
          <tr>
            <th style="width:180px;">Request Code</th>
            <td class="fw-600">${erHeader.requestCode}</td>
          </tr>
          <tr>
            <th>Created By</th>
            <td class="text-muted fs-14">${erHeader.createdByName}</td>
          </tr>
          <tr>
            <th>Request Date</th>
            <td class="text-muted"><fmt:formatDate value="${erHeader.requestDate}" pattern="dd/MM/yyyy HH:mm"/></td>
          </tr>
          <tr>
            <th>Expected Export Date</th>
            <td class="fw-600 text-primary"><fmt:formatDate value="${erHeader.expectedExportDate}" pattern="dd/MM/yyyy"/></td>
          </tr>
          <tr>
            <th>Note</th>
            <td class="text-muted fs-14">
              <c:choose>
                <c:when test="${empty erHeader.note}">—</c:when>
                <c:otherwise>${erHeader.note}</c:otherwise>
              </c:choose>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <div class="card">
    <div class="card-body">
      <div class="h2 mb-16">Requested Items</div>
      <table class="table">
        <thead>
          <tr>
            <th style="width:60px;" class="text-center">#</th>
            <th style="width:150px;">Product Name</th>
            <th>SKU</th>
            <th style="width:140px;" class="text-center">Request Qty</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty erItems}">
            <tr><td colspan="4" class="small muted" style="padding:18px; text-align:center;">No items.</td></tr>
          </c:if>
          <c:forEach var="it" items="${erItems}">
            <tr>
              <td class="text-center text-muted fs-12">${it.no}</td>
              <td class="mono-text fs-12">${fn:escapeXml(it.productName)}</td>
              <td class="fw-600">
                <c:choose>
                  <c:when test="${empty it.skuCode}">-</c:when>
                  <c:otherwise>${fn:escapeXml(it.skuCode)}</c:otherwise>
                </c:choose>
              </td>
              <td class="text-center fw-700">${it.requestQty}</td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

</div>