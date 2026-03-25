<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="role" value="${sessionScope.roleName}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Export Management
</h4>

<c:if test="${not empty param.msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        ${fn:escapeXml(param.msg)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty param.err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        ${fn:escapeXml(param.err)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/home" class="row g-3 px-1">
            <input type="hidden" name="p" value="export-receipt-list"/>
            <input type="hidden" name="page" value="1"/>
            <input type="hidden" name="status" value="${fn:escapeXml(status)}"/>
            
            <div class="col-md-4">
                <label class="form-label">Search Receipt</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" name="q" class="form-control" value="${fn:escapeXml(q)}" placeholder="Receipt or Request code..."/>
                </div>
            </div>
            
            <div class="col-md-3">
                <label class="form-label">From Date</label>
                <input type="date" name="from" class="form-control" value="${fn:escapeXml(from)}"/>
            </div>
            
            <div class="col-md-3">
                <label class="form-label">To Date</label>
                <input type="date" name="to" class="form-control" value="${fn:escapeXml(to)}"/>
            </div>
            
            <div class="col-md-2 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Filter</button>
                <a class="btn btn-outline-secondary" href="${ctx}/home?p=export-receipt-list"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between pb-0">
        <div class="card-title mb-0">
            <h5 class="m-0 me-2">Export Receipts</h5>
        </div>
        <c:if test="${role eq 'STAFF'}">
            <a class="btn btn-primary" href="${ctx}/home?p=create-export-receipt"><i class="bx bx-plus me-1"></i> Create Receipt</a>
        </c:if>
    </div>

    <div class="card-body">
        <div class="nav-align-top mb-4">
            <ul class="nav nav-tabs" role="tablist">
                <c:set var="statusBaseUrl" value="${ctx}/home?p=export-receipt-list&page=1&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}" />
                <li class="nav-item">
                    <a class="nav-link ${status=='all' || empty status ? 'active' : ''}" href="${statusBaseUrl}&status=all">
                        All <span class="badge badge-center rounded-pill bg-label-secondary ms-1">${tabCounts['all']}</span>
                    </a>
                </li>
               
            </ul>
        </div>

        <table class="table table-hover text-nowrap">
                <thead>
                    <tr>
                        <th class="text-center">#</th>
                        <th>Receipt Code</th>
                        <th>Request Code</th>
                        <th>Created By</th>
                        <th class="text-center">Export Date</th>
                        <th class="text-center">Qty</th>
                        <th class="text-center">Status</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    <c:if test="${empty rows}">
                        <tr><td colspan="8" class="text-center p-5">No export receipts found.</td></tr>
                    </c:if>
                    <c:forEach var="r" items="${rows}" varStatus="st">
                        <tr>
                            <td class="text-center text-muted small">${(page-1)*pageSize + st.index + 1}</td>
                            <td><span class="badge bg-label-primary font-monospace fw-bold">${r.exportCode}</span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${empty r.requestCode || r.requestCode == '-'}">
                                        <span class="text-muted small">N/A</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="fw-semibold">${r.requestCode}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${fn:escapeXml(r.createdByName)}</td>
                            <td class="text-center text-muted small">${r.exportDateUi}</td>
                            <td class="text-center fw-bold text-primary">${r.totalQty}</td>
                                    <td class="text-center">
                        <c:set var="statusUp" value="${fn:toUpperCase(r.status)}"/>
                        <c:choose>
                            <c:when test="${statusUp == 'CONFIRMED'}">
                                <span class="badge bg-label-success">Completed</span>
                            </c:when>
                         
                          
                            <c:otherwise>
                                <span class="badge bg-label-secondary">
                                    <c:out value="${r.status}"/>
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                            <td class="text-center">
                                <div class="dropdown">
                                    <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown" data-bs-boundary="viewport">
                                        <i class="bx bx-dots-vertical-rounded"></i>
                                    </button>
                                    <div class="dropdown-menu dropdown-menu-end">
                                        <a class="dropdown-item" href="${ctx}/home?p=export-receipt-detail&id=${r.exportId}"><i class="bx bx-show-alt me-1"></i> View Detail</a>
                                        <a class="dropdown-item" href="${ctx}/export-receipt-pdf?id=${r.exportId}" target="_blank"><i class="bx bxs-file-pdf me-1"></i> Export PDF</a>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

        <c:if test="${totalPages > 1}">
            <c:url var="baseUrl" value="/home">
                <c:param name="p" value="export-receipt-list"/>
                <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
                <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
            </c:url>

            <div class="card-footer d-flex justify-content-between align-items-center px-0 pb-0">
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
</div>

