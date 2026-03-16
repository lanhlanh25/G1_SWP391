<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  .ir-list-wrap { padding: 24px; }
  .ir-list-card {
    background: var(--surface, #fff);
    border: 1px solid var(--border, #e2e8f2);
    border-radius: var(--radius, 16px);
    box-shadow: var(--shadow, 0 4px 16px rgba(16,24,40,.06));
    padding: 20px 24px;
  }

  .ir-toprow {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;
    flex-wrap: wrap;
  }

  .ir-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border: 1px solid var(--border, #e2e8f2);
    border-radius: var(--radius-xs, 8px);
    background: var(--surface, #fff);
    font-size: 13px;
    font-weight: 600;
    color: var(--text, #0d1829);
    cursor: pointer;
    text-decoration: none;
    transition: background .15s, border-color .15s;
  }
  .ir-btn:hover { background: var(--surface-2, #f8fafc); color: var(--text,#0d1829); }
  .ir-btn.primary {
    background: var(--primary, #3b82f6);
    border-color: var(--primary, #3b82f6);
    color: #fff;
  }
  .ir-btn.primary:hover { background: var(--primary-2, #2563eb); }

  .ir-filters {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 12px;
  }
  .ir-left-f, .ir-right-f {
    display: flex;
    gap: 8px;
    align-items: center;
    flex-wrap: wrap;
  }

  .ir-list-wrap input[type="text"],
  .ir-list-wrap input[type="date"],
  .ir-list-wrap select {
    padding: 8px 12px;
    border: 1px solid var(--border, #e2e8f2);
    border-radius: var(--radius-xs, 8px);
    font-size: 13px;
    background: var(--surface, #fff);
    color: var(--text, #0d1829);
  }

  /* Tabs */
  .ir-tabs {
    display: flex;
    gap: 6px;
    margin-bottom: 16px;
    flex-wrap: wrap;
  }
  .ir-tab {
    display: inline-flex;
    gap: 6px;
    align-items: center;
    padding: 7px 14px;
    border: 1px solid var(--border, #e2e8f2);
    border-radius: 20px;
    background: var(--surface, #fff);
    text-decoration: none;
    color: var(--text-2, #334155);
    font-size: 13px;
    font-weight: 600;
    transition: background .15s, border-color .15s;
  }
  .ir-tab.active {
    background: var(--primary-light, #eff6ff);
    border-color: var(--primary-border, #bfdbfe);
    color: var(--primary-2, #2563eb);
  }
  .ir-tab .cnt {
    background: rgba(59,130,246,.12);
    color: var(--primary-2, #2563eb);
    border-radius: 20px;
    padding: 1px 8px;
    font-size: 11.5px;
    font-weight: 700;
  }
  .ir-tab.active .cnt {
    background: var(--primary, #3b82f6);
    color: #fff;
  }

  /* Table */
  .ir-table {
    border-collapse: collapse;
    width: 100%;
    font-size: 13px;
  }
  .ir-table th, .ir-table td {
    border: 1px solid var(--border, #e2e8f2);
    padding: 10px 12px;
    vertical-align: middle;
  }
  .ir-table th {
    background: var(--surface-2, #f8fafc);
    font-weight: 700;
    color: var(--text-2, #334155);
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: .04em;
    white-space: nowrap;
  }
  .ir-table td { color: var(--text, #0d1829); }
  .ir-table tbody tr:hover { background: var(--surface-2, #f8fafc); }
  .muted-cell { color: var(--muted, #64748b); text-align: center; }

  /* Status badges */
  .status-badge {
    display: inline-flex;
    align-items: center;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 700;
  }
 .status-completed { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
  .status-pending   { background: #fffbeb; color: #92400e; border: 1px solid #fcd34d; }
  .status-cancelled { background: #fef2f2; color: #b91c1c; border: 1px solid #fca5a5; }

  /* Category badge */
  .cat-badge {
    display: inline-flex;
    align-items: center;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 700;
    background: var(--primary-light, #eff6ff);
    color: var(--primary-2, #2563eb);
    border: 1px solid var(--primary-border, #bfdbfe);
  }

  /* Actions cell */
  .ir-actions {
    display: flex;
    gap: 6px;
    align-items: center;
    flex-wrap: wrap;
  }

  /* Pager */
  .ir-pager {
    display: flex;
    justify-content: flex-end;
    gap: 6px;
    margin-top: 16px;
    align-items: center;
  }
  .ir-pill {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 36px;
    padding: 6px 10px;
    border: 1px solid var(--border, #e2e8f2);
    border-radius: 8px;
    background: var(--surface, #fff);
    font-size: 13px;
    font-weight: 600;
    color: var(--text-2, #334155);
  }
  .ir-pill.active {
    background: var(--primary, #3b82f6);
    border-color: var(--primary, #3b82f6);
    color: #fff;
  }

  /* Alert */
  .ir-alert-ok {
    padding: 10px 14px;
    border: 1px solid #86efac;
    background: #f0fdf4;
    border-radius: 10px;
    color: #166534;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 14px;
  }
  .ir-alert-err {
    padding: 10px 14px;
    border: 1px solid #fca5a5;
    background: #fef2f2;
    border-radius: 10px;
    color: #b91c1c;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 14px;
  }
</style>

<div class="ir-list-wrap">
  <div class="ir-list-card">

    <!-- Top row: only EXPORT for all roles, CREATE only for STAFF -->
    <div class="ir-toprow">
      <div style="display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
        <form method="get" action="${ctx}/home" style="display:inline;">
          <input type="hidden" name="p" value="import-receipt-list"/>
          <input type="hidden" name="action" value="export"/>
          <button type="submit" class="ir-btn primary">Export Excel</button>
        </form>

        <c:if test="${role eq 'STAFF'}">
          <a class="ir-btn" href="${ctx}/home?p=create-import-receipt">+ Create Import Receipt</a>
        </c:if>
      </div>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty param.msg}">
      <div class="ir-alert-ok">${fn:escapeXml(param.msg)}</div>
    </c:if>
    <c:if test="${not empty param.err}">
      <div class="ir-alert-err">${fn:escapeXml(param.err)}</div>
    </c:if>

    <!-- Filters -->
    <form method="get" action="${ctx}/home">
      <input type="hidden" name="p" value="import-receipt-list"/>
      <div class="ir-filters">
        <div class="ir-left-f">
          <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search by Receipt Code" style="min-width:220px;"/>
          <button class="ir-btn" type="submit">Search</button>
        </div>
        <div class="ir-right-f">
          <input type="date" name="from" value="${fn:escapeXml(from)}"/>
          <input type="date" name="to" value="${fn:escapeXml(to)}"/>
          <button class="ir-btn" type="submit">Apply</button>
        </div>
      </div>
    </form>

    <!-- Status tabs: only ALL and COMPLETED -->
    <c:url var="tabAllUrl" value="/home">
      <c:param name="p" value="import-receipt-list"/><c:param name="page" value="1"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="all"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>
    <c:url var="tabCompletedUrl" value="/home">
      <c:param name="p" value="import-receipt-list"/><c:param name="page" value="1"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="completed"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>

    <div class="ir-tabs">
      <a class="ir-tab ${status=='all' || empty status ? 'active' : ''}" href="${tabAllUrl}">
        All <span class="cnt"><c:out value="${tabCounts['all']}"/></span>
      </a>
      <a class="ir-tab ${status=='completed' ? 'active' : ''}" href="${tabCompletedUrl}">
        Completed <span class="cnt"><c:out value="${tabCounts['completed']}"/></span>
      </a>
    </div>

    <!-- Table -->
    <div style="overflow-x:auto;">
      <table class="ir-table">
        <thead>
          <tr>
            <th style="width:50px;">No</th>
            <th>Receipt Code</th>
            <th>Supplier</th>
            <th>Created By</th>
            <th>Created Date</th>
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
              <td style="font-weight:600;"><c:out value="${r.importCode}"/></td>
              <td><c:out value="${r.supplierName}"/></td>
              <td><c:out value="${r.createdByName}"/></td>
              <td style="color:var(--muted);"><c:out value="${r.receiptDate}"/></td>
              <td style="font-weight:700;text-align:center;"><c:out value="${r.totalQuantity}"/></td>
              <td><span class="cat-badge">Phone</span></td>
              <td>
                <c:choose>
                  <c:when test="${r.statusUi == 'CONFIRMED' || r.statusUi == 'completed' || r.statusUi == 'COMPLETED'}">
                    <span class="status-badge status-completed">Completed</span>
                  </c:when>
                  <c:when test="${r.statusUi == 'pending' || r.statusUi == 'PENDING'}">
                    <span class="status-badge status-pending">Pending</span>
                  </c:when>
                  <c:when test="${r.statusUi == 'cancelled' || r.statusUi == 'CANCELLED' || r.statusUi == 'CANCELED'}">
                    <span class="status-badge status-cancelled">Cancelled</span>
                  </c:when>
                  <c:otherwise>
                    <span class="status-badge status-completed">Completed</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <div class="ir-actions">
                  <a class="ir-btn" style="padding:5px 12px;font-size:12px;"
                     href="${ctx}/home?p=import-receipt-detail&id=${r.importId}">View</a>
                  <a class="ir-btn primary" style="padding:5px 12px;font-size:12px;"
                     href="${ctx}/import-receipt-pdf?id=${r.importId}">PDF</a>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <!-- Pager -->
    <c:url var="prevUrl" value="/home">
      <c:param name="p" value="import-receipt-list"/><c:param name="page" value="${page-1}"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>
    <c:url var="nextUrl" value="/home">
      <c:param name="p" value="import-receipt-list"/><c:param name="page" value="${page+1}"/>
      <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
      <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
    </c:url>

    <c:if test="${totalPages > 1}">
      <div class="ir-pager">
        <c:choose>
          <c:when test="${page <= 1}">
            <span class="ir-btn" style="opacity:.4;pointer-events:none;">← Prev</span>
          </c:when>
          <c:otherwise>
            <a class="ir-btn" href="${prevUrl}">← Prev</a>
          </c:otherwise>
        </c:choose>

        <span class="ir-pill active"><c:out value="${page}"/> / <c:out value="${totalPages}"/></span>

        <c:choose>
          <c:when test="${page >= totalPages}">
            <span class="ir-btn" style="opacity:.4;pointer-events:none;">Next →</span>
          </c:when>
          <c:otherwise>
            <a class="ir-btn" href="${nextUrl}">Next →</a>
          </c:otherwise>
        </c:choose>
      </div>
    </c:if>

  </div>
</div>
