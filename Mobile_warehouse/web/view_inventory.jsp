<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<div class="page-wrap">

  <div class="topbar">
    <div style="display:flex; align-items:center; gap:10px;">
      <a class="btn" href="${pageContext.request.contextPath}/home?p=dashboard">← Back</a>
      <h1 class="h1" style="margin:0;">Inventory Management</h1>
    </div>
  </div>

  <c:if test="${not empty param.msg}"><p class="msg-ok">${fn:escapeXml(param.msg)}</p></c:if>
  <c:if test="${not empty param.err}"><p class="msg-err">${fn:escapeXml(param.err)}</p></c:if>

  <%-- Summary cards --%>
  <div class="stat-cards" style="margin-bottom:14px;">
    <div class="card stat-card-item">
      <div class="small muted">Total Products</div>
      <div class="stat-value">${totalProducts}</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">Total Quantity</div>
      <div class="stat-value">${totalQty}</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">Low Stock Items
       
      </div>
      <div class="stat-value">${lowStockItems}</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">Out of Stock Items</div>
      <div class="stat-value">${outOfStockItems}</div>
    </div>
  </div>

  <%-- Filter --%>
  <div class="card" style="margin-bottom:14px;">
    <div class="card-body">
      <form method="get" action="${pageContext.request.contextPath}/inventory">
        <input type="hidden" name="page"     value="1"/>
        <input type="hidden" name="pageSize" value="${pageSize}"/>
        <div class="filters" style="grid-template-columns: 2fr 1fr 1fr auto auto;">
          <div>
            <label class="label">Search</label>
            <input class="input" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Product name, SKU..."/>
          </div>
          <div>
            <label class="label">Brand</label>
            <select class="select" name="brandId">
              <option value="">All Brands</option>
              <c:forEach var="b" items="${brands}">
                <option value="${b.id}" <c:if test="${b.id == brandId}">selected</c:if>>${fn:escapeXml(b.name)}</option>
              </c:forEach>
            </select>
          </div>
          <div>
            <label class="label">Stock Status</label>
            <select class="select" name="stockStatus">
              <option value=""   <c:if test="${empty stockStatus}">selected</c:if>>All Status</option>
              <option value="OK"  <c:if test="${stockStatus=='OK'}">selected</c:if>>In Stock</option>
              <option value="LOW" <c:if test="${stockStatus=='LOW'}">selected</c:if>>Low Stock</option>
              <option value="OUT" <c:if test="${stockStatus=='OUT'}">selected</c:if>>Out of Stock</option>
            </select>
          </div>
          <div style="display:flex; align-items:flex-end;">
            <button class="btn btn-primary btn-sm btn-equal" type="submit" >Search</button>
          </div>
          <div style="display:flex; align-items:flex-end;">
            <a class="btn btn-outline btn-sm btn-equal" href="${pageContext.request.contextPath}/inventory" >Reset</a>
          </div>
        </div>
      </form>
    </div>
  </div>

  <%-- Table --%>
  <div class="card">
    <div class="card-body" style="padding:0;">
      <table class="table">
        <thead>
          <tr>
            <th style="width:150px;">Product Code</th>
            <th>Product Name</th>
            <th style="width:120px;">Brand</th>
            <th style="width:90px; text-align:center;">Quantity</th>
            <th style="width:160px;">Stock Status</th>
            <th style="width:130px; text-align:center;">Last Updated</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="it" items="${inventoryModels}">
            <tr>
              <td style="text-align:left;">${fn:escapeXml(it.productCode)}</td>
              <td>
                <c:url var="detailUrl" value="/inventory-details">
                  <c:param name="productCode" value="${it.productCode}"/>
                  <c:param name="q"           value="${q}"/>
                  <c:param name="brandId"     value="${brandId}"/>
                  <c:param name="stockStatus" value="${stockStatus}"/>
                  <c:param name="page"        value="${pageNumber}"/>
                  <c:param name="pageSize"    value="${pageSize}"/>
                </c:url>
                <a href="${detailUrl}" style="color:var(--primary); text-decoration:underline;">
                  ${fn:escapeXml(it.productName)}
                </a>
              </td>
              <td>${fn:escapeXml(it.brandName)}</td>
              <td class="center">${it.totalQty} Phone</td>

              <%-- Badge dựa theo ROP formula --%>
              <td class="center">
                <c:set var="st" value="${it.status}"/>
                <c:choose>
                  <c:when test="${st == 'OK'}">
                    <span class="badge badge-active">In Stock</span>
                  </c:when>
                  <c:when test="${st == 'LOW'}">
                    <span class="badge badge-warning"
                          title="Stock ≤ ROP: reorder recommended">Low Stock</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-inactive">Out of Stock</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td style="text-align:center;">${fn:escapeXml(it.lastUpdated)}</td>
            </tr>
          </c:forEach>
          <c:if test="${empty inventoryModels}">
            <tr><td colspan="6" class="small muted" style="padding:20px; text-align:center;">No data</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
