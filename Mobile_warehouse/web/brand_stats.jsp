<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Reports /</span> Brand Statistics
</h4>

<%-- Alerts --%>
<c:if test="${not empty param.msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        ${param.msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty param.err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        ${param.err}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<%-- Stat Cards --%>
<div class="row g-4 mb-4">
    <div class="col-sm-6 col-md-4 col-xl-2">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-buildings"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0">${summary.totalBrands}</h4>
                </div>
                <p class="mb-0 small text-muted">Total Brands</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-2">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-category"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0">${summary.totalProducts}</h4>
                </div>
                <p class="mb-0 small text-muted">Product Types</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-2">
        <div class="card h-100 border-primary border-opacity-25 shadow-none" style="background: rgba(105, 108, 255, 0.05);">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-package"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0 text-primary">${summary.totalStockUnits}</h4>
                </div>
                <p class="mb-0 small text-muted">Stock Units</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-2">
        <div class="card h-100 border-danger border-opacity-25 shadow-none" style="background: rgba(255, 62, 29, 0.05);">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-danger"><i class="bx bx-error fs-4"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0 text-danger">${summary.lowStockProducts}</h4>
                </div>
                <p class="mb-0 small text-muted">Low Stock</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-2">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-success"><i class="bx bx-down-arrow-alt"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0">${summary.importedUnitsInRange}</h4>
                </div>
                <p class="mb-0 small text-muted">Imported</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-2">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-warning"><i class="bx bx-up-arrow-alt"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0">${summary.exportedUnitsInRange}</h4>
                </div>
                <p class="mb-0 small text-muted">Exported</p>
            </div>
        </div>
    </div>
</div>

