<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
  .imei-wrap { padding: 24px; }
  .imei-topbar { display:flex; align-items:center; gap:14px; margin-bottom:22px; flex-wrap:wrap; }
  .imei-title  { font-size:22px; font-weight:800; color:var(--text); letter-spacing:-.02em; margin:0; }

  /* chips */
  .imei-chips { display:flex; gap:10px; margin-bottom:20px; flex-wrap:wrap; }
  .imei-chip {
    background:var(--primary); border-radius:var(--radius-sm);
    padding:12px 18px; color:#fff; flex:1; min-width:120px;
  }
  .imei-chip .chip-label { font-size:10.5px; font-weight:700; text-transform:uppercase; letter-spacing:.08em; opacity:.78; margin-bottom:5px; }
  .imei-chip .chip-val   { font-size:16px; font-weight:800; }

  /* search filter card */
  .imei-filter-card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); padding:16px 20px; margin-bottom:18px; }
  .imei-filter-row  { display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap; }
  .imei-filter-grp  { display:flex; flex-direction:column; gap:5px; flex:1; min-width:200px; }
  .imei-filter-grp label { font-size:11.5px; font-weight:600; color:var(--text-2); }
  .imei-filter-grp input {
    padding:8px 12px; border:1px solid var(--border); border-radius:var(--radius-xs);
    font-size:13px; font-family:inherit; background:var(--surface); color:var(--text);
    transition:border-color .15s;
  }
  .imei-filter-grp input:focus { outline:none; border-color:var(--primary); box-shadow:0 0 0 3px rgba(59,130,246,.1); }

  /* table card */
  .imei-card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
  .imei-tbl  { width:100%; border-collapse:collapse; font-size:13.5px; }
  .imei-tbl th { padding:11px 16px; background:#f8fafd; font-weight:700; font-size:12px; color:var(--text-2); text-transform:uppercase; letter-spacing:.04em; border-bottom:1px solid var(--border); white-space:nowrap; }
  .imei-tbl td { padding:12px 16px; border-bottom:1px solid var(--border); color:var(--text); vertical-align:middle; }
  .imei-tbl tbody tr:last-child td { border-bottom:none; }
  .imei-tbl tbody tr:hover td      { background:#f7f9ff; }
  .tc { text-align:center; }
  .tl { text-align:left; }
  .imei-mono { font-family:'Courier New',monospace; font-size:13.5px; font-weight:600; letter-spacing:.04em; }

  /* paging */
  .imei-paging { display:flex; align-items:center; justify-content:space-between; padding:14px 20px; border-top:1px solid var(--border); background:var(--surface-2); flex-wrap:wrap; gap:10px; }
  .imei-paging-info { font-size:13px; color:var(--muted); }
  .imei-paging-btns { display:flex; gap:6px; align-items:center; }
  .imei-paging-btns a, .imei-paging-btns span {
    display:inline-flex; align-items:center; padding:7px 13px;
    border:1px solid var(--border); border-radius:var(--radius-xs);
    background:var(--surface); font-size:13px; font-weight:600; color:var(--text); text-decoration:none;
  }
  .imei-paging-btns a:hover  { background:var(--surface-2); }
  .pg-active   { background:var(--primary) !important; border-color:var(--primary) !important; color:#fff !important; pointer-events:none; }
  .pg-disabled { opacity:.4; pointer-events:none; }
  .psz-wrap3 { display:flex; align-items:center; gap:8px; font-size:13px; color:var(--muted); }
  .psz-wrap3 select { padding:6px 10px; border:1px solid var(--border); border-radius:var(--radius-xs); font-size:13px; font-family:inherit; background:var(--surface); }
  .empty-row { text-align:center; padding:40px; color:var(--muted); font-size:14px; }
</style>

<div class="imei-wrap">

  <!-- Top bar -->
  <!-- back URL passed as param.back, fallback to inventory-count -->
  <div class="imei-topbar">
    <c:choose>
      <c:when test="${not empty param.back}">
        <a href="${fn:escapeXml(param.back)}" class="btn btn-sm">← Back</a>
      </c:when>
      <c:otherwise>
        <a href="${ctx}/inventory-count" class="btn btn-sm">← Back</a>
      </c:otherwise>
    </c:choose>
    <a href="${ctx}/home" class="btn btn-sm">Home</a>
    <h1 class="imei-title">View IMEI List</h1>
  </div>

  <!-- SKU info chips -->
  <!-- attrs: skuCode, productCode, productModel, color, ramGb, storageGb -->
  <div class="imei-chips">
    <div class="imei-chip">
      <div class="chip-label">SKU Code</div>
      <div class="chip-val">${fn:escapeXml(skuCode)}</div>
    </div>
    <div class="imei-chip">
      <div class="chip-label">Product Code</div>
      <div class="chip-val">${fn:escapeXml(productCode)}</div>
    </div>
    <div class="imei-chip">
      <div class="chip-label">Product Model</div>
      <div class="chip-val">${fn:escapeXml(productModel)}</div>
    </div>
    <div class="imei-chip">
      <div class="chip-label">Color</div>
      <div class="chip-val">${fn:escapeXml(color)}</div>
    </div>
    <div class="imei-chip">
      <div class="chip-label">RAM</div>
      <div class="chip-val">${ramGb} GB</div>
    </div>
    <div class="imei-chip">
      <div class="chip-label">Storage</div>
      <div class="chip-val">${storageGb} GB</div>
    </div>
  </div>

  <!-- Search filter -->
  <!-- attrs: q, skuId -->
  <div class="imei-filter-card">
    <form method="get" action="${ctx}/imei-list">
      <input type="hidden" name="skuId"    value="${skuId}"/>
      <input type="hidden" name="page"     value="1"/>
      <input type="hidden" name="pageSize" value="${pageSize}"/>
      <input type="hidden" name="back"     value="${fn:escapeXml(param.back)}"/>
      <div class="imei-filter-row">
        <div class="imei-filter-grp">
          <label>Search IMEI</label>
          <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search IMEI…"/>
        </div>
        <div style="display:flex;gap:8px;align-items:flex-end;">
         <button type="submit" class="btn btn-primary btn-sm btn-equal">Search</button>
          <c:url var="resetUrl" value="/imei-list">
            <c:param name="skuId" value="${skuId}"/>
            <c:param name="back"  value="${param.back}"/>
          </c:url>
        <a href="${resetUrl}" class="btn btn-outline btn-sm btn-equal">Reset</a>
        </div>
      </div>
    </form>
  </div>

  <!-- Table -->
  <!-- attrs: imeiRows = List<ImeiRow>; fields: imei, importDate(Timestamp), exportDate(Timestamp) -->
  <div class="imei-card">
    <div style="overflow-x:auto;">
      <table class="imei-tbl">
        <thead>
          <tr>
            <th class="tc" style="width:50px;">#</th>
            <th class="tl">IMEI</th>
            <th class="tc">Import Date</th>
            <th class="tc">Export Date</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty imeiRows}">
            <tr><td colspan="4" class="empty-row">No IMEI records found.</td></tr>
          </c:if>
          <c:forEach var="r" items="${imeiRows}" varStatus="st">
            <tr>
              <td class="tc" style="color:var(--muted);font-size:12px;">
                ${(pageNumber - 1) * pageSize + st.index + 1}
              </td>
              <td class="imei-mono tl">${fn:escapeXml(r.imei)}</td>
              <td class="tc" style="color:var(--text-2);">
                <c:choose>
                  <c:when test="${not empty r.importDate}">
                    <fmt:formatDate value="${r.importDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:when>
                  <c:otherwise><span style="color:var(--muted);">—</span></c:otherwise>
                </c:choose>
              </td>
              <td class="tc">
                <c:choose>
                  <c:when test="${not empty r.exportDate}">
                    <fmt:formatDate value="${r.exportDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:when>
                  <c:otherwise><span style="color:var(--muted);">-</span></c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <!-- Paging (attrs: pageNumber, pageSize, totalPages) -->
    <div class="imei-paging">
      <span class="imei-paging-info">
        Page ${pageNumber} / ${totalPages}
      </span>

      <div class="imei-paging-btns">
        <c:url var="prevUrl" value="/imei-list">
          <c:param name="skuId"    value="${skuId}"/>
          <c:param name="q"        value="${q}"/>
          <c:param name="page"     value="${pageNumber - 1}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="back"     value="${param.back}"/>
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
          <c:url var="pgUrl" value="/imei-list">
            <c:param name="skuId"    value="${skuId}"/>
            <c:param name="q"        value="${q}"/>
            <c:param name="page"     value="${pg}"/>
            <c:param name="pageSize" value="${pageSize}"/>
            <c:param name="back"     value="${param.back}"/>
          </c:url>
          <c:choose>
            <c:when test="${pg == pageNumber}"><span class="pg-active">${pg}</span></c:when>
            <c:otherwise><a href="${pgUrl}">${pg}</a></c:otherwise>
          </c:choose>
        </c:forEach>

        <c:url var="nextUrl" value="/imei-list">
          <c:param name="skuId"    value="${skuId}"/>
          <c:param name="q"        value="${q}"/>
          <c:param name="page"     value="${pageNumber + 1}"/>
          <c:param name="pageSize" value="${pageSize}"/>
          <c:param name="back"     value="${param.back}"/>
        </c:url>
        <a class="${pageNumber >= totalPages ? 'pg-disabled' : ''}" href="${nextUrl}">Next →</a>
      </div>

      <div class="psz-wrap3">
        Show
        <select onchange="
          location.href='${ctx}/imei-list?skuId=${skuId}&q=${fn:escapeXml(q)}&back='+encodeURIComponent('${fn:escapeXml(param.back)}')+'&page=1&pageSize='+this.value">
          <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 Row</option>
          <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 Row</option>
          <option value="50" ${pageSize == 50 ? 'selected' : ''}>50 Row</option>
        </select>
      </div>
    </div>

  </div><!-- /.imei-card -->
</div>
