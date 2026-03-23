<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">System /</span> Role Management
</h4>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/home" class="row g-3 px-1">
            <input type="hidden" name="p" value="role-list"/>
            
            <div class="col-md-6">
                <label class="form-label">Search Roles</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" name="q" class="form-control" value="${fn:escapeXml(param.q)}" placeholder="Search roles..."/>
                </div>
            </div>
            
            <div class="col-md-3">
                <label class="form-label">Status</label>
                <select class="form-select" name="status">
                    <option value="" ${empty param.status ? 'selected' : ''}>All Statuses</option>
                    <option value="1" ${param.status == '1' ? 'selected' : ''}>Active</option>
                    <option value="0" ${param.status == '0' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>
            
            <div class="col-md-3 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Filter</button>
                <a class="btn btn-outline-secondary" href="${ctx}/home?p=role-list"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between pb-0 mb-3">
        <h5 class="m-0">Roles Database</h5>
        <a class="btn btn-primary" href="${ctx}/home?p=role-add">
            <i class="bx bx-plus me-1"></i> Add Role
        </a>
    </div>
    
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th class="text-center" style="width:70px;">#</th>
                    <th>Role Name</th>
                    <th>Description</th>
                    <th class="text-center">Users</th>
                    <th class="text-center">Status</th>
                    <th class="text-center">Actions</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:if test="${empty roles}">
                    <tr><td colspan="6" class="text-center p-5 text-muted">No roles found matching your criteria.</td></tr>
                </c:if>
                <c:forEach var="r" items="${roles}" varStatus="st">
                    <tr>
                        <td class="text-center text-muted small">${st.index + 1}</td>
                        <td><strong>${fn:escapeXml(r.roleName)}</strong></td>
                        <td><small class="text-muted text-wrap d-block" style="max-width: 300px;">${r.description == null ? '—' : fn:escapeXml(r.description)}</small></td>
                        <td class="text-center">
                            <span class="badge bg-label-secondary font-monospace">${r.userCount}</span>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${r.status == 1}">
                                    <span class="badge bg-label-success">Active</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-label-danger">Inactive</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="${ctx}/home?p=role-detail&roleId=${r.roleId}"><i class="bx bx-show-alt me-1"></i> View Detail</a>
                                    <a class="dropdown-item" href="${ctx}/home?p=role-update&roleId=${r.roleId}"><i class="bx bx-shield-quarter me-1"></i> Permissions</a>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>
