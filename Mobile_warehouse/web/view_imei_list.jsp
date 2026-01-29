<%-- 
    Document   : view_imei_list
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
  .wrap{ padding:10px; background:#f4f4f4; font-family:Arial, Helvetica, sans-serif; }
  .topbar{ display:flex; gap:10px; align-items:center; }
  .btn{ padding:6px 14px; border:1px solid #333; background:#eee; text-decoration:none; color:#000; display:inline-block; }
  .title{ margin:0 0 0 10px; font-weight:700; }

  .cards{ margin-top:10px; display:flex; gap:12px; flex-wrap:wrap; }
  .card{ width:120px; height:55px; background:#3a7bd5; border:2px solid #1d4f91; padding:6px 8px; font-size:12px; }
  .card .v{ font-weight:800; font-size:14px; margin-top:4px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }

  .box{ margin-top:10px; border:2px solid #3b5db7; background:#fff; padding:10px; }
  table{ width:100%; border-collapse:collapse; margin-top:10px; }
  th,td{ border:1px solid #333; padding:6px; font-size:12px; }
  th{ background:#ddd; }

  .st-active{ color:#0a8a0a; font-weight:700; }
  .st-inactive{ color:#d00000; font-weight:700; }

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
    <a class="btn" href="${pageContext.request.contextPath}/inventory-count">Back</a>
    <a class="btn" href="${pageContext.request.contextPath}/home">Home</a>
    <h3 class="title">View Imei List</h3>
  </div>

  <div class="cards">
    <div class="card"><div>SKU</div><div class="v">${skuCode}</div></div>
    <div class="card"><div>Product Code</div><div class="v">${productCode}</div></div>
    <div class="card" style="width:170px;"><div>Product model</div><div class="v">${productModel}</div></div>
    <div class="card"><div>Color</div><div class="v">${color}</div></div>
    <div class="card"><div>Ram</div><div class="v">${ramGb} GB</div></div>
    <div class="card"><div>Storage</div><div class="v">${storageGb} GB</div></div>
  </div>

  <div class="box">
    <b>Search Imei</b>

    <form method="get" action="${pageContext.request.contextPath}/imei-list" style="margin-top:8px;">
      <input type="hidden" name="skuId" value="${skuId}"/>

      <input type="text" name="q" value="${q}" placeholder="Imei,...."
             style="width:240px; height:28px; padding:0 8px;"/>

      <select name="status" style="height:30px; margin-left:14px;">
        <option value="" ${empty status ? "selected" : ""}>Status</option>
        <option value="ACTIVE" ${status=="ACTIVE" ? "selected" : ""}>Active</option>
        <option value="INACTIVE" ${status=="INACTIVE" ? "selected" : ""}>Inactive</option>
      </select>

      <button class="btn" type="submit" style="margin-left:12px;">Search</button>
      <a class="btn" href="${pageContext.request.contextPath}/imei-list?skuId=${skuId}">Reset</a>

      <input type="hidden" name="page" value="1"/>
      <input type="hidden" name="pageSize" value="${pageSize}"/>
    </form>

    <table>
      <thead>
        <tr>
          <th style="width:60%;">Imei</th>
          <th>Status</th>
        </tr>
      </thead>

      <tbody>
        <c:forEach var="r" items="${imeiRows}">
          <tr>
            <td style="text-align:center;">${r.imei}</td>
            <td style="text-align:center;">
              <c:choose>
                <c:when test="${r.status == 'ACTIVE'}"><span class="st-active">Active</span></c:when>
                <c:when test="${r.status == 'INACTIVE'}"><span class="st-inactive">Inactive</span></c:when>
                <c:otherwise><span>${r.status}</span></c:otherwise>
              </c:choose>
            </td>
          </tr>
        </c:forEach>

        <c:if test="${empty imeiRows}">
          <tr><td colspan="2" style="text-align:center;">No data</td></tr>
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
        <c:url var="prevUrl" value="/imei-list">
          <c:param name="skuId" value="${skuId}"/>
          <c:param name="q" value="${q}"/>
          <c:param name="status" value="${status}"/>
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
              <c:url var="pageUrl" value="/imei-list">
                <c:param name="skuId" value="${skuId}"/>
                <c:param name="q" value="${q}"/>
                <c:param name="status" value="${status}"/>
                <c:param name="pageSize" value="${pageSize}"/>
                <c:param name="page" value="${i}"/>
              </c:url>
              <a class="pg" href="${pageUrl}">${i}</a>
            </c:otherwise>
          </c:choose>
        </c:forEach>

        <c:url var="nextUrl" value="/imei-list">
          <c:param name="skuId" value="${skuId}"/>
          <c:param name="q" value="${q}"/>
          <c:param name="status" value="${status}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="page" value="${pageNumber+1}"/>
        </c:url>
        <a class="pg ${pageNumber>=totalPages ? 'disabled' : ''}" href="${nextUrl}">Next</a>
      </div>

      <div>
        Show
        <select onchange="location.href='${pageContext.request.contextPath}/imei-list?skuId=${skuId}&q=${q}&status=${status}&page=1&pageSize='+this.value;">
          <option value="10" ${pageSize==10 ? "selected" : ""}>10 Row</option>
          <option value="20" ${pageSize==20 ? "selected" : ""}>20 Row</option>
        </select>
      </div>
    </div>

  </div>
</div>
