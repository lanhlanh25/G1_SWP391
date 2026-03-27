<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Home /</span> Sales Dashboard
</h4>

<div class="row">
    <div class="col-lg-12 mb-4">
        <div class="card bg-primary text-white">
            <div class="card-body d-flex align-items-center justify-content-between p-4">
                <div>
                    <h5 class="card-title text-white mb-1">Welcome back, Sales Associate!</h5>
                    <p class="mb-0 text-white opacity-75">Track your shipments and manage inventory movements today.</p>
                </div>
                <div class="avatar avatar-lg bg-white rounded">
                    <i class="bx bx-trending-up text-primary fs-3"></i>
                </div>
            </div>
        </div>
    </div>
</div>

    <div class="row">
        <!-- Export -->
        <div class="col-lg-4 col-md-6 mb-4">
            <div class="card h-100 border-top border-primary border-3">
                <div class="card-body text-center">
                    <div class="avatar avatar-lg mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-export fs-4"></i></span>
                    </div>
                    <h5 class="card-title">Export</h5>
                    <p class="card-text small text-muted">Create new export requests for processing.</p>
                    <a href="${ctx}/home?p=create-export-request" class="btn btn-sm btn-primary">Create Request</a>
                </div>
            </div>
        </div>

        <!-- Tracking -->
        <div class="col-lg-4 col-md-6 mb-4">
            <div class="card h-100 border-top border-info border-3">
                <div class="card-body text-center">
                    <div class="avatar avatar-lg mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-list-check fs-4"></i></span>
                    </div>
                    <h5 class="card-title">Tracking</h5>
                    <p class="card-text small text-muted">Monitor fulfillment and shipment status.</p>
                    <a href="${ctx}/home?p=export-request-list" class="btn btn-sm btn-info">Open List</a>
                </div>
            </div>
        </div>

        <!-- Inbound -->
        <div class="col-lg-4 col-md-6 mb-4">
            <div class="card h-100 border-top border-warning border-3">
                <div class="card-body text-center">
                    <div class="avatar avatar-lg mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-warning"><i class="bx bx-import fs-4"></i></span>
                    </div>
                    <h5 class="card-title">Import</h5>
                    <p class="card-text small text-muted">Request stock replenishment when needed.</p>
                    <a href="${ctx}/home?p=create-import-request" class="btn btn-sm btn-warning text-white">New Request</a>
                </div>
            </div>
        </div>

        
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5 class="card-title m-0">Today's Workflow</h5>
                    <small class="text-muted">Launch common sales actions</small>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-4 col-sm-6">
                            <a href="${ctx}/home?p=create-export-request" class="btn btn-outline-primary w-100 py-3">
                                <i class="bx bx-plus-circle d-block fs-3 mb-1"></i> New Export Request
                            </a>
                        </div>
                        <div class="col-md-4 col-sm-6">
                            <a href="${ctx}/home?p=export-request-list" class="btn btn-outline-info w-100 py-3">
                                <i class="bx bx-list-ul d-block fs-3 mb-1"></i> Review Export List
                            </a>
                        </div>
                        <div class="col-md-4 col-sm-6">
                            <a href="${ctx}/home?p=create-import-request" class="btn btn-outline-warning w-100 py-3">
                                <i class="bx bx-send d-block fs-3 mb-1"></i> New Import Request
                            </a>
                        </div>
                        <div class="col-md-4 col-sm-6">
                            <a href="${ctx}/home?p=import-request-list" class="btn btn-outline-secondary w-100 py-3">
                                <i class="bx bx-history d-block fs-3 mb-1"></i> Review Import List
                            </a>
                        </div>

                        <div class="col-md-4 col-sm-6">
                            <a href="${ctx}/home?p=dashboard" class="btn btn-label-primary w-100 py-3">
                                <i class="bx bx-home-alt d-block fs-3 mb-1"></i> Overview Home
                            </a>
                        </div>
                    </div>
                </div>
            </div>
    </div>
</div>
