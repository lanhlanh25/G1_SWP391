<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

  <div class="topbar">
    <div class="d-flex align-center gap-12">
      <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
      <h1 class="h1">Import Request Management</h1>
    </div>
  </div>

  <c:if test="${not empty param.msg}">
    <div class="msg-ok">${param.msg}</div>
  </c:if>

  <div class="card mb-16">
    <div class="card-body">
      <form method="get" action="${ctx}/home" class="filters">
        <input type="hidden" name="p" value="import-request-list"/>
        <div class="filter-group">
          <label class="label">Search</label>
          <input class="input" type="text" name="q" placeholder="Request code..." value="${fn:escapeXml(q)}"/>
        </div>
        <div class="filter-group">
          <label class="label">Status</label>
          <select class="input" name="status">
            <option value="">All Statuses</option>
            <option value="NEW" ${status eq 'NEW' ? 'selected' : ''}>New</option>
            <option value="COMPLETE" ${status eq 'COMPLETE' ? 'selected' : ''}>Complete</option>
          </select>
        </div>
        <div class="filter-group">
          <label class="label">Request Date</label>
          <input class="input" type="date" name="reqDate" value="${reqDate}"/>
        </div>
        <div class="filter-group">
          <label class="label">Exp. Import Date</label>
          <input class="input" type="date" name="expDate" value="${expDate}"/>
        </div>
        <div class="filter-actions d-flex gap-8 align-end">
          <button class="btn btn-primary" type="submit">Apply</button>
          <a class="btn btn-outline" href="${ctx}/home?p=import-request-list">Reset</a>
        </div>
      </form>
    </div>
  </div>

      <table class="table">
        <thead>
          <tr>
            <th style="width:140px;">Request Code</th>
            <th>Created By</th>
            <th style="width:140px;">Request Date</th>
            <th style="width:140px;">Expected Date</th>
            <th style="width:100px;" class="text-center">Items</th>
            <th style="width:100px;" class="text-center">Total Qty</th>
            <th style="width:120px;" class="text-center">Status</th>
            <th style="width:180px;" class="text-center">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty irList}">
            <tr><td colspan="8" class="text-center p-24 text-muted">No requests found.</td></tr>
          </c:if>

          <c:forEach var="r" items="${irList}">
            <tr>
              <td class="fw-600">${fn:escapeXml(r.requestCode)}</td>
              <td>${fn:escapeXml(r.createdByName)}</td>
              <td class="text-muted"><c:out value="${r.requestDate}"/></td>
              <td class="text-muted"><c:out value="${r.expectedImportDate}"/></td>
              <td class="text-center fw-600">${r.totalItems}</td>
              <td class="text-center fw-700">${r.totalQty}</td>
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
                <div class="d-flex gap-8 align-center justify-center no-wrap">
                  <c:if test="${role eq 'STAFF'}">
                    <c:choose>
                      <c:when test="${r.status eq 'COMPLETE'}">
                        <span class="btn btn-sm btn-outline disabled" style="opacity:.6;">Created</span>
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
    <div class="paging-info">Page <b>${page}</b> of <b>${totalPages}</b></div>
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
