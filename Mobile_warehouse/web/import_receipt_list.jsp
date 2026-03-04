<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Import Receipt List</div>
    <div style="display:flex; gap:8px; flex-wrap:wrap;">
      <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
      <c:if test="${role == 'MANAGER'}">
        <a class="btn btn-warning" href="${ctx}/home?p=request-delete-import-receipt-list">Request Delete List</a>
      </c:if>
      <a class="btn btn-outline"
         href="${ctx}/import-receipt-list?action=export&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
        ↓ Export
      </a>
      <a class="btn btn-primary" href="${ctx}/home?p=create-import-receipt">+ Create Import Receipt</a>
    </div>
  </div>

  <%-- Filters --%>
  <div class="card" style="margin-bottom:14px;">
    <div class="card-body">
      <form method="get" action="${ctx}/import-receipt-list">
        <div class="filters" style="grid-template-columns: 2fr 1fr 1fr 1fr auto auto;">
          <div>
            <label class="label">Search</label>
            <input class="input" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Import code..."/>
          </div>
          <div>
            <label class="label">Status</label>
            <select class="select" name="status">
              <option value="all"       ${status=='all'       || empty status ? 'selected' : ''}>ALL</option>
              <option value="pending"   ${status=='pending'   ? 'selected' : ''}>Pending</option>
              <option value="completed" ${status=='completed' ? 'selected' : ''}>Completed</option>
              <option value="cancelled" ${status=='cancelled' ? 'selected' : ''}>Cancelled</option>
            </select>
          </div>
          <div>
            <label class="label">From</label>
            <input class="input" type="date" name="from" value="${fn:escapeXml(from)}"/>
          </div>
          <div>
            <label class="label">To</label>
            <input class="input" type="date" name="to" value="${fn:escapeXml(to)}"/>
          </div>
          <div style="display:flex; align-items:flex-end;">
            <button class="btn btn-primary" type="submit">Search</button>
          </div>
          <div style="display:flex; align-items:flex-end;">
            <a class="btn btn-outline" href="${ctx}/import-receipt-list">Reset</a>
          </div>
        </div>
      </form>

      <%-- Status tabs --%>
      <div class="status-tabs">
        <a class="status-tab ${status=='all' || empty status ? 'active' : ''}"
           href="${ctx}/import-receipt-list?status=all&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
          ALL <span class="tab-count"><c:out value="${tabCounts['all']}"/></span>
        </a>
        <a class="status-tab ${status=='pending' ? 'active' : ''}"
           href="${ctx}/import-receipt-list?status=pending&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
          Pending <span class="tab-count"><c:out value="${tabCounts['pending']}"/></span>
        </a>
        <a class="status-tab ${status=='completed' ? 'active' : ''}"
           href="${ctx}/import-receipt-list?status=completed&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
          Completed <span class="tab-count"><c:out value="${tabCounts['completed']}"/></span>
        </a>
        <a class="status-tab ${status=='cancelled' ? 'active' : ''}"
           href="${ctx}/import-receipt-list?status=cancelled&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
          Cancelled <span class="tab-count"><c:out value="${tabCounts['cancelled']}"/></span>
        </a>
      </div>
    </div>
  </div>

  <%-- Table --%>
  <div class="card">
    <div class="card-body" style="padding:0;">
      <table class="table">
        <thead>
          <tr>
            <th style="width:50px;">No</th>
            <th>Receipt Code</th>
            <th>Supplier</th>
            <th>Created By</th>
            <th>Created Date</th>
            <th style="text-align:center; width:110px;">Total Qty</th>
            <th style="width:110px;">Status</th>
            <th style="width:260px;">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty rows}">
            <tr><td colspan="8" class="small muted" style="padding:20px;">No data</td></tr>
          </c:if>
          <c:forEach var="r" items="${rows}" varStatus="st">
            <tr>
              <td><c:out value="${st.index + 1}"/></td>
              <td><c:out value="${r.importCode}"/></td>
              <td><c:out value="${r.supplierName}"/></td>
              <td><c:out value="${r.createdByName}"/></td>
              <td><c:out value="${r.receiptDate}"/></td>
              <td style="text-align:center;"><c:out value="${r.totalQuantity}"/></td>
              <td><c:out value="${r.statusUi}"/></td>
              <td>
                <div style="display:flex; gap:6px; flex-wrap:wrap;">
                  <a class="btn btn-sm" href="${ctx}/import-receipt-detail?id=${r.importId}">View</a>
                  <a class="btn btn-primary btn-sm" href="${ctx}/import-receipt-pdf?id=${r.importId}">PDF</a>
                  <c:if test="${role == 'MANAGER' && r.status == 'PENDING'}">
                    <form style="display:inline;" method="post" action="${ctx}/import-receipt-list"
                          onsubmit="return confirm('Delete this receipt?');">
                      <input type="hidden" name="action" value="delete"/>
                      <input type="hidden" name="id" value="${r.importId}"/>
                      <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                    </form>
                  </c:if>
                  <c:if test="${role == 'STAFF' && r.status == 'PENDING'}">
                    <a class="btn btn-warning btn-sm"
                       href="${ctx}/home?p=request-delete-import-receipt&id=${r.importId}">
                      Request Delete
                    </a>
                  </c:if>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <%-- Pagination --%>
  <div class="paging" style="margin-top:14px; justify-content:flex-end;">
    <c:choose>
      <c:when test="${page <= 1}"><span class="paging-btn disabled">← Prev</span></c:when>
      <c:otherwise>
        <a class="paging-btn" href="${ctx}/import-receipt-list?page=${page-1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">← Prev</a>
      </c:otherwise>
    </c:choose>
    <b>${page}</b>
    <c:choose>
      <c:when test="${page >= totalPages}"><span class="paging-btn disabled">Next →</span></c:when>
      <c:otherwise>
        <a class="paging-btn" href="${ctx}/import-receipt-list?page=${page+1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">Next →</a>
      </c:otherwise>
    </c:choose>
  </div>

</div>
