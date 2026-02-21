<%--
    Document   : export_receipt_list
    Created on : Feb 19, 2026
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="role" value="${sessionScope.roleName}" />

<style>
  :root{
    --blue:#1f6feb;
    --line:#2e3f95;
    --bg:#f4f4f4;
  }
  .wrap{padding:14px; background:var(--bg); font-family:Arial, Helvetica, sans-serif;}
  .frame{border:2px solid var(--line); background:#fff; padding:12px;}
  .topbar{display:flex; justify-content:space-between; align-items:center; gap:12px; margin-bottom:10px; flex-wrap:wrap;}
  .title{font-size:22px; font-weight:700;}
  .btn{display:inline-block; padding:6px 12px; border:1px solid #333; background:#f6f6f6; text-decoration:none; color:#111; cursor:pointer; font-size:13px;}
  .btn.primary{background:var(--blue); color:#fff; border-color:var(--blue);}
  .btnRow{display:flex; gap:8px; align-items:center; flex-wrap:wrap;}
  .filters{display:flex; justify-content:space-between; align-items:center; gap:12px; margin:8px 0 10px; flex-wrap:wrap;}
  .leftFilters{display:flex; gap:8px; align-items:center; flex-wrap:wrap;}
  .rightFilters{display:flex; gap:8px; align-items:center; flex-wrap:wrap;}
  input[type="text"], input[type="date"], select{
    padding:6px 8px; border:1px solid #333; box-sizing:border-box; font-size:13px;
  }
  table{width:100%; border-collapse:collapse;}
  th,td{border:1px solid #cfcfcf; padding:8px; font-size:13px; vertical-align:middle;}
  th{background:#efefef; text-align:left;}
  .actions{display:flex; gap:6px; flex-wrap:wrap; align-items:center;}
  .pager{display:flex; justify-content:flex-end; gap:6px; margin-top:10px; align-items:center; flex-wrap:wrap;}
  .pill{display:inline-block; min-width:26px; text-align:center; padding:4px 8px; border:1px solid #aaa; background:#f6f6f6;}
  .pill.active{background:var(--blue); color:#fff; border-color:var(--blue);}
  .muted{color:#666; font-size:12px;}
  .msg{border:1px solid #0a7f3f; background:#e9fff1; padding:8px; margin:10px 0; color:#0a7f3f; font-size:13px;}
  .err{border:1px solid #b00020; background:#ffe9ee; padding:8px; margin:10px 0; color:#b00020; font-size:13px;}
</style>

<div class="wrap">
  <div class="frame">

    <div class="topbar">
      <div class="btnRow">
        <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
        <div class="title">View export receipt list</div>
      </div>

      <div class="btnRow">
        <c:if test="${role == 'STAFF' || role == 'SALE'}">
          <a class="btn primary" href="${ctx}/home?p=create-export-receipt">CREATE EXPORT RECEIPT</a>
        </c:if>
      </div>
    </div>

    <c:if test="${not empty msg}">
      <div class="msg"><c:out value="${msg}"/></div>
    </c:if>
    <c:if test="${not empty err}">
      <div class="err"><c:out value="${err}"/></div>
    </c:if>

    <!-- FILTER -->
    <form method="get" action="${ctx}/home">
      <input type="hidden" name="p" value="export-receipt-list"/>

      <div class="filters">
        <div class="leftFilters">
          <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search by Export Code" />
          <button class="btn" type="submit">SEARCH</button>
        </div>

        <div class="rightFilters">
          <!-- ✅ dùng ALL / DRAFT / CONFIRMED / CANCELLED cho khớp DB -->
          <select name="status">
            <option value="ALL" ${status=='ALL' || empty status ? 'selected' : ''}>ALL</option>
            <option value="DRAFT" ${status=='DRAFT' ? 'selected' : ''}>DRAFT</option>
            <option value="CONFIRMED" ${status=='CONFIRMED' ? 'selected' : ''}>CONFIRMED</option>
            <option value="CANCELLED" ${status=='CANCELLED' ? 'selected' : ''}>CANCELLED</option>
          </select>

          <input type="date" name="from" value="${fn:escapeXml(from)}"/>
          <input type="date" name="to" value="${fn:escapeXml(to)}"/>
          <button class="btn" type="submit">Apply</button>
        </div>
      </div>
    </form>

    <table>
      <thead>
        <tr>
          <th style="width:60px;">No</th>
          <th style="width:170px;">Receipt Code</th>
          <th style="width:170px;">Request Code</th>
          <th style="width:170px;">Created By</th>
          <th style="width:180px;">Export Date</th>
          <th style="width:120px;">Total Qty</th>
          <th style="width:120px;">Status</th>
          <th style="width:260px;">Action</th>
        </tr>
      </thead>

      <tbody>
        <c:if test="${empty rows}">
          <tr>
            <td colspan="8" class="muted">No data</td>
          </tr>
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
                <c:otherwise>
                  <c:out value="${r.requestCode}"/>
                </c:otherwise>
              </c:choose>
            </td>

            <td><c:out value="${r.createdByName}"/></td>
            <td><c:out value="${r.exportDateUi}"/></td>
            <td><c:out value="${r.totalQty}"/></td>
            <td><c:out value="${r.status}"/></td>

            <td>
              <div class="actions">
                <a class="btn" href="${ctx}/home?p=export-receipt-detail&id=${r.exportId}">View Detail</a>
                <a class="btn primary" href="${ctx}/export-receipt-pdf?id=${r.exportId}" target="_blank">Download PDF</a>
              </div>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>

    <!-- PAGER -->
    <div class="pager">
      <c:set var="cur" value="${page}" />
      <c:set var="tp" value="${totalPages}" />

      <c:choose>
        <c:when test="${cur <= 1}">
          <span class="btn" style="opacity:.5; pointer-events:none;">Prev</span>
        </c:when>
        <c:otherwise>
          <a class="btn"
             href="${ctx}/home?p=export-receipt-list&page=${cur-1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">Prev</a>
        </c:otherwise>
      </c:choose>

      <span class="pill active"><c:out value="${cur}"/></span>

      <c:choose>
        <c:when test="${cur >= tp}">
          <span class="btn" style="opacity:.5; pointer-events:none;">Next</span>
        </c:when>
        <c:otherwise>
          <a class="btn"
             href="${ctx}/home?p=export-receipt-list&page=${cur+1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">Next</a>
        </c:otherwise>
      </c:choose>
    </div>

  </div>
</div>
