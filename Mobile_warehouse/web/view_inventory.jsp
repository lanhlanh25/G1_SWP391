<%-- 
    Document   : view_inventory
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
  .inv-wrap { padding: 10px; background: #f4f4f4; font-family: Arial, Helvetica, sans-serif; }
  .inv-top { display:flex; gap:12px; align-items:center; }
  .btn { padding:6px 12px; border:1px solid #333; background:#eee; cursor:pointer; text-decoration:none; color:#000; display:inline-block; }
  .cards { display:flex; gap:14px; flex-wrap:wrap; margin-top:10px; }
  .card {
      width: 165px; height: 55px; background:#3a7bd5; color:#000;
      border:2px solid #1d4f91; padding:6px 10px; font-size:12px;
  }
  .card .v { font-weight:bold; font-size:16px; margin-top:2px; }
  .box { margin-top:10px; border:2px solid #3b5db7; background:#fff; padding:10px; }

  table { width:100%; border-collapse:collapse; margin-top:10px; }
  th, td { border:1px solid #333; padding:6px; font-size:12px; }
  th { background:#ddd; }

  .status-ok { background:#00ff4c; border:1px solid #333; padding:2px 8px; display:inline-block; }
  .status-low { background:#ffd400; border:1px solid #333; padding:2px 8px; display:inline-block; }
  .status-out { background:#ff3b30; border:1px solid #333; padding:2px 8px; display:inline-block; }

  .paging { display:flex; justify-content:center; align-items:center; gap:8px; }
  .pg {
    display:inline-block; padding:6px 16px;
    border:2px solid #1d4f91; background:#eee; color:#000;
    text-decoration:none; font-weight:600;
  }
  .pg.active { background:#3a7bd5; color:#000; }
  .pg.disabled { pointer-events:none; opacity:0.5; }

  .pagerbar{ display:flex; align-items:center; justify-content:space-between; margin-top:12px; gap:10px; }
  .showrow select{ height:28px; }
</style>

<div class="inv-wrap">

  <div class="inv-top">
    <!-- ✅ Back về HOME -->
    <a class="btn" href="${pageContext.request.contextPath}/home">Back</a>
    <h3 style="margin:0;">Inventory Management</h3>
  </div>

  <div class="cards">
    <div class="card"><div>Total Products</div><div class="v">${totalProducts}</div></div>
    <div class="card"><div>Total Quantity</div><div class="v">${totalQty}</div></div>
    <div class="card"><div>Low Stock Items</div><div class="v">${lowStockItems}</div></div>
    <div class="card"><div>Out of Stock Items</div><div class="v">${outOfStockItems}</div></div>
  </div>

  <div class="box">
    <b>Search Criteria</b>

    <form method="get" action="${pageContext.request.contextPath}/inventory" style="margin-top:8px;">
      <input type="text" name="q" value="${q}" placeholder="Product name, SKU,..." style="width:260px; height:28px; padding:0 8px;"/>

      <select name="brandId" style="width:140px; margin-left:12px; height:30px;">
        <option value="">All Brands</option>
        <c:forEach var="b" items="${brands}">
          <option value="${b.id}" ${b.id == brandId ? "selected" : ""}>${b.name}</option>
        </c:forEach>
      </select>

      <select name="stockStatus" style="width:120px; margin-left:12px; height:30px;">
        <option value="" ${empty stockStatus ? "selected" : ""}>Stock Status</option>
        <option value="OK"  ${stockStatus=="OK" ? "selected" : ""}>OK</option>
        <option value="LOW" ${stockStatus=="LOW" ? "selected" : ""}>Low Stock</option>
        <option value="OUT" ${stockStatus=="OUT" ? "selected" : ""}>Out Of Stock</option>
      </select>

      <button class="btn" type="submit" style="margin-left:10px;">Search</button>
      <a class="btn" href="${pageContext.request.contextPath}/inventory">Reset</a>

      <input type="hidden" name="page" value="1"/>
      <input type="hidden" name="pageSize" value="${pageSize}"/>
    </form>

    <table>
      <thead>
        <tr>
          <th style="width:110px;">Product Code</th>
          <th>Product Name</th>
          <th style="width:120px;">Brand</th>
          <th style="width:90px;">Quantity</th>
          <th style="width:120px;">Status</th>
          <th style="width:120px;">Last Updated</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="it" items="${inventoryModels}">
          <tr>
            <td style="text-align:center;">${it.productCode}</td>

            <td>
              <c:url var="updUrl" value="/inventory-update">
                <c:param name="productCode" value="${it.productCode}"/>
                <c:param name="page" value="1"/>
                <c:param name="pageSize" value="10"/>
              </c:url>
              <a href="${updUrl}" style="color:#0b39b8; text-decoration:underline;">
                ${it.productName}
              </a>
            </td>

            <td>${it.brandName}</td>
            <td style="text-align:center;">${it.totalQty}</td>
            <td style="text-align:center;">
              <c:choose>
                <c:when test="${it.status == 'OK'}"><span class="status-ok">OK</span></c:when>
                <c:when test="${it.status == 'LOW'}"><span class="status-low">Low Stock</span></c:when>
                <c:otherwise><span class="status-out">Out Of Stock</span></c:otherwise>
              </c:choose>
            </td>
            <td style="text-align:center;">${it.lastUpdated}</td>
          </tr>
        </c:forEach>

        <c:if test="${empty inventoryModels}">
          <tr><td colspan="6" style="text-align:center;">No data</td></tr>
        </c:if>
      </tbody>
    </table>

    <c:choose>
      <c:when test="${totalPages <= 3}">
        <c:set var="startPage" value="1"/>
        <c:set var="endPage" value="${totalPages}"/>
      </c:when>
      <c:when test="${pageNumber <= 1}">
        <c:set var="startPage" value="1"/>
        <c:set var="endPage" value="3"/>
      </c:when>
      <c:when test="${pageNumber >= totalPages}">
        <c:set var="startPage" value="${totalPages-2}"/>
        <c:set var="endPage" value="${totalPages}"/>
      </c:when>
      <c:otherwise>
        <c:set var="startPage" value="${pageNumber-1}"/>
        <c:set var="endPage" value="${pageNumber+1}"/>
      </c:otherwise>
    </c:choose>

    <div class="pagerbar">
      <div>Page ${pageNumber}</div>

      <div class="paging">
        <c:url var="prevUrl" value="/inventory">
          <c:param name="q" value="${q}"/>
          <c:param name="brandId" value="${brandId}"/>
          <c:param name="stockStatus" value="${stockStatus}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="page" value="${pageNumber-1}"/>
        </c:url>
        <a class="pg ${pageNumber<=1 ? 'disabled' : ''}" href="${prevUrl}">Prev</a>

        <c:forEach var="i" begin="${startPage}" end="${endPage}">
          <c:choose>
            <c:when test="${i == pageNumber}">
              <span class="pg active">${i}</span>
            </c:when>
            <c:otherwise>
              <c:url var="pageUrl" value="/inventory">
                <c:param name="q" value="${q}"/>
                <c:param name="brandId" value="${brandId}"/>
                <c:param name="stockStatus" value="${stockStatus}"/>
                <c:param name="pageSize" value="${pageSize}"/>
                <c:param name="page" value="${i}"/>
              </c:url>
              <a class="pg" href="${pageUrl}">${i}</a>
            </c:otherwise>
          </c:choose>
        </c:forEach>

        <c:url var="nextUrl" value="/inventory">
          <c:param name="q" value="${q}"/>
          <c:param name="brandId" value="${brandId}"/>
          <c:param name="stockStatus" value="${stockStatus}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="page" value="${pageNumber+1}"/>
        </c:url>
        <a class="pg ${pageNumber>=totalPages ? 'disabled' : ''}" href="${nextUrl}">Next</a>
      </div>

      <div class="showrow">
        Show
        <select onchange="location.href='${pageContext.request.contextPath}/inventory?q=${q}&brandId=${brandId}&stockStatus=${stockStatus}&page=1&pageSize='+this.value;">
          <option value="5"  ${pageSize==5 ? "selected" : ""}>5</option>
          <option value="10" ${pageSize==10 ? "selected" : ""}>10</option>
          <option value="20" ${pageSize==20 ? "selected" : ""}>20</option>
        </select>
        Row
      </div>
    </div>

  </div>
</div>
