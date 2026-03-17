<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<link rel="stylesheet" href="${ctx}/app.css"/>

<style>
  .irr-wrap { padding: 24px; }
  .irr-topbar { display:flex; align-items:center; gap:14px; margin-bottom:24px; flex-wrap:wrap; }
  .irr-title  { font-size:22px; font-weight:800; color:var(--text); letter-spacing:-.02em; margin:0; }


  .irr-filter-card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); padding:18px 22px; margin-bottom:22px; }
  .irr-filter-row  { display:flex; gap:14px; align-items:flex-end; flex-wrap:wrap; }
  .irr-filter-grp  { display:flex; flex-direction:column; gap:5px; }
  .irr-filter-grp label { font-size:11.5px; font-weight:600; color:var(--text-2); }
  .irr-filter-grp input, .irr-filter-grp select {
    padding:8px 12px; border:1px solid var(--border); border-radius:var(--radius-xs);
    font-size:13px; font-family:inherit; background:var(--surface); color:var(--text);
    min-width:160px; transition:border-color .15s;
  }
  @media (max-width: 560px){
    .import-report-filters{ grid-template-columns: 1fr !important; }
    .import-report-filters .apply-wrap{ justify-content:stretch; }
    .import-report-filters .apply-wrap .btn{ width:100%; }
  }


  .irr-stats { display:flex; gap:14px; margin-bottom:22px; flex-wrap:wrap; }
  .irr-stat  { flex:1; min-width:180px; background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); padding:20px 22px; }
  .irr-stat .stat-label { font-size:12px; font-weight:600; color:var(--muted); text-transform:uppercase; letter-spacing:.06em; margin-bottom:8px; }
  .irr-stat .stat-val   { font-size:26px; font-weight:800; color:var(--text); letter-spacing:-.02em; }
  .irr-stat-primary { border-left:4px solid var(--primary); }
  .irr-stat-primary .stat-val { color:var(--primary-2); }
  .irr-stat-blue { background:var(--primary); border-color:var(--primary); }
  .irr-stat-blue .stat-label, .irr-stat-blue .stat-val { color:#fff; }


  .irr-card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
  .irr-tbl  { width:100%; border-collapse:collapse; font-size:13.5px; }
  .irr-tbl th { padding:11px 16px; background:#f8fafd; font-weight:700; font-size:12px; color:var(--text-2); text-transform:uppercase; letter-spacing:.04em; border-bottom:1px solid var(--border); white-space:nowrap; }
  .irr-tbl td { padding:13px 16px; border-bottom:1px solid var(--border); color:var(--text); vertical-align:middle; }
  .irr-tbl tbody tr:last-child td { border-bottom:none; }
  .irr-tbl tbody tr:hover td      { background:#f7f9ff; }
  .tr { text-align:right; font-weight:700; }


  .irr-paging { display:flex; align-items:center; justify-content:center; gap:8px; padding:16px 20px; border-top:1px solid var(--border); flex-wrap:wrap; }
  .irr-paging a, .irr-paging span {
    display:inline-flex; align-items:center; padding:7px 14px;
    border:1px solid var(--border); border-radius:var(--radius-xs);
    background:var(--surface); font-size:13px; font-weight:600; color:var(--text); text-decoration:none;
  }
  .irr-paging a:hover { background:var(--surface-2); }
  .pg-active   { background:var(--primary-light) !important; border-color:var(--primary-border) !important; color:var(--primary-2) !important; pointer-events:none; }
  .pg-disabled { opacity:.4; pointer-events:none; }
  .empty-row { text-align:center; padding:40px; color:var(--muted); font-size:14px; }
</style>

<div class="page-wrap">


  <div class="irr-topbar">
    <a href="${ctx}/home?p=dashboard" class="btn btn-sm">← Back</a>
    <h1 class="irr-title">Import Receipt Report</h1>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err">${fn:escapeXml(err)}</div>
  </c:if>


  <div class="irr-filter-card">
    <form method="get" action="${ctx}/import-receipt-report">
      <div class="irr-filter-row">
        <div class="irr-filter-grp">
          <label>From</label>
          <input type="date" name="from" value="${fn:escapeXml(from)}"/>
        </div>
        <div class="irr-filter-grp">
          <label>To</label>
          <input type="date" name="to" value="${fn:escapeXml(to)}"/>
        </div>
        <div class="irr-filter-grp">
          <label>Supplier</label>
          <select name="supplierId">
            <option value="">All suppliers</option>
            <c:forEach var="s" items="${suppliers}">
              <option value="${s.id}" ${supplierId == s.id ? 'selected' : ''}>
                ${fn:escapeXml(s.name)}
              </option>
            </c:forEach>
          </select>
        </div>
        <div style="display:flex;align-items:flex-end;">
          <button type="submit" class="btn btn-primary">Apply</button>
        </div>
      </div>
    </form>
  </div>


  <div class="irr-stats">
    <div class="irr-stat irr-stat-primary">
      <div class="stat-label">Total Import Receipts</div>
      <div class="stat-val">${reportSummary.totalReceipts}</div>
    </div>

    <div class="card stat-card-item" style="border-color: var(--primary-border); background: var(--primary-light);">
      <div class="muted-label">Total Phone Quantity</div>
      <div class="stat-value">
        <c:out value="${reportSummary.totalPhoneQty}" default="0"/> Phones
      </div>
    </div>
  </div>


  <div style="font-size:16px;font-weight:700;color:var(--text);margin:0 0 14px;">Import History</div>

  <table class="table">
    <thead>
      <tr>
        <th>RECEIPT CODE</th>
        <th>CREATED DATE</th>
        <th>SUPPLIER</th>
        <th>TOTAL QUANTITY</th>
        <th>STATUS</th>
      </tr>
    </thead>
    <tbody>
      <c:choose>
        <c:when test="${empty rows}">
          <tr>
            <td colspan="5" style="text-align:center; color:#64748b; font-weight:700;">
              No import receipts found
            </td>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty rows}">
            <tr><td colspan="5" class="empty-row">No import receipts found for the selected period.</td></tr>
          </c:if>

          <c:forEach var="r" items="${rows}">
            <tr>
              <td><c:out value="${r.importCode}"/></td>
              <td>
                <c:choose>
                  <c:when test="${not empty r.receiptDate}">
                    <fmt:formatDate value="${r.receiptDate}" pattern="yyyy-MM-dd HH:mm"/>
                  </c:when>
                  <c:otherwise>—</c:otherwise>
                </c:choose>
              </td>
              <td>${fn:escapeXml(r.supplierName)}</td>
              <td class="tr">
                ${r.totalQuantity}
                <span style="font-size:11px;color:var(--muted);margin-left:2px;">Phone</span>
              </td>
              <td>
    
                <span class="badge badge-active">Completed</span>
              </td>
            </tr>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </tbody>
  </table>


    <c:if test="${totalPages > 1}">
      <div class="irr-paging">
        <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}&supplierId=${supplierId}"/>

    <c:choose>
      <c:when test="${page > 1}">
        <a class="paging-btn" href="${ctx}/import-receipt-report?${qsBase}&page=${page - 1}">Prev</a>
      </c:when>
      <c:otherwise>
        <span class="paging-btn disabled">Prev</span>
      </c:otherwise>
    </c:choose>

    <c:forEach var="pg" begin="1" end="${totalPages}">
      <c:choose>
        <c:when test="${pg == page}">
          <b>${pg}</b>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/import-receipt-report?${qsBase}&page=${pg}">${pg}</a>
        </c:otherwise>
      </c:choose>
    </c:forEach>

    <c:choose>
      <c:when test="${page < totalPages}">
        <a class="paging-btn" href="${ctx}/import-receipt-report?${qsBase}&page=${page + 1}">Next</a>
      </c:when>
      <c:otherwise>
        <span class="paging-btn disabled">Next</span>
      </c:otherwise>
    </c:choose>
  </div>

  </div>
</div>
