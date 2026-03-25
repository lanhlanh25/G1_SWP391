<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<link rel="stylesheet" href="${ctx}/assets/css/app.css">
<%-- Internal styles moved to app.css --%>

<div class="ic-wrap">

  <!-- Top bar -->
  <div class="ic-topbar">
    <div style="display:flex;align-items:center;gap:14px;">
      <a href="${ctx}/home?p=dashboard" class="btn btn-sm">← Back</a>
      <h1 class="ic-title">Inventory Count</h1>
    </div>
    <button type="button" class="btn btn-primary" id="btnSave">Save Count</button>
  </div>

  <%-- Flash messages (passed as query params after redirect) --%>
  <c:if test="${not empty param.msg}">
    <div class="alert alert-success mb-12">✓ ${fn:escapeXml(param.msg)}</div>
  </c:if>
  <c:if test="${not empty param.err}">
    <div class="alert alert-danger mb-12">✕ ${fn:escapeXml(param.err)}</div>
  </c:if>

  <!-- Filter (GET form) -->
  <!-- attrs: q, brandId -->
  <!-- brands = List<IdName> with fields: id, name -->
  <div class="ic-filter-card">
    <form method="get" action="${ctx}/inventory-count">
      <div class="ic-filter-row">
        <div class="ic-filter-grp">
          <label>Product name, SKU…</label>
          <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search product or SKU…"/>
        </div>
        <div class="ic-filter-grp">
          <label>Brand</label>
          <select name="brandId">
            <option value="">All Brands</option>
            <%-- brands is List<IdName>; IdName has getId() and getName() --%>
            <c:forEach var="b" items="${brands}">
              <option value="${b.id}" ${brandId == b.id ? 'selected' : ''}>
                ${fn:escapeXml(b.name)}
              </option>
            </c:forEach>
          </select>
        </div>
        <input type="hidden" name="page"     value="1"/>
        <input type="hidden" name="pageSize" value="${pageSize}"/>
        <div style="display:flex;gap:8px;align-items:flex-end;">
          <button type="submit" class="btn btn-primary btn-sm  btn-equal" >Search</button>
          <a href="${ctx}/inventory-count" class="btn btn-outline btn-sm btn-equal" >Reset</a>
        </div>
      </div>
    </form>
  </div>

  <!-- POST form wrapping the table -->
  <!-- rows = List<InventoryCountRow>
       fields: skuId, skuCode, productName, color, ramGb, storageGb, systemQty, countedQty -->
  <form method="post" action="${ctx}/inventory-count" id="countForm">
    <input type="hidden" name="q"        value="${fn:escapeXml(q)}"/>
    <input type="hidden" name="brandId"  value="${fn:escapeXml(brandId)}"/>
    <input type="hidden" name="page"     value="${pageNumber}"/>
    <input type="hidden" name="pageSize" value="${pageSize}"/>

    <div class="ic-card">
      <div class="ic-card-head">
        <%-- save button triggers form submit via JS --%>
      </div>

      <%-- build back-URL for IMEI link --%>
      <c:url var="backToCount" value="/inventory-count">
        <c:param name="q"        value="${q}"/>
        <c:param name="brandId"  value="${brandId}"/>
        <c:param name="page"     value="${pageNumber}"/>
        <c:param name="pageSize" value="${pageSize}"/>
      </c:url>

      <div style="overflow-x:auto;">
        <table class="ic-tbl">
          <thead>
            <tr>
              <th>#</th>
              <th>SKU</th>
              <th>Product Name</th>
              <th class="text-center">Color</th>
              <th class="text-center">RAM</th>
              <th class="text-center">Storage</th>
              <th class="text-right">System Qty</th>
              <th class="text-center">Counted Qty</th>
              <th class="text-center">Status</th>
              <th class="text-center">Action</th>
            </tr>
          </thead>
          <tbody>
            <c:if test="${empty rows}">
              <tr><td colspan="10" class="empty-row">No data found.</td></tr>
            </c:if>
            <c:forEach var="r" items="${rows}" varStatus="st">
              <tr>
                <td style="color:var(--muted);font-size:12px;" class="tc">
                  ${(pageNumber - 1) * pageSize + st.index + 1}
                </td>
                <td style="font-weight:700;font-size:12.5px;">${fn:escapeXml(r.skuCode)}</td>
                <td>${fn:escapeXml(r.productName)}</td>
                <td class="text-center">${fn:escapeXml(r.color)}</td>
                <td class="text-center">${r.ramGb} GB</td>
                <td class="text-center">${r.storageGb} GB</td>
                <td class="text-right">
                  ${r.systemQty}
                  <span class="muted font-xs">Phone</span>
                </td>
                <td class="text-center">
                  <input type="hidden" name="skuId" value="${r.skuId}"/>
                  <div class="d-inline-flex align-center gap-8">
                    <input class="counted-inp js-counted"
                           type="number"
                           name="countedQty"
                           min="0"
                           value="${r.countedQty}"
                           data-system="${r.systemQty}"/>
                    <span class="muted font-xs">Phone</span>
                  </div>
                </td>
                <td class="text-center js-status-cell">
                  <c:choose>
                    <c:when test="${r.countedQty == r.systemQty}">
                      <span class="badge badge-success">enough</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge badge-danger">missing</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="text-center">
                  <c:url var="imeiUrl" value="/imei-list">
                    <c:param name="skuId"    value="${r.skuId}"/>
                    <c:param name="page"     value="1"/>
                    <c:param name="pageSize" value="10"/>
                    <c:param name="back"     value="${backToCount}"/>
                  </c:url>
                  <a class="btn btn-sm btn-outline" href="${imeiUrl}">View IMEI</a>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>

      <!-- Paging (attrs: pageNumber, pageSize, totalPages, totalItems) -->
      <div class="paging-footer">
        <div class="paging-info">
          Page <b>${pageNumber}</b> of <b>${totalPages}</b>
