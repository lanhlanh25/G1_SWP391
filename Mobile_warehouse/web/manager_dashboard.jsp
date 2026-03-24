<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Home /</span> Manager Dashboard
</h4>

<div class="row">
    <div class="col-lg-8 mb-4 order-0">
        <div class="card">
            <div class="d-flex align-items-end row">
                <div class="col-sm-7">
                    <div class="card-body">
                        <h5 class="card-title text-primary">Welcome back, Manager! 🎉</h5>
                        <p class="mb-4">
                            You have <span class="fw-bold">${pendingApprovals}</span> pending requests in your queue. 
                            Check the newest updates in the approval center below.
                        </p>
                    </div>
                </div>
                <div class="col-sm-5 text-center text-sm-left">
                    <div class="card-body pb-0 px-0 px-md-4">
                        <img src="${ctx}/assets/img/illustrations/man-with-laptop-light.png"
                             height="140"
                             alt="View Badge User"
                             data-app-dark-img="illustrations/man-with-laptop-dark.png"
                             data-app-light-img="illustrations/man-with-laptop-light.png" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-4 col-md-4 order-1">
        <div class="row">
            <div class="col-lg-6 col-md-12 col-6 mb-4">
                <div class="card">
                    <div class="card-body">
                        <div class="card-title d-flex align-items-start justify-content-between">
                            <div class="avatar flex-shrink-0">
                                <img src="${ctx}/assets/img/icons/unicons/chart-success.png" alt="chart success" class="rounded" />
                            </div>
                        </div>
                        <span class="fw-semibold d-block mb-1">Today Imported</span>
                        <h3 class="card-title mb-2 text-success">${todayImportedUnits}</h3>
                        <small class="text-success fw-semibold"><i class="bx bx-up-arrow-alt"></i> Units</small>
                    </div>
                </div>
            </div>

            <div class="col-lg-6 col-md-12 col-6 mb-4">
                <div class="card">
                    <div class="card-body">
                        <div class="card-title d-flex align-items-start justify-content-between">
                            <div class="avatar flex-shrink-0">
                                <img src="${ctx}/assets/img/icons/unicons/wallet-info.png" alt="Credit Card" class="rounded" />
                            </div>
                        </div>
                        <span class="fw-semibold d-block mb-1">Today Exported</span>
                        <h3 class="card-title text-nowrap mb-1 text-info">${todayExportedUnits}</h3>
                        <small class="text-info fw-semibold"><i class="bx bx-down-arrow-alt"></i> Units</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Inventory Summary Row -->
