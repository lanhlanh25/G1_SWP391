<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="role" value="${sessionScope.roleName}"/>

<link rel="stylesheet" href="${ctx}/assets/css/app.css">
<%-- Internal styles moved to app.css --%>

<div class="p-24">
  <div class="topbar mb-20">
    <div class="d-flex align-center gap-10">
      <a class="btn btn-outline" href="${ctx}/home?p=dashboard">← Back</a>
      <h1 class="h1">Export Management</h1>
    </div>
  </div>

  <div class="erl-card">

    <div class="er-toprow">
      <div style="display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
        <c:if test="${role eq 'STAFF'}">
          <a class="er-btn" href="${ctx}/home?p=create-export-receipt">+ Create Export Receipt</a>
        </c:if>
      </div>
    </div>

    <c:if test="${not empty param.msg}">
      <div class="alert alert-success mb-14">${fn:escapeXml(param.msg)}</div>
    </c:if>
    <c:if test="${not empty param.err}">
      <div class="alert alert-danger mb-14">${fn:escapeXml(param.err)}</div>
    </c:if>

    <form method="get" action="${ctx}/home">
      <input type="hidden" name="p" value="export-receipt-list"/>
      <div class="filters mb-12">
        <div class="d-flex gap-8 align-center flex-wrap">
          <input type="text" name="q" class="input" value="${fn:escapeXml(q)}" placeholder="Search Receipt..." style="min-width:220px;"/>
          <button class="btn btn-outline" type="submit">Search</button>
        </div>
        <div class="d-flex gap-8 align-center flex-wrap">
          <input type="date" name="from" class="input" value="${fn:escapeXml(from)}"/>
          <input type="date" name="to" class="input" value="${fn:escapeXml(to)}"/>
          <button class="btn btn-outline" type="submit">Apply</button>
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

    <div class="erl-tabs">
      <a class="erl-tab ${status=='all' || empty status ? 'active' : ''}" href="${tabAllUrl}">
        All <span class="cnt"><c:out value="${tabCounts['all']}"/></span>
      </a>
      <a class="erl-tab ${status=='pending' ? 'active' : ''}" href="${tabPendingUrl}">
        Pending <span class="cnt"><c:out value="${empty tabCounts['pending'] ? 0 : tabCounts['pending']}"/></span>
      </a>
      <a class="erl-tab ${status=='completed' ? 'active' : ''}" href="${tabCompletedUrl}">
        Completed <span class="cnt"><c:out value="${tabCounts['completed']}"/></span>
      </a>
      <a class="erl-tab ${status=='cancelled' ? 'active' : ''}" href="${tabCancelledUrl}">
        Cancelled <span class="cnt"><c:out value="${empty tabCounts['cancelled'] ? 0 : tabCounts['cancelled']}"/></span>
      </a>
    </div>

    <div class="table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th style="width:50px;" class="text-center">No</th>
            <th style="width:140px;">Receipt Code</th>
            <th>Request Code</th>
            <th>Created By</th>
            <th style="width:140px;">Export Date</th>
            <th style="width:80px;" class="text-center">Qty</th>
            <th>Category</th>
            <th style="width:120px;" class="text-center">Status</th>
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
              <td class="text-center text-muted">
                <c:out value="${(page-1)*pageSize + st.index + 1}"/>
              </td>
              <td class="fw-600"><c:out value="${r.exportCode}"/></td>
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
              <td class="text-muted"><c:out value="${r.exportDateUi}"/></td>
              <td class="text-center fw-700"><c:out value="${r.totalQty}"/></td>
              <td class="text-center"><span class="badge badge-outline">Phone</span></td>
              <td>
                <c:choose>
                  <c:when test="${r.status == 'CONFIRMED' || r.status == 'completed' || r.status == 'COMPLETED'}">
                    <span class="badge badge-active">Completed</span>
                  </c:when>
                  <c:when test="${r.status == 'pending' || r.status == 'PENDING'}">
                    <span class="badge badge-warning">Pending</span>
                  </c:when>
                  <c:when test="${r.status == 'cancelled' || r.status == 'CANCELLED' || r.status == 'CANCELED'}">
                    <span class="badge badge-inactive">Cancelled</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-active"><c:out value="${r.status}"/></span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <div class="d-flex gap-8 align-center justify-center flex-nowrap">
                  <a class="btn btn-sm btn-outline"
                     href="${ctx}/home?p=export-receipt-detail&id=${r.exportId}">View</a>
                  <a class="btn btn-sm btn-primary"
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

      <div class="paging-footer">
        <div class="paging-info">Page <b>${page}</b> of <b>${totalPages}</b></div>
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
