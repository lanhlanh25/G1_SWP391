<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Reports /</span> Inventory Report
</h4>

<c:if test="${not empty err}">
    <div class="alert alert-danger" role="alert">
        <i class="bx bx-error me-1"></i> ${fn:escapeXml(err)}
    </div>
</c:if>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/inventory-report" class="row g-3">
            <input type="hidden" name="page" value="1"/>

            <div class="col-md-3">
                <label class="form-label">From Date</label>
                <input class="form-control" type="date" name="from" value="${fn:escapeXml(from)}"/>
            </div>

            <div class="col-md-3">
                <label class="form-label">To Date</label>
                <input class="form-control" type="date" name="to" value="${fn:escapeXml(to)}"/>
            </div>

            <div class="col-md-3">
                <label class="form-label">Brand</label>
                <select class="form-select" name="brandId">
                    <option value="">All Brands</option>
                    <c:forEach var="b" items="${brands}">
                        <option value="${b.id}" ${brandId == b.id ? 'selected' : ''}>
                            ${fn:escapeXml(b.name)}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-3">
                <label class="form-label">Search</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Product name or code..."/>
                </div>
            </div>

            <div class="col-12 d-flex justify-content-end gap-2 mt-3">
                <button type="submit" class="btn btn-primary">Apply Filters</button>
                <a href="${ctx}/inventory-report" class="btn btn-outline-secondary">Reset</a>
            </div>
        </form>
    </div>
</div>

