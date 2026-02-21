<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  :root{
    --blue:#3a7bd5;
    --line:#2e3f95;
    --bg:#f4f4f4;
    --th:#d9d9d9;
  }
  .wrap{padding:14px; background:var(--bg); font-family:Arial, Helvetica, sans-serif; min-height: 100vh;}
  .frame{border:2px solid var(--line); background:#fff; padding:12px;}
  .topbar{display:flex; justify-content:space-between; align-items:center; gap:12px; margin-bottom:10px;}
  .title{font-size:22px; font-weight:700;}
  .btn{display:inline-block; padding:6px 12px; border:1px solid #333; background:#f6f6f6; text-decoration:none; color:#111; cursor:pointer; font-size:13px;}
  .btn.primary{background:#1f6feb; color:#fff; border-color:#1f6feb;}
  .btn.danger{background:#ff4d4d; color:#fff; border-color:#ff4d4d;}
  .btn.warning{background:#ff9800; color:#fff; border-color:#ff9800;}
  .btnRow{display:flex; gap:8px; align-items:center;}
  .filters{display:flex; justify-content:space-between; align-items:center; gap:12px; margin:8px 0 10px;}
  .leftFilters{display:flex; gap:8px; align-items:center;}
  .rightFilters{display:flex; gap:8px; align-items:center;}
  input[type="text"], input[type="date"], select{
    padding:6px 8px; border:1px solid #333; box-sizing:border-box; font-size:13px;
  }
  table{width:100%; border-collapse:collapse;}
  th,td{border:1px solid #cfcfcf; padding:8px; font-size:13px; vertical-align:middle;}
  th{background:#efefef; text-align:left;}
  .actions{display:flex; gap:6px; flex-wrap:wrap; align-items:center;}
  .pager{display:flex; justify-content:flex-end; gap:6px; margin-top:10px; align-items:center;}
  .pill{display:inline-block; min-width:26px; text-align:center; padding:4px 8px; border:1px solid #aaa; background:#f6f6f6; text-decoration:none; color: #111;}
  .pill.active{background:#1f6feb; color:#fff; border-color:#1f6feb;}
  .muted{color:#666; font-size:12px;}
  form.inline{display:inline;}
</style>

<div class="wrap">
  <div class="frame">

    <div class="topbar">
      <div class="btnRow">
        <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
        <div class="title">View export receipt list</div>
      </div>

      <div class="btnRow">
        <a class="btn primary"
           href="${ctx}/export-receipt-list?action=export&searchCode=${fn:escapeXml(param.searchCode)}&status=${fn:escapeXml(param.status)}&fromDate=${fn:escapeXml(param.fromDate)}&toDate=${fn:escapeXml(param.toDate)}">
          EXPORT
        </a>
        <a class="btn" href="${ctx}/create-export-receipt">CREATE EXPORT RECEIPT</a>
      </div>
    </div>

    <form method="get" action="${ctx}/export-receipt-list">
      <div class="filters">
        <div class="leftFilters">
          <input type="text" name="searchCode" value="${fn:escapeXml(param.searchCode)}" placeholder="Search by Receipt Code" />
          <button class="btn" type="submit">SEARCH</button>
        </div>

        <div class="rightFilters">
          <select name="status">
            <option value="">STATUS (ALL)</option>
            <option value="DRAFT" ${param.status == 'DRAFT' ? 'selected' : ''}>Draft</option>
            <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
            <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
          </select>

          <input type="date" name="fromDate" value="${fn:escapeXml(param.fromDate)}"/>
          <input type="date" name="toDate" value="${fn:escapeXml(param.toDate)}"/>
          <button class="btn" type="submit">Apply</button>
        </div>
      </div>
    </form>

    <table>
      <thead>
        <tr>
          <th style="width:50px;">No</th>
          <th style="width:140px;">Receipt Code</th>
          <th>Customer</th>
          <th style="width:140px;">Created By</th>
          <th style="width:140px;">Export Date</th>
          <th style="width:100px;">Quantity</th>
          <th style="width:100px;">Status</th>
          <th style="width:150px;">Action</th>
        </tr>
      </thead>
      <tbody>
        <c:if test="${empty exportList}">
          <tr>
            <td colspan="8" class="muted" style="text-align:center; padding: 20px;">No export receipts found.</td>
          </tr>
        </c:if>

        <c:forEach var="item" items="${exportList}" varStatus="status">
          <tr>
            <td>${(pageIndex - 1) * 10 + status.index + 1}</td>
            <td><strong>${item.receiptCode}</strong></td>
            <td>${item.customerName}</td>
            <td>${item.createdByName}</td>
            <td><fmt:formatDate value="${item.exportDate}" pattern="dd/MM/yyyy"/></td>
            <td>${item.totalQuantity}</td>
            <td>${item.status}</td>
            <td>
              <div class="actions">
             <a class="btn" href="export-receipt-detail?id=${item.exportId}">View Detail</a>
              </div>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>

    <c:if test="${totalPages > 0}">
      <div class="pager">
        <c:set var="urlParams" value="&searchCode=${param.searchCode}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}" />

        <c:choose>
          <c:when test="${pageIndex <= 1}">
            <span class="btn" style="opacity:.5; pointer-events:none;">Prev</span>
          </c:when>
          <c:otherwise>
            <a class="btn" href="${ctx}/export-receipt-list?page=${pageIndex - 1}${urlParams}">Prev</a>
          </c:otherwise>
        </c:choose>

        <c:forEach begin="1" end="${totalPages}" var="i">
          <a href="${ctx}/export-receipt-list?page=${i}${urlParams}" 
             class="pill ${i == pageIndex ? 'active' : ''}">${i}</a>
        </c:forEach>

        <c:choose>
          <c:when test="${pageIndex >= totalPages}">
            <span class="btn" style="opacity:.5; pointer-events:none;">Next</span>
          </c:when>
          <c:otherwise>
            <a class="btn" href="${ctx}/export-receipt-list?page=${pageIndex + 1}${urlParams}">Next</a>
          </c:otherwise>
        </c:choose>
      </div>
    </c:if>

  </div>
</div>