<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="role" value="${sessionScope.roleName}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Import Receipt List
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
            <input type="hidden" name="p" value="import-receipt-list"/>
            <input type="hidden" name="page" value="1"/>
            <input type="hidden" name="status" value="${fn:escapeXml(status)}"/>
            
            <div class="col-md-4">
                <label class="form-label">Search Receipt Code</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" name="q" class="form-control" value="${fn:escapeXml(q)}" placeholder="IR-2026..."/>
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
                <a class="btn btn-outline-secondary" href="${ctx}/home?p=import-receipt-list"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between pb-0">
        <div class="card-title mb-0">
            <h5 class="m-0 me-2">Import Receipts</h5>
        </div>
        <div class="d-flex gap-2">
            <form method="get" action="${ctx}/home">
                <input type="hidden" name="p" value="import-receipt-list"/>
                <input type="hidden" name="action" value="export"/>
                <input type="hidden" name="q" value="${fn:escapeXml(q)}"/>
                <input type="hidden" name="from" value="${fn:escapeXml(from)}"/>
                <input type="hidden" name="to" value="${fn:escapeXml(to)}"/>
                <input type="hidden" name="status" value="${fn:escapeXml(status)}"/>
                <button type="submit" class="btn btn-outline-success">
                    <i class="bx bx-export me-1"></i> Export Excel
                </button>
            </form>
            <c:if test="${role eq 'STAFF'}">
                <a class="btn btn-primary" href="${ctx}/home?p=create-import-receipt"><i class="bx bx-plus me-1"></i> Create Receipt</a>
            </c:if>
        </div>
    </div>

    <div class="card-body">
        <div class="nav-align-top mb-4 mt-3">
            <ul class="nav nav-tabs" role="tablist">
                <c:set var="statusBaseUrl" value="${ctx}/home?p=import-receipt-list&page=1&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}" />
                <li class="nav-item">
                    <a class="nav-link ${status=='all' || empty status ? 'active' : ''}" href="${statusBaseUrl}&status=all">
                        All <span class="badge badge-center rounded-pill bg-label-secondary ms-1">${tabCounts['all']}</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${status=='completed' ? 'active' : ''}" href="${statusBaseUrl}&status=completed">
                        Completed <span class="badge badge-center rounded-pill bg-label-success ms-1">${tabCounts['completed']}</span>
                    </a>
                </li>
            </ul>
        </div>

        <div class="table-responsive text-nowrap">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th class="text-center">#</th>
                        <th>Receipt Code</th>
                        <th>Supplier</th>
                        <th>Created By</th>
                        <th class="text-center">Date</th>
                        <th class="text-center">Qty</th>
                        <th class="text-center">Status</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    <c:if test="${empty rows}">
                        <tr><td colspan="8" class="text-center p-5 text-muted">No receipts found.</td></tr>
                    </c:if>
                    <c:forEach var="r" items="${rows}" varStatus="st">
                        <tr>
                            <td class="text-center text-muted small">${(page-1)*pageSize + st.index + 1}</td>
                            <td><span class="badge bg-label-primary font-monospace fw-bold">${r.importCode}</span></td>
                            <td><strong>${fn:escapeXml(r.supplierName)}</strong></td>
                            <td><small>${fn:escapeXml(r.createdByName)}</small></td>
                            <td class="text-center text-muted small">${r.receiptDate}</td>
                            <td class="text-center fw-bold text-primary">${r.totalQuantity}</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${r.statusUi == 'CONFIRMED' || r.statusUi == 'completed' || r.statusUi == 'COMPLETED'}">
                                        <span class="badge bg-label-success">Completed</span>
                                    </c:when>
                                    <c:when test="${r.statusUi == 'pending' || r.statusUi == 'PENDING'}">
                                        <span class="badge bg-label-warning">Pending</span>
                                    </c:when>
                                    <c:when test="${r.statusUi == 'cancelled' || r.statusUi == 'CANCELLED' || r.statusUi == 'CANCELED'}">
                                        <span class="badge bg-label-danger">Cancelled</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-label-secondary">${r.statusUi}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <div class="dropdown">
                                    <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                        <i class="bx bx-dots-vertical-rounded"></i>
                                    </button>
                                    <div class="dropdown-menu">
                                        <a class="dropdown-item" href="${ctx}/home?p=import-receipt-detail&id=${r.importId}"><i class="bx bx-show-alt me-1"></i> View Detail</a>
                                        <a class="dropdown-item text-warning" href="${ctx}/import-receipt-pdf?id=${r.importId}"><i class="bx bxs-file-pdf me-1"></i> Export PDF</a>
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
                <c:param name="p" value="import-receipt-list"/>
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