<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="d" value="${supplierDetail}"/>
<c:set var="isManager" value="${not empty sessionScope.roleName && sessionScope.roleName.toUpperCase() == 'MANAGER'}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Supplier Detail
</h4>

<c:if test="${not empty msg}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        ${msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="row g-4">
    <!-- Left: Supplier Info -->
    <div class="col-md-7">
        <div class="card h-100">
            <div class="card-header d-flex align-items-center justify-content-between">
                <h5 class="mb-0">Supplier Information</h5>
                <div class="d-flex gap-2">
                    <a class="btn btn-outline-secondary btn-sm" href="${ctx}/home?p=view_supplier">
                        <i class="bx bx-arrow-back me-1"></i> Back
                    </a>
                    <c:if test="${isManager}">
                        <a class="btn btn-primary btn-sm" href="${ctx}/home?p=update_supplier&id=${d.supplierId}">
                            <i class="bx bx-edit-alt me-1"></i> Update
                        </a>
                    </c:if>
                </div>
            </div>
            <div class="card-body">
                <table class="table table-borderless">
                    <tbody>
                        <tr>
                            <th class="ps-0" style="width: 150px;">Supplier ID</th>
                            <td class="text-muted">#${d.supplierId}</td>
                        </tr>
                        <tr>
                            <th class="ps-0">Supplier Name</th>
                            <td class="fw-bold fs-5">${d.supplierName}</td>
                        </tr>
                        <tr>
                            <th class="ps-0">Phone</th>
                            <td><span class="badge bg-label-primary">${d.phone}</span></td>
                        </tr>
                        <tr>
                            <th class="ps-0">Email</th>
                            <td>${d.email}</td>
                        </tr>
                        <tr>
                            <th class="ps-0">Address</th>
                            <td>${d.address}</td>
                        </tr>
                        <tr>
                            <th class="ps-0">Status</th>
                            <td>
                                <span class="badge ${d.isActive == 1 ? 'bg-label-success' : 'bg-label-secondary'}">
                                    ${d.isActive == 1 ? 'Active' : 'Inactive'}
                                </span>
                            </td>
                        </tr>
                        <c:if test="${isManager}">
                        <tr>
                            <th class="ps-0">Action</th>
                            <td class="pt-3">
                                <c:choose>
                                    <c:when test="${d.isActive == 1}">
                                        <a class="btn btn-outline-danger btn-sm" href="${ctx}/home?p=supplier_inactive&id=${d.supplierId}">
                                            <i class="bx bx-block me-1"></i> Deactivate
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post" action="${ctx}/supplier-toggle" class="d-inline">
                                            <input type="hidden" name="supplierId" value="${d.supplierId}"/>
                                            <button type="submit" class="btn btn-outline-success btn-sm">
                                                <i class="bx bx-check-circle me-1"></i> Re-activate
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                                <a class="btn btn-outline-info btn-sm ms-2" href="${ctx}/home?p=view_history&supplierId=${d.supplierId}">
                                    <i class="bx bx-history me-1"></i> Trade History
                                </a>
                            </td>
                        </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Right: Activity Summary -->
    <div class="col-md-5">
        <div class="card h-100">
            <div class="card-header border-bottom">
                <h5 class="mb-0">Activity Summary</h5>
            </div>
            <div class="card-body pt-4">
                <div class="row g-4">
                    <div class="col-6">
                        <div class="d-flex align-items-center mb-2">
                            <div class="avatar me-2">
                                <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-receipt"></i></span>
                            </div>
                            <h4 class="ms-1 mb-0">${d.totalImportReceipts}</h4>
                        </div>
                        <p class="mb-0 small text-muted">Total Receipts</p>
                    </div>
                    <div class="col-6">
                        <div class="d-flex align-items-center mb-2">
                            <div class="avatar me-2">
                                <span class="avatar-initial rounded bg-label-info"><i class="bx bx-package"></i></span>
                            </div>
                            <h4 class="ms-1 mb-0">${d.totalQtyImported}</h4>
                        </div>
                        <p class="mb-0 small text-muted">Total Qty</p>
                    </div>
                </div>

                <hr class="my-4">

                <div>
                    <h6 class="mb-3">Last Transaction</h6>
                    <div class="d-flex align-items-center">
                        <div class="avatar avatar-sm me-3">
                            <span class="avatar-initial rounded bg-label-secondary"><i class="bx bx-time"></i></span>
                        </div>
                        <div>
                            <p class="mb-0 fw-bold">
                                <c:choose>
                                    <c:when test="${not empty d.lastTransaction}">${d.lastTransaction}</c:when>
                                    <c:otherwise><span class="text-muted">No transactions found</span></c:otherwise>
                                </c:choose>
                            </p>
                            <small class="text-muted">Recorded Date</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>