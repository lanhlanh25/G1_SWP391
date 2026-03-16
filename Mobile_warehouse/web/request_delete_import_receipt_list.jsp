<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>


<div class="page-wrap">
  <div class="card">

    <div class="card-header">
      <div>
        <div class="h2">Request Delete Import Receipt List</div>
        <div class="small" style="margin-top:4px;">
          Pending requests for deleting import receipts
        </div>
      </div>

      <a class="btn btn-outline" href="${ctx}/home?p=import-receipt-list">Back</a>
    </div>

    <div class="card-body">

   
      <form method="get" action="${ctx}/home" class="filters" style="grid-template-columns: 2fr 1fr auto auto;">
        <input type="hidden" name="p" value="request-delete-import-receipt-list"/>

        <div class="field">
          <label>Search</label>
          <input class="input" type="text" name="q"
                 value="${fn:escapeXml(q)}"
                 placeholder="Search by import code"/>
        </div>

        <div class="field">
          <label>Transaction Date</label>
          <input class="input" type="date" name="transactionTime"
                 value="${fn:escapeXml(transactionTime)}"/>
        </div>

        <div class="field" style="display:flex; align-items:end;">
          <button type="submit" class="btn btn-primary">Search</button>
        </div>

        <div class="field" style="display:flex; align-items:end;">
          <a class="btn" href="${ctx}/home?p=request-delete-import-receipt-list">Reset</a>
        </div>
      </form>

      <table class="table">
        <thead>
          <tr>
            <th style="width:70px;">NO</th>
            <th style="width:180px;">IMPORT CODE</th>
            <th>NOTE</th>
            <th style="width:180px;">CREATE BY</th>
            <th style="width:220px;">TRANSACTION TIME</th>
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
             
                  <td>${st.index + 1}</td>
                  <td>${fn:escapeXml(r.importCode)}</td>
                  <td>${fn:escapeXml(r.note)}</td>
                  <td>${fn:escapeXml(r.requestedByName)}</td>
                  <td>
                    <fmt:formatDate value="${r.transactionTime}" pattern="MM/dd/yyyy h:mm a"/>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>

    
      <c:if test="${totalPages > 1}">
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

          <c:forEach var="p" begin="1" end="${totalPages}">
            <c:choose>
              <c:when test="${p == page}">
                <b>${p}</b>
              </c:when>
              <c:otherwise>
                <a href="${ctx}/home?${qsBase}&page=${p}">${p}</a>
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
      </c:if>

    </div>
  </div>
</div>