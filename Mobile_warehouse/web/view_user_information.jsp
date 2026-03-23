<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="container-xxl flex-grow-1">
    <div class="row">
        <div class="col-12">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${ctx}/home?p=dashboard">Home</a></li>
                    <li class="breadcrumb-item"><a href="${ctx}/home?p=user-list">Users</a></li>
                    <li class="breadcrumb-item active">View Details</li>
                </ol>
            </nav>

            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bx bx-user me-1"></i> User Information</h5>
                    <a class="btn btn-outline-secondary btn-sm" href="${ctx}/home?p=user-list">
                        <i class="bx bx-arrow-back me-1"></i> Back to List
                    </a>
                </div>
                <div class="card-body">
                    <div class="d-flex align-items-center mb-4 pb-2 border-bottom">
                        <div class="avatar avatar-xl me-3">
                            <img src="${ctx}/${empty user.avatar ? 'assets/default-avatar.jpg' : user.avatar}?v=<fmt:formatDate value='${now}' pattern='yyyyMMddHHmmssSSS'/>"
                                 alt="Avatar" class="rounded-circle" style="object-fit:cover;">
                        </div>
                        <div>
                            <h4 class="mb-0 fw-bold">${user.fullName}</h4>
                            <span class="badge bg-label-primary mb-1">${roleName}</span>
                            <div class="text-muted small">@${user.username}</div>
                        </div>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label text-muted small">User ID</label>
                            <input type="text" class="form-control bg-light" value="${user.userId}" readonly />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label text-muted small">Username</label>
                            <input type="text" class="form-control bg-light" value="${user.username}" readonly />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small">Full Name</label>
                            <input type="text" class="form-control bg-light" value="${user.fullName}" readonly />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label text-muted small">Email Address</label>
                            <div class="input-group input-group-merge">
                                <span class="input-group-text"><i class="bx bx-envelope"></i></span>
                                <input type="text" class="form-control bg-light" value="${user.email}" readonly />
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small">Phone Number</label>
                            <div class="input-group input-group-merge">
                                <span class="input-group-text"><i class="bx bx-phone"></i></span>
                                <input type="text" class="form-control bg-light" value="${user.phone}" readonly />
                            </div>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-muted small">Address</label>
                            <textarea class="form-control bg-light" rows="2" readonly>${user.address}</textarea>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label text-muted small">System Status</label>
                            <div>
                                <c:choose>
                                    <c:when test="${user.status == 1}">
                                        <span class="badge bg-label-success px-3 py-2"><i class="bx bx-check-circle me-1"></i> Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-label-secondary px-3 py-2"><i class="bx bx-block me-1"></i> Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="mt-5 border-top pt-4">
                        <a href="${ctx}/home?p=user-update&id=${user.userId}" class="btn btn-primary">
                            <i class="bx bx-edit-alt me-1"></i> Update User Information
                        </a>
                        <a href="${ctx}/home?p=user-list" class="btn btn-outline-secondary ms-2">Close</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>