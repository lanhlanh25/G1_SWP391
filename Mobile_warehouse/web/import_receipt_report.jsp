<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">
  <div class="topbar">
    <div class="d-flex align-center gap-12">
      <h1 class="h1">Import Receipt Report</h1>
      <!--<span class="text-muted fs-14 mt-4">Inventory inflow analytics</span>-->
    </div>
    <div class="d-flex gap-8 align-center">
      <a class="btn btn-outline" href="${ctx}/home?p=dashboard">← Dashboard</a>
    </div>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err mb-16">${fn:escapeXml(err)}</div>
  </c:if>

  <!-- Filters -->
  <div class="card mb-16">
    <div class="card-body">
      <form method="get" action="${ctx}/import-receipt-report">
        <div class="d-flex gap-16 align-end flex-wrap">
          <div style="width:160px;">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">From Date</label>
            <input class="input" type="date" name="from" value="${fn:escapeXml(from)}" />
          </div>
          <div style="width:160px;">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">To Date</label>
            <input class="input" type="date" name="to" value="${fn:escapeXml(to)}" />
          </div>
          <div style="width:180px;">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Supplier</label>
            <select class="select" name="supplierId">
              <option value="">All Suppliers</option>
              <c:forEach var="s" items="${suppliers}">
                <option value="${s.id}" ${supplierId == s.id ? 'selected' : ''}>
                  ${fn:escapeXml(s.name)}
                </option>
              </c:forEach>
            </select>
          </div>
          <div class="d-flex gap-8">
            <button class="btn btn-primary" type="submit">Apply Filters</button>
            <a href="${ctx}/import-receipt-report" class="btn btn-outline">Reset</a>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- Stats -->
  <div class="grid-12 gap-16 mb-16">
    <div class="col-6">
      <div class="card stat-card-item p-20  d-flex justify-between align-center h-full">
        <div>
          <div class="muted fs-12 uppercase mb-4">Total Import Receipts</div>
          <div class="h2 m-0 text-primary">
            <c:out value="${reportSummary.totalReceipts}" default="0"/>
          </div>
          <div class="fs-10 text-muted mt-4">Confirmed receipts</div>
        </div>
      </div>
    </div>

    <div class="col-6">
      <div class="card p-20 d-flex justify-between align-center h-full">
        <div>
          <div class="muted fs-12 uppercase mb-4">Total Phone Quantity</div>
          <div class="h2 m-0 text-primary">
            <c:out value="${reportSummary.totalPhoneQty}" default="0"/>
            <span class="fs-14 fw-600 text-muted ml-4">Phones</span>
          </div>
          <div class="fs-10 text-muted mt-4">Successfully imported</div>
        </div>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-body">
      <div class="d-flex justify-between align-center mb-16">
        <div class="h2">Import History</div>
        <div class="text-muted fs-14">Records found: <b class="text-primary">${totalItems}</b></div>
      </div>
      
      <table class="table">
        <thead>
          <tr>
            <th>Receipt Code</th>
            <th>Created Date</th>
            <th>Supplier</th>
            <th class="text-center">Total Quantity</th>
            <th class="text-right">Status</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty rows}">
              <tr>
                <td colspan="5">
                  <div class="p-40 text-center text-muted">
                    No import receipts found in this period.
                  </div>
                </td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="r" items="${rows}">
                <tr>
                  <td class="fw-600 text-primary"><c:out value="${r.importCode}"/></td>
                  <td class="text-muted fs-13">
                    <c:choose>
                      <c:when test="${not empty r.receiptDate}">
                        <fmt:formatDate value="${r.receiptDate}" pattern="yyyy-MM-dd HH:mm"/>
                      </c:when>
                      <c:otherwise>—</c:otherwise>
                    </c:choose>
                  </td>
                  <td><c:out value="${r.supplierName}"/></td>
                  <td class="text-center fw-700"><c:out value="${r.totalQuantity}"/> <span class="fs-12 text-muted fw-400">Phone</span></td>
                  <td class="text-right"><span class="badge badge-active">Completed</span></td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>

      <c:if test="${totalPages > 1}">
        <div class="d-flex justify-between align-center mt-20">
          <div class="fs-13 text-muted">Page <b>${page}</b> of <b>${totalPages}</b></div>
          <div class="d-flex gap-4">
            <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}&supplierId=${supplierId}" />

            <c:choose>
              <c:when test="${page > 1}">
                <a class="btn btn-sm btn-outline" href="${ctx}/import-receipt-report?${qsBase}&page=${page - 1}">Prev</a>
              </c:when>
              <c:otherwise>
                <span class="btn btn-sm btn-outline disabled">Prev</span>
              </c:otherwise>
            </c:choose>

            <c:forEach var="pg" begin="1" end="${totalPages}">
              <c:choose>
                <c:when test="${pg == page}">
                  <span class="btn btn-sm btn-primary">${pg}</span>
                </c:when>
                <c:otherwise>
                  <a class="btn btn-sm btn-outline" href="${ctx}/import-receipt-report?${qsBase}&page=${pg}">${pg}</a>
                </c:otherwise>
              </c:choose>
            </c:forEach>

            <c:choose>
              <c:when test="${page < totalPages}">
                <a class="btn btn-sm btn-outline" href="${ctx}/import-receipt-report?${qsBase}&page=${page + 1}">Next</a>
              </c:when>
              <c:otherwise>
                <span class="btn btn-sm btn-outline disabled">Next</span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</div>
