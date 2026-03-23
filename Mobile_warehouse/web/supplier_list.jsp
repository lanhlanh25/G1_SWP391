<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="isManager" value="${not empty sessionScope.roleName && fn:toUpperCase(sessionScope.roleName) == 'MANAGER'}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Supplier Management
</h4>

<c:if test="${not empty param.msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        ${param.msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${pageContext.request.contextPath}/home" class="row g-3">
            <input type="hidden" name="p" value="view_supplier"/>
            <input type="hidden" name="page" value="1"/>
            
            <div class="col-md-4">
                <label class="form-label">Search Supplier</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control" name="q" value="${q}" placeholder="Name, email, phone..."/>
                </div>
            </div>
            
            <div class="col-md-2">
                <label class="form-label">Status</label>
                <select class="form-select" name="status">
                    <option value="" ${empty status ? 'selected' : ''}>All Status</option>
                    <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>
            
            <div class="col-md-3">
                <label class="form-label">Sort By</label>
                <div class="input-group">
                    <select class="form-select" name="sortBy">
                        <option value="newest" ${sortBy == 'newest' ? 'selected' : ''}>Newest</option>
                        <option value="name" ${sortBy == 'name' ? 'selected' : ''}>Name</option>
                        <option value="transactions" ${sortBy == 'transactions' ? 'selected' : ''}>Transactions</option>
                    </select>
                    <select class="form-select" name="sortOrder" style="max-width: 100px;">
                        <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>DESC</option>
                        <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>ASC</option>
                    </select>
                </div>
            </div>
            
            <div class="col-md-3 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Apply Filters</button>
                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/home?p=view_supplier"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Supplier List</h5>
        <c:if test="${isManager}">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/home?p=add_supplier"><i class="bx bx-plus me-1"></i> Add Supplier</a>
        </c:if>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Supplier</th>
                    <th>Contact</th>
                    <th class="text-center">Status</th>
                    <th class="text-center">Transactions</th>
                    <th class="text-center">Action</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:if test="${empty suppliers}">
                    <tr><td colspan="5" class="text-center p-4">No suppliers found matching your criteria.</td></tr>
                </c:if>
                <c:forEach var="s" items="${suppliers}">
                    <tr>
                        <td>
                            <div class="d-flex align-items-center">
                                <div class="avatar avatar-xs me-2">
                                    <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-buildings"></i></span>
                                </div>
                                <div>
                                    <h6 class="mb-0 text-truncate" style="max-width: 200px;">${s.supplierName}</h6>
                                    <small class="text-muted">ID: ${s.supplierId}</small>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex flex-column">
                                <small class="fw-semibold">${s.email}</small>
                                <small class="text-muted">${s.phone}</small>
                            </div>
                        </td>
                        <td class="text-center">
                            <span class="badge ${s.isActive == 1 ? 'bg-label-success' : 'bg-label-secondary'}">
                                ${s.isActive == 1 ? 'Active' : 'Inactive'}
                            </span>
                        </td>
                        <td class="text-center">
                            <span class="fw-bold">${s.totalTransactions}</span>
                        </td>
                        <td class="text-center">
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="${ctx}/home?p=supplier_detail&id=${s.supplierId}"><i class="bx bx-show-alt me-1"></i> View Detail</a>
                                    <c:if test="${isManager}">
                                        <a class="dropdown-item" href="${ctx}/home?p=update_supplier&id=${s.supplierId}"><i class="bx bx-edit-alt me-1"></i> Edit Supplier</a>
                                        <c:choose>
                                            <c:when test="${s.isActive == 1}">
                                                <a class="dropdown-item text-danger" href="${ctx}/home?p=supplier_inactive&id=${s.supplierId}"><i class="bx bx-block me-1"></i> Deactivate</a>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="post" action="${ctx}/supplier-toggle" id="form-enable-${s.supplierId}" class="d-none">
                                                    <input type="hidden" name="supplierId" value="${s.supplierId}"/>
                                                </form>
                                                <a class="dropdown-item text-success" href="javascript:void(0);" onclick="document.getElementById('form-enable-${s.supplierId}').submit();"><i class="bx bx-check-circle me-1"></i> Activate</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <c:set var="safeTotal"      value="${empty totalItems  ? 0 : totalItems}"/>
    <c:set var="safePage"       value="${empty page        ? 1 : page}"/>
    <c:set var="safeTotalPages" value="${empty totalPages  ? 1 : totalPages}"/>
    <c:set var="safePageSize"   value="${empty pageSize    ? 5 : pageSize}"/>
    <c:set var="startRow" value="${safeTotal == 0 ? 0 : (safePage-1)*safePageSize+1}"/>
    <c:set var="endRow"   value="${safeTotal == 0 ? 0 : (safePage*safePageSize > safeTotal ? safeTotal : safePage*safePageSize)}"/>
    <c:set var="base" value="${ctx}/home?p=view_supplier&q=${q}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&page="/>

    <div class="card-footer d-flex justify-content-between align-items-center">
        <div class="text-muted small">
            Page <strong>${safePage}</strong> of <strong>${safeTotalPages}</strong>
        </div>

        <nav aria-label="Page navigation">
            <ul class="pagination pagination-sm mb-0">
                <%-- Prev Button --%>
                <li class="page-item ${safePage <= 1 ? 'disabled' : ''}">
                    <a class="page-link" href="${safePage > 1 ? base.concat(safePage-1) : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                </li>

                <%-- Dynamic Page Numbers --%>
                <c:set var="startPage" value="${safePage - 1 > 1 ? safePage - 1 : 1}"/>
                <c:set var="endPage" value="${safePage + 1 < safeTotalPages ? safePage + 1 : safeTotalPages}"/>
                
                <c:if test="${startPage > 1}">
                    <li class="page-item"><a class="page-link" href="${base}1">1</a></li>
                    <c:if test="${startPage > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                </c:if>

                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                    <li class="page-item ${i == safePage ? 'active' : ''}">
                        <a class="page-link" href="${base}${i}">${i}</a>
                    </li>
                </c:forEach>

                <c:if test="${endPage < safeTotalPages}">
                    <c:if test="${endPage < safeTotalPages - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    <li class="page-item"><a class="page-link" href="${base}${safeTotalPages}">${safeTotalPages}</a></li>
                </c:if>

                <%-- Next Button --%>
                <li class="page-item ${safePage >= safeTotalPages ? 'disabled' : ''}">
                    <a class="page-link" href="${safePage < safeTotalPages ? base.concat(safePage+1) : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                </li>
            </ul>
        </nav>
    </div>
</div>