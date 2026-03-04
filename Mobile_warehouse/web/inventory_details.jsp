<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Inventory Details</div>
    <div style="display:flex; gap:8px;">
      <a class="btn" href="${pageContext.request.contextPath}/inventory">← Back</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/home">Home</a>
    </div>
  </div>

  <c:if test="${not empty param.msg}"><p class="msg-ok">${param.msg}</p></c:if>
  <c:if test="${not empty param.err}"><p class="msg-err">${param.err}</p></c:if>

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
    <div class="card stat-card-item">
      <div class="small muted">Product Code</div>
      <div class="stat-value">${productCode}</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">Product Model</div>
      <div class="stat-value">${productModel}</div>
    </div>
  </div>

    <div class="box">

      <%-- back link to return from IMEI page if you choose to use it later --%>
      <c:url var="backToDetails" value="/inventory-details">
        <c:param name="productCode" value="${productCode}"/>
        <c:param name="page" value="${pageNumber}"/>
        <c:param name="pageSize" value="${pageSize}"/>
      </c:url>

      <table>
        <thead>
          <tr>
            <th>SKU</th>
            <th>Color</th>
            <th style="text-align:center; width:90px;">RAM</th>
            <th style="text-align:center; width:110px;">Storage</th>
            <th style="text-align:center; width:150px;">Status</th>
            <th style="text-align:center; width:110px;">Quantity</th>
            <th style="width:140px;">Last Updated</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="s" items="${skuRows}">
            <tr>
              <td>${s.skuCode}</td>
              <td>${s.color}</td>
              <td style="text-align:center;">${s.ramGb} GB</td>
              <td style="text-align:center;">${s.storageGb} GB</td>
              <td style="text-align:center;">
                <c:choose>
                  <c:when test="${s.stockStatus == 'OK'}">
                    <span class="badge badge-active">In Stock</span>
                  </c:when>
                  <c:when test="${s.stockStatus == 'LOW'}">
                    <span class="badge badge-warning">Low Stock</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-inactive">Out of Stock</span>
                  </c:otherwise>
                </c:choose>
              </td>

              <td class="center">${s.qty} Phone</td>

              <td class="center">
                <c:url var="imeiUrl" value="/imei-list">
                  <c:param name="skuId" value="${s.skuId}"/>
                  <c:param name="page" value="1"/>
                  <c:param name="pageSize" value="10"/>
                  <%-- Optional: pass back link so IMEI page can return here if you later support it --%>
                  <c:param name="back" value="${backToDetails}"/>
                </c:url>

                <a href="${imeiUrl}" style="color:#0b39b8; text-decoration:underline;">
                  View List IMEI
                </a>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty skuRows}">
            <tr><td colspan="7" class="small muted" style="padding:20px; text-align:center;">No SKU found</td></tr>
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
