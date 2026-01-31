<%-- 
    Document   : view_inventory
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

  .inv-wrap{
    padding:10px;
    background:var(--bg);
    font-family:Arial, Helvetica, sans-serif;
  }

 
  .frame{
    border:2px solid var(--line);
    background:#fff;
    padding:10px;
  }

  .topbar{
    display:flex;
    align-items:center;
    gap:10px;
    margin-bottom:6px;
  }
  .btn{
    padding:6px 12px;
    border:1px solid #333;
    background:#eee;
    cursor:pointer;
    text-decoration:none;
    color:#000;
    display:inline-block;
    font-size:12px;
  }
  .title{
    margin:0;
    font-weight:700;
    font-size:14px;
  }


  .cards{
    display:flex;
    gap:18px;
    flex-wrap:wrap;
    margin:6px 0 10px 0;
  }
  .card{
    width:165px;
    height:55px;
    background:var(--blue);
    border:2px solid var(--blue2);
    padding:6px 10px;
    box-sizing:border-box;
  }
  .card .k{
    font-size:11px;
    font-weight:700;
    color:#000;
    line-height:1.1;
  }
  .card .v{
    font-size:12px;
    margin-top:6px;
    color:#000;
  }

  
  .box{
    border:2px solid var(--line);
    padding:8px;
    margin-top:6px;
  }
  .box-title{
    font-weight:700;
    font-size:12px;
    margin-bottom:8px;
  }
  .search-row{
    display:flex;
    align-items:center;
    gap:12px;
    flex-wrap:wrap;
  }
  .search-row input[type="text"]{
    width:260px;
    height:26px;
    padding:0 8px;
    border:1px solid #777;
    outline:none;
  }
  .search-row select{
    height:28px;
    border:1px solid #777;
    outline:none;
    background:#fff;
  }
  .search-row .brand{ width:150px; }
  .search-row .status{ width:140px; }


  table{
    width:100%;
    border-collapse:collapse;
    margin-top:10px;
  }
  th, td{
    border:1px solid var(--line);
    padding:6px;
    font-size:12px;
  }
  th{
    background:var(--th);
    text-align:left;
  }
  td.center{ text-align:center; }


  .pill{
    display:inline-block;
    padding:2px 10px;
    border:1px solid #333;
    font-weight:700;
    font-size:11px;
  }
  .pill-ok{ background:#00ff4c; }
  .pill-low{ background:#ffd400; }
  .pill-out{ background:#ff3b30; color:#000; }

  
  .pagerbar{
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-top:12px;
    gap:10px;
    flex-wrap:wrap;
  }
  .paging{
    display:flex;
    justify-content:center;
    align-items:center;
    gap:8px;
    flex-wrap:wrap;
  }
  .pg{
    display:inline-block;
    padding:6px 16px;
    border:2px solid var(--blue2);
    background:#eee;
    color:#000;
    text-decoration:none;
    font-weight:600;
    font-size:12px;
  }
  .pg.active{
    background:var(--blue);
    color:#000;
  }
  .pg.disabled{
    pointer-events:none;
    opacity:0.5;
  }
</style>

<div class="inv-wrap">
  <div class="frame">

    <div class="topbar">
      <a class="btn" href="${pageContext.request.contextPath}/home">Back</a>
      <h3 class="title">Inventory Management</h3>
    </div>

    <c:if test="${not empty param.msg}">
      <div style="color:green; font-weight:700; margin-top:6px;">${param.msg}</div>
    </c:if>
    <c:if test="${not empty param.err}">
      <div style="color:red; font-weight:700; margin-top:6px;">${param.err}</div>
    </c:if>

 
    <div class="cards">
      <div class="card">
        <div class="k">Total Products</div>
        <div class="v">${totalProducts} product</div>
      </div>
      <div class="card">
        <div class="k">Total Quantity</div>
        <div class="v">${totalQty} Phone</div>
      </div>
      <div class="card">
        <div class="k">Low Stock Items</div>
        <div class="v">${lowStockItems}</div>
      </div>
      <div class="card">
        <div class="k">Out of Stock Items</div>
        <div class="v">${outOfStockItems}</div>
      </div>
    </div>

   
    <div class="box">
      <div class="box-title">Search Criteria</div>

      <form method="get" action="${pageContext.request.contextPath}/inventory">
        <div class="search-row">
          
          <input type="text" name="q" value="${q}" placeholder="Product name, SKU,..." />

          
          <select class="brand" name="brandId">
            <option value="">All Brands</option>
            <c:forEach var="b" items="${brands}">
              <option value="${b.id}" <c:if test="${b.id == brandId}">selected</c:if>>${b.name}</option>
            </c:forEach>
          </select>

          
          <select class="status" name="stockStatus">
            <option value="" <c:if test="${empty stockStatus}">selected</c:if>>Stock Status</option>
            <option value="OK"  <c:if test="${stockStatus=='OK'}">selected</c:if>>In Stock</option>
            <option value="LOW" <c:if test="${stockStatus=='LOW'}">selected</c:if>>Low Stock</option>
            <option value="OUT" <c:if test="${stockStatus=='OUT'}">selected</c:if>>Out of Stock</option>
          </select>

          <button class="btn" type="submit">Search</button>
          <a class="btn" href="${pageContext.request.contextPath}/inventory">Reset</a>

        
          <input type="hidden" name="page" value="1"/>
          <input type="hidden" name="pageSize" value="${pageSize}"/>
        </div>
      </form>

     
      <table>
        <thead>
          <tr>
            <th style="width:110px;">Product Code</th>
            <th>Product Name</th>
            <th style="width:120px;">Brand</th>
            <th style="width:90px;">Quantity</th>
            <th style="width:140px;">Inventory Status</th>
            <th style="width:120px;">Last Updated</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="it" items="${inventoryModels}">
            <tr>
              <td class="center">${it.productCode}</td>

              <td>
               
                <c:url var="detailUrl" value="/inventory-details">
                  <c:param name="productCode" value="${it.productCode}"/>
                  <!-- giữ filter + page/pageSize của list (để detail có thể back đúng ngữ cảnh nếu bạn dùng) -->
                  <c:param name="q" value="${q}"/>
                  <c:param name="brandId" value="${brandId}"/>
                  <c:param name="stockStatus" value="${stockStatus}"/>
                  <c:param name="page" value="${pageNumber}"/>
                  <c:param name="pageSize" value="${pageSize}"/>
                </c:url>

                <a href="${detailUrl}" style="color:#0b39b8; text-decoration:underline;">
                  ${it.productName}
                </a>
              </td>

              <td>${it.brandName}</td>
              <td class="center">${it.totalQty}</td>

              <td class="center">
                <c:choose>
                  <c:when test="${it.status == 'OK'}"><span class="pill pill-ok">In Stock</span></c:when>
                  <c:when test="${it.status == 'LOW'}"><span class="pill pill-low">Low Stock</span></c:when>
                  <c:otherwise><span class="pill pill-out">Out of Stock</span></c:otherwise>
                </c:choose>
              </td>

              <td class="center">${it.lastUpdated}</td>
            </tr>
          </c:forEach>

          <c:if test="${empty inventoryModels}">
            <tr><td colspan="6" class="center">No data</td></tr>
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

        <div>
          <c:url var="sizeBaseUrl" value="/inventory">
            <c:param name="q" value="${q}"/>
            <c:param name="brandId" value="${brandId}"/>
            <c:param name="stockStatus" value="${stockStatus}"/>
            <c:param name="page" value="1"/>
          </c:url>

          Show
          <select onchange="location.href='${sizeBaseUrl}&pageSize='+this.value;">
            <option value="5"  <c:if test="${pageSize==5}">selected</c:if>>5</option>
            <option value="10" <c:if test="${pageSize==10}">selected</c:if>>10</option>
            <option value="20" <c:if test="${pageSize==20}">selected</c:if>>20</option>
          </select>
          Row
        </div>
      </div>

    </div>
  </div>
</div>

