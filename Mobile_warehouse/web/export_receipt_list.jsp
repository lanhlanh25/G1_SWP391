<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="role" value="${sessionScope.roleName}"/>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Export Receipt List</div>
    <div style="display:flex; gap:8px;">
      <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
      <c:if test="${role == 'STAFF' || role == 'SALE'}">
        <a class="btn btn-primary" href="${ctx}/home?p=create-export-receipt">+ Create Export Receipt</a>
      </c:if>
    </div>
  </div>

  <c:if test="${not empty msg}"><p class="msg-ok"><c:out value="${msg}"/></p></c:if>
  <c:if test="${not empty err}"><p class="msg-err"><c:out value="${err}"/></p></c:if>

  <%-- Filters --%>
  <div class="card" style="margin-bottom:14px;">
    <div class="card-body">
      <form method="get" action="${ctx}/home">
        <input type="hidden" name="p" value="export-receipt-list"/>
        <div class="filters" style="grid-template-columns: 2fr 1fr 1fr 1fr auto auto;">
          <div>
            <label class="label">Search</label>
            <input class="input" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Export code..."/>
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
            <a class="btn btn-outline" href="${ctx}/home?p=export-receipt-list">Reset</a>
          </div>
        </div>
      </form>
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
            <th>Request Code</th>
            <th>Created By</th>
            <th>Export Date</th>
            <th style="width:100px; text-align:center;">Total Qty</th>
            
            <th style="width:220px;">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty rows}">
            <tr><td colspan="8" class="small muted" style="padding:20px;">No data</td></tr>
          </c:if>
          <c:forEach var="r" items="${rows}" varStatus="st">
            <tr>
              <td><c:out value="${st.index + 1}"/></td>
              <td><c:out value="${r.exportCode}"/></td>
              <td>
                <c:choose>
                  <c:when test="${empty r.requestCode || r.requestCode == '-'}">
                    <span class="muted">N/A</span>
                  </c:when>
                  <c:otherwise><c:out value="${r.requestCode}"/></c:otherwise>
                </c:choose>
              </td>
              <td><c:out value="${r.createdByName}"/></td>
              <td><c:out value="${r.exportDateUi}"/></td>
              <td style="text-align:center;"><c:out value="${r.totalQty}"/></td>
              
              <td>
                <div style="display:flex; gap:6px;">
                  <a class="btn btn-sm" href="${ctx}/home?p=export-receipt-detail&id=${r.exportId}">View</a>
                  <a class="btn btn-primary btn-sm" href="${ctx}/export-receipt-pdf?id=${r.exportId}" target="_blank">PDF</a>
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
      <c:when test="${page <= 1}">
        <span class="paging-btn disabled">← Prev</span>
      </c:when>
      <c:otherwise>
        <a class="paging-btn" href="${ctx}/home?p=export-receipt-list&page=${page-1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">← Prev</a>
      </c:otherwise>
    </c:choose>

    <b>${page}</b>

    <c:choose>
      <c:when test="${page >= totalPages}">
        <span class="paging-btn disabled">Next →</span>
      </c:when>
      <c:otherwise>
        <a class="paging-btn" href="${ctx}/home?p=export-receipt-list&page=${page+1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">Next →</a>
      </c:otherwise>
    </c:choose>
  </div>

</div>
