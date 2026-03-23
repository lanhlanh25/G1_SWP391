<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Home /</span> Staff Dashboard
</h4>

<div class="row">
    <div class="col-lg-12 mb-4">
        <div class="card bg-info text-white">
            <div class="card-body d-flex align-items-center justify-content-between p-4">
                <div>
                    <h5 class="card-title text-white mb-1">Warehouse Operations</h5>
                    <p class="mb-0 text-white opacity-75">Monitoring inventory levels and daily warehouse activities.</p>
                </div>
                <div class="avatar avatar-lg bg-white rounded">
                    <i class="bx bx-package text-info fs-3"></i>
                </div>
            </div>
        </div>
    </div>
</div>

    <div class="row">
        <!-- Inventory -->
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card h-100 border-top border-primary border-3">
                <div class="card-body text-center">
                    <div class="avatar avatar-lg mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-collection fs-4"></i></span>
                    </div>
                    <h5 class="card-title">Inventory</h5>
                    <p class="card-text small text-muted">Review current stock levels and details.</p>
                    <a href="${ctx}/inventory" class="btn btn-sm btn-primary">Open Inventory</a>
                </div>
            </div>
        </div>

        <!-- Audit -->
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card h-100 border-top border-warning border-3">
                <div class="card-body text-center">
                    <div class="avatar avatar-lg mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-warning"><i class="bx bx-check-square fs-4"></i></span>
                    </div>
                    <h5 class="card-title">Audit</h5>
                    <p class="card-text small text-muted">Perform physical counting checks.</p>
                    <a href="${ctx}/inventory-count" class="btn btn-sm btn-warning text-white">Start Count</a>
                </div>
            </div>
        </div>

        <!-- Inbound -->
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card h-100 border-top border-success border-3">
                <div class="card-body text-center">
                    <div class="avatar avatar-lg mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-success"><i class="bx bx-down-arrow-circle fs-4"></i></span>
                    </div>
                    <h5 class="card-title">Inbound</h5>
                    <p class="card-text small text-muted">Handle new incoming shipment receipts.</p>
                    <div class="d-flex justify-content-center gap-1">
                        <a href="${ctx}/home?p=import-receipt-list" class="btn btn-xs btn-outline-success">List</a>
                        <a href="${ctx}/home?p=create-import-receipt" class="btn btn-xs btn-success">Create</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Outbound -->
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card h-100 border-top border-info border-3">
                <div class="card-body text-center">
                    <div class="avatar avatar-lg mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-up-arrow-circle fs-4"></i></span>
                    </div>
                    <h5 class="card-title">Outbound</h5>
                    <p class="card-text small text-muted">Prepare and issue export receipts.</p>
                    <div class="d-flex justify-content-center gap-1">
                        <a href="${ctx}/home?p=export-receipt-list" class="btn btn-xs btn-outline-info">List</a>
                        <a href="${ctx}/home?p=create-export-receipt" class="btn btn-xs btn-info">Create</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5 class="card-title m-0">Quick Access</h5>
                    <small class="text-muted">Direct links to common tools</small>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-3 col-sm-6">
                            <a href="${ctx}/inventory" class="btn btn-outline-primary w-100">
                                <i class="bx bx-package me-1"></i> Stock Overview
                            </a>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <a href="${ctx}/inventory-count" class="btn btn-outline-warning w-100">
                                <i class="bx bx-edit me-1"></i> Inventory Count
                            </a>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <a href="${ctx}/home?p=view_supplier" class="btn btn-outline-secondary w-100">
                                <i class="bx bx-group me-1"></i> View Suppliers
                            </a>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <a href="${ctx}/home?p=my-profile" class="btn btn-outline-dark w-100">
                                <i class="bx bx-user me-1"></i> My Profile
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
