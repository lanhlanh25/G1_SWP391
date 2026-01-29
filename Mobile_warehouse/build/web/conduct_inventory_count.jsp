<%-- 
    Document   : conduct_inventory_count
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
  .wrap{ padding:10px; background:#f4f4f4; font-family:Arial, Helvetica, sans-serif; }
  .topbar{ display:flex; gap:10px; align-items:center; }
  .btn{ padding:6px 14px; border:1px solid #333; background:#eee; text-decoration:none; color:#000; display:inline-block; cursor:pointer; }
  .title{ margin:0 0 0 10px; font-weight:800; }

  .box{ margin-top:10px; border:2px solid #3b5db7; background:#fff; padding:10px; }
  table{ width:100%; border-collapse:collapse; margin-top:10px; }
  th,td{ border:1px solid #333; padding:6px; font-size:12px; }
  th{ background:#ddd; }

  .st-enough{ color:#0a8a0a; font-weight:800; }
  .st-missing{ color:#d00000; font-weight:800; }
  .diff-input{ width:70px; padding:3px 6px; }

  /* Pagination kiểu ảnh */
  .paging { display:flex; justify-content:center; align-items:center; gap:8px; margin-top:12px; }
  .pg {
    display:inline-block; padding:6px 16px;
    border:2px solid #1d4f91; background:#eee; color:#000;
    text-decoration:none; font-weight:600;
  }
  .pg.active { background:#3a7bd5; color:#000; }
  .pg.disabled { pointer-events:none; opacity:0.5; }

  .pagerbar{ display:flex; align-items:center; justify-content:space-between; margin-top:12px; gap:10px; }
</style>

<div class="wrap">

  <div class="topbar">
    <!-- ✅ Back về HOME -->
    <a class="btn" href="${pageContext.request.contextPath}/home">Back</a>
    <h3 class="title">Conduct Inventory Count</h3>
  </div>

  <div class="box">
    <b>Search Criteria</b>

    <!-- SEARCH (GET) -->
    <form method="get" action="${pageContext.request.contextPath}/inventory-count" style="margin-top:8px;">
      <input type="text" name="q" value="${q}" placeholder="Product name, SKU,..."
             style="width:240px; height:28px; padding:0 8px;"/>

     

      <select name="brandId" style="height:30px; margin-left:12px; width:120px;">
        <option value="">All Brands</option>
        <c:forEach var="b" items="${brands}">
          <option value="${b.id}" ${b.id == brandId ? "selected" : ""}>${b.name}</option>
        </c:forEach>
      </select>

      <button class="btn" type="submit" style="margin-left:12px;">Search</button>
      <a class="btn" href="${pageContext.request.contextPath}/inventory-count">Reset</a>

      <input type="hidden" name="page" value="1"/>
      <input type="hidden" name="pageSize" value="${pageSize}"/>
    </form>

    <!-- SAVE (POST) -->
    <form method="post" action="${pageContext.request.contextPath}/inventory-count" style="margin-top:8px;">
      <input type="hidden" name="q" value="${q}"/>
      <input type="hidden" name="brandId" value="${brandId}"/>
      <input type="hidden" name="page" value="${pageNumber}"/>
      <input type="hidden" name="pageSize" value="${pageSize}"/>

      <div style="display:flex; justify-content:flex-end;">
        <button class="btn" type="submit">Save</button>
      </div>

      <table>
        <thead>
          <tr>
            <th style="width:160px;">SKU</th>
            <th>Product Name</th>
            <th style="width:120px;">Color</th>
            <th style="width:80px;">RAM</th>
            <th style="width:95px;">Storage</th>
            <th style="width:95px;">System Qty</th>
            <th style="width:100px;">Difference</th>
            <th style="width:90px;">Status</th>
            <th style="width:110px;">Action</th>
          </tr>
        </thead>

        <tbody>
          <c:forEach var="r" items="${rows}">
            <tr>
              <td>${r.skuCode}</td>
              <td>${r.productName}</td>
              <td>${r.color}</td>
              <td style="text-align:center;">${r.ramGb} GB</td>
              <td style="text-align:center;">${r.storageGb} GB</td>
              <td style="text-align:center;">${r.systemQty}</td>

              <td style="text-align:center;">
                <input type="hidden" name="skuId" value="${r.skuId}"/>
                <input class="diff-input" type="number" name="countedQty" min="0" value="${r.countedQty}"/>
              </td>

              <td style="text-align:center;">
                <c:choose>
                  <c:when test="${r.countedQty == r.systemQty}">
                    <span class="st-enough">enough</span>
                  </c:when>
                  <c:otherwise>
                    <span class="st-missing">missing</span>
                  </c:otherwise>
                </c:choose>
              </td>

              <td style="text-align:center;">
                <c:url var="imeiUrl" value="/imei-list">
                  <c:param name="skuId" value="${r.skuId}"/>
                  <c:param name="page" value="1"/>
                  <c:param name="pageSize" value="10"/>
                </c:url>
                <a href="${imeiUrl}" style="color:#0b39b8; text-decoration:underline;">View List IMEI</a>
              </td>
            </tr>
          </c:forEach>

          <c:if test="${empty rows}">
            <tr><td colspan="9" style="text-align:center;">No data</td></tr>
          </c:if>
        </tbody>
      </table>
    </form>

    <!-- ===== Pagination kiểu ảnh (an toàn: trang hiện tại là span) ===== -->
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
        <c:url var="prevUrl" value="/inventory-count">
          <c:param name="q" value="${q}"/>
          <c:param name="brandId" value="${brandId}"/>
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
              <c:url var="pageUrl" value="/inventory-count">
                <c:param name="q" value="${q}"/>
                <c:param name="brandId" value="${brandId}"/>
                <c:param name="pageSize" value="${pageSize}"/>
                <c:param name="page" value="${i}"/>
              </c:url>
              <a class="pg" href="${pageUrl}">${i}</a>
            </c:otherwise>
          </c:choose>
        </c:forEach>

        <c:url var="nextUrl" value="/inventory-count">
          <c:param name="q" value="${q}"/>
          <c:param name="brandId" value="${brandId}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="page" value="${pageNumber+1}"/>
        </c:url>
        <a class="pg ${pageNumber>=totalPages ? 'disabled' : ''}" href="${nextUrl}">Next</a>
      </div>

      <div>
        Show
        <select onchange="location.href='${pageContext.request.contextPath}/inventory-count?q=${q}&brandId=${brandId}&page=1&pageSize='+this.value;">
          <option value="10" ${pageSize==10 ? "selected" : ""}>10</option>
          <option value="20" ${pageSize==20 ? "selected" : ""}>20</option>
        </select>
        Row
      </div>
    </div>

  </div>
</div>
