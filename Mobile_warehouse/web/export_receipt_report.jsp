<%--
    Document   : export_receipt_report
    Created on : Mar 6, 2026, 1:09:56 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="page-wrap">
  <div class="report-page-head mb-16">
    <div class="d-flex align-center gap-12">
      <h1 class="report-title">Export Receipt Report</h1>
      <span class="text-muted fs-14 mt-4">Inventory outflow analytics</span>
    </div>
    <div class="d-flex gap-8 align-center">
      <a class="btn btn-outline" href="${ctx}/home?p=dashboard">← Dashboard</a>
    </div>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err mb-16">${fn:escapeXml(err)}</div>
  </c:if>

  <div class="card mb-16">
    <div class="card-body">
      <form method="get" action="${ctx}/export-receipt-report">
        <div class="d-flex gap-16 align-end flex-wrap">
          <div style="flex:1; min-width:200px;">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">From Date</label>
            <input class="input" type="date" name="from" value="${from}" />
          </div>
          <div style="flex:1; min-width:200px;">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">To Date</label>
            <input class="input" type="date" name="to" value="${to}" />
          </div>
          <div class="d-flex gap-8">
            <button class="btn btn-primary" type="submit">Apply Filters</button>
            <a href="${ctx}/export-receipt-report" class="btn btn-outline">Reset</a>
          </div>
        </div>
      </form>
    </div>
  </div>

  <div class="row g-4 mb-4">
    <div class="col-md-6">
      <div class="card p-20 d-flex justify-between align-center h-full mb-0">
        <div>
          <div class="muted fs-12 uppercase mb-4">Total Export Receipts</div>
          <div class="h2 m-0 text-primary">
            <c:out value="${reportSummary.totalExportReceipts}" default="0"/>
          </div>
          <div class="fs-10 text-muted mt-4">In selected period</div>
        </div>
      </div>
    </div>

    <div class="col-md-6">
      <div class="card p-20 d-flex justify-between align-center h-full mb-0">
        <div>
          <div class="muted fs-12 uppercase mb-4">Total Item Quantity</div>
          <div class="h2 m-0 text-primary">
            <c:out value="${reportSummary.totalItemQty}" default="0"/>
            <span class="fs-14 fw-600 text-muted ml-4">Items</span>
          </div>
          <div class="fs-10 text-muted mt-4">Successfully exported</div>
        </div>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-body">
      <div class="d-flex justify-between align-center mb-16">
        <div class="h2">Export History</div>
        <div class="text-muted fs-14">Records found: <b class="text-primary">${totalItems}</b></div>
      </div>

      <table class="table">
        <thead>
          <tr>
            <th>Receipt Code</th>
            <th>Created Date</th>
            <th>Created By</th>
            <th class="text-center">Total Quantity</th>
            <th class="text-center">Status</th>
            <th class="text-center">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty rows}">
              <tr>
                <td colspan="6">
                  <div class="p-40 text-center text-muted">
                    No export receipts found in this period.
                  </div>
                </td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="r" items="${rows}">
                <tr>
                  <td class="fw-600 text-primary"><c:out value="${r.exportCode}"/></td>
                  <td class="text-muted fs-13"><c:out value="${r.exportDateUi}"/></td>
                  <td><c:out value="${r.createdByName}"/></td>
                  <td class="text-center fw-700"><c:out value="${r.totalQuantity}"/> <span class="fs-12 text-muted fw-400">Item</span></td>
                  <td class="text-center"><span class="badge badge-active"><c:out value="${r.status}"/></span></td>
                  <td class="text-center">
                    <a class="btn btn-icon btn-sm btn-outline-primary" href="${ctx}/home?p=export-receipt-detail&id=${r.exportId}">
                      <i class="bx bx-show"></i>
                    </a>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>

      <c:if test="${totalPages > 1}">
        <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Page <strong>${page}</strong> of <strong>${totalPages}</strong>
            </div>
            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}" />

                    <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${page > 1 ? ctx.concat('/export-receipt-report?').concat(qsBase).concat('&page=').concat(page-1) : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                    </li>

          
                    <c:forEach var="p" begin="1" end="${totalPages}">
                        <li class="page-item ${p == page ? 'active' : ''}">
                            <a class="page-link" href="${ctx}/export-receipt-report?${qsBase}&page=${p}">${p}</a>
                        </li>
                    </c:forEach>

                    <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${page < totalPages ? ctx.concat('/export-receipt-report?').concat(qsBase).concat('&page=').concat(page+1) : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
      </c:if>

    </div>
  </div>
</div>
