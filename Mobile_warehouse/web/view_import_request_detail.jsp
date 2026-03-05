<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Import Request Detail</div>
    <a class="btn" href="${ctx}/home?p=import-request-list">← Back to List</a>
  </div>

  <div class="card" style="margin-bottom:14px;">
    <div class="card-header"><span class="h2">Request Info</span></div>
    <div class="card-body">
      <div class="info-grid">
        <span class="label">Request Code</span>
        <span><c:out value="${irHeader.requestCode}"/></span>

        <span class="label">Created By</span>
        <span><c:out value="${irHeader.createdByName}"/></span>

        <span class="label">Request Date</span>
        <span><fmt:formatDate value="${irHeader.requestDate}" pattern="yyyy-MM-dd HH:mm:ss"/></span>

        <span class="label">Expected Import Date</span>
        <span><fmt:formatDate value="${irHeader.expectedImportDate}" pattern="yyyy-MM-dd"/></span>

        <span class="label">Status</span>
        <span><c:out value="${irHeader.status}"/></span>
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
            <th>SKU</th>
            <th style="width:140px; text-align:center;">Request Qty</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty irItems}">
            <tr><td colspan="4" class="small muted" style="padding:18px; text-align:center;">No items.</td></tr>
          </c:if>
          <c:forEach var="it" items="${irItems}">
            <tr>
              <td style="text-align:center;">${it.no}</td>
              <td>${fn:escapeXml(it.productCode)}</td>
              <td>${fn:escapeXml(it.skuCode)}</td>
              <td style="text-align:center;">${it.requestQty}</td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

</div>