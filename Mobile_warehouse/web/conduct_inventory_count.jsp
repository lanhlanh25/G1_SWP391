<%-- 
    Document   : conduct_inventory_count
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Conduct Inventory Count</div>
    <a class="btn" href="${pageContext.request.contextPath}/home">← Back</a>
  </div>

  <%-- Search --%>
  <div class="card" style="margin-bottom:16px;">
    <div class="card-header">
      <span class="h2">Search Criteria</span>
    </div>
    <div class="card-body">
      <form method="get" action="${pageContext.request.contextPath}/inventory-count">
        <div class="filters" style="grid-template-columns: 2fr 1fr auto;">
          <div>
            <label class="label">Product name / SKU</label>
            <input class="input" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Product name, SKU,..."/>
          </div>
          <div>
            <label class="label">Brand</label>
            <select class="select" name="brandId">
              <option value="">All Brands</option>
              <c:forEach var="b" items="${brands}">
                <option value="${b.id}" <c:if test="${b.id == brandId}">selected</c:if>>
                  ${fn:escapeXml(b.name)}
                </option>
              </c:forEach>
            </select>
          </div>
          <div style="display:flex; align-items:flex-end; gap:8px;">
            <button class="btn btn-primary" type="submit">Search</button>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/inventory-count">Reset</a>
          </div>
        </div>
        <input type="hidden" name="page" value="1"/>
        <input type="hidden" name="pageSize" value="${pageSize}"/>
      </form>
    </div>
  </div>

  <%-- Table + Save --%>
  <form method="post" action="${pageContext.request.contextPath}/inventory-count">
    <input type="hidden" name="q" value="${fn:escapeXml(q)}"/>
    <input type="hidden" name="brandId" value="${fn:escapeXml(brandId)}"/>
    <input type="hidden" name="page" value="${pageNumber}"/>
    <input type="hidden" name="pageSize" value="${pageSize}"/>

    <div class="card">
      <div class="card-header">
        <span class="h2">Inventory Items</span>
        <button class="btn btn-primary" type="submit">💾 Save</button>
      </div>

      <%-- link back để IMEI list quay về đúng inventory-count + giữ filter/page --%>
      <c:url var="backToCount" value="/inventory-count">
        <c:param name="q" value="${q}"/>
        <c:param name="brandId" value="${brandId}"/>
        <c:param name="page" value="${pageNumber}"/>
        <c:param name="pageSize" value="${pageSize}"/>
      </c:url>

      <table>
        <thead>
          <tr>
            <th style="width:160px;">SKU</th>
            <th>Product Name</th>
            <th style="width:120px;">Color</th>
            <th style="width:80px;">RAM</th>
            <th style="width:95px;">Storage</th>
            <th style="width:95px;">System Qty</th>
            <th style="width:110px;">Counted Qty</th>
            <th style="width:90px;">Status</th>
            <th style="width:120px;">Action</th>
          </tr>
        </thead>

        <tbody>
          <c:forEach var="r" items="${rows}">
            <tr>
              <td>${fn:escapeXml(r.skuCode)}</td>
              <td>${fn:escapeXml(r.productName)}</td>
              <td>${fn:escapeXml(r.color)}</td>
              <td style="text-align:center;">${r.ramGb} GB</td>
              <td style="text-align:center;">${r.storageGb} GB</td>

              <td style="text-align:center;">${r.systemQty} Phone</td>

              <td style="text-align:center;">
                <input type="hidden" name="skuId" value="${r.skuId}"/>

                <div style="display:inline-flex; align-items:center; gap:6px;">
                  <input class="diff-input js-counted"
                         type="number"
                         name="countedQty"
                         min="0"
                         value="${r.countedQty}"
                         data-system="${r.systemQty}" />
                  <span>Phone</span>
                </div>
              </td>

              <td style="text-align:center;" class="js-status">
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
                  <c:param name="back" value="${backToCount}"/>
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
        <select onchange="location.href='${pageContext.request.contextPath}/inventory-count?q=${fn:escapeXml(q)}&brandId=${fn:escapeXml(brandId)}&page=1&pageSize='+this.value;">
          <option value="10" ${pageSize==10 ? "selected" : ""}>10</option>
          <option value="20" ${pageSize==20 ? "selected" : ""}>20</option>
        </select>
        Row
      </div>
    </div>
  </form>

  <%-- Pagination --%>
  <c:choose>
    <c:when test="${totalPages <= 3}"><c:set var="startPage" value="1"/><c:set var="endPage" value="${totalPages}"/></c:when>
    <c:when test="${pageNumber <= 1}"><c:set var="startPage" value="1"/><c:set var="endPage" value="3"/></c:when>
    <c:when test="${pageNumber >= totalPages}"><c:set var="startPage" value="${totalPages-2}"/><c:set var="endPage" value="${totalPages}"/></c:when>
    <c:otherwise><c:set var="startPage" value="${pageNumber-1}"/><c:set var="endPage" value="${pageNumber+1}"/></c:otherwise>
  </c:choose>

  <div style="display:flex; align-items:center; justify-content:space-between; margin-top:14px; flex-wrap:wrap; gap:10px;">
    <div class="small">Page ${pageNumber} of ${totalPages}</div>

    <div class="paging">
      <c:url var="prevUrl" value="/inventory-count">
        <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/>
        <c:param name="pageSize" value="${pageSize}"/><c:param name="page" value="${pageNumber-1}"/>
      </c:url>
      <a class="paging-btn ${pageNumber<=1 ? 'disabled' : ''}" href="${prevUrl}">← Prev</a>

      <c:forEach var="i" begin="${startPage}" end="${endPage}">
        <c:choose>
          <c:when test="${i == pageNumber}"><b>${i}</b></c:when>
          <c:otherwise>
            <c:url var="pageUrl" value="/inventory-count">
              <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/>
              <c:param name="pageSize" value="${pageSize}"/><c:param name="page" value="${i}"/>
            </c:url>
            <a class="paging-btn" href="${pageUrl}">${i}</a>
          </c:otherwise>
        </c:choose>
      </c:forEach>

      <c:url var="nextUrl" value="/inventory-count">
        <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/>
        <c:param name="pageSize" value="${pageSize}"/><c:param name="page" value="${pageNumber+1}"/>
      </c:url>
      <a class="paging-btn ${pageNumber>=totalPages ? 'disabled' : ''}" href="${nextUrl}">Next →</a>
    </div>

    <div style="display:flex; align-items:center; gap:8px;" class="small">
      Show
      <select class="select" style="width:auto; padding:6px 10px;"
              onchange="location.href='${pageContext.request.contextPath}/inventory-count?q=${q}&brandId=${brandId}&page=1&pageSize='+this.value;">
        <option value="10" ${pageSize==10 ? "selected" : ""}>10</option>
        <option value="20" ${pageSize==20 ? "selected" : ""}>20</option>
      </select>
      rows
    </div>
  </div>

</div>

<script>
  function updateStatus(inp) {
    const system = parseInt(inp.dataset.system || "0", 10);
    const counted = parseInt(inp.value || "0", 10);
    const cell = inp.closest("tr")?.querySelector(".js-status");
    if (!cell) return;
    cell.innerHTML = (counted === system)
      ? '<span class="badge badge-active">Enough</span>'
      : '<span class="badge badge-inactive">Missing</span>';
  }
  document.querySelectorAll(".js-counted").forEach(inp => {
    inp.addEventListener("input", () => updateStatus(inp));
    updateStatus(inp);
  });
</script>
