<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!-- Breadcrumb/Back button -->
<div class="mb-4">
    <a href="${ctx}/home?p=product-list" class="btn btn-outline-secondary btn-sm">
        <i class="bx bx-chevron-left"></i> Back to Products
    </a>
</div>

<div class="card shadow-sm border-0">
    <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center border-bottom">
        <h5 class="mb-0 text-primary fw-bold">
            <i class="bx bx-grid-alt me-2"></i>Product Variants Matrix
        </h5>
        <div class="text-muted small">
            Product ID: <span class="badge bg-label-primary px-2">${param.productId}</span>
        </div>
    </div>

    <div class="card-body pt-4">
        <form method="get" action="${ctx}/home" class="row g-3 mb-4">
            <input type="hidden" name="p" value="variant-matrix">
            <input type="hidden" name="productId" value="${param.productId}">


            <div class="col-md-2">
                <label class="form-label fw-semibold small text-uppercase">Color</label>
                <select class="form-select border-light shadow-none" name="color">
                    <option value="">All Colors</option>
                    <c:forEach items="${colors}" var="c">
                        <option value="${c}" ${param.color == c ? "selected" : ""}>${c}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label fw-semibold small text-uppercase">Storage</label>
                <select class="form-select border-light shadow-none" name="storage">
                    <option value="">All Storage</option>
                    <c:forEach items="${storages}" var="s">
                        <option value="${s}" ${param.storage == s ? "selected" : ""}>${s}GB</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label fw-semibold small text-uppercase">RAM</label>
                <select class="form-select border-light shadow-none" name="ram">
                    <option value="">All RAM</option>
                    <c:forEach items="${rams}" var="r">
                        <option value="${r}" ${param.ram == r ? "selected" : ""}>${r}GB</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label fw-semibold small text-uppercase">Status</label>
                <select class="form-select border-light shadow-none" name="status">
                    <option value="">All Status</option>
                    <option value="ACTIVE" ${param.status == "ACTIVE" ? "selected" : ""}>Active</option>
                    <option value="INACTIVE" ${param.status == "INACTIVE" ? "selected" : ""}>Inactive</option>
                </select>
            </div>
            <div class="col-md-2 d-flex align-items-end gap-2">
                <button class="btn btn-primary flex-grow-1 shadow-sm" type="submit">Filter</button>
                <a href="${ctx}/home?p=variant-matrix&productId=${param.productId}" class="btn btn-outline-secondary shadow-sm" title="Reset Filters">
                    <i class="bx bx-refresh"></i>
                </a>
            </div>
            <div class="col-md-3">
                <label class="form-label fw-semibold small text-uppercase">Search SKU</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text bg-light border-light"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control border-light shadow-none" name="sku" 
                           value="${fn:escapeXml(param.sku)}" placeholder="SKU code...">
                </div>
            </div>
            <div class="col-md-3">
                <label class="form-label fw-semibold small text-uppercase">Search Product</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text bg-light border-light"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control border-light shadow-none" name="q" 
                           value="${fn:escapeXml(q)}" placeholder="Product name...">
                </div>
            </div>



        </form>

        <div class="table-responsive text-nowrap mt-2 rounded">
            <table class="table table-hover align-middle">
                <thead class="bg-light">
                    <tr>
                        <th class="py-3">SKU Code</th>
                        <th class="py-3">Product</th>
                        <th class="py-3 text-center">Color</th>
                        <th class="py-3 text-center">Storage</th>
                        <th class="py-3 text-center">RAM</th>
                        <th class="py-3 text-center">Status</th>
                        <th class="py-3 text-center">Action</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    <c:forEach items="${skus}" var="s">
                        <tr>
                            <td>
                                <span class="badge bg-label-secondary font-monospace px-2">${s.skuCode}</span>
                            </td>
                            <td><span class="fw-bold text-dark">${fn:escapeXml(s.productName)}</span></td>
                            <td class="text-center"><span class="fw-semibold">${s.color}</span></td>
                            <td class="text-center">${s.storageGb}GB</td>
                            <td class="text-center">${s.ramGb}GB</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${s.status == 'ACTIVE'}">
                                        <span class="badge bg-label-success">ACTIVE</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-label-secondary">INACTIVE</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <div class="d-flex justify-content-center gap-2">
                                    <c:if test="${sessionScope.roleName == 'MANAGER' || role == 'MANAGER'}">
                                        <a href="${ctx}/manager/sku/toggle?id=${s.skuId}"
                                           class="btn btn-icon btn-sm ${s.status == 'ACTIVE' ? 'btn-outline-danger' : 'btn-outline-success'}"
                                           data-bs-toggle="tooltip" 
                                           title="${s.status == 'ACTIVE' ? 'Deactivate' : 'Activate'}"
                                           onclick="return confirm('${s.status == 'ACTIVE' ? 'Deactivate' : 'Activate'} SKU ${fn:escapeXml(s.skuCode)}?');">
                                            <i class="bx ${s.status == 'ACTIVE' ? 'bx-toggle-left' : 'bx-toggle-right'}"></i>
                                        </a>
                                    </c:if>
                                    <button type="button" class="btn btn-sm btn-outline-primary px-3"
                                            onclick="showImeiModal('${s.skuId}', '${fn:escapeXml(s.skuCode)}')">
                                        <i class="bx bx-list-ul me-1"></i> View IMEI
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty skus}">
                        <tr>
                            <td colspan="7" class="text-center p-5 text-muted bg-light">
                                <i class="bx bx-info-circle fs-3 d-block mb-2"></i>
                                No variants found matching your criteria.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <%-- Pagination Footer --%>
    <c:if test="${not empty skus}">
        <div class="card-footer px-4 py-3 border-top bg-light mt-auto">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div class="text-muted small">
                    Showing <b>${(page - 1) * pageSize + 1}</b> to 
                    <b>${(page * pageSize) > totalItems ? totalItems : (page * pageSize)}</b> 
                    of <b>${totalItems}</b> variants
                </div>

                <c:if test="${totalPages > 1}">
                    <nav aria-label="Variant navigation">
                        <ul class="pagination pagination-sm mb-0">
                            <%-- First --%>
                            <c:url var="firstUrl" value="/home">
                                <c:param name="p" value="variant-matrix"/><c:param name="page" value="1"/>
                                <c:param name="color" value="${color}"/><c:param name="storage" value="${storage}"/><c:param name="ram" value="${ram}"/><c:param name="sku" value="${sku}"/><c:param name="status" value="${status}"/><c:param name="productId" value="${productId}"/><c:param name="q" value="${q}"/>
                            </c:url>
                            <li class="page-item ${page == 1 ? 'disabled' : ''}">
                                <a class="page-link shadow-none" href="${firstUrl}"><i class="bx bx-chevrons-left"></i></a>
                            </li>

                            <c:url var="prevUrl" value="/home">
                                <c:param name="p" value="variant-matrix"/><c:param name="page" value="${page - 1}"/>
                                <c:param name="color" value="${color}"/><c:param name="storage" value="${storage}"/><c:param name="ram" value="${ram}"/><c:param name="sku" value="${sku}"/><c:param name="status" value="${status}"/><c:param name="productId" value="${productId}"/><c:param name="q" value="${q}"/>
                            </c:url>
                            <li class="page-item ${page == 1 ? 'disabled' : ''}">
                                <a class="page-link shadow-none" href="${prevUrl}"><i class="bx bx-chevron-left"></i></a>
                            </li>

                            <c:forEach begin="${page - 2 < 1 ? 1 : page - 2}" end="${(page + 2 > totalPages) ? totalPages : (page + 2)}" var="i">
                                <c:url var="pageUrl" value="/home">
                                    <c:param name="p" value="variant-matrix"/><c:param name="page" value="${i}"/>
                                    <c:param name="color" value="${color}"/><c:param name="storage" value="${storage}"/><c:param name="ram" value="${ram}"/><c:param name="sku" value="${sku}"/><c:param name="status" value="${status}"/><c:param name="productId" value="${productId}"/><c:param name="q" value="${q}"/>
                                </c:url>
                                <li class="page-item ${page == i ? 'active shadow-sm' : ''}">
                                    <a class="page-link shadow-none" href="${pageUrl}">${i}</a>
                                </li>
                            </c:forEach>

                            <c:url var="nextUrl" value="/home">
                                <c:param name="p" value="variant-matrix"/><c:param name="page" value="${page + 1}"/>
                                <c:param name="color" value="${color}"/><c:param name="storage" value="${storage}"/><c:param name="ram" value="${ram}"/><c:param name="sku" value="${sku}"/><c:param name="status" value="${status}"/><c:param name="productId" value="${productId}"/><c:param name="q" value="${q}"/>
                            </c:url>
                            <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                                <a class="page-link shadow-none" href="${nextUrl}"><i class="bx bx-chevron-right"></i></a>
                            </li>

                            <c:url var="lastUrl" value="/home">
                                <c:param name="p" value="variant-matrix"/><c:param name="page" value="${totalPages}"/>
                                <c:param name="color" value="${color}"/><c:param name="storage" value="${storage}"/><c:param name="ram" value="${ram}"/><c:param name="sku" value="${sku}"/><c:param name="status" value="${status}"/><c:param name="productId" value="${productId}"/><c:param name="q" value="${q}"/>
                            </c:url>
                            <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                                <a class="page-link shadow-none" href="${lastUrl}"><i class="bx bx-chevrons-right"></i></a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </div>
        </div>
    </c:if>
</div>

<%@ include file="/WEB-INF/jspf/imei_modal.jspf" %>
<script>
    // Initializing tooltips for the reverted design
    document.addEventListener('DOMContentLoaded', function () {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    });
</script>