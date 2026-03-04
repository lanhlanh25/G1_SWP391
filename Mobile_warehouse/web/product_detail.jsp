<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Product Detail</div>
    <a class="btn" href="${pageContext.request.contextPath}/home?p=product-list">← Back to List</a>
  </div>

  <c:if test="${product == null}">
    <div class="card">
      <div class="card-body"><p class="msg-err">Product not found.</p></div>
    </div>
  </c:if>

  <c:if test="${product != null}">

    <%-- Product info --%>
    <div class="card" style="margin-bottom:16px;">
      <div class="card-header"><span class="h2">Product Info</span></div>
      <div class="card-body">
        <div class="info-grid">
          <span class="label">Product Code</span>
          <span>${product.productCode}</span>

          <span class="label">Product Name</span>
          <span>${product.productName}</span>

          <span class="label">Brand</span>
          <span>${product.brandName}</span>

          <span class="label">Model</span>
          <span>${product.model}</span>

          <span class="label">Status</span>
          <span>
            <c:choose>
              <c:when test="${product.status == 'ACTIVE'}">
                <span class="badge badge-active">Active</span>
              </c:when>
              <c:otherwise>
                <span class="badge badge-inactive">Inactive</span>
              </c:otherwise>
            </c:choose>
          </span>

          <span class="label">Description</span>
          <span>${product.description}</span>
        </div>
      </div>
    </div>

    <%-- SKU list --%>
    <div class="card">
      <div class="card-header"><span class="h2">SKU List</span></div>
      <div class="card-body" style="padding:0;">
        <table class="table">
          <thead>
            <tr>
              <th>SKU Code</th>
              <th>Color</th>
              <th style="text-align:center; width:100px;">RAM (GB)</th>
              <th style="text-align:center; width:120px;">Storage (GB)</th>
              <th style="width:140px;">Price</th>
              <th style="width:110px;">Status</th>
            </tr>
          </thead>
          <tbody>
            <c:if test="${empty skuList}">
              <tr><td colspan="6" class="small muted" style="padding:20px; text-align:center;">No SKU found</td></tr>
            </c:if>
            <c:forEach items="${skuList}" var="s">
              <tr>
                <td>${s.skuCode}</td>
                <td>${s.color}</td>
                <td style="text-align:center;">${s.ramGb}</td>
                <td style="text-align:center;">${s.storageGb}</td>
                <td>${s.price}</td>
                <td>
                  <c:choose>
                    <c:when test="${s.status == 'ACTIVE'}">
                      <span class="badge badge-active">Active</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge badge-inactive">Inactive</span>
                    </c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

  </c:if>
</div>
