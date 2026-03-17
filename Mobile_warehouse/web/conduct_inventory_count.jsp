<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
  .ic-wrap { padding: 0; }
  .ic-topbar { display:flex; align-items:center; justify-content:space-between; margin-bottom:22px; flex-wrap:wrap; gap:12px; }
  .ic-title  { font-size:22px; font-weight:700; color:var(--text); letter-spacing:-.02em; margin:0; }

  /* flash messages */
  .ic-msg-ok  { background:#dcfce7; color:#15803d; border:1px solid #bbf7d0; padding:10px 16px; border-radius:var(--radius-xs); font-weight:600; margin-bottom:14px; }
  .ic-msg-err { background:#fee2e2; color:#b91c1c; border:1px solid #fecaca; padding:10px 16px; border-radius:var(--radius-xs); font-weight:600; margin-bottom:14px; }

  /* filter card */
  .ic-filter-card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); padding:18px 20px; margin-bottom:18px; }
  .ic-filter-row  { display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap; }
  .ic-filter-grp  { display:flex; flex-direction:column; gap:5px; flex:1; min-width:180px; }
  .ic-filter-grp label { font-size:11.5px; font-weight:600; color:var(--text-2); }
  .ic-filter-grp input, .ic-filter-grp select {
    padding:8px 12px; border:1px solid var(--border); border-radius:var(--radius-xs);
    font-size:13px; font-family:inherit; background:var(--surface); color:var(--text);
    transition:border-color .15s;
  }
  .ic-filter-grp input:focus, .ic-filter-grp select:focus {
    outline:none; border-color:var(--primary); box-shadow:0 0 0 3px rgba(59,130,246,.1);
  }

  /* table card */
  .ic-card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
  .ic-card-head { display:flex; align-items:center; justify-content:flex-end; padding:14px 20px; border-bottom:1px solid var(--border); background:var(--surface-2); }

  .ic-tbl   { width:100%; border-collapse:collapse; font-size:13.5px; }
  .ic-tbl th { padding:14px 16px; background:transparent; font-weight:600; font-size:14px; color:var(--muted); border-bottom:1px solid var(--border); white-space:nowrap; }
  .ic-tbl td { padding:14px 16px; border-bottom:1px solid var(--border); color:var(--text); vertical-align:middle; }
  .ic-tbl tbody tr:last-child td { border-bottom:none; }
  .ic-tbl tbody tr:hover td      { background:#f7f9ff; }
  .tc { text-align:center; }
  .tr { text-align:right; font-weight:700; }

  /* status badges */
  .stbadge { display:inline-flex; align-items:center; padding:3px 10px; border-radius:999px; font-size:12px; font-weight:700; border:1px solid transparent; }
  .st-enough  { background:#dcfce7; color:#15803d; border-color:#bbf7d0; }
  .st-missing { background:#fee2e2; color:#b91c1c; border-color:#fecaca; }

  /* counted input */
  .counted-inp {
    width:80px; padding:6px 10px; border:1px solid var(--border);
    border-radius:var(--radius-xs); font-size:13px; text-align:right;
    font-family:inherit; transition:border-color .15s;
  }
  .counted-inp:focus   { outline:none; border-color:var(--primary); box-shadow:0 0 0 3px rgba(59,130,246,.1); }
  .counted-inp.changed { border-color:#f59e0b; background:#fffbeb; }

  /* paging */
  .ic-paging { display:flex; align-items:center; justify-content:space-between; padding:14px 20px; border-top:1px solid var(--border); background:var(--surface-2); flex-wrap:wrap; gap:10px; }
  .ic-paging-info { font-size:13px; color:var(--muted); }
  .ic-paging-btns { display:flex; gap:6px; align-items:center; }
  .ic-paging-btns a, .ic-paging-btns span {
    display:inline-flex; align-items:center; padding:7px 13px;
    border:1px solid var(--border); border-radius:var(--radius-xs);
    background:var(--surface); font-size:13px; font-weight:600; color:var(--text); text-decoration:none;
  }
  .ic-paging-btns a:hover  { background:var(--surface-2); }
  .pg-active   { background:var(--primary) !important; border-color:var(--primary) !important; color:#fff !important; pointer-events:none; }
  .pg-disabled { opacity:.4; pointer-events:none; }
  .psz-wrap2 { display:flex; align-items:center; gap:8px; font-size:13px; color:var(--muted); }
  .psz-wrap2 select { padding:6px 10px; border:1px solid var(--border); border-radius:var(--radius-xs); font-size:13px; font-family:inherit; background:var(--surface); }
  .empty-row { text-align:center; padding:40px; color:var(--muted); font-size:14px; }
</style>

<div class="ic-wrap">

  <!-- Top bar -->
  <div class="ic-topbar">
    <div style="display:flex;align-items:center;gap:14px;">
      <a href="${ctx}/home?p=dashboard" class="btn btn-sm">← Back</a>
      <h1 class="ic-title">Conduct Inventory Count</h1>
    </div>
    <button type="button" class="btn btn-primary" id="btnSave">Save Count</button>
  </div>

  <%-- Flash messages (passed as query params after redirect) --%>
  <c:if test="${not empty param.msg}">
    <div class="ic-msg-ok">✓ ${fn:escapeXml(param.msg)}</div>
  </c:if>
  <c:if test="${not empty param.err}">
    <div class="ic-msg-err">✕ ${fn:escapeXml(param.err)}</div>
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
              <th class="tc">Color</th>
              <th class="tc">RAM</th>
              <th class="tc">Storage</th>
              <th class="tr">System Qty</th>
              <th class="tc">Counted Qty</th>
              <th class="tc">Status</th>
              <th class="tc">Action</th>
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
                <td class="tc">${fn:escapeXml(r.color)}</td>
                <td class="tc">${r.ramGb} GB</td>
                <td class="tc">${r.storageGb} GB</td>
                <td class="tr">
                  ${r.systemQty}
                  <span style="font-size:11px;color:var(--muted);">Phone</span>
                </td>
                <td class="tc">
                  <input type="hidden" name="skuId" value="${r.skuId}"/>
                  <div style="display:inline-flex;align-items:center;gap:6px;">
                    <input class="counted-inp js-counted"
                           type="number"
                           name="countedQty"
                           min="0"
                           value="${r.countedQty}"
                           data-system="${r.systemQty}"/>
                    <span style="font-size:12px;color:var(--muted);">Phone</span>
                  </div>
                </td>
                <td class="tc js-status-cell">
                  <c:choose>
                    <c:when test="${r.countedQty == r.systemQty}">
                      <span class="stbadge st-enough">enough</span>
                    </c:when>
                    <c:otherwise>
                      <span class="stbadge st-missing">missing</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="tc">
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
      <div class="ic-paging">
        <span class="ic-paging-info">
          Page ${pageNumber} / ${totalPages}
          &nbsp;•&nbsp; Total <strong>${totalItems}</strong> SKUs
        </span>

        <div class="ic-paging-btns">
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

        <div class="psz-wrap2">
          Show
          <select onchange="location.href='${ctx}/inventory-count?q=${fn:escapeXml(q)}&brandId=${fn:escapeXml(brandId)}&page=1&pageSize='+this.value">
            <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
          </select>
          Row
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