<!--          &nbsp;•&nbsp; Total <strong>${totalItems}</strong> SKUs-->
        </div>

        <div class="paging">
          <c:url var="prevUrl" value="/inventory-count">
            <c:param name="q"        value="${q}"/>
            <c:param name="brandId"  value="${brandId}"/>
            <c:param name="page"     value="${pageNumber - 1}"/>
            <c:param name="pageSize" value="${pageSize}"/>
          </c:url>
          <a class="${pageNumber <= 1 ? 'pg-disabled' : ''}" href="${prevUrl}">← Prev</a>

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
            <c:url var="pgUrl" value="/inventory-count">
              <c:param name="q"        value="${q}"/>
              <c:param name="brandId"  value="${brandId}"/>
              <c:param name="page"     value="${pg}"/>
              <c:param name="pageSize" value="${pageSize}"/>
            </c:url>
            <c:choose>
              <c:when test="${pg == pageNumber}"><span class="pg-active">${pg}</span></c:when>
              <c:otherwise><a href="${pgUrl}">${pg}</a></c:otherwise>
            </c:choose>
          </c:forEach>

          <c:url var="nextUrl" value="/inventory-count">
            <c:param name="q"        value="${q}"/>
            <c:param name="brandId"  value="${brandId}"/>
            <c:param name="page"     value="${pageNumber + 1}"/>
            <c:param name="pageSize" value="${pageSize}"/>
          </c:url>
          <a class="${pageNumber >= totalPages ? 'pg-disabled' : ''}" href="${nextUrl}">Next →</a>
        </div>

        <div class="paging-size">
          <span>Rows:</span>
          <select class="select w-70" onchange="location.href='${ctx}/inventory-count?q=${fn:escapeXml(q)}&brandId=${fn:escapeXml(brandId)}&page=1&pageSize='+this.value">
            <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
          </select>
        </div>
      </div>

    </div><!-- /.ic-card -->
  </form>

</div>

<script>
// Live status update when counted qty changes
function updateStatus(inp) {
  const sys = parseInt(inp.dataset.system || '0', 10);
  const val = parseInt(inp.value || '0', 10);
  const cell = inp.closest('tr').querySelector('.js-status-cell');
  if (!cell) return;
  inp.classList.toggle('changed', val !== sys);
  cell.innerHTML = (val === sys)
    ? '<span class="stbadge st-enough">enough</span>'
    : '<span class="stbadge st-missing">missing</span>';
}

document.querySelectorAll('.js-counted').forEach(inp => {
  inp.addEventListener('input', () => updateStatus(inp));
  updateStatus(inp);
});

document.getElementById('btnSave').addEventListener('click', function() {
  if (confirm('Save inventory count for all displayed SKUs?')) {
    document.getElementById('countForm').submit();
  }
});
</script>
