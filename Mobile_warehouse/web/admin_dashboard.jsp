<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Home /</span> System Admin Dashboard
</h4>

<div class="row">
    <div class="col-lg-12 mb-4">
        <div class="card bg-dark text-white">
            <div class="card-body d-flex align-items-center justify-content-between p-4">
                <div>
                    <h5 class="card-title text-white mb-1">Administrator Control Panel</h5>
                    <p class="mb-0 text-white opacity-75">Manage users, security, and global system configurations.</p>
                </div>
                <div class="avatar avatar-lg bg-white rounded">
                    <i class="bx bx-shield-quarter text-dark fs-3"></i>
                </div>
            </div>
        </div>
    </div>
</div>

    <div class="row">
        <!-- Users -->
        <div class="col-md-4 mb-4">
            <div class="card h-100">
                <div class="card-body text-center">
                    <div class="avatar avatar-md mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-user fs-4"></i></span>
                    </div>
                    <h5 class="card-title">User Management</h5>
                    <p class="card-text small text-muted">Manage system accounts and access.</p>
                    <a href="${ctx}/home?p=user-list" class="btn btn-sm btn-primary">User List</a>
                </div>
            </div>
        </div>

        <!-- Roles -->
        <div class="col-md-4 mb-4">
            <div class="card h-100">
                <div class="card-body text-center">
                    <div class="avatar avatar-md mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-key fs-4"></i></span>
                    </div>
                    <h5 class="card-title">Roles & Perms</h5>
                    <p class="card-text small text-muted">Define permissions and role levels.</p>
                    <a href="${ctx}/home?p=role-list" class="btn btn-sm btn-info">Role List</a>
                </div>
            </div>
        </div>

        <!-- Logs -->
        <div class="col-md-4 mb-4">
            <div class="card h-100">
                <div class="card-body text-center">
                    <div class="avatar avatar-md mx-auto mb-3">
                        <span class="avatar-initial rounded bg-label-secondary"><i class="bx bx-list-ul fs-4"></i></span>
                    </div>
                    <h5 class="card-title">System Logs</h5>
                    <p class="card-text small text-muted">Review system activities and audit trails.</p>
                    <a href="javascript:void(0);" class="btn btn-sm btn-secondary disabled">Coming Soon</a>
                </div>
            </div>
        </div>
    </div>
</div>