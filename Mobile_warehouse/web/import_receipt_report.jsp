<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Reports /</span> Import Receipt Report
</h4>

<c:if test="${not empty err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        <i class="bx bx-error me-1"></i> ${fn:escapeXml(err)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<!-- Stats -->
<div class="row g-4 mb-4">
    <div class="col-sm-6 col-lg-6">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-receipt"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Total Import Receipts</span>
                <h3 class="card-title mb-2"><c:out value="${reportSummary.totalReceipts}" default="0"/></h3>
                <small class="text-muted">Confirmed receipts in this period</small>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-lg-6">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-mobile-alt"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Total Phone Quantity</span>
                <h3 class="card-title mb-2 text-primary">
                    <c:out value="${reportSummary.totalPhoneQty}" default="0"/>
                    <span class="fs-6 fw-normal text-muted">Phones</span>
                </h3>
                <small class="text-muted">Successfully imported units</small>
            </div>
        </div>
    </div>
</div>

<!-- Filters -->
<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/import-receipt-report" class="row g-3 px-1">
            <div class="col-md-3">
                <label class="form-label">From Date</label>
                <input class="form-control" type="date" name="from" value="${fn:escapeXml(from)}" />
            </div>
            <div class="col-md-3">
                <label class="form-label">To Date</label>
                <input class="form-control" type="date" name="to" value="${fn:escapeXml(to)}" />
            </div>
            <div class="col-md-4">
                <label class="form-label">Supplier</label>
                <select class="form-select" name="supplierId">
                    <option value="">All Suppliers</option>
                    <c:forEach var="s" items="${suppliers}">
                        <option value="${s.id}" ${supplierId == s.id ? 'selected' : ''}>
                            ${fn:escapeXml(s.name)}
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Filter</button>
                <a href="${ctx}/import-receipt-report" class="btn btn-outline-secondary"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Import History</h5>
        <div class="text-muted small">Records found: <strong class="text-primary">${totalItems}</strong></div>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Receipt Code</th>
                    <th>Created Date</th>
                    <th>Supplier</th>
                    <th class="text-center">Total Quantity</th>
                    <th class="text-center">Status</th>
                    <th class="text-center">Action</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:choose>
                    <c:when test="${empty rows}">
                        <tr><td colspan="5" class="text-center p-5">No import receipts found in this period.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="r" items="${rows}">
                            <tr>
                                <td><span class="badge bg-label-primary font-monospace fw-bold">${r.importCode}</span></td>
                                <td>
                                    <small class="text-muted">
                                        <c:choose>
                                            <c:when test="${not empty r.receiptDate}">
                                                <fmt:formatDate value="${r.receiptDate}" pattern="yyyy-MM-dd HH:mm"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </small>
                                </td>
                                <td><strong><c:out value="${r.supplierName}"/></strong></td>
                                <td class="text-center"><span class="fw-bold">${r.totalQuantity}</span> <small class="text-muted">Phones</small></td>
                                <td class="text-center"><span class="badge bg-label-success">Completed</span></td>
                                <td class="text-center">
                                    <a class="btn btn-icon btn-sm btn-outline-primary" href="${ctx}/home?p=import-receipt-detail&id=${r.importId}">
                                        <i class="bx bx-show"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <c:if test="${totalPages > 1}">
        <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}&supplierId=${supplierId}" />
        <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted small">Page <strong>${page}</strong> of <strong>${totalPages}</strong></div>
            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <%-- Prev Button --%>
                    <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${page > 1 ? ctx.concat('/import-receipt-report?').concat(qsBase).concat('&page=').concat(page - 1) : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                    </li>

                    <%-- Dynamic Page Numbers --%>
                    <c:set var="startPage" value="${page - 1 > 1 ? page - 1 : 1}"/>
                    <c:set var="endPage" value="${page + 1 < totalPages ? page + 1 : totalPages}"/>
                    
                    <c:if test="${startPage > 1}">
                        <li class="page-item"><a class="page-link" href="${ctx}/import-receipt-report?${qsBase}&page=1">1</a></li>
                        <c:if test="${startPage > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    </c:if>

                    <c:forEach var="i" begin="${startPage}" end="${endPage}">
                        <li class="page-item ${i == page ? 'active' : ''}">
                            <a class="page-link" href="${ctx}/import-receipt-report?${qsBase}&page=${i}">${i}</a>
                        </li>
                    </c:forEach>

                    <c:if test="${endPage < totalPages}">
                        <c:if test="${endPage < totalPages - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                        <li class="page-item"><a class="page-link" href="${ctx}/import-receipt-report?${qsBase}&page=${totalPages}">${totalPages}</a></li>
                    </c:if>

                    <%-- Next Button --%>
                    <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${page < totalPages ? ctx.concat('/import-receipt-report?').concat(qsBase).concat('&page=').concat(page + 1) : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

