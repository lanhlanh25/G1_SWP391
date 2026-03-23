<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Reports /</span> Stock Movement History
</h4>

<c:if test="${not empty err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        <i class="bx bx-error me-1"></i> ${fn:escapeXml(err)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/home" class="row g-3 px-1">
            <input type="hidden" name="p" value="stock-movement-history"/>
            <input type="hidden" name="page" value="1"/>
            
            <div class="col-md-3">
                <label class="form-label">Search Keyword</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" name="keyword" value="${fn:escapeXml(keyword)}" class="form-control" placeholder="Product name or code">
                </div>
            </div>

            <div class="col-md-2">
                <label class="form-label">From Date</label>
                <input type="date" name="from" value="${fn:escapeXml(from)}" class="form-control">
            </div>

            <div class="col-md-2">
                <label class="form-label">To Date</label>
                <input type="date" name="to" value="${fn:escapeXml(to)}" class="form-control">
            </div>

            <div class="col-md-2">
                <label class="form-label">Type</label>
                <select name="movementType" class="form-select">
                    <option value="ALL" ${movementType eq 'ALL' ? 'selected' : ''}>All Types</option>
                    <option value="IMPORT" ${movementType eq 'IMPORT' ? 'selected' : ''}>Import</option>
                    <option value="EXPORT" ${movementType eq 'EXPORT' ? 'selected' : ''}>Export</option>
                </select>
            </div>

            <div class="col-md-3 d-flex align-items-end gap-2">
                <button type="submit" class="btn btn-primary w-100">Apply</button>
                <a href="${ctx}/home?p=stock-movement-history" class="btn btn-outline-secondary"><i class="bx bx-refresh"></i></a>
            </div>
            
            <div class="col-md-4">
                <label class="form-label">Reference Code</label>
                <input type="text" name="referenceCode" value="${fn:escapeXml(referenceCode)}" class="form-control" placeholder="IR... / ER...">
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between pb-0 mb-3">
        <h5 class="m-0">Movement List</h5>
        <div class="text-muted small">Total Found: <strong>${totalItems}</strong></div>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th class="text-center">Date / Time</th>
                    <th>Product Details</th>
                    <th class="text-center">Type</th>
                    <th class="text-center">Qty</th>
                    <th class="text-center">Ref Code</th>
                    <th class="text-center">In Charge</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:choose>
                    <c:when test="${empty rows}">
                        <tr><td colspan="6" class="text-center p-5 text-muted">No stock movement found.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="r" items="${rows}">
                            <tr>
                                <td class="text-center">
                                    <small class="text-muted"><fmt:formatDate value="${r.movementTime}" pattern="dd/MM/yyyy HH:mm"/></small>
                                </td>
                                <td>
                                    <span class="badge bg-label-info font-monospace small mb-1">${r.productCode}</span><br/>
                                    <strong>${fn:escapeXml(r.productName)}</strong>
                                </td>
                                <td class="text-center">
                                    <span class="badge ${r.movementType eq 'IMPORT' ? 'bg-label-success' : 'bg-label-info'}">
                                        <i class="bx ${r.movementType eq 'IMPORT' ? 'bx-down-arrow-alt' : 'bx-up-arrow-alt'} me-1"></i>
                                        ${r.movementType eq 'IMPORT' ? 'Import' : 'Export'}
                                    </span>
                                </td>
                                <td class="text-center fw-bold">
                                    <c:choose>
                                        <c:when test="${r.qtyChange gt 0}">
                                            <span class="text-success">+${r.qtyChange}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-danger">${r.qtyChange}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${r.movementType eq 'IMPORT'}">
                                            <a class="fw-semibold text-primary" href="${ctx}/home?p=import-receipt-detail&id=${r.referenceId}">
                                                ${r.referenceCode}
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="fw-semibold text-info" href="${ctx}/home?p=export-receipt-detail&id=${r.referenceId}">
                                                ${r.referenceCode}
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center"><small class="fw-bold">${r.performedBy}</small></td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <c:if test="${totalPages > 1}">
        <c:url var="baseUrl" value="/home">
            <c:param name="p" value="stock-movement-history"/>
            <c:param name="keyword" value="${keyword}"/>
            <c:param name="from" value="${from}"/>
            <c:param name="to" value="${to}"/>
            <c:param name="movementType" value="${movementType}"/>
            <c:param name="referenceCode" value="${referenceCode}"/>
            <c:param name="performedBy" value="${performedBy}"/>
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
