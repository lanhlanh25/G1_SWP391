<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="role" value="${sessionScope.roleName}"/>

<style>
  .er-list-wrap { padding: 24px; }
  .er-list-card {
    background: var(--surface); border: 1px solid var(--border);
    border-radius: var(--radius); box-shadow: var(--shadow); padding: 20px 24px;
  }
  .er-toprow { display: flex; justify-content: space-between; align-items: center; gap: 10px; margin-bottom: 16px; flex-wrap: wrap; }
  .er-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 7px 16px; border: 1px solid var(--border);
    border-radius: var(--radius-sm); background: var(--surface);
    font-size: 13px; font-weight: 600; color: var(--text-2);
    cursor: pointer; text-decoration: none; transition: all .15s;
  }
  .er-btn:hover { background: var(--surface-2); color: var(--text); text-decoration: none; }
  .er-btn.primary { background: var(--primary); border-color: var(--primary); color: #fff; }
  .er-btn.primary:hover { background: var(--primary-2); }
  .er-filters { display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 12px; }
  .er-left-f, .er-right-f { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
  .er-list-wrap input[type="text"], .er-list-wrap input[type="date"], .er-list-wrap select {
    padding: 7px 12px; border: 1px solid var(--border); border-radius: var(--radius-sm);
    font-size: 13px; background: var(--surface); color: var(--text);
  }
  .er-list-wrap input:focus, .er-list-wrap select:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 3px rgba(50,31,219,.12); }
  .er-tabs { display: flex; gap: 6px; margin-bottom: 16px; flex-wrap: wrap; }
  .er-tab {
    display: inline-flex; gap: 6px; align-items: center; padding: 6px 14px;
    border: 1px solid var(--border); border-radius: var(--radius-sm);
    background: var(--surface); text-decoration: none; color: var(--text-2);
    font-size: 13px; font-weight: 600; transition: all .15s;
  }
  .er-tab:hover { text-decoration: none; }
  .er-tab.active { background: var(--primary); border-color: var(--primary); color: #fff; }
  .er-tab .cnt { background: rgba(50,31,219,.12); color: var(--primary); border-radius: 999px; padding: 1px 8px; font-size: 11px; font-weight: 700; }
  .er-tab.active .cnt { background: rgba(255,255,255,.25); color: #fff; }
  .er-table { border-collapse: separate; border-spacing: 0; width: 100%; font-size: 13px; border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; }
  .er-table th, .er-table td { border-bottom: 1px solid var(--border); padding: 10px 12px; vertical-align: middle; }
  .er-table th { background: var(--surface-2); font-weight: 600; color: var(--text-2); font-size: 12px; text-transform: uppercase; letter-spacing: .03em; white-space: nowrap; }
  .er-table td { color: var(--text); }
  .er-table tbody tr:hover { background: #f3f4f7; }
  .er-table tbody tr:last-child td { border-bottom: none; }
  .muted-cell { color: var(--muted); text-align: center; }
  .status-badge { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: var(--radius-sm); font-size: 12px; font-weight: 700; }
  .status-completed { background: #e6f9ed; color: #0d6832; border: 1px solid #b5e8c5; }
  .status-pending { background: #fff8e1; color: #7c5e00; border: 1px solid #ffe082; }
  .status-cancelled { background: #fdf0f0; color: #b91c1c; border: 1px solid #f5c6cb; }
  .cat-badge { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: var(--radius-sm); font-size: 12px; font-weight: 700; background: var(--primary-light); color: var(--primary); border: 1px solid var(--primary-border); }
  .er-actions { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
  .er-pager { display: flex; justify-content: flex-end; gap: 6px; margin-top: 16px; align-items: center; }
  .er-pill { display: inline-flex; align-items: center; justify-content: center; min-width: 36px; padding: 6px 10px; border: 1px solid var(--border); border-radius: var(--radius-sm); background: var(--surface); font-size: 13px; font-weight: 600; color: var(--text-2); }
  .er-pill.active { background: var(--primary); border-color: var(--primary); color: #fff; }
  .er-alert-ok { padding: 10px 14px; border: 1px solid #b5e8c5; background: #e6f9ed; border-radius: var(--radius-sm); color: #0d6832; font-size: 13px; font-weight: 600; margin-bottom: 14px; }
  .er-alert-err { padding: 10px 14px; border: 1px solid #f5c6cb; background: #fdf0f0; border-radius: var(--radius-sm); color: #b91c1c; font-size: 13px; font-weight: 600; margin-bottom: 14px; }
</style>

<div class="er-list-wrap">
  <div class="topbar" style="margin-bottom: 20px;">
    <div style="display:flex; align-items:center; gap:10px;">
      <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
      <h1 class="h1">Export Receipts</h1>
    </div>
  </div>

  <div class="er-list-card">

    <div class="er-toprow">
      <div style="display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
        <c:if test="${role eq 'STAFF'}">
          <a class="er-btn" href="${ctx}/home?p=create-export-receipt">+ Create Export Receipt</a>
        </c:if>
      </div>
    </div>

    <c:if test="${not empty param.msg}">
      <div class="er-alert-ok">${fn:escapeXml(param.msg)}</div>
    </c:if>
    <c:if test="${not empty param.err}">
      <div class="er-alert-err">${fn:escapeXml(param.err)}</div>
    </c:if>

    <form method="get" action="${ctx}/home">
      <input type="hidden" name="p" value="export-receipt-list"/>
      <div class="er-filters">
        <div class="er-left-f">
          <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search by Receipt Code" style="min-width:220px;"/>
          <button class="er-btn" type="submit">Search</button>
        </div>
        <div class="er-right-f">
          <input type="date" name="from" value="${fn:escapeXml(from)}"/>
          <input type="date" name="to" value="${fn:escapeXml(to)}"/>
          <button class="er-btn" type="submit">Apply</button>
        </div>
      </div>
    </form>

    <c:url var="tabAllUrl" value="/home">
      <c:param name="p" value="export-receipt-list"/><c:param name="page" value="1"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="all"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>
    <c:url var="tabPendingUrl" value="/home">
      <c:param name="p" value="export-receipt-list"/><c:param name="page" value="1"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="pending"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>
    <c:url var="tabCompletedUrl" value="/home">
      <c:param name="p" value="export-receipt-list"/><c:param name="page" value="1"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="completed"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>
    <c:url var="tabCancelledUrl" value="/home">
      <c:param name="p" value="export-receipt-list"/><c:param name="page" value="1"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="cancelled"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>

    <div class="er-tabs">
      <a class="er-tab ${status=='all' || empty status ? 'active' : ''}" href="${tabAllUrl}">
        All <span class="cnt"><c:out value="${tabCounts['all']}"/></span>
      </a>
      <a class="er-tab ${status=='pending' ? 'active' : ''}" href="${tabPendingUrl}">
        Pending <span class="cnt"><c:out value="${empty tabCounts['pending'] ? 0 : tabCounts['pending']}"/></span>
      </a>
      <a class="er-tab ${status=='completed' ? 'active' : ''}" href="${tabCompletedUrl}">
        Completed <span class="cnt"><c:out value="${tabCounts['completed']}"/></span>
      </a>
      <a class="er-tab ${status=='cancelled' ? 'active' : ''}" href="${tabCancelledUrl}">
        Cancelled <span class="cnt"><c:out value="${empty tabCounts['cancelled'] ? 0 : tabCounts['cancelled']}"/></span>
      </a>
    </div>

    <div style="overflow-x:auto;">
      <table class="er-table">
        <thead>
          <tr>
            <th style="width:50px;">No</th>
            <th>Receipt Code</th>
            <th>Request Code</th>
            <th>Created By</th>
            <th>Export Date</th>
            <th>Total Qty</th>
            <th>Category</th>
            <th>Status</th>
            <th style="width:180px;">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty rows}">
            <tr>
              <td colspan="9" class="muted-cell" style="padding:24px;">No data found</td>
            </tr>
          </c:if>

          <c:forEach var="r" items="${rows}" varStatus="st">
            <tr>
              <td style="text-align:center;color:var(--muted);">
                <c:out value="${(page-1)*pageSize + st.index + 1}"/>
              </td>
              <td style="font-weight:600;"><c:out value="${r.exportCode}"/></td>
              <td>
                <c:choose>
                  <c:when test="${empty r.requestCode || r.requestCode == '-'}">
                    <span style="color:var(--muted);">N/A</span>
                  </c:when>
                  <c:otherwise>
                    <c:out value="${r.requestCode}"/>
                  </c:otherwise>
                </c:choose>
              </td>
              <td><c:out value="${r.createdByName}"/></td>
              <td style="color:var(--muted);"><c:out value="${r.exportDateUi}"/></td>
              <td style="font-weight:700;text-align:center;"><c:out value="${r.totalQty}"/></td>
              <td><span class="cat-badge">Phone</span></td>
              <td>
                <c:choose>
                  <c:when test="${r.status == 'CONFIRMED' || r.status == 'completed' || r.status == 'COMPLETED'}">
                    <span class="status-badge status-completed">Completed</span>
                  </c:when>
                  <c:when test="${r.status == 'pending' || r.status == 'PENDING'}">
                    <span class="status-badge status-pending">Pending</span>
                  </c:when>
                  <c:when test="${r.status == 'cancelled' || r.status == 'CANCELLED' || r.status == 'CANCELED'}">
                    <span class="status-badge status-cancelled">Cancelled</span>
                  </c:when>
                  <c:otherwise>
                    <span class="status-badge status-completed"><c:out value="${r.status}"/></span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <div class="er-actions">
                  <a class="er-btn" style="padding:5px 12px;font-size:12px;"
                     href="${ctx}/home?p=export-receipt-detail&id=${r.exportId}">View</a>
                  <a class="er-btn primary" style="padding:5px 12px;font-size:12px;"
                     href="${ctx}/export-receipt-pdf?id=${r.exportId}" target="_blank">PDF</a>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <c:url var="prevUrl" value="/home">
      <c:param name="p" value="export-receipt-list"/><c:param name="page" value="${page-1}"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>
    <c:url var="nextUrl" value="/home">
      <c:param name="p" value="export-receipt-list"/><c:param name="page" value="${page+1}"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>

      <div class="paging-footer" style="justify-content:flex-end;">
        <div class="paging">
          <c:choose>
            <c:when test="${page <= 1}">
              <span class="paging-btn disabled">← Prev</span>
            </c:when>
            <c:otherwise>
              <a class="paging-btn" href="${prevUrl}">← Prev</a>
            </c:otherwise>
          </c:choose>

          <c:forEach begin="1" end="${totalPages}" var="i">
            <c:choose>
              <c:when test="${i == page}">
                <span class="paging-btn active">${i}</span>
              </c:when>
              <c:otherwise>
                <c:url var="pageUrl" value="/home">
                  <c:param name="p" value="export-receipt-list"/><c:param name="page" value="${i}"/>
                  <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
                  <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
                </c:url>
                <a class="paging-btn" href="${pageUrl}">${i}</a>
              </c:otherwise>
            </c:choose>
          </c:forEach>

          <c:choose>
            <c:when test="${page >= totalPages}">
              <span class="paging-btn disabled">Next →</span>
            </c:when>
            <c:otherwise>
              <a class="paging-btn" href="${nextUrl}">Next →</a>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

  </div>
</div>