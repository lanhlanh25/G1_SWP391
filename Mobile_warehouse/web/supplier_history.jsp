<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="sup" value="${supplier}"/>

<div class="page-wrap">

  <div class="topbar">
    <div>
      <div class="title">Transaction History</div>
      <div class="small muted" style="margin-top:4px;">
        Supplier: <b><c:out value="${sup.supplierName}"/></b>
        <span class="muted">(ID: ${sup.supplierId})</span>
      </div>
    </div>
    <a class="btn" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${sup.supplierId}">
      ← Back to Supplier Detail
    </a>
  </div>

  <c:if test="${not empty msg}">
    <p class="msg-err">${msg}</p>
  </c:if>

  <%-- Filters --%>
  <div class="card" style="margin-bottom:14px;">
    <div class="card-body">
      <form method="get" action="${pageContext.request.contextPath}/home">
        <input type="hidden" name="p" value="view_history"/>
        <input type="hidden" name="supplierId" value="${sup.supplierId}"/>
        <div class="filters" style="grid-template-columns: 2fr 1fr 1fr 1fr auto;">
          <div>
            <label class="label">Search receipt</label>
            <input class="input" name="q" value="${q}" placeholder="receipt code..."/>
          </div>
          <div>
            <label class="label">From</label>
            <input class="input" type="date" name="from" value="${from}"/>
          </div>
          <div>
            <label class="label">To</label>
            <input class="input" type="date" name="to" value="${to}"/>
          </div>
          <div>
            <label class="label">Status</label>
            <select class="select" name="status">
              <option value=""          ${empty status         ? 'selected' : ''}>All</option>
              <option value="DRAFT"     ${status=='DRAFT'      ? 'selected' : ''}>DRAFT</option>
              <option value="CONFIRMED" ${status=='CONFIRMED'  ? 'selected' : ''}>CONFIRMED</option>
              <option value="CANCELLED" ${status=='CANCELLED'  ? 'selected' : ''}>CANCELLED</option>
              <option value="COMPLETED" ${status=='COMPLETED'  ? 'selected' : ''}>COMPLETED</option>
            </select>
          </div>
          <div style="display:flex; align-items:flex-end;">
            <button class="btn btn-primary" type="submit">Apply</button>
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
            <th>Receipt Code</th>
            <th>Date</th>
            <th>Status</th>
            <th style="text-align:center; width:110px;">Total Units</th>
            <th>Created By</th>
            <th>Note</th>
            <th style="width:120px;">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty receipts}">
            <tr><td colspan="7" class="small muted" style="padding:20px;">No receipts found.</td></tr>
          </c:if>
          <c:forEach var="r" items="${receipts}">
            <tr>
              <td><b>${r.importCode}</b></td>
              <td>
                <c:choose>
                  <c:when test="${r.receiptDate != null}">
                    <fmt:formatDate value="${r.receiptDate}" pattern="yyyy-MM-dd HH:mm"/>
                  </c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </td>
              <td>${r.status}</td>
              <td style="text-align:center;">${r.totalUnits}</td>
              <td><c:out value="${r.createdByName}"/></td>
              <td><c:out value="${r.note}"/></td>
              <td>
                <a class="btn btn-sm" href="${pageContext.request.contextPath}/import-receipt-detail?id=${r.importId}">
                  View Receipt
                </a>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <%-- Pagination --%>
  <c:set var="base" value="${pageContext.request.contextPath}/home?p=view_history&supplierId=${sup.supplierId}&q=${q}&from=${from}&to=${to}&status=${status}&page="/>
  <div class="paging-footer">
    <div class="paging-info">
      <c:choose>
        <c:when test="${totalItems > 0}">
          Showing ${(page-1)*pageSize+1}–${page*pageSize > totalItems ? totalItems : page*pageSize} of ${totalItems} receipts
        </c:when>
        <c:otherwise>Showing 0 receipts</c:otherwise>
      </c:choose>
    </div>
    <div class="paging">
      <a class="paging-btn ${page==1 ? 'disabled' : ''}" href="${base}${page-1}">← Prev</a>
      <c:forEach var="i" begin="1" end="${totalPages}">
        <c:choose>
          <c:when test="${i==page}"><span class="paging-btn active">${i}</span></c:when>
          <c:otherwise><a class="paging-btn" href="${base}${i}">${i}</a></c:otherwise>
        </c:choose>
      </c:forEach>
      <a class="paging-btn ${page==totalPages ? 'disabled' : ''}" href="${base}${page+1}">Next →</a>
    </div>
  </div>

</div>