<%-- Pagination --%>
<c:if test="${totalPages > 1}">
  <div style="display:flex; justify-content:space-between; align-items:center; margin-top:14px; flex-wrap:wrap; gap:8px;">
    
    <%-- Page info --%>
    <div class="small muted">
      Showing ${(pageNumber - 1) * pageSize + 1}–${pageNumber * pageSize > totalItems ? totalItems : pageNumber * pageSize}
      of ${totalItems} items
    </div>

    <%-- Page buttons --%>
    <div style="display:flex; gap:4px; flex-wrap:wrap;">

      <%-- Previous --%>
      <c:choose>
        <c:when test="${pageNumber <= 1}">
          <button class="btn btn-outline btn-sm" disabled>‹ Prev</button>
        </c:when>
        <c:otherwise>
          <c:url var="prevUrl" value="/inventory">
            <c:param name="q"           value="${q}"/>
            <c:param name="brandId"     value="${brandId}"/>
            <c:param name="stockStatus" value="${stockStatus}"/>
            <c:param name="page"        value="${pageNumber - 1}"/>
            <c:param name="pageSize"    value="${pageSize}"/>
          </c:url>
          <a class="btn btn-outline btn-sm" href="${prevUrl}">‹ Prev</a>
        </c:otherwise>
      </c:choose>

      <%-- Page numbers (show up to 5 around current) --%>
      <c:set var="startPage" value="${pageNumber - 2 > 1 ? pageNumber - 2 : 1}"/>
      <c:set var="endPage"   value="${pageNumber + 2 < totalPages ? pageNumber + 2 : totalPages}"/>

      <c:if test="${startPage > 1}">
        <c:url var="p1Url" value="/inventory">
          <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/>
          <c:param name="stockStatus" value="${stockStatus}"/><c:param name="page" value="1"/>
          <c:param name="pageSize" value="${pageSize}"/>
        </c:url>
        <a class="btn btn-outline btn-sm" href="${p1Url}">1</a>
        <c:if test="${startPage > 2}"><span style="align-self:center; padding:0 4px;">…</span></c:if>
      </c:if>

      <c:forEach var="i" begin="${startPage}" end="${endPage}">
        <c:url var="pageUrl" value="/inventory">
          <c:param name="q"           value="${q}"/>
          <c:param name="brandId"     value="${brandId}"/>
          <c:param name="stockStatus" value="${stockStatus}"/>
          <c:param name="page"        value="${i}"/>
          <c:param name="pageSize"    value="${pageSize}"/>
        </c:url>
        <c:choose>
          <c:when test="${i == pageNumber}">
            <button class="btn btn-primary btn-sm" disabled>${i}</button>
          </c:when>
          <c:otherwise>
            <a class="btn btn-outline btn-sm" href="${pageUrl}">${i}</a>
          </c:otherwise>
        </c:choose>
      </c:forEach>

      <c:if test="${endPage < totalPages}">
        <c:if test="${endPage < totalPages - 1}"><span style="align-self:center; padding:0 4px;">…</span></c:if>
        <c:url var="lastUrl" value="/inventory">
          <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/>
          <c:param name="stockStatus" value="${stockStatus}"/><c:param name="page" value="${totalPages}"/>
          <c:param name="pageSize" value="${pageSize}"/>
        </c:url>
        <a class="btn btn-outline btn-sm" href="${lastUrl}">${totalPages}</a>
      </c:if>

      <%-- Next --%>
      <c:choose>
        <c:when test="${pageNumber >= totalPages}">
          <button class="btn btn-outline btn-sm" disabled>Next ›</button>
        </c:when>
        <c:otherwise>
          <c:url var="nextUrl" value="/inventory">
            <c:param name="q"           value="${q}"/>
            <c:param name="brandId"     value="${brandId}"/>
            <c:param name="stockStatus" value="${stockStatus}"/>
            <c:param name="page"        value="${pageNumber + 1}"/>
            <c:param name="pageSize"    value="${pageSize}"/>
          </c:url>
          <a class="btn btn-outline btn-sm" href="${nextUrl}">Next ›</a>
        </c:otherwise>
      </c:choose>

    </div>

    <%-- Page size selector --%>
    <form method="get" action="${pageContext.request.contextPath}/inventory" style="display:flex; align-items:center; gap:6px;">
      <input type="hidden" name="q"           value="${fn:escapeXml(q)}"/>
      <input type="hidden" name="brandId"     value="${brandId}"/>
      <input type="hidden" name="stockStatus" value="${stockStatus}"/>
      <input type="hidden" name="page"        value="1"/>
      <span class="small muted">Rows:</span>
      <select class="select" name="pageSize" onchange="this.form.submit()" style="width:70px;">
        <option value="10"  <c:if test="${pageSize==10}">selected</c:if>>10</option>
        <option value="20"  <c:if test="${pageSize==20}">selected</c:if>>20</option>
        <option value="50"  <c:if test="${pageSize==50}">selected</c:if>>50</option>
      </select>
    </form>

  </div>
</c:if>
</div>
