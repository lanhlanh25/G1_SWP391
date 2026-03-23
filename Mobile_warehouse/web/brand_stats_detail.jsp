<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<c:url var="backUrl" value="/home">
    <c:param name="p" value="brand-stats"/>
    <c:param name="q" value="${param.listQ}"/>
    <c:param name="status" value="${param.listStatus}"/>
    <c:param name="brandId" value="${param.listBrandId}"/>
    <c:param name="sortBy" value="${param.listSortBy}"/>
    <c:param name="sortOrder" value="${param.listSortOrder}"/>
    <c:param name="range" value="${param.listRange}"/>
    <c:param name="page" value="${empty param.listPage ? 1 : param.listPage}"/>
</c:url>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Reports / Brand Statistics /</span> ${brand.brandName} Analytics
</h4>

<%-- Stat Cards --%>
<div class="row g-4 mb-4">
    <div class="col-sm-6 col-md-4 col-xl-2">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-category"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0">${detailSummary.totalProducts}</h4>
                </div>
                <p class="mb-0 small text-muted">Total Products</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-2">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-package"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0">${detailSummary.totalStockUnits}</h4>
                </div>
                <p class="mb-0 small text-muted">In Stock</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-2 text-nowrap">
        <div class="card h-100 border-danger border-opacity-25 shadow-none" style="background: rgba(255, 62, 29, 0.05);">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-danger"><i class="bx bx-error"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0 text-danger">${detailSummary.lowStockProducts}</h4>
                </div>
                <p class="mb-0 small text-muted">Low Stock Alerts</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-3">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-success"><i class="bx bx-trending-up"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0 text-success">${detailSummary.importedUnitsInRange}</h4>
                </div>
                <p class="mb-0 small text-muted">Imports (Range)</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-md-4 col-xl-3">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-warning"><i class="bx bx-trending-down"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0 text-warning">${detailSummary.exportedUnitsInRange}</h4>
                </div>
                <p class="mb-0 small text-muted">Exports (Range)</p>
            </div>
        </div>
    </div>
</div>

<%-- Sorting & Actions --%>
<div class="card mb-4">
    <div class="card-body pt-3 pb-3">
        <form method="get" action="${ctx}/home" class="row g-3 align-items-end">
            <input type="hidden" name="p" value="brand-stats-detail"/>
            <input type="hidden" name="brandId" value="${param.brandId}"/>
            <input type="hidden" name="listQ" value="${param.listQ}"/>
            <input type="hidden" name="listStatus" value="${param.listStatus}"/>
            <input type="hidden" name="listBrandId" value="${param.listBrandId}"/>
            <input type="hidden" name="listSortBy" value="${param.listSortBy}"/>
            <input type="hidden" name="listSortOrder" value="${param.listSortOrder}"/>
            <input type="hidden" name="listRange" value="${param.listRange}"/>
            <input type="hidden" name="listPage" value="${empty param.listPage ? 1 : param.listPage}"/>

            <div class="col-md-3">
                <label class="form-label small text-uppercase fw-semibold">Sort By</label>
                <select class="form-select" name="dSortBy">
                    <option value="stock"  ${dSortBy=='stock' ? 'selected' : ''}>Total Stock</option>
                    <option value="import" ${dSortBy=='import' ? 'selected' : ''}>Imported Units</option>
                    <option value="export" ${dSortBy=='export' ? 'selected' : ''}>Exported Units</option>
                    <option value="name"   ${dSortBy=='name' ? 'selected' : ''}>Product Name</option>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label small text-uppercase fw-semibold">Order</label>
                <select class="form-select" name="dSortOrder">
                    <option value="DESC" ${dSortOrder=='DESC' ? 'selected' : ''}>High to Low</option>
                    <option value="ASC"  ${dSortOrder=='ASC' ? 'selected' : ''}>Low to High</option>
                </select>
            </div>

            <div class="col-md-7 d-flex gap-2">
                <button class="btn btn-primary px-4" type="submit">
                    <i class="bx bx-sort me-1"></i> Apply Sorting
                </button>
                <a class="btn btn-outline-secondary" href="${ctx}/home?p=brand-stats-detail&brandId=${param.brandId}">
                    <i class="bx bx-refresh me-1"></i> Reset
                </a>
                <a class="btn btn-label-secondary ms-auto" href="${backUrl}">
                    <i class="bx bx-arrow-back me-1"></i> Back to List
                </a>
            </div>
        </form>
    </div>
</div>

<%-- Product Table --%>
<div class="card">
    <div class="card-header border-bottom">
        <h5 class="mb-0">Product Performance: ${brand.brandName}</h5>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th style="width: 150px;">Code</th>
                    <th>Product Name</th>
                    <th class="text-center">Stock</th>
                    <th class="text-center">Imported</th>
                    <th class="text-center">Exported</th>
                    <th class="text-center">Status</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:forEach items="${products}" var="p">
                    <tr class="${p.stockStatus == 'Out Of Stock' || p.stockStatus == 'Reorder Needed' ? 'table-danger table-opacity-10' : ''}">
                        <td><span class="fw-bold text-primary">${p.productCode}</span></td>
                        <td>${p.productName}</td>
                        <td class="text-center fw-bold fs-5">${p.totalStockUnits}</td>
                        <td class="text-center"><span class="badge bg-label-success">+${p.importedUnits}</span></td>
                        <td class="text-center"><span class="badge bg-label-warning">-${p.exportedUnits}</span></td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${p.stockStatus == 'Out Of Stock'}">
                                    <span class="badge bg-label-danger">Out of Stock</span>
                                </c:when>
                                <c:when test="${p.stockStatus == 'Reorder Needed'}">
                                    <span class="badge bg-label-warning text-dark fw-bold">Low Stock</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge ${p.totalStockUnits > 0 ? 'bg-label-info' : 'bg-label-secondary'}">
                                        <c:out value="${p.stockStatus}"/>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty products}">
                    <tr>
                        <td colspan="6" class="text-center p-5 text-muted">
                            <i class="bx bx-info-circle mb-2 d-block fs-1"></i>
                            No products found for this brand.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>
