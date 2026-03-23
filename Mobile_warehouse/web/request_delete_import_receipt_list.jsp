<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Delete Import Request Management
</h4>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/home" class="row g-3 px-1">
            <input type="hidden" name="p" value="request-delete-import-receipt-list"/>
            <input type="hidden" name="page" value="1"/>
            
            <div class="col-md-4">
                <label class="form-label">Search Import Code</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" name="q" class="form-control" value="${fn:escapeXml(q)}" placeholder="Import code..."/>
                </div>
            </div>
            
            <div class="col-md-3">
                <label class="form-label">Request Date</label>
                <input type="date" name="transactionTime" class="form-control" value="${fn:escapeXml(transactionTime)}"/>
            </div>
            
            <div class="col-md-3 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Filter</button>
                <a class="btn btn-outline-secondary" href="${ctx}/home?p=request-delete-import-receipt-list"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between pb-0 mb-3">
        <h5 class="m-0">Delete Requests</h5>
        <div class="text-muted small">Total Found: <strong>${totalItems}</strong></div>
    </div>
    
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th class="text-center">#</th>
                    <th>Import Code</th>
                    <th>Note / Reason</th>
                    <th>Requested By</th>
                    <th class="text-center">Request Time</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:choose>
                    <c:when test="${empty requests}">
                        <tr><td colspan="5" class="text-center p-5 text-muted">No pending delete requests found.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="r" items="${requests}" varStatus="st">
                            <tr>
                                <td class="text-center text-muted small">${(page-1)*pageSize + st.index + 1}</td>
                                <td><span class="badge bg-label-primary font-monospace fw-bold">${fn:escapeXml(r.importCode)}</span></td>
                                <td><small class="text-wrap" style="max-width: 300px; display: block;">${fn:escapeXml(r.note)}</small></td>
                                <td><small class="fw-bold">${fn:escapeXml(r.requestedByName)}</small></td>
                                <td class="text-center">
                                    <small class="text-muted"><fmt:formatDate value="${r.transactionTime}" pattern="dd/MM/yyyy HH:mm"/></small>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <c:if test="${totalPages > 1}">
        <c:url var="baseUrl" value="/home">
            <c:param name="p" value="request-delete-import-receipt-list"/>
            <c:param name="q" value="${q}"/>
            <c:param name="transactionTime" value="${transactionTime}"/>
        </c:url>

        <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Showing <strong>${totalItems == 0 ? 0 : (page - 1) * pageSize + 1}</strong>–<strong>${page * pageSize < totalItems ? page * pageSize : totalItems}</strong> of <strong>${totalItems}</strong>
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