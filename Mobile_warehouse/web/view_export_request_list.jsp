<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Export Request List
</h4>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/home" class="row g-3 px-1">
            <input type="hidden" name="p" value="export-request-list"/>
            <input type="hidden" name="page" value="1"/>
            
            <div class="col-md-3">
                <label class="form-label">Search Request</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control" name="q" placeholder="Request code..." value="${fn:escapeXml(q)}"/>
                </div>
            </div>
            
            <div class="col-md-2">
                <label class="form-label">Status</label>
                <select class="form-select" name="status">
                    <option value="">All Statuses</option>
                    <option value="NEW" ${status eq 'NEW' ? 'selected' : ''}>New</option>
                    <option value="COMPLETE" ${status eq 'COMPLETE' ? 'selected' : ''}>Complete</option>
                </select>
            </div>
            
            <div class="col-md-2">
                <label class="form-label">Request Date</label>
                <input class="form-control" type="date" name="reqDate" value="${reqDate}"/>
            </div>
            
            <div class="col-md-2">
                <label class="form-label">Expected Date</label>
                <input class="form-control" type="date" name="expDate" value="${expDate}"/>
            </div>
            
            <div class="col-md-3 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Apply</button>
                <a class="btn btn-outline-secondary" href="${ctx}/home?p=export-request-list"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Export Requests</h5>
        <div class="text-muted small">Total: <strong>${totalItems}</strong></div>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Request Code</th>
                    <th>Created By</th>
                    <th class="text-center">Request Date</th>
                    <th class="text-center">Expected Date</th>
                    <th class="text-center">Items</th>
                    <th class="text-center">Total Qty</th>
                    <th class="text-center">Status</th>
                    <th class="text-center">Action</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:if test="${empty erList}">
                    <tr><td colspan="8" class="text-center p-4">No export requests found.</td></tr>
                </c:if>
                <c:forEach var="r" items="${erList}">
                    <tr>
                        <td><span class="badge bg-label-secondary font-monospace fw-bold">${fn:escapeXml(r.requestCode)}</span></td>
                        <td><strong>${fn:escapeXml(r.createdByName)}</strong></td>
                        <td class="text-center"><small class="text-muted"><c:out value="${r.requestDate}"/></small></td>
                        <td class="text-center"><small class="text-muted"><c:out value="${r.expectedExportDate}"/></small></td>
                        <td class="text-center"><span class="fw-bold">${r.totalItems}</span></td>
                        <td class="text-center"><span class="fw-bold text-primary">${r.totalQty}</span></td>
                        <td class="text-center">
                            <span class="badge ${r.status eq 'COMPLETE' ? 'bg-label-success' : 'bg-label-warning'}">
                                ${r.status eq 'COMPLETE' ? 'Complete' : 'New'}
                            </span>
                        </td>
                        <td class="text-center">
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="${ctx}/home?p=export-request-detail&id=${r.requestId}"><i class="bx bx-show-alt me-1"></i> View Detail</a>
                                    <c:if test="${role eq 'STAFF'}">
                                        <c:choose>
                                            <c:when test="${r.status eq 'COMPLETE'}">
                                                <a class="dropdown-item disabled" href="javascript:void(0);"><i class="bx bx-check-circle me-1"></i> Receipt Created</a>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="dropdown-item text-primary" href="${ctx}/home?p=create-export-receipt&requestId=${r.requestId}"><i class="bx bx-plus-circle me-1"></i> Create Receipt</a>
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

    <c:if test="${totalPages > 1}">
        <c:url var="baseUrl" value="/home">
            <c:param name="p" value="export-request-list"/>
            <c:param name="q" value="${q}"/>
            <c:param name="status" value="${status}"/>
            <c:param name="reqDate" value="${reqDate}"/>
            <c:param name="expDate" value="${expDate}"/>
        </c:url>

        <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Page <strong>${page}</strong> of <strong>${totalPages}</strong>
            </div>

            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <%-- Prev Button --%>
                    <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${page > 1 ? baseUrl.concat('&page=').concat(page-1) : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                    </li>

                    <%-- Sliding Window logic --%>
                    <c:set var="startPage" value="${page - 1 > 1 ? page - 1 : 1}"/>
                    <c:set var="endPage"   value="${page + 1 < totalPages ? page + 1 : totalPages}"/>

                    <c:if test="${startPage > 1}">
                        <li class="page-item"><a class="page-link" href="${baseUrl}&page=1">1</a></li>
                        <c:if test="${startPage > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    </c:if>

                    <c:forEach var="i" begin="${startPage}" end="${endPage}">
                        <li class="page-item ${i == page ? 'active' : ''}"><a class="page-link" href="${baseUrl}&page=${i}">${i}</a></li>
                    </c:forEach>

                    <c:if test="${endPage < totalPages}">
                        <c:if test="${endPage < totalPages - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                        <li class="page-item"><a class="page-link" href="${baseUrl}&page=${totalPages}">${totalPages}</a></li>
                    </c:if>

                    <%-- Next Button --%>
                    <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${page < totalPages ? baseUrl.concat('&page=').concat(page+1) : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>
