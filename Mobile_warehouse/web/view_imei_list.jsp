<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> IMEI Inventory Detail
</h4>

<div class="row mb-4">
    <div class="col-12">
        <div class="card bg-label-primary border-primary">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-2 col-sm-4">
                        <small class="text-uppercase text-muted d-block mb-1">SKU Code</small>
                        <span class="fw-bold text-primary font-monospace">${fn:escapeXml(skuCode)}</span>
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <small class="text-uppercase text-muted d-block mb-1">Product Code</small>
                        <span class="fw-bold">${fn:escapeXml(productCode)}</span>
                    </div>
                    <div class="col-md-3 col-sm-4">
                        <small class="text-uppercase text-muted d-block mb-1">Product Model</small>
                        <span class="fw-bold">${fn:escapeXml(productModel)}</span>
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <small class="text-uppercase text-muted d-block mb-1">Color</small>
                        <span class="badge bg-label-info">${fn:escapeXml(color)}</span>
                    </div>
                    <div class="col-md-1 col-sm-4">
                        <small class="text-uppercase text-muted d-block mb-1">RAM</small>
                        <span class="fw-bold">${ramGb} GB</span>
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <small class="text-uppercase text-muted d-block mb-1">Storage</small>
                        <span class="fw-bold">${storageGb} GB</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/imei-list" class="row g-3 px-1">
            <input type="hidden" name="skuId" value="${skuId}"/>
            <input type="hidden" name="page" value="1"/>
            <input type="hidden" name="pageSize" value="${pageSize}"/>
            <input type="hidden" name="back" value="${fn:escapeXml(param.back)}"/>
            
            <div class="col-md-8">
                <label class="form-label">Search IMEI</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" name="q" class="form-control" value="${fn:escapeXml(q)}" placeholder="Search IMEI…"/>
                </div>
            </div>
            
            <div class="col-md-4 d-flex align-items-end gap-2">
                <button type="submit" class="btn btn-primary w-100">Search</button>
                <c:choose>
                    <c:when test="${not empty param.back}">
                        <a href="${fn:escapeXml(param.back)}" class="btn btn-outline-secondary w-100"><i class="bx bx-arrow-back me-1"></i> Back</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${ctx}/inventory-count" class="btn btn-outline-secondary w-100"><i class="bx bx-arrow-back me-1"></i> Back</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between pb-3">
        <h5 class="m-0">IMEI Records</h5>
        <div class="d-flex align-items-center gap-2 small">
            <span class="text-muted">Rows:</span>
            <select class="form-select form-select-sm w-auto" onchange="
                location.href='${ctx}/imei-list?skuId=${skuId}&q=${fn:escapeXml(q)}&back='+encodeURIComponent('${fn:escapeXml(param.back)}')+'&page=1&pageSize='+this.value">
                <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
            </select>
        </div>
    </div>
    
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th class="text-center" style="width:70px;">#</th>
                    <th>IMEI</th>
                    <th class="text-center">Import Date</th>
                    <th class="text-center">Export Date</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:if test="${empty imeiRows}">
                    <tr><td colspan="4" class="text-center p-5 text-muted">No IMEI records found.</td></tr>
                </c:if>
                <c:forEach var="r" items="${imeiRows}" varStatus="st">
                    <tr>
                        <td class="text-center text-muted small">${(pageNumber - 1) * pageSize + st.index + 1}</td>
                        <td class="font-monospace fw-bold text-primary">${fn:escapeXml(r.imei)}</td>
                        <td class="text-center small">
                            <c:choose>
                                <c:when test="${not empty r.importDate}">
                                    <fmt:formatDate value="${r.importDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </c:when>
                                <c:otherwise><span class="text-muted small">—</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center small">
                            <c:choose>
                                <c:when test="${not empty r.exportDate}">
                                    <fmt:formatDate value="${r.exportDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </c:when>
                                <c:otherwise><span class="text-muted small">-</span></c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <c:if test="${totalPages > 1}">
        <c:url var="baseUrl" value="/imei-list">
            <c:param name="skuId"    value="${skuId}"/>
            <c:param name="q"        value="${q}"/>
            <c:param name="pageSize" value="${pageSize}"/>
            <c:param name="back"     value="${param.back}"/>
        </c:url>

        <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Page <strong>${pageNumber}</strong> of <strong>${totalPages}</strong>
            </div>

            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <%-- Prev Button --%>
                    <li class="page-item ${pageNumber <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageNumber > 1 ? baseUrl.concat('&page=').concat(pageNumber-1) : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                    </li>

                    <%-- Sliding Window logic --%>
                    <c:set var="startPage" value="${pageNumber - 1 > 1 ? pageNumber - 1 : 1}"/>
                    <c:set var="endPage"   value="${pageNumber + 1 < totalPages ? pageNumber + 1 : totalPages}"/>

                    <c:if test="${startPage > 1}">
                        <li class="page-item"><a class="page-link" href="${baseUrl}&page=1">1</a></li>
                        <c:if test="${startPage > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    </c:if>

                    <c:forEach var="i" begin="${startPage}" end="${endPage}">
                        <li class="page-item ${i == pageNumber ? 'active' : ''}"><a class="page-link" href="${baseUrl}&page=${i}">${i}</a></li>
                    </c:forEach>

                    <c:if test="${endPage < totalPages}">
                        <c:if test="${endPage < totalPages - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                        <li class="page-item"><a class="page-link" href="${baseUrl}&page=${totalPages}">${totalPages}</a></li>
                    </c:if>

                    <%-- Next Button --%>
                    <li class="page-item ${pageNumber >= totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${pageNumber < totalPages ? baseUrl.concat('&page=').concat(pageNumber+1) : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

