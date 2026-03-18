<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<%-- No internal styles here, using app.css --%>

<div class="page-wrap p-24">

  <!-- Top bar -->
  <div class="topbar mb-20">
    <div class="d-flex align-center gap-12">
      <c:choose>
        <c:when test="${not empty param.back}">
          <a href="${fn:escapeXml(param.back)}" class="btn">← Back</a>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/inventory-count" class="btn">← Back</a>
        </c:otherwise>
      </c:choose>
      <h1 class="h1">View IMEI List</h1>
    </div>
  </div>

  <!-- SKU info chips -->
  <!-- attrs: skuCode, productCode, productModel, color, ramGb, storageGb -->
  <!-- SKU info chips -->
  <div class="chip-grid">
    <div class="chip">
      <div class="chip-label">SKU Code</div>
      <div class="chip-value">${fn:escapeXml(skuCode)}</div>
    </div>
    <div class="chip">
      <div class="chip-label">Product Code</div>
      <div class="chip-value">${fn:escapeXml(productCode)}</div>
    </div>
    <div class="chip">
      <div class="chip-label">Product Model</div>
      <div class="chip-value">${fn:escapeXml(productModel)}</div>
    </div>
    <div class="chip">
      <div class="chip-label">Color</div>
      <div class="chip-value">${fn:escapeXml(color)}</div>
    </div>
    <div class="chip">
      <div class="chip-label">RAM</div>
      <div class="chip-value">${ramGb} GB</div>
    </div>
    <div class="chip">
      <div class="chip-label">Storage</div>
      <div class="chip-value">${storageGb} GB</div>
    </div>
  </div>

  <!-- Search filter -->
  <!-- attrs: q, skuId -->
  <!-- Search filter -->
  <form method="get" action="${ctx}/imei-list" class="filters mb-20">
    <input type="hidden" name="skuId"    value="${skuId}"/>
    <input type="hidden" name="page"     value="1"/>
    <input type="hidden" name="pageSize" value="${pageSize}"/>
    <input type="hidden" name="back"     value="${fn:escapeXml(param.back)}"/>
    
    <div class="filter-group">
      <label>Search IMEI</label>
      <input class="input" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search IMEI…"/>
    </div>
    
    <div class="filter-actions h-38">
      <button type="submit" class="btn btn-primary">Search</button>
      <c:url var="resetUrl" value="/imei-list">
        <c:param name="skuId" value="${skuId}"/>
        <c:param name="back"  value="${param.back}"/>
      </c:url>
      <a href="${resetUrl}" class="btn">Reset</a>
    </div>
  </form>

  <!-- Table -->
  <!-- attrs: imeiRows = List<ImeiRow>; fields: imei, importDate(Timestamp), exportDate(Timestamp) -->
  <!-- Table -->
  <div class="card">
    <div class="card-body p-0">
      <table class="table mb-0">
        <thead>
          <tr>
            <th class="text-center" style="width:50px;">#</th>
            <th>IMEI</th>
            <th class="text-center">Import Date</th>
            <th class="text-center">Export Date</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty imeiRows}">
            <tr><td colspan="4" class="empty-row">No IMEI records found.</td></tr>
          </c:if>
          <c:forEach var="r" items="${imeiRows}" varStatus="st">
            <tr>
              <td class="text-center muted font-sm">
                ${(pageNumber - 1) * pageSize + st.index + 1}
              </td>
              <td class="mono-text">${fn:escapeXml(r.imei)}</td>
              <td class="text-center text-2">
                <c:choose>
                  <c:when test="${not empty r.importDate}">
                    <fmt:formatDate value="${r.importDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:when>
                  <c:otherwise><span class="muted">—</span></c:otherwise>
                </c:choose>
              </td>
              <td class="text-center">
                <c:choose>
                  <c:when test="${not empty r.exportDate}">
                    <fmt:formatDate value="${r.exportDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:when>
                  <c:otherwise><span class="muted">-</span></c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <!-- Paging -->
    <div class="paging-footer">
      <div class="paging-info">Page <b>${pageNumber}</b> of <b>${totalPages}</b></div>

      <div class="paging">
        <c:url var="prevUrl" value="/imei-list">
          <c:param name="skuId"    value="${skuId}"/>
          <c:param name="q"        value="${q}"/>
          <c:param name="page"     value="${pageNumber - 1}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="back"     value="${param.back}"/>
        </c:url>
        <a class="paging-btn ${pageNumber <= 1 ? 'disabled' : ''}" href="${prevUrl}">← Prev</a>

        <c:choose>
          <c:when test="${totalPages <= 5}">
            <c:set var="pgS" value="1"/><c:set var="pgE" value="${totalPages}"/>
          </c:when>
          <c:when test="${pageNumber <= 3}">
            <c:set var="pgS" value="1"/><c:set var="pgE" value="5"/>
          </c:when>
          <c:when test="${pageNumber >= totalPages - 2}">
            <c:set var="pgS" value="${totalPages - 4}"/><c:set var="pgE" value="${totalPages}"/>
          </c:when>
          <c:otherwise>
            <c:set var="pgS" value="${pageNumber - 2}"/><c:set var="pgE" value="${pageNumber + 2}"/>
          </c:otherwise>
        </c:choose>

        <c:forEach begin="${pgS}" end="${pgE}" var="pg">
          <c:url var="pgUrl" value="/imei-list">
            <c:param name="skuId"    value="${skuId}"/>
            <c:param name="q"        value="${q}"/>
            <c:param name="page"     value="${pg}"/>
            <c:param name="pageSize" value="${pageSize}"/>
            <c:param name="back"     value="${param.back}"/>
          </c:url>
          <c:choose>
            <c:when test="${pg == pageNumber}"><span class="paging-btn active">${pg}</span></c:when>
            <c:otherwise><a class="paging-btn" href="${pgUrl}">${pg}</a></c:otherwise>
          </c:choose>
        </c:forEach>

        <c:url var="nextUrl" value="/imei-list">
          <c:param name="skuId"    value="${skuId}"/>
          <c:param name="q"        value="${q}"/>
          <c:param name="page"     value="${pageNumber + 1}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="back"     value="${param.back}"/>
        </c:url>
        <a class="paging-btn ${pageNumber >= totalPages ? 'disabled' : ''}" href="${nextUrl}">Next →</a>
      </div>

      <div class="paging-size">
        <span>Rows:</span>
        <select class="select w-70" onchange="
          location.href='${ctx}/imei-list?skuId=${skuId}&q=${fn:escapeXml(q)}&back='+encodeURIComponent('${fn:escapeXml(param.back)}')+'&page=1&pageSize='+this.value">
          <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
          <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
          <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
        </select>
      </div>
    </div>

  </div>
</div>
