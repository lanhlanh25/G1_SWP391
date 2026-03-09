<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setTimeZone value="Asia/Ho_Chi_Minh"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Export Request Detail</div>
    <a class="btn" href="${ctx}/home?p=export-request-list">← Back to List</a>
  </div>

  <div class="card" style="margin-bottom:14px;">
    <div class="card-header"><span class="h2">Request Info</span></div>
    <div class="card-body">
      <div class="info-grid">
        <span class="label">Request Code</span>
        <span>${erHeader.requestCode}</span>

        <span class="label">Created By</span>
        <span>${erHeader.createdByName}</span>

        <span class="label">Request Date</span>
        <span><fmt:formatDate value="${erHeader.requestDate}" pattern="yyyy-MM-dd HH:mm:ss"/></span>

        <span class="label">Expected Export Date</span>
        <span><fmt:formatDate value="${erHeader.expectedExportDate}" pattern="yyyy-MM-dd"/></span>
        
        <span class="label">Note</span>
        <span>${erHeader.note}</span>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-header"><span class="h2">Items</span></div>
    <div class="card-body" style="padding:0;">
      <table class="table">
        <thead>
          <tr>
            <th style="width:60px; text-align:center;">No</th>
            <th>Product Code</th>
            <th>SKU (option)</th>
            <th style="width:140px; text-align:center;">Request Qty</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty erItems}">
            <tr><td colspan="4" class="small muted" style="padding:18px; text-align:center;">No items.</td></tr>
          </c:if>
          <c:forEach var="it" items="${erItems}">
            <tr>
              <td style="text-align:center;">${it.no}</td>
              <td>${fn:escapeXml(it.productCode)}</td>
              <td>
                <c:choose>
                  <c:when test="${empty it.skuCode}">-</c:when>
                  <c:otherwise>${fn:escapeXml(it.skuCode)}</c:otherwise>
                </c:choose>
              </td>
              <td style="text-align:center;">${it.requestQty}</td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

</div>