<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Inventory Management
</h4>

<c:if test="${not empty param.msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        <i class="bx bx-check me-1"></i> ${fn:escapeXml(param.msg)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty param.err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        <i class="bx bx-error me-1"></i> ${fn:escapeXml(param.err)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="row g-4 mb-4">
    <div class="col-sm-6 col-lg-3">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-mobile-alt"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Total Products</span>
                <h3 class="card-title mb-2">${totalProducts}</h3>
                <small class="text-muted">Unique phone models</small>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-lg-3">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-package"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Total Quantity</span>
                <h3 class="card-title mb-2 text-primary">${totalQty}</h3>
                <small class="text-muted">Item in stock</small>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-lg-3">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-warning"><i class="bx bx-trending-down"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Low Stock</span>
                <h3 class="card-title mb-2 text-warning">${lowStockItems}</h3>
                <small class="text-muted">Below threshold</small>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-lg-3">
        <div class="card h-100">
            <div class="card-body">
                <div class="card-title d-flex align-items-start justify-content-between">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-danger"><i class="bx bx-error"></i></span>
                    </div>
                </div>
                <span class="fw-semibold d-block mb-1 text-muted small uppercase">Out of Stock</span>
                <h3 class="card-title mb-2 text-danger">${outOfStockItems}</h3>
                <small class="text-muted">Zero items left</small>
            </div>
        </div>
    </div>
