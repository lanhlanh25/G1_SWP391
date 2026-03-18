<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

  <div class="topbar">
    <div style="display:flex; align-items:center; gap:10px;">
      <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
      <h1 class="h1">View Import Request List</h1>
    </div>
  </div>

  <c:if test="${not empty param.msg}">
    <div class="msg-ok">${param.msg}</div>
  </c:if>

  <div class="card">
    <div class="card-body">
      <div class="h2" style="margin-bottom:6px;">Manage Import Requests</div>
      <div class="muted" style="margin-bottom:14px;">Track and process incoming material requests from different departments.</div>

      <form method="get" action="${ctx}/home" class="filters" style="grid-template-columns: 1.2fr 0.8fr 1fr 1fr auto auto; gap: 12px; align-items: end;">
        <input type="hidden" name="p" value="import-request-list"/>
        
        <div class="filter-group">
          <label>Search Request</label>
          <input class="input" type="text" name="q" placeholder="Request code..." value="${fn:escapeXml(q)}"/>
        </div>
        
        <div class="filter-group">
          <label>Status</label>
          <select class="select" name="status">
            <option value="">All Status</option>
            <option value="NEW" ${status eq 'NEW' ? 'selected' : ''}>New</option>
            <option value="COMPLETE" ${status eq 'COMPLETE' ? 'selected' : ''}>Complete</option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>Request Date</label>
          <input class="input" type="date" name="reqDate" value="${reqDate}"/>
        </div>
        
        <div class="filter-group">
          <label>Exp. Import Date</label>
          <input class="input" type="date" name="expDate" value="${expDate}"/>
        </div>
        
        <div class="filter-actions" style="display:contents;">
          <button class="btn btn-primary" type="submit" style="height: 38px;">Apply</button>
          <a class="btn" href="${ctx}/home?p=import-request-list" style="height: 38px;">Reset</a>
        </div>
      </form>

      <table class="table">
        <thead>
          <tr>
            <th>Request Code</th>
            <th>Created By</th>
            <th>Request Date</th>
            <th>Expected Date</th>
            <th style="width:100px; text-align:center;">Items</th>
            <th style="width:100px; text-align:center;">Qty</th>
            <th style="width:120px; text-align:center;">Status</th>
            <th style="width:240px;">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty irList}">
            <tr><td colspan="8" style="text-align:center; padding:24px; color:var(--muted);">No requests found.</td></tr>
          </c:if>

          <c:forEach var="r" items="${irList}">
            <tr>
              <td style="font-weight:600;">${fn:escapeXml(r.requestCode)}</td>
              <td>${fn:escapeXml(r.createdByName)}</td>
              <td style="color:var(--muted);"><c:out value="${r.requestDate}"/></td>
              <td style="color:var(--muted);"><c:out value="${r.expectedImportDate}"/></td>
              <td style="text-align:center;">${r.totalItems}</td>
              <td style="text-align:center; font-weight:700;">${r.totalQty}</td>
              <td style="text-align:center;">
                <c:choose>
                  <c:when test="${r.status eq 'COMPLETE'}">
                    <span class="badge badge-active">Complete</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-info">New</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <div style="display:flex; gap:6px; flex-wrap:nowrap; align-items:center;">
                  <%-- STAFF sees Create button for NEW requests --%>
                  <c:if test="${role eq 'STAFF'}">
                    <c:choose>
                      <c:when test="${r.status eq 'COMPLETE'}">
                        <span class="btn btn-sm" style="pointer-events:none; opacity:.4;">Created</span>
                      </c:when>
                      <c:otherwise>
                        <a class="btn btn-sm btn-primary" href="${ctx}/home?p=create-import-receipt&requestId=${r.requestId}">Create</a>
                      </c:otherwise>
                    </c:choose>
                  </c:if>
                  <a class="btn btn-sm btn-info" href="${ctx}/home?p=import-request-detail&id=${r.requestId}">View</a>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <c:url var="baseUrl" value="/home">
    <c:param name="p" value="import-request-list"/>
    <c:param name="q" value="${q}"/>
    <c:param name="status" value="${status}"/>
    <c:param name="reqDate" value="${reqDate}"/>
    <c:param name="expDate" value="${expDate}"/>
  </c:url>
  <div class="paging-footer">
    <div class="paging-info">Total: <b>${totalItems}</b> item(s) • Page <b>${page}</b>/<b>${totalPages}</b></div>
    <div class="paging">
      <c:choose>
        <c:when test="${page > 1}"><a class="paging-btn" href="${baseUrl}&page=${page-1}">← Prev</a></c:when>
        <c:otherwise><span class="paging-btn disabled">← Prev</span></c:otherwise>
      </c:choose>
      <c:forEach var="i" begin="1" end="${totalPages}">
        <c:choose>
          <c:when test="${i==page}"><span class="paging-btn active">${i}</span></c:when>
          <c:otherwise><a class="paging-btn" href="${baseUrl}&page=${i}">${i}</a></c:otherwise>
        </c:choose>
      </c:forEach>
      <c:choose>
        <c:when test="${page < totalPages}"><a class="paging-btn" href="${baseUrl}&page=${page+1}">Next →</a></c:when>
        <c:otherwise><span class="paging-btn disabled">Next →</span></c:otherwise>
      </c:choose>
    </div>
  </div>

</div>
