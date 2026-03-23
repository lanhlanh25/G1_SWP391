<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="isManager" value="${not empty sessionScope.roleName && sessionScope.roleName.toUpperCase() == 'MANAGER'}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Master Data / Brands /</span> Brand Details
</h4>

<c:if test="${not empty param.msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        ${param.msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">General Information</h5>
        <div class="d-flex gap-2">
            <a class="btn btn-outline-secondary btn-sm" href="${ctx}/home?p=brand-list">
                <i class="bx bx-arrow-back me-1"></i> Back to List
            </a>
            <c:if test="${isManager}">
                <a class="btn btn-primary btn-sm" href="${ctx}/home?p=brand-update&id=${brand.brandId}">
                    <i class="bx bx-edit-alt me-1"></i> Update
                </a>
            </c:if>
        </div>
    </div>
    <div class="card-body">
        <table class="table table-borderless">
            <tbody>
                <tr>
                    <th class="ps-0" style="width: 200px;">Brand Name</th>
                    <td class="fw-bold fs-5">${brand.brandName}</td>
                </tr>
                <tr>
                    <th class="ps-0">Status</th>
                    <td>
                        <span class="badge ${brand.active ? 'bg-label-success' : 'bg-label-secondary'}">
                            ${brand.active ? 'Active' : 'Inactive'}
                        </span>
                    </td>
                </tr>
                <tr>
                    <th class="ps-0">Description</th>
                    <td class="text-muted">${empty brand.description ? 'No description provided' : brand.description}</td>
                </tr>
                <tr>
                    <th class="ps-0">Created At</th>
                    <td><span class="text-muted"><c:out value="${brand.createdAt}"/></span></td>
                </tr>
                <tr>
                    <th class="ps-0">Last Updated</th>
                    <td><span class="text-muted"><c:out value="${brand.updatedAt}"/></span></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>