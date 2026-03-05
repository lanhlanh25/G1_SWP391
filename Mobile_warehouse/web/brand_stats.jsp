<%-- 
    Document   : brand_stats
    Created on : Jan 29, 2026, 12:24:52 AM
    Author     : ADMIN
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="roleName" value="${sessionScope.roleName}" />

<c:url var="exportUrl" value="/manager/brand-stats-export">
  <c:param name="q" value="${q}" />
  <c:param name="status" value="${status}" />
  <c:param name="brandId" value="${brandId}" />
  <c:param name="sortBy" value="${sortBy}" />
  <c:param name="sortOrder" value="${sortOrder}" />
  <c:param name="range" value="${range}" />
</c:url>

<div class="container page-wrap brand-stats">
  <div class="topbar">
    <div>
      <div class="title">View Product Statistics By Brand</div>
      <div class="small">Summary and analytics by brand</div>
    </div>

    <div class="actions">
      <c:if test="${sessionScope.roleName != null && fn:toUpperCase(sessionScope.roleName) == 'MANAGER'}">
        <c:url var="exportPdfUrl" value="/manager/brand-stats-export-pdf">
          <c:param name="q" value="${q}"/>
          <c:param name="status" value="${status}"/>
          <c:param name="brandId" value="${brandId}"/>
          <c:param name="sortBy" value="${sortBy}"/>
          <c:param name="sortOrder" value="${sortOrder}"/>
          <c:param name="range" value="${range}"/>
        </c:url>
        <a class="btn btn-primary" href="${exportPdfUrl}">Export PDF</a>
      </c:if>
    </div>
  </div>

  <c:if test="${not empty param.msg}">
    <div class="msg-ok">${param.msg}</div>
  </c:if>
  <c:if test="${not empty param.err}">
    <div class="msg-err">${param.err}</div>
  </c:if>

  <!-- Summary cards -->
  <div class="cards">
    <div class="card stat-card">
      <div class="label">Total Brands</div>
      <div class="value">${summary.totalBrands}</div>
    </div>
    <div class="card stat-card">
      <div class="label">Total Products</div>
      <div class="value">${summary.totalProducts}</div>
    </div>
    <div class="card stat-card">
      <div class="label">Total Stock Units</div>
      <div class="value">${summary.totalStockUnits}</div>
    </div>
    <div class="card stat-card">
      <div class="label">Low Stock Products</div>
      <div class="value">${summary.lowStockProducts}</div>
    </div>
    <div class="card stat-card">
      <div class="label">Imported Units (Range)</div>
      <div class="value">${summary.importedUnitsInRange}</div>
    </div>
    <div class="card stat-card">
      <div class="label">Exported Units (Range)</div>
      <div class="value">${summary.exportedUnitsInRange}</div>
    </div>
  </div>

  <!-- Filter + Sort form -->
  <form method="get" action="${ctx}/home">
    <input type="hidden" name="p" value="brand-stats"/>

    <div class="filters">
      <div class="field">
        <label>Data Range</label>
        <select class="select" name="range">
          <option value="all" ${empty range || range=='all' ? 'selected' : ''}>All Time</option>
          <option value="today" ${range=='today' ? 'selected' : ''}>Today</option>
          <option value="last7" ${range=='last7' ? 'selected' : ''}>Last 7 Days</option>
          <option value="last30" ${range=='last30' ? 'selected' : ''}>Past 30 Days</option>
          <option value="last90" ${range=='last90' ? 'selected' : ''}>Past 90 Days (Quarter)</option>
          <option value="month" ${range=='month' ? 'selected' : ''}>This Month</option>
          <option value="lastMonth" ${range=='lastMonth' ? 'selected' : ''}>Last Month</option>
        </select>
        <div class="muted" style="margin-top:6px;">Range affects: Imported Units, Exported Units</div>
      </div>

      <div class="field">
        <label>Brand</label>
        <select class="select" name="brandId" id="brandIdSelect">
          <option value="" ${empty brandId ? 'selected' : ''}>All</option>
          <c:forEach items="${allBrands}" var="b">
            <option value="${b.brandId}" ${not empty brandId && brandId == (b.brandId) ? 'selected' : ''}>
              ${b.brandName}
            </option>
          </c:forEach>
        </select>
      </div>

      <div class="field">
        <label>Brand Status</label>
        <select class="select" name="status">
          <option value="" ${empty status ? 'selected' : ''}>All</option>
          <option value="active" ${status=='active' ? 'selected' : ''}>Active</option>
          <option value="inactive" ${status=='inactive' ? 'selected' : ''}>Inactive</option>
        </select>
      </div>

      <div class="field">
        <label>Search</label>
        <input class="input" type="text" name="q" id="searchInput" value="${q}" placeholder="brand name"/>
        <input type="hidden" name="q" id="qHidden" value="${q}" />
      </div>
    </div>

    <div class="sort-row">
      <div class="field">
        <label>Sort By</label>
        <select class="select" name="sortBy">
          <option value="stock"    ${sortBy=='stock' ? 'selected' : ''}>Total Stock</option>
          <option value="products" ${sortBy=='products' ? 'selected' : ''}>Total Product</option>
          <option value="low"      ${sortBy=='low' ? 'selected' : ''}>Low Stock</option>
          <option value="import"   ${sortBy=='import' ? 'selected' : ''}>Imported Units</option>
          <option value="export"   ${sortBy=='export' ? 'selected' : ''}>Exported Units</option>
          <option value="name"     ${sortBy=='name' ? 'selected' : ''}>Brand Name</option>
        </select>
      </div>

      <div class="field">
        <label>Order</label>
        <select class="select" name="sortOrder">
          <option value="DESC" ${sortOrder=='DESC' ? 'selected' : ''}>Descending (Z→A / High→Low)</option>
          <option value="ASC"  ${sortOrder=='ASC' ? 'selected' : ''}>Ascending (A→Z / Low→High)</option>
        </select>
      </div>

      <button class="btn btn-primary" type="submit">Apply</button>
      <a class="btn btn-outline" href="${ctx}/home?p=brand-stats">Reset</a>
    </div>
  </form>

  <!-- Applied summary (giữ nguyên logic của bạn) -->
  <c:set var="statusLabel"
         value="${status=='active' ? 'Active'
                  : status=='inactive' ? 'Inactive'
                  : 'All'}" />
  <c:set var="sortLabel"
         value="${sortBy=='name' ? 'Brand Name'
                  : sortBy=='products' ? 'Total Products'
                  : sortBy=='low' ? 'Low Stock Count'
                  : sortBy=='import' ? 'Imported Units'
                  : sortBy=='export' ? 'Exported Units'
                  : 'Total Stock'}" />
  <c:set var="orderLabel" value="${empty sortOrder ? 'DESC' : sortOrder}" />
  <c:set var="brandNameLabel" value="All" />
  <c:if test="${not empty brandId}">
    <c:set var="brandIdNum" value="${brandId}" />
    <c:forEach items="${allBrands}" var="bb">
      <c:if test="${bb.brandId == brandIdNum}">
        <c:set var="brandNameLabel" value="${bb.brandName}" />
      </c:if>
    </c:forEach>
  </c:if>

  <div class="muted" style="margin:6px 0 10px;">
    Applied:
    Range =
    <b>
      <c:choose>
        <c:when test="${empty range || range=='all'}">All Time</c:when>
        <c:when test="${range=='today'}">Today</c:when>
        <c:when test="${range=='last7'}">Last 7 Days</c:when>
        <c:when test="${range=='last30'}">Past 30 Days</c:when>
        <c:when test="${range=='last90'}">Past 90 Days (Quarter)</c:when>
        <c:when test="${range=='month'}">This Month</c:when>
        <c:when test="${range=='lastMonth'}">Last Month</c:when>
        <c:otherwise>All Time</c:otherwise>
      </c:choose>
    </b>
    • Brand = <b>${brandNameLabel}</b>
    • Status = <b>${statusLabel}</b>
    • Search = <b>${empty q ? '-' : q}</b>
    • Sort = <b>${sortLabel}</b> <b>${orderLabel}</b>
  </div>

  <!-- Result table -->
  <table class="table">
    <thead>
      <tr>
        <th style="width:60px;">#</th>
        <th>Brand Name</th>
        <th style="width:120px;">#Product<br/><span class="muted">(Number of products under this brand)</span></th>
        <th style="width:120px;">Total Stock</th>
        <th style="width:140px;">Low Stock Count</th>
        <th style="width:140px;">Imported Units</th>
        <th style="width:140px;">Exported Units</th>
        <th style="width:140px;">Action</th>
      </tr>
    </thead>

    <tbody>
      <c:forEach items="${rows}" var="r" varStatus="st">
        <tr>
          <td>${(page - 1) * pageSize + st.index + 1}</td>
          <td>
            ${r.brandName}
            <span class="badge ${r.active ? 'badge-active' : 'badge-inactive'}">
              ${r.active ? 'Active' : 'Inactive'}
            </span>
          </td>
          <td>${r.totalProducts}</td>
          <td>${r.totalStockUnits}</td>
          <td>${r.lowStockProducts}</td>
          <td>${r.importedUnits}</td>
          <td>${r.exportedUnits}</td>
          <td>
            <c:url var="detailUrl" value="/home">
              <c:param name="p" value="brand-stats-detail"/>
              <c:param name="brandId" value="${r.brandId}"/>
              <c:param name="listQ" value="${q}"/>
              <c:param name="listStatus" value="${status}"/>
              <c:param name="listBrandId" value="${brandId}"/>
              <c:param name="listSortBy" value="${sortBy}"/>
              <c:param name="listSortOrder" value="${sortOrder}"/>
              <c:param name="listRange" value="${range}"/>
              <c:param name="listPage" value="${page}"/>
            </c:url>
            <a class="btn btn-outline btn-sm" href="${detailUrl}">View Details</a>
          </td>
        </tr>
      </c:forEach>

      <c:if test="${empty rows}">
        <tr>
          <td colspan="8" style="text-align:center; color:#666;">No data</td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <!-- Paging -->
  <div class="paging">
    <c:choose>
      <c:when test="${page <= 1}">
        <span style="color:#999;">&laquo; Prev</span>
      </c:when>
      <c:otherwise>
        <c:url var="prevUrl" value="/home">
          <c:param name="p" value="brand-stats"/>
          <c:param name="page" value="${page-1}"/>
          <c:param name="q" value="${q}"/>
          <c:param name="status" value="${status}"/>
          <c:param name="brandId" value="${brandId}"/>
          <c:param name="sortBy" value="${sortBy}"/>
          <c:param name="sortOrder" value="${sortOrder}"/>
          <c:param name="range" value="${range}"/>
        </c:url>
        <a href="${prevUrl}">&laquo; Prev</a>
      </c:otherwise>
    </c:choose>

    <c:forEach begin="1" end="${totalPages}" var="i">
      <c:choose>
        <c:when test="${i == page}">
          <b>${i}</b>
        </c:when>
        <c:otherwise>
          <c:url var="pageUrl" value="/home">
            <c:param name="p" value="brand-stats"/>
            <c:param name="page" value="${i}"/>
            <c:param name="q" value="${q}"/>
            <c:param name="status" value="${status}"/>
            <c:param name="brandId" value="${brandId}"/>
            <c:param name="sortBy" value="${sortBy}"/>
            <c:param name="sortOrder" value="${sortOrder}"/>
            <c:param name="range" value="${range}"/>
          </c:url>
          <a href="${pageUrl}">${i}</a>
        </c:otherwise>
      </c:choose>
    </c:forEach>

    <c:choose>
      <c:when test="${page >= totalPages}">
        <span style="color:#999;">Next &raquo;</span>
      </c:when>
      <c:otherwise>
        <c:url var="nextUrl" value="/home">
          <c:param name="p" value="brand-stats"/>
          <c:param name="page" value="${page+1}"/>
          <c:param name="q" value="${q}"/>
          <c:param name="status" value="${status}"/>
          <c:param name="brandId" value="${brandId}"/>
          <c:param name="sortBy" value="${sortBy}"/>
          <c:param name="sortOrder" value="${sortOrder}"/>
          <c:param name="range" value="${range}"/>
        </c:url>
        <a href="${nextUrl}">Next &raquo;</a>
      </c:otherwise>
    </c:choose>
  </div>
</div>