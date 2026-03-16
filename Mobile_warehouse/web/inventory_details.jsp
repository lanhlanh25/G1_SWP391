<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
  .invd-wrap { padding: 24px; }
  .invd-topbar { display:flex; align-items:center; gap:14px; margin-bottom:22px; flex-wrap:wrap; }
  .invd-title  { font-size:22px; font-weight:800; color:var(--text); letter-spacing:-.02em; margin:0; }

  /* chips */
  .invd-chips { display:flex; gap:12px; margin-bottom:20px; flex-wrap:wrap; }
  .invd-chip {
    background:var(--primary); border-radius:var(--radius-sm);
    padding:14px 20px; color:#fff; min-width:150px; flex:1;
  }
  .invd-chip .chip-label { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.08em; opacity:.8; margin-bottom:6px; }
  .invd-chip .chip-val   { font-size:20px; font-weight:800; }

  /* table */
  .invd-card  { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
  .invd-tbl   { width:100%; border-collapse:collapse; font-size:13.5px; }
  .invd-tbl th { padding:11px 16px; background:#f8fafd; font-weight:700; font-size:12px; color:var(--text-2); text-transform:uppercase; letter-spacing:.04em; border-bottom:1px solid var(--border); white-space:nowrap; }
  .invd-tbl td { padding:12px 16px; border-bottom:1px solid var(--border); color:var(--text); vertical-align:middle; }
  .invd-tbl tbody tr:last-child td { border-bottom:none; }
  .invd-tbl tbody tr:hover td      { background:#f7f9ff; }
  .tc { text-align:center; }
  .tr { text-align:right; font-weight:700; }
  .tl { text-align:left; }

  /* status badges */
  .stbadge { display:inline-flex; align-items:center; padding:5px 14px; border-radius:999px; font-size:12.5px; font-weight:700; border:1px solid transparent; }
  .st-ok  { background:#dcfce7; color:#15803d; border-color:#bbf7d0; }
  .st-low { background:#fef3c7; color:#92400e; border-color:#fde68a; }
  .st-out { background:#fee2e2; color:#b91c1c; border-color:#fecaca; }

  /* ROP hint */
  .rop-hint { font-size:11px; color:var(--muted); margin-top:3px; }

  /* paging */
  .inv-paging { display:flex; align-items:center; justify-content:space-between; padding:14px 20px; border-top:1px solid var(--border); background:var(--surface-2); flex-wrap:wrap; gap:10px; }
  .inv-paging-info { font-size:13px; color:var(--muted); }
  .inv-paging-btns { display:flex; gap:6px; align-items:center; }
  .inv-paging-btns a, .inv-paging-btns span {
    display:inline-flex; align-items:center; padding:7px 13px;
    border:1px solid var(--border); border-radius:var(--radius-xs);
    background:var(--surface); font-size:13px; font-weight:600; color:var(--text); text-decoration:none;
  }
  .inv-paging-btns a:hover  { background:var(--surface-2); }
  .pg-active   { background:var(--primary) !important; border-color:var(--primary) !important; color:#fff !important; pointer-events:none; }
  .pg-disabled { opacity:.4; pointer-events:none; }
  .psz-wrap { display:flex; align-items:center; gap:8px; font-size:13px; color:var(--muted); }
  .psz-wrap select { padding:6px 10px; border:1px solid var(--border); border-radius:var(--radius-xs); font-size:13px; font-family:inherit; background:var(--surface); }
  .empty-row { text-align:center; padding:40px; color:var(--muted); font-size:14px; }
</style>

<div class="invd-wrap">

  <div class="invd-topbar">
    <a href="${ctx}/inventory" class="btn btn-sm">← Back</a>
    <a href="${ctx}/home"      class="btn btn-sm">Home</a>
    <h1 class="invd-title">Inventory Details</h1>
  </div>

  <div class="invd-chips">
    <div class="invd-chip">
      <div class="chip-label">Quantity</div>
      <div class="chip-val">${totalQty} Phone</div>
    </div>
    <div class="invd-chip">
      <div class="chip-label">Product Code</div>
      <div class="chip-val">${fn:escapeXml(productCode)}</div>
    </div>
    <div class="invd-chip">
      <div class="chip-label">Product Model</div>
      <div class="chip-val">${fn:escapeXml(productModel)}</div>
    </div>
  </div>

  <c:url var="backToDetails" value="/inventory-details">
    <c:param name="productCode" value="${productCode}"/>
    <c:param name="page"        value="${pageNumber}"/>
    <c:param name="pageSize"    value="${pageSize}"/>
  </c:url>

  <div class="invd-card">
    <div style="overflow-x:auto;">
      <table class="invd-tbl">
        <thead>
          <tr>
            <th class="tl">SKU</th>
            <th class="tc">Color</th>
            <th class="tc">RAM</th>
            <th class="tc">Storage</th>
            <th class="tc">
              Inventory Status
            
            </th>
            <th class="tr">Quantity</th>
            <th class="tc">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty skuRows}">
            <tr><td colspan="7" class="empty-row">No SKU variants found.</td></tr>
          </c:if>
          <c:forEach var="s" items="${skuRows}">
            <tr>
              <td class="tl" style="font-weight:700;">${fn:escapeXml(s.skuCode)}</td>
              <td class="tc">${fn:escapeXml(s.color)}</td>
              <td class="tc">${s.ramGb} GB</td>
              <td class="tc">${s.storageGb} GB</td>
              <td class="tc">
                <%-- Badge theo ROP: OUT / LOW / OK --%>
                <c:choose>
                  <c:when test="${s.stockStatus == 'OK'}">
                    <span class="stbadge st-ok">In Stock</span>
                  </c:when>
                  <c:when test="${s.stockStatus == 'LOW'}">
                    <span class="stbadge st-low"
                          title="Stock (${s.qty}) ≤ ROP (${s.rop}) — reorder recommended">
                      Low Stock
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="stbadge st-out">Out of Stock</span>
                  </c:otherwise>
                </c:choose>
                <%-- Hiển thị ROP nhỏ bên dưới để manager tham khảo --%>
                <div class="rop-hint">ROP: ${s.rop}</div>
              </td>
              <td class="tr">
                ${s.qty}
                <span style="font-size:11px;color:var(--muted);margin-left:2px;">Phone</span>
              </td>
              <td class="tc">
                <c:url var="imeiUrl" value="/imei-list">
                  <c:param name="skuId"    value="${s.skuId}"/>
                  <c:param name="page"     value="1"/>
                  <c:param name="pageSize" value="10"/>
                  <c:param name="back"     value="${backToDetails}"/>
                </c:url>
                <a class="btn btn-sm btn-outline" href="${imeiUrl}">View List IMEI</a>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <div class="inv-paging">
      <span class="inv-paging-info">Page ${pageNumber} / ${totalPages}</span>

      <div class="inv-paging-btns">
        <c:url var="prevUrl" value="/inventory-details">
          <c:param name="productCode" value="${productCode}"/>
          <c:param name="page"        value="${pageNumber - 1}"/>
          <c:param name="pageSize"    value="${pageSize}"/>
        </c:url>
        <a class="${pageNumber <= 1 ? 'pg-disabled' : ''}" href="${prevUrl}">← Prev</a>

        <c:choose>
          <c:when test="${totalPages <= 5}">
            <c:set var="pgStart" value="1"/><c:set var="pgEnd" value="${totalPages}"/>
          </c:when>
          <c:when test="${pageNumber <= 3}">
            <c:set var="pgStart" value="1"/><c:set var="pgEnd" value="5"/>
          </c:when>
          <c:when test="${pageNumber >= totalPages - 2}">
            <c:set var="pgStart" value="${totalPages - 4}"/><c:set var="pgEnd" value="${totalPages}"/>
          </c:when>
          <c:otherwise>
            <c:set var="pgStart" value="${pageNumber - 2}"/><c:set var="pgEnd" value="${pageNumber + 2}"/>
          </c:otherwise>
        </c:choose>

        <c:forEach begin="${pgStart}" end="${pgEnd}" var="pg">
          <c:url var="pgUrl" value="/inventory-details">
            <c:param name="productCode" value="${productCode}"/>
            <c:param name="page"        value="${pg}"/>
            <c:param name="pageSize"    value="${pageSize}"/>
          </c:url>
          <c:choose>
            <c:when test="${pg == pageNumber}"><span class="pg-active">${pg}</span></c:when>
            <c:otherwise><a href="${pgUrl}">${pg}</a></c:otherwise>
          </c:choose>
        </c:forEach>

        <c:url var="nextUrl" value="/inventory-details">
          <c:param name="productCode" value="${productCode}"/>
          <c:param name="page"        value="${pageNumber + 1}"/>
          <c:param name="pageSize"    value="${pageSize}"/>
        </c:url>
        <a class="${pageNumber >= totalPages ? 'pg-disabled' : ''}" href="${nextUrl}">Next →</a>
      </div>

      <div class="psz-wrap">
        Show
        <select onchange="location.href='${ctx}/inventory-details?productCode=${fn:escapeXml(productCode)}&page=1&pageSize='+this.value">
          <option value="5"  ${pageSize == 5  ? 'selected' : ''}>5</option>
          <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
          <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
        </select>
        Row
      </div>
    </div>
  </div>

</div>