</div>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${pageContext.request.contextPath}/inventory" class="row g-3">
            <input type="hidden" name="page"     value="1"/>
            <input type="hidden" name="pageSize" value="${pageSize}"/>
            
            <div class="col-md-4">
                <label class="form-label">Search</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control" name="q" value="${fn:escapeXml(q)}" placeholder="Product name, SKU..."/>
                </div>
            </div>

            <div class="col-md-3">
                <label class="form-label">Brand</label>
                <select class="form-select" name="brandId">
                    <option value="">All Brands</option>
                    <c:forEach var="b" items="${brands}">
                        <option value="${b.id}" <c:if test="${b.id == brandId}">selected</c:if>>${fn:escapeXml(b.name)}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-3">
                <label class="form-label">Stock Status</label>
                <select class="form-select" name="stockStatus">
                    <option value=""   <c:if test="${empty stockStatus}">selected</c:if>>All Stock Status</option>
                    <option value="OK"  <c:if test="${stockStatus=='OK'}">selected</c:if>>In Stock</option>
                    <option value="LOW" <c:if test="${stockStatus=='LOW'}">selected</c:if>>Low Stock</option>
                    <option value="OUT" <c:if test="${stockStatus=='OUT'}">selected</c:if>>Out of Stock</option>
                </select>
            </div>

            <div class="col-md-2 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Apply</button>
                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/inventory"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Inventory Details</h5>
        <div class="d-flex align-items-center gap-2">
            <label class="small text-muted mb-0">Rows:</label>
            <form method="get" action="${pageContext.request.contextPath}/inventory" class="d-inline">
                <input type="hidden" name="q"           value="${fn:escapeXml(q)}"/>
                <input type="hidden" name="brandId"     value="${brandId}"/>
                <input type="hidden" name="stockStatus" value="${stockStatus}"/>
                <input type="hidden" name="page"        value="1"/>
                <select class="form-select form-select-sm" name="pageSize" onchange="this.form.submit()" style="width: 70px;">
                    <option value="10"  <c:if test="${pageSize==10}">selected</c:if>>10</option>
                    <option value="20"  <c:if test="${pageSize==20}">selected</c:if>>20</option>
                    <option value="50"  <c:if test="${pageSize==50}">selected</c:if>>50</option>
                </select>
            </form>
        </div>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Product Code</th>
                    <th>Product Name</th>
                    <th>Brand</th>
                    <th class="text-center">Quantity</th>
                    <th class="text-center">Unit</th>
                    <th class="text-center">Stock Status</th>
                    <th class="text-center">Last Updated</th>
                    <th class="text-center">Actions</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:if test="${empty inventoryModels}">
                    <tr><td colspan="7" class="text-center p-4">No inventory data matching your search.</td></tr>
                </c:if>
                <c:forEach var="it" items="${inventoryModels}">
                    <tr>
                        <td><span class="badge bg-label-secondary font-monospace">${fn:escapeXml(it.productCode)}</span></td>
                        <td><strong>${fn:escapeXml(it.productName)}</strong></td>
                        <td><small class="text-muted">${fn:escapeXml(it.brandName)}</small></td>
                        <td class="text-center"><span class="fw-bold">${it.totalQty}</span>
                        <td class="text-center"><small class="text-muted">Item</small></td>
                        <td class="text-center">
                            <c:set var="st" value="${it.status}"/>
                            <c:choose>
                                <c:when test="${st == 'OK'}">
                                    <span class="badge bg-label-success">In Stock</span>
                                </c:when>
                                <c:when test="${st == 'LOW'}">
                                    <span class="badge bg-label-warning" title="Stock < 10">Low Stock</span>
                                </c:when>
                                <c:when test="${st == 'AT_THRESHOLD'}">
                                    <span class="badge bg-label-info">At Threshold</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-label-danger">Out of Stock</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><small class="text-muted">${fn:escapeXml(it.lastUpdated)}</small></td>
                        <td class="text-center">
                            <c:url var="detailUrl" value="/inventory-details">
                                <c:param name="productCode" value="${it.productCode}"/>
                                <c:param name="q"           value="${q}"/>
                                <c:param name="brandId"     value="${brandId}"/>
                                <c:param name="stockStatus" value="${stockStatus}"/>
                                <c:param name="page"        value="${pageNumber}"/>
                                <c:param name="pageSize"    value="${pageSize}"/>
                            </c:url>
                            <a class="btn btn-icon btn-sm btn-outline-primary" href="${detailUrl}"><i class="bx bx-show"></i></a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <c:set var="fromItem" value="${totalItems == 0 ? 0 : (pageNumber - 1) * pageSize + 1}"/>
    <c:set var="toItem" value="${pageNumber * pageSize > totalItems ? totalItems : pageNumber * pageSize}"/>

    <div class="card-footer d-flex justify-content-between align-items-center">
        <div class="text-muted small">
            Page <strong>${pageNumber}</strong> of <strong>${totalPages}</strong>
        </div>

        <nav aria-label="Page navigation">
            <ul class="pagination pagination-sm mb-0">
                <%-- Prev Button --%>
                <li class="page-item ${pageNumber <= 1 ? 'disabled' : ''}">
                    <c:url var="prevUrl" value="/inventory">
                        <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/><c:param name="stockStatus" value="${stockStatus}"/><c:param name="page" value="${pageNumber - 1}"/><c:param name="pageSize" value="${pageSize}"/>
                    </c:url>
                    <a class="page-link" href="${pageNumber > 1 ? prevUrl : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                </li>

                <%-- Sliding Window logic --%>
                <c:set var="startPage" value="${pageNumber - 1 > 1 ? pageNumber - 1 : 1}"/>
                <c:set var="endPage"   value="${pageNumber + 1 < totalPages ? pageNumber + 1 : totalPages}"/>

                <c:if test="${startPage > 1}">
                    <c:url var="p1Url" value="/inventory">
                        <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/><c:param name="stockStatus" value="${stockStatus}"/><c:param name="page" value="1"/><c:param name="pageSize" value="${pageSize}"/>
                    </c:url>
                    <li class="page-item"><a class="page-link" href="${p1Url}">1</a></li>
                    <c:if test="${startPage > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                </c:if>

                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                    <c:url var="pageUrl" value="/inventory">
                        <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/><c:param name="stockStatus" value="${stockStatus}"/><c:param name="page" value="${i}"/><c:param name="pageSize" value="${pageSize}"/>
                    </c:url>
                    <li class="page-item ${i == pageNumber ? 'active' : ''}"><a class="page-link" href="${pageUrl}">${i}</a></li>
                </c:forEach>

                <c:if test="${endPage < totalPages}">
                    <c:if test="${endPage < totalPages - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    <c:url var="pLastUrl" value="/inventory">
                        <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/><c:param name="stockStatus" value="${stockStatus}"/><c:param name="page" value="${totalPages}"/><c:param name="pageSize" value="${pageSize}"/>
                    </c:url>
                    <li class="page-item"><a class="page-link" href="${pLastUrl}">${totalPages}</a></li>
                </c:if>

                <%-- Next Button --%>
                <li class="page-item ${pageNumber >= totalPages ? 'disabled' : ''}">
                    <c:url var="nextUrl" value="/inventory">
                        <c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/><c:param name="stockStatus" value="${stockStatus}"/><c:param name="page" value="${pageNumber + 1}"/><c:param name="pageSize" value="${pageSize}"/>
                    </c:url>
                    <a class="page-link" href="${pageNumber < totalPages ? nextUrl : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                </li>
            </ul>
        </nav>
    </div>
</div>

</div>