<div class="row g-4 mb-4">
    <div class="col-lg-2 col-md-4 col-6">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-cube"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Opening Stock</span>
                <h3 class="card-title mb-2">${fn:escapeXml(summary.totalOpening)}</h3>
            </div>
        </div>
    </div>
    <div class="col-lg-2 col-md-4 col-6">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-success"><i class="bx bx-trending-up"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Stock In</span>
                <h3 class="card-title mb-2 text-success">+${fn:escapeXml(summary.totalImport)}</h3>
            </div>
        </div>
    </div>
    <div class="col-lg-2 col-md-4 col-6">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-warning"><i class="bx bx-trending-down"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Stock Out</span>
                <h3 class="card-title mb-2 text-warning">-${fn:escapeXml(summary.totalExport)}</h3>
            </div>
        </div>
    </div>
    <div class="col-lg-2 col-md-4 col-6">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-archive"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Closing Stock</span>
                <h3 class="card-title mb-2 text-primary">${fn:escapeXml(summary.totalClosing)}</h3>
            </div>
        </div>
    </div>
    <div class="col-lg-4 col-md-12 col-12">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-danger"><i class="bx bx-error"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Needs Reorder</span>
                <h3 class="card-title mb-2 text-danger">${fn:escapeXml(summary.totalBelowRop)}</h3>
                <small class="text-danger fw-600">${fn:escapeXml(summary.totalOutOfStock)} out of stock</small>
            </div>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Inventory Details</h5>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Product Name</th>
                    <th>Brand</th>
                    <th class="text-center">Unit</th>
                    <th class="text-end">Opening</th>
                    <th class="text-end">Import</th>
                    <th class="text-end">Export</th>
                    <th class="text-end">Closing</th>
                    <th class="text-center">Status</th>
                    <th class="text-center">Actions</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:if test="${empty rows}">
                    <tr>
                        <td colspan="10" class="text-center p-4">No data found for the selected period.</td>
                    </tr>
                </c:if>

                <c:set var="sumOpen" value="${0}"/>
                <c:set var="sumImp" value="${0}"/>
                <c:set var="sumExp" value="${0}"/>
                <c:set var="sumClose" value="${0}"/>

                <c:forEach var="r" items="${rows}">
                    <c:set var="sumOpen" value="${sumOpen + r.openingQty}"/>
                    <c:set var="sumImp" value="${sumImp + r.importQty}"/>
                    <c:set var="sumExp" value="${sumExp + r.exportQty}"/>
                    <c:set var="sumClose" value="${sumClose + r.closingQty}"/>

                    <c:url var="detailUrl" value="/home">
                        <c:param name="p" value="stock-movement-history"/>
                        <c:param name="productId" value="${r.productId}"/>
                        <c:param name="from" value="${from}"/>
                        <c:param name="to" value="${to}"/>
                    </c:url>

                    <tr>
                        <td><span class="badge bg-label-secondary font-monospace">${fn:escapeXml(r.productCode)}</span></td>
                        <td>
                            <a href="${ctx}/home?p=product-detail&id=${r.productId}" class="text-dark">
                                <strong>${fn:escapeXml(r.productName)}</strong>
                            </a>
                        </td>
                        <td><small class="text-muted">${fn:escapeXml(r.brandName)}</small></td>
                        <td class="text-center">${fn:escapeXml(r.unit)}</td>
                        <td class="text-end fw-semibold">${r.openingQty}</td>
                        <td class="text-end text-success fw-semibold">+${r.importQty}</td>
                        <td class="text-end text-warning fw-semibold">-${r.exportQty}</td>
                        <td class="text-end text-primary fw-bold">${r.closingQty}</td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${r.ropStatus eq 'Out Of Stock'}">
                                    <span class="badge bg-label-danger">Out of Stock</span>
                                </c:when>
                                <c:when test="${r.ropStatus eq 'Reorder Needed'}">
                                    <span class="badge bg-label-warning">Reorder Needed</span>
                                </c:when>
                                <c:when test="${r.ropStatus eq 'At Threshold'}">
                                    <span class="badge bg-label-info">At Threshold</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-label-success">InStock</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <a class="btn btn-icon btn-sm btn-outline-primary" href="${detailUrl}"><i class="bx bx-show"></i></a>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${not empty rows}">
                    <tr class="table-light fw-bold">
                        <td colspan="4" class="text-end">Page Total</td>
                        <td class="text-end">${sumOpen}</td>
                        <td class="text-end text-success">+${sumImp}</td>
                        <td class="text-end text-warning">-${sumExp}</td>
                        <td class="text-end text-primary">${sumClose}</td>
                        <td colspan="2"></td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <c:set var="safeTotalItems" value="${empty totalItems ? 0 : totalItems}"/>
    <c:set var="fromItem" value="${safeTotalItems == 0 ? 0 : ((page - 1) * pageSize + 1)}"/>
    <c:set var="toItem" value="${page * pageSize > safeTotalItems ? safeTotalItems : page * pageSize}"/>

    <div class="card-footer d-flex justify-content-between align-items-center">
        <div class="text-muted small">
            Page <strong>${page}</strong> of <strong>${totalPages}</strong>
        </div>

        <nav aria-label="Page navigation">
            <ul class="pagination pagination-sm mb-0">
                <%-- Prev Button --%>
                <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                    <c:url var="prevUrl" value="/inventory-report">
                        <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/><c:param name="brandId" value="${brandId}"/><c:param name="keyword" value="${keyword}"/><c:param name="page" value="${page - 1}"/>
                    </c:url>
                    <a class="page-link" href="${page > 1 ? prevUrl : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                </li>

                <%-- Dynamic Page Numbers --%>
                <c:set var="startPage" value="${page - 1 > 1 ? page - 1 : 1}"/>
                <c:set var="endPage" value="${page + 1 < totalPages ? page + 1 : totalPages}"/>

                <c:if test="${startPage > 1}">
                    <c:url var="p1Url" value="/inventory-report">
                        <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/><c:param name="brandId" value="${brandId}"/><c:param name="keyword" value="${keyword}"/><c:param name="page" value="1"/>
                    </c:url>
                    <li class="page-item"><a class="page-link" href="${p1Url}">1</a></li>
                    <c:if test="${startPage > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    </c:if>

                <c:forEach var="pg" begin="${startPage}" end="${endPage}">
                    <c:url var="pUrl" value="/inventory-report">
                        <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/><c:param name="brandId" value="${brandId}"/><c:param name="keyword" value="${keyword}"/><c:param name="page" value="${pg}"/>
                    </c:url>
                    <li class="page-item ${pg == page ? 'active' : ''}"><a class="page-link" href="${pUrl}">${pg}</a></li>
                    </c:forEach>

                <c:if test="${endPage < totalPages}">
                    <c:if test="${endPage < totalPages - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                        <c:url var="pLastUrl" value="/inventory-report">
                            <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/><c:param name="brandId" value="${brandId}"/><c:param name="keyword" value="${keyword}"/><c:param name="page" value="${totalPages}"/>
                        </c:url>
                    <li class="page-item"><a class="page-link" href="${pLastUrl}">${totalPages}</a></li>
                    </c:if>

                <%-- Next Button --%>
                <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                    <c:url var="nextUrl" value="/inventory-report">
                        <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/><c:param name="brandId" value="${brandId}"/><c:param name="keyword" value="${keyword}"/><c:param name="page" value="${page + 1}"/>
                    </c:url>
                    <a class="page-link" href="${page < totalPages ? nextUrl : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                </li>
            </ul>
        </nav>
    </div>
</div>

</div>

