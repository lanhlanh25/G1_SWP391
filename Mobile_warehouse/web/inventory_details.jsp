<%-- 
    Document   : inventory_details
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
  :root{
    --blue:#3a7bd5;
    --blue2:#1d4f91;
    --line:#2e3f95;
    --bg:#f4f4f4;
    --th:#d9d9d9;
  }

  .wrap { padding:10px; background:var(--bg); font-family:Arial, Helvetica, sans-serif; }

  .frame{
    border:2px solid var(--line);
    background:#fff;
    padding:10px;
  }

  .topbar { display:flex; gap:10px; align-items:center; margin-bottom:6px; }
  .btn {
    padding:6px 14px; border:1px solid #333; background:#eee; cursor:pointer;
    text-decoration:none; color:#000; display:inline-block; font-size:12px;
  }
  .title { margin:0 0 0 8px; font-weight:700; font-size:14px; }

  .cards { margin-top:10px; display:flex; align-items:flex-start; gap:18px; flex-wrap:wrap; }
  .card {
    width:200px; height:70px; background:var(--blue); border:2px solid var(--blue2);
    padding:8px 10px; font-size:12px; box-sizing:border-box;
  }
  .card .v { font-weight:800; font-size:16px; margin-top:6px; }

  .box { margin-top:10px; border:2px solid var(--line); background:#fff; padding:10px; }


  table { width:100%; border-collapse:collapse; margin-top:10px; }
  th, td { border:1px solid var(--line); padding:6px; font-size:12px; }
  th { background:var(--th); text-align:left; }
  td.center { text-align:center; }


  .pill{
    display:inline-block; padding:2px 10px; border:1px solid #333; font-weight:700; font-size:11px;
  }
  .pill-ok { background:#00ff4c; }
  .pill-low { background:#ffd400; }
  .pill-out { background:#ff3b30; color:#000; }


  .pagerbar{ display:flex; align-items:center; justify-content:space-between; margin-top:12px; gap:10px; flex-wrap:wrap; }
  .paging { display:flex; justify-content:center; align-items:center; gap:8px; flex-wrap:wrap; }
  .pg{
    display:inline-block; padding:6px 16px;
    border:2px solid var(--blue2); background:#eee; color:#000;
    text-decoration:none; font-weight:600; font-size:12px;
  }
  .pg.active{ background:var(--blue); color:#000; }
  .pg.disabled{ pointer-events:none; opacity:0.5; }
</style>

<div class="wrap">
  <div class="frame">

    <div class="topbar">
   
      <a class="btn" href="${pageContext.request.contextPath}/inventory">Back</a>
      <a class="btn" href="${pageContext.request.contextPath}/home">Home</a>
      <h3 class="title">Inventory Details</h3>
    </div>

    <c:if test="${not empty param.msg}">
      <div style="color:green; font-weight:700; margin-top:6px;">${param.msg}</div>
    </c:if>
    <c:if test="${not empty param.err}">
      <div style="color:red; font-weight:700; margin-top:6px;">${param.err}</div>
    </c:if>

    
    <div class="cards">
      <div class="card">
        <div>Quantity</div>
        <div class="v">${totalQty} Phone</div>
      </div>
      <div class="card">
        <div>Product Code</div>
        <div class="v">${productCode}</div>
      </div>
      <div class="card">
        <div>Product model</div>
        <div class="v">${productModel}</div>
      </div>
    </div>

    <div class="box">
      <table>
        <thead>
          <tr>
            <th style="width:170px;">SKU</th>
            <th style="width:120px;">Color</th>
            <th style="width:90px;">RAM</th>
            <th style="width:110px;">Storage</th>
            <th style="width:140px;">Inventory Status</th>
            <th style="width:130px;">Quantity</th>
            <th style="width:130px;">Last Updated</th>
          </tr>
        </thead>

        <tbody>
          <c:forEach var="s" items="${skuRows}">
            <tr>
              <td>${s.skuCode}</td>
              <td>${s.color}</td>
              <td class="center">${s.ramGb} GB</td>
              <td class="center">${s.storageGb} GB</td>

              <td class="center">
                <c:choose>
                  <c:when test="${s.stockStatus == 'OK'}"><span class="pill pill-ok">In Stock</span></c:when>
                  <c:when test="${s.stockStatus == 'LOW'}"><span class="pill pill-low">Low Stock</span></c:when>
                  <c:otherwise><span class="pill pill-out">Out of Stock</span></c:otherwise>
                </c:choose>
              </td>

              
              <td class="center">${s.qty}</td>

              <td class="center">${s.lastUpdated}</td>
            </tr>
          </c:forEach>

          <c:if test="${empty skuRows}">
            <tr><td colspan="7" class="center">No SKU found</td></tr>
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
          <c:url var="prevUrl" value="/inventory-details">
            <c:param name="productCode" value="${productCode}"/>
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
                <c:url var="pageUrl" value="/inventory-details">
                  <c:param name="productCode" value="${productCode}"/>
                  <c:param name="pageSize" value="${pageSize}"/>
                  <c:param name="page" value="${i}"/>
                </c:url>
                <a class="pg" href="${pageUrl}">${i}</a>
              </c:otherwise>
            </c:choose>
          </c:forEach>

          <c:url var="nextUrl" value="/inventory-details">
            <c:param name="productCode" value="${productCode}"/>
            <c:param name="pageSize" value="${pageSize}"/>
            <c:param name="page" value="${pageNumber+1}"/>
          </c:url>
          <a class="pg ${pageNumber>=totalPages ? 'disabled' : ''}" href="${nextUrl}">Next</a>
        </div>

        <div>
          Show
          <select onchange="location.href='${pageContext.request.contextPath}/inventory-details?productCode=${productCode}&page=1&pageSize='+this.value;">
            <option value="5"  ${pageSize==5 ? "selected" : ""}>5</option>
            <option value="10" ${pageSize==10 ? "selected" : ""}>10</option>
            <option value="20" ${pageSize==20 ? "selected" : ""}>20</option>
          </select>
          Row
        </div>
      </div>

    </div>
  </div>
</div>
