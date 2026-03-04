<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<div class="page-wrap">

  <div class="topbar">
    <%-- Back thông minh: nếu có param.back thì quay về đó --%>
    <c:choose>
      <c:when test="${not empty param.back}">
        <a class="btn" href="${param.back}">Back</a>
      </c:when>
      <c:otherwise>
        <a class="btn" href="${pageContext.request.contextPath}/inventory-count">Back</a>
      </c:otherwise>
    </c:choose>

    <a class="btn" href="${pageContext.request.contextPath}/home">Home</a>
    <h3 class="title">View IMEI List</h3>
  </div>

  <div class="cards">
    <div class="card"><div class="label">SKU Code</div><div class="value">${fn:escapeXml(skuCode)}</div></div>
    <div class="card"><div class="label">Product Code</div><div class="value">${fn:escapeXml(productCode)}</div></div>
    <div class="card"><div class="label">Product Model</div><div class="value">${fn:escapeXml(productModel)}</div></div>
    <div class="card"><div class="label">Color</div><div class="value">${fn:escapeXml(color)}</div></div>
    <div class="card"><div class="label">RAM</div><div class="value">${ramGb} GB</div></div>
    <div class="card"><div class="label">Storage</div><div class="value">${storageGb} GB</div></div>
  </div>

  <%-- SKU Stats --%>
  <div class="stat-cards" style="margin-bottom:14px;">
    <div class="card stat-card-item">
      <div class="small muted">SKU Code</div>
      <div class="stat-value" style="font-size:16px;">${skuCode}</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">Product Code</div>
      <div class="stat-value" style="font-size:16px;">${productCode}</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">Product Model</div>
      <div class="stat-value" style="font-size:16px;">${productModel}</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">Color</div>
      <div class="stat-value" style="font-size:16px;">${color}</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">RAM</div>
      <div class="stat-value" style="font-size:16px;">${ramGb} GB</div>
    </div>
    <div class="card stat-card-item">
      <div class="small muted">Storage</div>
      <div class="stat-value" style="font-size:16px;">${storageGb} GB</div>
    </div>
  </div>

    <form method="get" action="${pageContext.request.contextPath}/imei-list" style="margin-top:8px;">
      <input type="hidden" name="skuId" value="${skuId}"/>
      <input type="hidden" name="page" value="1"/>
      <input type="hidden" name="pageSize" value="${pageSize}"/>
      <input type="hidden" name="back" value="${param.back}"/>

      <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search IMEI..."
             style="width:240px; height:28px; padding:0 8px;"/>

      <button class="btn" type="submit" style="margin-left:12px;">Search</button>

      <c:url var="resetUrl" value="/imei-list">
        <c:param name="skuId" value="${skuId}"/>
        <c:param name="back" value="${param.back}"/>
      </c:url>
      <a class="btn" href="${resetUrl}">Reset</a>
    </form>

    <table>
      <thead>
        <tr>
          <th style="width:40%;">IMEI</th>
          <th style="width:30%;">Import Date</th>
          <th style="width:30%;">Export Date</th>
        </tr>
      </thead>

      <tbody>
        <c:forEach var="r" items="${imeiRows}">
          <tr>
            <td style="text-align:center;">${fn:escapeXml(r.imei)}</td>

            <td style="text-align:center;">
              <c:choose>
                <c:when test="${not empty r.importDate}">
                  <fmt:formatDate value="${r.importDate}" pattern="dd/MM/yyyy HH:mm"/>
                </c:when>
                <c:otherwise>-</c:otherwise>
              </c:choose>
            </td>

            <td style="text-align:center;">
              <c:choose>
                <c:when test="${not empty r.exportDate}">
                  <fmt:formatDate value="${r.exportDate}" pattern="dd/MM/yyyy HH:mm"/>
                </c:when>
                <c:otherwise><span style="color:#999;">-</span></c:otherwise>
              </c:choose>
            </td>
          </tr>
        </c:forEach>

        <c:if test="${empty imeiRows}">
          <tr><td colspan="3" style="text-align:center;">No data</td></tr>
        </c:if>
      </tbody>
    </table>

    <%-- Paging window --%>
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
      <div>Page ${pageNumber} / ${totalPages}</div>

      <div class="paging">
        <c:url var="prevUrl" value="/imei-list">
          <c:param name="skuId" value="${skuId}"/>
          <c:param name="q" value="${q}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="page" value="${pageNumber-1}"/>
          <c:param name="back" value="${param.back}"/>
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
                <c:param name="pageSize" value="${pageSize}"/>
                <c:param name="page" value="${i}"/>
                <c:param name="back" value="${param.back}"/>
              </c:url>
              <a class="pg" href="${pageUrl}">${i}</a>
            </c:otherwise>
          </c:choose>
        </c:forEach>

        <c:url var="nextUrl" value="/imei-list">
          <c:param name="skuId" value="${skuId}"/>
          <c:param name="q" value="${q}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="page" value="${pageNumber+1}"/>
          <c:param name="back" value="${param.back}"/>
        </c:url>
        <a class="pg ${pageNumber>=totalPages ? 'disabled' : ''}" href="${nextUrl}">Next</a>
      </div>

      <div>
        Show
        <select onchange="location.href='${pageContext.request.contextPath}/imei-list?skuId=${skuId}&q=${fn:escapeXml(q)}&back='+encodeURIComponent('${fn:escapeXml(param.back)}')+'&page=1&pageSize='+this.value;">
          <option value="10" ${pageSize==10 ? "selected" : ""}>10 Row</option>
          <option value="20" ${pageSize==20 ? "selected" : ""}>20 Row</option>
        </select>
      </div>
    </div>
  </div>
</div>
