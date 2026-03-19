<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>


<div class="page-wrap">
    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <a class="btn" href="${ctx}/home?p=import-receipt-list">← Back</a>
            <h1 class="h1">Delete Import Request Management</h1>
        </div>
    </div>

    <div class="card mb-16">
        <div class="card-body">
            <form method="get" action="${ctx}/home" class="filters">
                <input type="hidden" name="p" value="request-delete-import-receipt-list"/>
                <div class="filter-group">
                    <label class="label">Search</label>
                    <input class="input" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Import code..."/>
                </div>
                <div class="filter-group">
                    <label class="label">Date</label>
                    <input class="input" type="date" name="transactionTime" value="${fn:escapeXml(transactionTime)}"/>
                </div>
                <div class="filter-actions d-flex gap-8 align-end">
                    <button type="submit" class="btn btn-primary">Search</button>
                    <a class="btn btn-outline" href="${ctx}/home?p=request-delete-import-receipt-list">Reset</a>
                </div>
            </form>
        </div>
    </div>

      <div class="card">
        <table class="table">
            <thead>
                <tr>
                    <th style="width:70px;" class="text-center">No</th>
                    <th style="width:180px;">Import Code</th>
                    <th>Note</th>
                    <th style="width:180px;">Requested By</th>
                    <th style="width:200px;" class="text-center">Request Time</th>
                </tr>
            </thead>

        <tbody>
          <c:choose>
            <c:when test="${empty requests}">
              <tr>
                <td colspan="5" style="text-align:center; color:#64748b; font-weight:700;">
                  No pending delete requests
                </td>
              </tr>
            </c:when>

            <c:otherwise>
              <c:forEach var="r" items="${requests}" varStatus="st">
                <tr>
                  <td class="text-center text-muted">${st.index + 1}</td>
                  <td class="fw-600">${fn:escapeXml(r.importCode)}</td>
                  <td>${fn:escapeXml(r.note)}</td>
                  <td>${fn:escapeXml(r.requestedByName)}</td>
                  <td class="text-center text-muted">
                    <fmt:formatDate value="${r.transactionTime}" pattern="dd/MM/yyyy HH:mm"/>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>

    
      <c:if test="${totalPages > 1}">
        <div class="paging-footer">
          <div class="paging-info">
             Showing <b>${totalItems == 0 ? 0 : (page - 1) * pageSize + 1}</b>–<b>${page * pageSize < totalItems ? page * pageSize : totalItems}</b> of <b>${totalItems}</b>
          </div>
          <div class="paging">
          <c:set var="qsBase"
                 value="p=request-delete-import-receipt-list&q=${fn:escapeXml(q)}&transactionTime=${fn:escapeXml(transactionTime)}" />

          <c:choose>
            <c:when test="${page > 1}">
              <a class="paging-btn" href="${ctx}/home?${qsBase}&page=${page-1}">Prev</a>
            </c:when>
            <c:otherwise>
              <span class="paging-btn disabled">Prev</span>
            </c:otherwise>
          </c:choose>

          <c:set var="pgStart" value="${page - 1 < 1 ? 1 : page - 1}" />
          <c:set var="pgEnd" value="${pgStart + 2 > totalPages ? totalPages : pgStart + 2}" />
          <c:if test="${pgEnd == totalPages}">
              <c:set var="pgStart" value="${pgEnd - 2 < 1 ? 1 : pgEnd - 2}" />
          </c:if>

          <c:forEach var="p" begin="${pgStart}" end="${pgEnd}">
            <c:choose>
              <c:when test="${p == page}">
                <span class="paging-btn active">${p}</span>
              </c:when>
              <c:otherwise>
                <a class="paging-btn" href="${ctx}/home?${qsBase}&page=${p}">${p}</a>
              </c:otherwise>
            </c:choose>
          </c:forEach>

          <c:choose>
            <c:when test="${page < totalPages}">
              <a class="paging-btn" href="${ctx}/home?${qsBase}&page=${page+1}">Next</a>
            </c:when>
            <c:otherwise>
              <span class="paging-btn disabled">Next</span>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
      </c:if>

    </div>
  </div>
</div>