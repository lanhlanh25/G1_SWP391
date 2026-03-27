<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Reports /</span> Export Receipt Report
</h4>

<c:if test="${not empty err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        <i class="bx bx-error me-1"></i> ${fn:escapeXml(err)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<!-- Filter -->
<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/export-receipt-report" class="row g-3 px-1">
            <div class="col-md-5">
                <label class="form-label">From Date</label>
                <input class="form-control" type="date" name="from" value="${fn:escapeXml(from)}" />
            </div>
            <div class="col-md-5">
                <label class="form-label">To Date</label>
                <input class="form-control" type="date" name="to" value="${fn:escapeXml(to)}" />
            </div>
            <div class="col-md-2 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Filter</button>
                <a href="${ctx}/export-receipt-report" class="btn btn-outline-secondary">
                    <i class="bx bx-refresh"></i>
                </a>
            </div>
        </form>
    </div>
</div>

<!-- Total Phone Quantity Banner -->
<div class="card mb-4" style="background: linear-gradient(135deg, #0ea5e9 0%, #2563eb 100%); color: #fff;">
    <div class="card-body text-center py-4">
        <div class="mb-1" style="font-size:1rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; opacity:.85;">
            <i class="bx bx-export me-1"></i> Total Phone Quantity
        </div>
        <div style="font-size:2.8rem; font-weight:700; line-height:1.1;">
            <c:out value="${totalPhoneQty}" default="0"/>
        </div>
        <div style="font-size:.9rem; opacity:.8; margin-top:4px;">
            Item
          
        </div>
    </div>
</div>

<!-- Export History Table -->
<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Export History</h5>
        <div class="text-muted small">
            Records found: <strong class="text-primary">${totalItems}</strong>
        </div>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th class="text-center" style="width:70px;">No.</th>
                    <th>Product Name</th>
                    <th class="text-center" style="width:160px;">Total Quantity</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:choose>
                    <c:when test="${empty productRows}">
                        <tr>
                            <td colspan="3" class="text-center p-5 text-muted">
                                No export data found for this period.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:set var="rowOffset" value="${(page - 1) * pageSize}"/>
                        <c:forEach var="r" items="${productRows}" varStatus="loop">
                            <tr>
                                <td class="text-center text-muted">
                                    ${rowOffset + loop.index + 1}
                                </td>
                                <td>
                                    <%-- Hyperlink: navigates to Stock Movement History
                                         pre-filtered by productId, from, to, type=EXPORT --%>
                                    <a href="${ctx}/home?p=stock-movement-history&productId=${r.productId}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}&movementType=EXPORT"
                                       class="fw-semibold text-info text-decoration-underline">
                                        <c:out value="${r.productName}"/>
                                    </a>
                                    <c:if test="${not empty r.productCode}">
                                        <br/><small class="text-muted font-monospace">${fn:escapeXml(r.productCode)}</small>
                                    </c:if>
                                </td>
                                <td class="text-center">
                                    <span class="fw-bold text-dark">${r.totalQuantity}</span>
                                    <small class="text-muted ms-1">Phones</small>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <%-- Pagination --%>
    <c:if test="${totalPages > 1}">
        <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}"/>
        <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Page <strong>${page}</strong> of <strong>${totalPages}</strong>
            </div>
            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                        <a class="page-link"
                           href="${page > 1 ? ctx.concat('/export-receipt-report?').concat(qsBase).concat('&page=').concat(page - 1) : 'javascript:void(0);'}">
                            <i class="bx bx-chevron-left"></i>
                        </a>
                    </li>

                    <c:set var="startPage" value="${page - 1 > 1 ? page - 1 : 1}"/>
                    <c:set var="endPage"   value="${page + 1 < totalPages ? page + 1 : totalPages}"/>

                    <c:if test="${startPage > 1}">
                        <li class="page-item">
                            <a class="page-link" href="${ctx}/export-receipt-report?${qsBase}&page=1">1</a>
                        </li>
                        <c:if test="${startPage > 2}">
                            <li class="page-item disabled"><span class="page-link">...</span></li>
                        </c:if>
                    </c:if>

                    <c:forEach var="i" begin="${startPage}" end="${endPage}">
                        <li class="page-item ${i == page ? 'active' : ''}">
                            <a class="page-link" href="${ctx}/export-receipt-report?${qsBase}&page=${i}">${i}</a>
                        </li>
                    </c:forEach>

                    <c:if test="${endPage < totalPages}">
                        <c:if test="${endPage < totalPages - 1}">
                            <li class="page-item disabled"><span class="page-link">...</span></li>
                        </c:if>
                        <li class="page-item">
                            <a class="page-link" href="${ctx}/export-receipt-report?${qsBase}&page=${totalPages}">${totalPages}</a>
                        </li>
                    </c:if>

                    <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                        <a class="page-link"
                           href="${page < totalPages ? ctx.concat('/export-receipt-report?').concat(qsBase).concat('&page=').concat(page + 1) : 'javascript:void(0);'}">
                            <i class="bx bx-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>
