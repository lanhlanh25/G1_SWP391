<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

  <div class="topbar mb-20">
    <div class="d-flex align-center gap-10">
      <a class="btn btn-outline" href="${ctx}/home?p=dashboard">← Back</a>
      <h1 class="h1 m-0">View Import Request List</h1>
    </div>
  </div>

  <c:if test="${not empty param.msg}">
    <div class="msg-ok">${param.msg}</div>
  </c:if>

  <div class="card">
    <div class="card-body">
      <div class="h2 mb-6">Manage Import Requests</div>
      <div class="muted mb-14">Track and process incoming material requests from different departments.</div>

      <form method="get" action="${ctx}/home" class="filters grid-6 align-end gap-12">
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
        
        <div class="filter-actions d-contents">
          <button class="btn btn-primary h-38" type="submit">Apply</button>
          <a class="btn h-38" href="${ctx}/home?p=import-request-list">Reset</a>
        </div>
      </form>

      <table class="table">
        <thead>
          <tr>
            <th>Request Code</th>
            <th>Created By</th>
            <th>Request Date</th>
            <th>Expected Date</th>
            <th class="w-100 text-center">Items</th>
            <th class="w-100 text-center">Qty</th>
            <th class="w-120 text-center">Status</th>
            <th class="w-240">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty irList}">
            <tr><td colspan="8" class="text-center p-24 text-muted">No requests found.</td></tr>
          </c:if>

          <c:forEach var="r" items="${irList}">
            <tr>
              <td class="font-bold">${fn:escapeXml(r.requestCode)}</td>
              <td>${fn:escapeXml(r.createdByName)}</td>
              <td class="text-muted"><c:out value="${r.requestDate}"/></td>
              <td class="text-muted"><c:out value="${r.expectedImportDate}"/></td>
              <td class="text-center">${r.totalItems}</td>
              <td class="text-center font-bold">${r.totalQty}</td>
              <td class="text-center">
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
                <div class="d-flex gap-6 no-wrap align-center">
                  <%-- STAFF sees Create button for NEW requests --%>
                  <c:if test="${role eq 'STAFF'}">
                    <c:choose>
                      <c:when test="${r.status eq 'COMPLETE'}">
                        <span class="btn btn-sm disabled-look">Created</span>
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
