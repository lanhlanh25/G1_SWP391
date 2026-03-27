<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Advanced /</span> Low Stock Report
</h4>

<%-- Alerts --%>
<c:if test="${not empty err || not empty param.err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        ${not empty err ? err : param.err}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<%-- Stat Cards --%>
<div class="row g-4 mb-4">
    <div class="col-sm-6 col-xl-3">
        <div class="card">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-danger"><i class="bx bx-error fs-4"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0 text-danger">${summary.outOfStock}</h4>
                </div>
                <p class="mb-0 small text-muted">Totally Out of Stock</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-xl-3">
        <div class="card">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-warning"><i class="bx bx-repost fs-4"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0 text-warning">${summary.productsAtOrBelowThreshold}</h4>
                </div>
                <p class="mb-0 small text-muted">At or Below Threshold</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-xl-3">
        <div class="card">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-timer fs-4"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0 text-primary">${summary.reorderNeeded}</h4>
                </div>
                <p class="mb-0 small text-muted">Reorder Needed</p>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-xl-3">
        <div class="card">
            <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                    <div class="avatar me-2">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-list-check fs-4"></i></span>
                    </div>
                    <h4 class="ms-1 mb-0">${summary.totalProducts}</h4>
                </div>
                <p class="mb-0 small text-muted">Total Products</p>
            </div>
        </div>
    </div>
</div>

<%-- Filter Card --%>
<div class="card mb-4">
    <div class="card-body pt-3 pb-3">
        <form method="get" action="${ctx}/home">
            <input type="hidden" name="p" value="low-stock-report"/>
            <div class="row g-3 align-items-end">
                <div class="col-md-4 col-lg-3">
                    <label class="form-label small text-uppercase fw-semibold">Search by Product</label>
                    <div class="input-group input-group-merge">
                        <span class="input-group-text"><i class="bx bx-search"></i></span>
                        <input type="text" class="form-control" name="q" value="${q}" placeholder="Product name or code..."/>
                    </div>
                </div>

                

                <div class="col-md-3 col-lg-2">
                    <label class="form-label small text-uppercase fw-semibold">Stock Status</label>
                    <select class="form-select" name="stockStatus">
                        <option value="">All Low Stock</option>
                        
                        <option value="Out Of Stock" ${stockStatus == 'Out Of Stock' ? 'selected' : ''}>Out Of Stock</option>
                        <option value="Reorder Needed" ${stockStatus == 'Reorder Needed' ? 'selected' : ''}>Reorder Needed</option>
                        <option value="At Threshold" ${stockStatus == 'At Threshold' ? 'selected' : ''}>At Threshold</option>
                        <option value="OK" ${stockStatus == 'OK' ? 'selected' : ''}>InStock</option>
                    </select>
                </div>

                <div class="col-md-2 col-lg-1">
                    <label class="form-label small text-uppercase fw-semibold">Min Stock</label>
                    <input type="number" class="form-control" min="0" name="minStock" value="${minStock}"/>
                </div>

                <div class="col-md-2 col-lg-1">
                    <label class="form-label small text-uppercase fw-semibold">Max Stock</label>
                    <input type="number" class="form-control" min="0" name="maxStock" value="${maxStock}"/>
                </div>

                <div class="col-md-4 col-lg-3 d-flex gap-2">
                    <button class="btn btn-primary px-4" type="submit">Apply Filters</button>
                    <a class="btn btn-outline-secondary" href="${ctx}/home?p=low-stock-report">Reset</a>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- Results Card --%>
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Inventory Requiring Attention</h5>
        <div class="text-muted small">
            Showing <strong>${totalItems == 0 ? 0 : (page - 1) * pageSize + 1}</strong>–<strong>${page * pageSize < totalItems ? page * pageSize : totalItems}</strong> of <strong>${totalItems}</strong> products
        </div>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead class="table-dark">
                <tr>
                    <th class="ps-3 text-uppercase small text-white">Product Information</th>
                    
                    <th class="text-center text-uppercase small text-white">Current</th>
                    <th class="text-center">Threshold</th>
                    <th class="text-center text-uppercase small text-white">Status</th>
                    <th class="text-center text-uppercase small text-white">Suggested</th>
                    <th class="text-center text-uppercase small text-white pe-3">Actions</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:forEach var="item" items="${rows}">
                    <tr>
                        <td class="ps-3">
                            <div class="fw-bold text-heading">${item.productName}</div>
                            <small class="text-muted mono-text fs-12">${item.productCode}</small>
                        </td>
                        
                        <td class="text-center fw-bold fs-5">${item.currentStock}</td>
                        <td class="text-center fw-semibold">${item.threshold}</td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${item.stockStatus == 'Out Of Stock'}">
                                    <span class="badge bg-label-danger text-uppercase px-3">Out Of Stock</span>
                                </c:when>
                                <c:when test="${item.stockStatus == 'Reorder Needed'}">
                                    <span class="badge bg-label-warning text-uppercase px-3">Reorder Needed</span>
                                </c:when>
                                <c:when test="${item.stockStatus == 'At Threshold'}">
                                    <span class="badge bg-label-info">At Threshold</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-label-success text-uppercase px-3">InStock</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center fw-bold text-primary">${item.suggestedReorderQty}</td>
                        <td class="text-center pe-3">
                            <div class="d-flex gap-2 justify-content-center">
                                <a class="btn btn-sm btn-outline-secondary py-1 px-3"
                                   href="${ctx}/home?p=product-detail&id=${item.productId}">
                                    View
                                </a>

                                <c:choose>
                                    <c:when test="${item.stockStatus != 'OK' && !item.hasActiveImportRequest}">
                                        <a class="btn btn-sm btn-primary py-1 px-2"
                                           href="${ctx}/home?p=create-import-request&productId=${item.productId}">
                                            Create Request
                                        </a>
                                    </c:when>
                                    <c:when test="${item.hasActiveImportRequest}">
                                        <span class="badge bg-label-info py-2 px-3">REQUESTED</span>
                                    </c:when>
                                </c:choose>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty rows}">
                    <tr>
                        <td colspan="10" class="text-center p-5 text-muted">
                            <i class="bx bx-info-circle mb-2 d-block fs-1"></i>
                            No low stock products found matching these criteria.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <%-- Pagination --%>
    <c:if test="${totalPages > 1}">
        <div class="card-footer d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Page <strong>${page}</strong> of <strong>${totalPages}</strong>
            </div>
            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <c:url var="basePageUrl" value="/home">
                        <c:param name="p" value="low-stock-report"/>
                        <c:param name="q" value="${q}"/>
                        <c:param name="supplierId" value="${supplierId}"/>
                        <c:param name="stockStatus" value="${stockStatus}"/>
                        <c:param name="minStock" value="${minStock}"/>
                        <c:param name="maxStock" value="${maxStock}"/>
                    </c:url>

                    <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${basePageUrl}&page=${page-1}"><i class="bx bx-chevron-left"></i></a>
                    </li>

                    <c:forEach begin="1" end="${totalPages}" var="pg">
                        <c:if test="${pg >= page - 1 && pg <= page + 1 || pg == 1 || pg == totalPages}">
                            <c:if test="${pg == page - 1 && pg > 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                            <li class="page-item ${pg == page ? 'active' : ''}">
                                <a class="page-link" href="${basePageUrl}&page=${pg}">${pg}</a>
                            </li>
                            <c:if test="${pg == page + 1 && pg < totalPages}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                            </c:if>
                        </c:forEach>

                    <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${basePageUrl}&page=${page+1}"><i class="bx bx-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>