<%-- Filters Card --%>
<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Filter Brand Data</h5>
        <div class="card-actions">
            <c:if test="${not empty sessionScope.roleName && fn:toUpperCase(sessionScope.roleName) == 'MANAGER'}">
                <c:url var="exportPdfUrl" value="/manager/brand-stats-export-pdf">
                    <c:param name="q" value="${q}"/>
                    <c:param name="status" value="${status}"/>
                    <c:param name="brandId" value="${brandId}"/>
                    <c:param name="sortBy" value="${sortBy}"/>
                    <c:param name="sortOrder" value="${sortOrder}"/>
                    <c:param name="range" value="${range}"/>
                </c:url>
                <a class="btn btn-outline-danger btn-sm" href="${exportPdfUrl}">
                    <i class="bx bxs-file-pdf me-1"></i> Export PDF
                </a>
            </c:if>
        </div>
    </div>
    <div class="card-body pt-0">
        <form method="get" action="${ctx}/home">
            <input type="hidden" name="p" value="brand-stats"/>
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Data Range</label>
                    <select class="form-select" name="range">
                        <option value="all" ${empty range || range=='all' ? 'selected' : ''}>All Time</option>
                        <option value="today" ${range=='today' ? 'selected' : ''}>Today</option>
                        <option value="last7" ${range=='last7' ? 'selected' : ''}>Last 7 Days</option>
                        <option value="last30" ${range=='last30' ? 'selected' : ''}>Past 30 Days</option>
                        <option value="last90" ${range=='last90' ? 'selected' : ''}>Past 90 Days</option>
                        <option value="month" ${range=='month' ? 'selected' : ''}>This Month</option>
                        <option value="lastMonth" ${range=='lastMonth' ? 'selected' : ''}>Last Month</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Brand</label>
                    <select class="form-select" name="brandId">
                        <option value="" ${empty brandId ? 'selected' : ''}>All Brands</option>
                        <c:forEach items="${allBrands}" var="b">
                            <option value="${b.brandId}" ${not empty brandId && brandId == (b.brandId) ? 'selected' : ''}>
                                ${b.brandName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-2">
                    <label class="form-label">Status</label>
                    <select class="form-select" name="status">
                        <option value="" ${empty status ? 'selected' : ''}>All Status</option>
                        <option value="active" ${status=='active' ? 'selected' : ''}>Active</option>
                        <option value="inactive" ${status=='inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Search Keyword</label>
                    <div class="input-group input-group-merge">
                        <span class="input-group-text"><i class="bx bx-search"></i></span>
                        <input type="text" class="form-control" name="q" value="${q}" placeholder="Brand name..."/>
                    </div>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Sort By</label>
                    <select class="form-select" name="sortBy">
                        <option value="stock"    ${sortBy=='stock' ? 'selected' : ''}>Total Stock</option>
                        <option value="products" ${sortBy=='products' ? 'selected' : ''}>Product Types</option>
                        <option value="low"      ${sortBy=='low' ? 'selected' : ''}>Low Stock</option>
                        <option value="import"   ${sortBy=='import' ? 'selected' : ''}>Imported Units</option>
                        <option value="export"   ${sortBy=='export' ? 'selected' : ''}>Exported Units</option>
                        <option value="name"     ${sortBy=='name' ? 'selected' : ''}>Brand Name</option>
                    </select>
                </div>

                <div class="col-md-2">
                    <label class="form-label">Order</label>
                    <select class="form-select" name="sortOrder">
                        <option value="DESC" ${sortOrder=='DESC' ? 'selected' : ''}>Descending</option>
                        <option value="ASC"  ${sortOrder=='ASC' ? 'selected' : ''}>Ascending</option>
                    </select>
                </div>

                <div class="col-md-7 d-flex align-items-end gap-2">
                    <button class="btn btn-primary" type="submit">
                        <i class="bx bx-filter-alt me-1"></i> Apply Filters
                    </button>
                    <a class="btn btn-outline-secondary" href="${ctx}/home?p=brand-stats">
                        <i class="bx bx-refresh me-1"></i> Reset
                    </a>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- Results Table --%>
<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Brand Ranking & Performance</h5>
        <div class="text-muted small">Total: <span class="fw-bold text-primary">${totalItems}</span> brands</div>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th style="width: 50px;">#</th>
                    <th>Brand Name</th>
                    <th class="text-center">Product Types</th>
                    <th class="text-center">Total Stock</th>
                    <th class="text-center">Low Stock</th>
                    <th class="text-center">Imported</th>
                    <th class="text-center">Exported</th>
                    <th class="text-center">Action</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:forEach items="${rows}" var="r" varStatus="st">
                    <tr class="${r.lowStockProducts > 0 ? 'table-danger table-opacity-10' : ''}">
                        <td>${(page - 1) * pageSize + st.index + 1}</td>
                        <td>
                            <div class="d-flex align-items-center">
                                <span class="fw-bold text-heading me-2">${r.brandName}</span>
                                <span class="badge badge-dot ${r.active ? 'bg-success' : 'bg-secondary'}"></span>
                                <small class="text-muted ms-1">${r.active ? 'Active' : 'Inactive'}</small>
                            </div>
                        </td>
                        <td class="text-center"><span class="badge bg-label-info">${r.totalProducts}</span></td>
                        <td class="text-center fw-bold">${r.totalStockUnits}</td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${r.lowStockProducts > 0}">
                                    <span class="badge bg-danger">${r.lowStockProducts}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">-</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center text-success fw-semibold">+${r.importedUnits}</td>
                        <td class="text-center text-warning fw-semibold">-${r.exportedUnits}</td>
                        <td class="text-center">
                            <c:url var="detailUrl" value="/home">
                                <c:param name="p" value="brand-stats-detail"/>
                                <c:param name="brandId" value="${r.brandId}"/>
                                <c:param name="listRange" value="${range}"/>
                            </c:url>
                            <a class="btn btn-sm btn-icon btn-label-primary" href="${detailUrl}" title="View Details">
                                <i class="bx bx-show-alt"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty rows}">
                    <tr>
                        <td colspan="8" class="text-center p-5">
                            <i class="bx bx-info-circle fs-1 mb-2 d-block text-muted"></i>
                            No brands found matching your filters.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <%-- Pagination --%>
    <c:if test="${totalPages > 1}">
        <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Page <strong>${page}</strong> of <strong>${totalPages}</strong>
            </div>
            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <c:url var="pageUrl" value="/home">
                        <c:param name="p" value="brand-stats"/>
                        <c:param name="q" value="${q}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="brandId" value="${brandId}"/>
                        <c:param name="sortBy" value="${sortBy}"/>
                        <c:param name="sortOrder" value="${sortOrder}"/>
                        <c:param name="range" value="${range}"/>
                    </c:url>

                    <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageUrl}&page=${page-1}"><i class="bx bx-chevron-left"></i></a>
                    </li>

                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:if test="${i >= page - 1 && i <= page + 1 || i == 1 || i == totalPages}">
                            <c:if test="${i == page - 1 && i > 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                            <li class="page-item ${i == page ? 'active' : ''}">
                                <a class="page-link" href="${pageUrl}&page=${i}">${i}</a>
                            </li>
                            <c:if test="${i == page + 1 && i < totalPages}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                        </c:if>
                    </c:forEach>

                    <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${pageUrl}&page=${page+1}"><i class="bx bx-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>