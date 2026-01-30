<%-- 
    Document   : update_inventory
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="roleUpper" value="${fn:toUpperCase(sessionScope.roleName)}"/>
<c:set var="canEdit" value="${roleUpper ne 'SALE'}"/>

<style>
  .wrap { padding: 10px; background:#f4f4f4; font-family:Arial, Helvetica, sans-serif; }
  .topbar { display:flex; gap:10px; align-items:center; }
  .btn { padding:6px 14px; border:1px solid #333; background:#eee; cursor:pointer; text-decoration:none; color:#000; display:inline-block; }
  .title { margin:0 0 0 14px; font-weight:700; }

  .cards { margin-top:10px; display:flex; align-items:flex-start; gap:18px; flex-wrap:wrap; }
  .card {
    width: 200px; height: 70px; background:#3a7bd5; border:2px solid #1d4f91;
    padding:8px 10px; font-size:12px;
  }
  .card .v { font-weight:800; font-size:18px; margin-top:6px; }

  .save-wrap { margin-left:auto; }
  .box { margin-top:10px; border:2px solid #3b5db7; background:#fff; padding:10px; }

  table { width:100%; border-collapse:collapse; margin-top:10px; }
  th, td { border:1px solid #333; padding:6px; font-size:12px; }
  th { background:#ddd; }

  .status-ok { background:#00ff4c; border:1px solid #333; padding:2px 10px; display:inline-block; }
  .status-low { background:#ffd400; border:1px solid #333; padding:2px 10px; display:inline-block; }
  .status-out { background:#ff3b30; border:1px solid #333; padding:2px 10px; display:inline-block; }

  .qty-input { width:90px; padding:4px 6px; }
  .msg { color:green; margin-top:8px; font-weight:700; }
  .err { color:red; margin-top:8px; font-weight:700; }
  .note { margin-top:8px; color:#555; }

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
    <!-- Back về view_inventory.jsp -->
    <a class="btn" href="${pageContext.request.contextPath}/inventory">Back</a>
    <a class="btn" href="${pageContext.request.contextPath}/home">Home</a>
    <h3 class="title">Update Inventory</h3>
  </div>

  <c:if test="${not empty param.msg}"><div class="msg">${param.msg}</div></c:if>
  <c:if test="${not empty param.err}"><div class="err">${param.err}</div></c:if>

  <c:if test="${not canEdit}">
    <div class="note">Role SALE chỉ được xem. Không được phép chỉnh Quantity hoặc Save.</div>
  </c:if>

  <form method="post" action="${pageContext.request.contextPath}/inventory-update">
    <input type="hidden" name="productCode" value="${productCode}"/>
    <input type="hidden" name="page" value="${pageNumber}"/>
    <input type="hidden" name="pageSize" value="${pageSize}"/>

    <div class="cards">
      <div class="card"><div>Quantity</div><div class="v">${totalQty}</div></div>
      <div class="card"><div>Product Code</div><div class="v">${productCode}</div></div>
      <div class="card"><div>Product model</div><div class="v">${productModel}</div></div>

      <div class="save-wrap">
        <c:choose>
          <c:when test="${canEdit}">
            <button class="btn" type="submit">Save</button>
          </c:when>
          <c:otherwise>
            <button class="btn" type="button" disabled style="opacity:.5;">Save</button>
          </c:otherwise>
        </c:choose>
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
            <th style="width:120px;">Status</th>
            <th style="width:130px;">Quantity</th>
            <th style="width:130px;">Last Updated</th>
          </tr>
        </thead>

        <tbody>
          <c:forEach var="s" items="${skuRows}">
            <tr>
              <td>${s.skuCode}</td>
              <td>${s.color}</td>
              <td>${s.ramGb} GB</td>
              <td>${s.storageGb} GB</td>

              <td style="text-align:center;">
                <c:choose>
                  <c:when test="${s.stockStatus == 'OK'}"><span class="status-ok">OK</span></c:when>
                  <c:when test="${s.stockStatus == 'LOW'}"><span class="status-low">Low Stock</span></c:when>
                  <c:otherwise><span class="status-out">Out Of Stock</span></c:otherwise>
                </c:choose>
              </td>

              <td style="text-align:center;">
                <input type="hidden" name="skuId" value="${s.skuId}"/>
                <input class="qty-input" type="number" name="qty" min="0" value="${s.qty}" ${canEdit ? "" : "disabled"} />
              </td>

              <td style="text-align:center;">${s.lastUpdated}</td>
            </tr>
          </c:forEach>

          <c:if test="${empty skuRows}">
            <tr><td colspan="7" style="text-align:center;">No SKU found</td></tr>
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
          <c:url var="prevUrl" value="/inventory-update">
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
                <c:url var="pageUrl" value="/inventory-update">
                  <c:param name="productCode" value="${productCode}"/>
                  <c:param name="pageSize" value="${pageSize}"/>
                  <c:param name="page" value="${i}"/>
                </c:url>
                <a class="pg" href="${pageUrl}">${i}</a>
              </c:otherwise>
            </c:choose>
          </c:forEach>

          <c:url var="nextUrl" value="/inventory-update">
            <c:param name="productCode" value="${productCode}"/>
            <c:param name="pageSize" value="${pageSize}"/>
            <c:param name="page" value="${pageNumber+1}"/>
          </c:url>
          <a class="pg ${pageNumber>=totalPages ? 'disabled' : ''}" href="${nextUrl}">Next</a>
        </div>

        <div>
          Show
          <select onchange="location.href='${pageContext.request.contextPath}/inventory-update?productCode=${productCode}&page=1&pageSize='+this.value;">
            <option value="5"  ${pageSize==5 ? "selected" : ""}>5</option>
            <option value="10" ${pageSize==10 ? "selected" : ""}>10</option>
            <option value="20" ${pageSize==20 ? "selected" : ""}>20</option>
          </select>
          Row
        </div>
      </div>

    </div>
  </form>
</div>