<div class="row">
    <div class="col-md-3 col-6 mb-4">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-secondary"><i class="bx bx-archive-in"></i></span>
                    </div>
                </div>
                <span class="d-block mb-1 text-muted">Opening Stock</span>
                <h4 class="card-title mb-1">${invTotalOpening}</h4>
                <div class="text-muted small">${invMonthLabel}</div>
            </div>
        </div>
    </div>

    <div class="col-md-3 col-6 mb-4">
        <div class="card h-100 border-bottom border-success border-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-success"><i class="bx bx-plus-circle"></i></span>
                    </div>
                </div>
                <div class="card-body py-3">
                    <ul class="nav nav-pills mb-3 gap-1" role="tablist">
                        <li class="nav-item">
                            <button type="button" class="nav-link btn btn-xs ${empty param.approvalType || param.approvalType eq 'import' ? 'active' : ''}" 
                                    onclick="switchTab('import')">
                                <i class="bx bx-downvote me-1"></i> Import
                            </button>
                        </li>
                        <li class="nav-item">
                            <button type="button" class="nav-link btn btn-xs ${param.approvalType eq 'export' ? 'active' : ''}" 
                                    onclick="switchTab('export')">
                                <i class="bx bx-upvote me-1"></i> Export
                            </button>
                        </li>
                    </ul>

                    <div class="table-responsive text-nowrap">
                        <table class="table table-hover table-sm">
                            <thead>
                                <tr>
                                    <th>Code</th>
                                    <th>Requested By</th>
                                    <th>Time</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${empty param.approvalType || param.approvalType eq 'import'}">
                                    <c:choose>
                                        <c:when test="${not empty dashboardImportRequests}">
                                            <c:forEach var="r" items="${dashboardImportRequests}">
                                                <tr>
                                                    <td><span class="fw-bold text-primary">${r.code}</span></td>
                                                    <td><small>${r.requestedBy}</small></td>
                                                    <td class="small text-muted">${r.requestedTime}</td>
                                                    <td class="text-center">
                                                        <a class="btn btn-xs btn-primary" href="${ctx}/home?p=import-request-detail&id=${r.id}">View</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr><td colspan="4" class="text-center p-4 text-muted">No pending import requests.</td></tr>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                                <c:if test="${param.approvalType eq 'export'}">
                                    <c:choose>
                                        <c:when test="${not empty dashboardExportRequests}">
                                            <c:forEach var="r" items="${dashboardExportRequests}">
                                                <tr>
                                                    <td><span class="fw-bold text-info">${r.code}</span></td>
                                                    <td><small>${r.requestedBy}</small></td>
                                                    <td class="small text-muted">${r.requestedTime}</td>
                                                    <td class="text-center">
                                                        <a class="btn btn-xs btn-primary" href="${ctx}/home?p=export-request-detail&id=${r.id}">View</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr><td colspan="4" class="text-center p-4 text-muted">No pending export requests.</td></tr>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="col-md-4 mb-4">
            <div class="card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5 class="card-title m-0">Quick Actions</h5>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-2">
                        <a href="${ctx}/home?p=import-request-list" class="btn btn-outline-primary text-start">
                            <i class="bx bx-check-shield me-2"></i> Review Import Requests
                        </a>
                        <a href="${ctx}/home?p=export-request-list" class="btn btn-outline-info text-start">
                            <i class="bx bx-navigation me-2"></i> Review Export Requests
                        </a>
                        <a href="${ctx}/home?p=brand-list" class="btn btn-outline-secondary text-start">
                            <i class="bx bx-copyright me-2"></i> Manage Brands
                        </a>
                        <a href="${ctx}/inventory-count" class="btn btn-outline-secondary text-start">
                            <i class="bx bx-check-square me-2"></i> Start Inventory Count
                        </a>
                        <a href="${ctx}/inventory-report" class="btn btn-outline-secondary text-start">
                             <i class="bx bx-spreadsheet me-2"></i> Inventory Report
                        </a>
                        <a href="${ctx}/home?p=low-stock-report" class="btn btn-outline-danger text-start">
                             <i class="bx bx-error-alt me-2"></i> Low Stock Report
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-3 col-6 mb-4">
        <div class="card h-100 border-bottom border-warning border-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-warning"><i class="bx bx-minus-circle"></i></span>
                    </div>
                </div>
                <span class="d-block mb-1 text-muted">Total Export</span>
                <h4 class="card-title mb-1 text-warning">-${invTotalExport}</h4>
                <div class="text-warning small">MTD</div>
            </div>
        </div>
    </div>

    <div class="col-md-3 col-6 mb-4">
        <div class="card h-100 border-bottom border-primary border-3">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-package"></i></span>
                    </div>
                </div>
                <span class="d-block mb-1 text-muted">Closing Stock</span>
                <h4 class="card-title mb-1 text-primary">${invTotalClosing}</h4>
                <div class="text-primary small">Current On-hand</div>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <!-- Approval Center -->
    <div class="col-md-8 mb-4">
        <div class="card h-100">
            <div class="card-header d-flex align-items-center justify-content-between pb-0">
                <div class="card-title mb-0">
                    <h5 class="m-0 me-2">Approval Center</h5>
                    <small class="text-muted">New requests awaiting review</small>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${param.approvalType eq 'export'}">
                            <a href="${ctx}/home?p=export-request-list&status=NEW" class="btn btn-sm btn-label-primary">View All</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${ctx}/home?p=import-request-list&status=NEW" class="btn btn-sm btn-label-primary">View All</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card-body py-3">
                <ul class="nav nav-pills mb-3 gap-1" role="tablist">
                    <li class="nav-item">
                        <button type="button"
                                class="nav-link btn btn-xs ${empty param.approvalType || param.approvalType eq 'import' ? 'active' : ''}"
                                onclick="switchTab('import')">
                            <i class="bx bx-downvote me-1"></i> Import
                        </button>
                    </li>
                    <li class="nav-item">
                        <button type="button"
                                class="nav-link btn btn-xs ${param.approvalType eq 'export' ? 'active' : ''}"
                                onclick="switchTab('export')">
                            <i class="bx bx-upvote me-1"></i> Export
                        </button>
                    </li>
                </ul>

                <div class="table-responsive text-nowrap">
                    <table class="table table-hover table-sm">
                        <thead>
                            <tr>
                                <th>Product Details</th>
                                <th>Supplier</th>
                                <th class="text-center">Stock / Threshold</th>
                                <th class="text-center">Status</th>
                                <th class="text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty param.approvalType || param.approvalType eq 'import'}">
                                <c:choose>
                                    <c:when test="${not empty dashboardImportRequests}">
                                        <c:forEach var="r" items="${dashboardImportRequests}">
                                            <tr>
                                                <td><span class="fw-bold text-primary">${r.code}</span></td>
                                                <td><small>${r.requestedBy}</small></td>
                                                <td class="small text-muted">${r.requestedTime}</td>
                                                <td class="text-center"><span class="badge bg-label-info">${r.status}</span></td>
                                                <td class="text-center">
                                                    <a class="btn btn-xs btn-primary" href="${ctx}/home?p=import-request-detail&id=${r.id}">View</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="avatar avatar-xs me-2">
                                                        <span class="avatar-initial rounded bg-label-danger"><i class="bx bx-mobile-alt"></i></span>
                                                    </div>
                                                    <div>
                                                        <div class="fw-bold">${item.productName}</div>
                                                        <small class="text-muted">${item.productCode}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><small>${item.supplierName}</small></td>
                                            <td class="text-center">
                                                <span class="fw-bold ${item.currentStock <= item.threshold ? 'text-danger' : ''}">${item.currentStock}</span>
                                                <span class="text-muted mx-1">/</span>
                                                <span class="small">${item.threshold}</span>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${item.stockStatus == 'Out Of Stock'}">
                                                        <span class="badge bg-danger">OOS</span>
                                                    </c:when>
                                                    <c:when test="${item.stockStatus == 'Reorder Needed'}">
                                                        <span class="badge bg-warning">Low</span>
                                                    </c:when>
                                                    <c:when test="${item.stockStatus == 'At Threshold'}">
                                                        <span class="badge bg-info">At Threshold</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-success">OK</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center fw-bold text-primary">${item.suggestedReorderQty}</td>
                                            <td class="text-center">
                                                <a class="btn btn-xs btn-outline-primary" href="${ctx}/home?p=product-detail&id=${item.productId}">View</a>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                            <c:if test="${param.approvalType eq 'export'}">
                                <c:choose>
                                    <c:when test="${not empty dashboardExportRequests}">
                                        <c:forEach var="r" items="${dashboardExportRequests}">
                                            <tr>
                                                <td><span class="fw-bold text-info">${r.code}</span></td>
                                                <td><small>${r.requestedBy}</small></td>
                                                <td class="small text-muted">${r.requestedTime}</td>
                                                <td class="text-center"><span class="badge bg-label-info">${r.status}</span></td>
                                                <td class="text-center">
                                                    <a class="btn btn-xs btn-primary" href="${ctx}/home?p=export-request-detail&id=${r.id}">View</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="5" class="text-center p-4 text-muted">No pending export requests.</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="col-md-4 mb-4">
        <div class="card h-100">
            <div class="card-header d-flex align-items-center justify-content-between">
                <h5 class="card-title m-0">Quick Actions</h5>
            </div>
            <div class="card-body">
                <div class="d-grid gap-2">
                    <a href="${ctx}/home?p=import-request-list" class="btn btn-outline-primary text-start">
                        <i class="bx bx-check-shield me-2"></i> Review Import Requests
                    </a>
                    <a href="${ctx}/home?p=export-request-list" class="btn btn-outline-info text-start">
                        <i class="bx bx-navigation me-2"></i> Review Export Requests
                    </a>
                    <a href="${ctx}/home?p=brand-list" class="btn btn-outline-secondary text-start">
                        <i class="bx bx-copyright me-2"></i> Manage Brands
                    </a>
                    <a href="${ctx}/inventory-count" class="btn btn-outline-secondary text-start">
                        <i class="bx bx-check-square me-2"></i> Start Inventory Count
                    </a>
                    <a href="${ctx}/inventory-report" class="btn btn-outline-secondary text-start">
                        <i class="bx bx-spreadsheet me-2"></i> Inventory Report
                    </a>
                    <a href="${ctx}/home?p=low-stock-report" class="btn btn-outline-danger text-start">
                        <i class="bx bx-error-alt me-2"></i> Low Stock Report
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <!-- Low Stock List -->
    <div class="col-lg-12 mb-4">
        <div class="card h-100">
            <div class="card-header d-flex align-items-center justify-content-between">
                <h5 class="card-title m-0">Critical Low Stock</h5>
                <a href="${ctx}/home?p=low-stock-report" class="btn btn-sm btn-outline-danger">Full Report</a>
            </div>

            <div class="table-responsive text-nowrap">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Product Details</th>
                            <th>Supplier</th>
                            <th class="text-center">Stock</th>
                            <th class="text-center">Threshold</th>
                            <th class="text-center">Status</th>
                            <th class="text-center">Suggested</th>
                            <th class="text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty dashboardLowStockRows}">
                                <c:forEach var="item" items="${dashboardLowStockRows}">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="avatar avatar-xs me-2">
                                                    <span class="avatar-initial rounded bg-label-danger">
                                                        <i class="bx bx-mobile-alt"></i>
                                                    </span>
                                                </div>
                                                <div>
                                                    <div class="fw-bold">${item.productName}</div>
                                                    <small class="text-muted">${item.productCode}</small>
                                                </div>
                                            </div>
                                        </td>

                                        <td><small>${item.supplierName}</small></td>

                                        <td class="text-center">
                                            <span class="fw-bold ${item.currentStock <= lowThreshold ? 'text-danger' : ''}">
                                                ${item.currentStock}
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <span class="small fw-semibold text-muted">${lowThreshold}</span>
                                        </td>

                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.currentStock == 0}">
                                                    <span class="badge bg-label-danger text-uppercase fw-semibold px-3 py-2">Out Of Stock</span>
                                                </c:when>
                                                <c:when test="${item.currentStock < 10}">
                                                    <span class="badge bg-label-warning text-uppercase fw-semibold px-3 py-2">Reorder Needed</span>
                                                </c:when>
                                                <c:when test="${item.currentStock == 10}">
                                                    <span class="badge bg-label-info text-uppercase fw-semibold px-3 py-2">At Threshold</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-label-success text-uppercase fw-semibold px-3 py-2">OK</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="text-center fw-bold text-primary">
                                            ${item.suggestedReorderQty}
                                        </td>

                                        <td class="text-center">
                                            <a class="btn btn-xs btn-outline-primary"
                                               href="${ctx}/home?p=product-detail&id=${item.productId}">
                                                View
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>

                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center p-5 text-muted">
                                        Everything is well stocked.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Recent Activities -->
    <div class="col-lg-12">
        <div class="card">
            <div class="card-header pb-3">
                <h5 class="m-0 me-2">Recent Activities</h5>
                <small class="text-muted">Latest transitions across the warehouse</small>
            </div>

            <div class="table-responsive text-nowrap">
                <table class="table table-borderless table-sm">
                    <thead class="border-bottom">
                        <tr>
                            <th>Time</th>
                            <th>Type</th>
                            <th>Reference</th>
                            <th class="text-center">Qty</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty dashboardRecentActivities}">
                                <c:forEach var="a" items="${dashboardRecentActivities}">
                                    <tr>
                                        <td>
                                            <small class="text-muted">
                                                <i class="bx bx-time-five animate-pulse me-1"></i>${a.time}
                                            </small>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${fn:contains(a.type, 'Import')}">
                                                    <span class="text-success">
                                                        <i class="bx bx-down-arrow-alt"></i> ${a.type}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-info">
                                                        <i class="bx bx-up-arrow-alt"></i> ${a.type}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="font-monospace fw-bold">${a.referenceCode}</td>
                                        <td class="text-center fw-bold">${a.units}</td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="text-center p-4 text-muted">No recent activities recorded.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    function switchTab(type) {
        const url = new URL(window.location.href);
        url.searchParams.set('p', 'dashboard');
        url.searchParams.set('approvalType', type);
        window.location.href = url.toString();
    }
</script>
