<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="cp"  value="${empty page ? 1 : page}" />
<c:set var="tp"  value="${empty totalPages ? 1 : totalPages}" />

<!-- Breadcrumb/Back button -->
<div class="mb-4">
    <a href="${ctx}/home?p=product-list" class="btn btn-outline-secondary btn-sm">
        <i class="bx bx-chevron-left"></i> Back to Products
    </a>
</div>

<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Product Variants Matrix</h5>
        <div class="text-muted small">
            Product ID: <span class="fw-bold">${param.productId}</span>
        </div>
    </div>

    <div class="card-body">
        <form method="get" action="${ctx}/home" class="row g-3 mb-4">
            <input type="hidden" name="p" value="variant-matrix">
            <input type="hidden" name="productId" value="${param.productId}">

            <div class="col-md-2">
                <label class="form-label">Color</label>
                <select class="form-select" name="color">
                    <option value="">All Colors</option>
                    <c:forEach items="${colors}" var="c">
                        <option value="${c}" ${param.color==c?"selected":""}>${c}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label">Storage</label>
                <select class="form-select" name="storage">
                    <option value="">All Storage</option>
                    <c:forEach items="${storages}" var="s">
                        <option value="${s}" ${param.storage==s?"selected":""}>${s}GB</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label">RAM</label>
                <select class="form-select" name="ram">
                    <option value="">All RAM</option>
                    <c:forEach items="${rams}" var="r">
                        <option value="${r}" ${param.ram==r?"selected":""}>${r}GB</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label">Status</label>
                <select class="form-select" name="status">
                    <option value="">All Status</option>
                    <option value="ACTIVE" ${param.status=="ACTIVE"?"selected":""}>Active</option>
                    <option value="INACTIVE" ${param.status=="INACTIVE"?"selected":""}>Inactive</option>
                </select>
            </div>

            <div class="col-md-3">
                <label class="form-label">Search SKU</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control" name="sku" value="${fn:escapeXml(param.sku)}" placeholder="SKU code...">
                </div>
            </div>

            <div class="col-md-1 d-flex align-items-end">
                <button class="btn btn-primary w-100" type="submit">Filter</button>
            </div>
        </form>

        <div class="table-responsive text-nowrap mt-2">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>SKU Code</th>
                        <th>Color</th>
                        <th class="text-center">Storage</th>
                        <th class="text-center">RAM</th>
                        <th class="text-center">Status</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    <c:forEach items="${skus}" var="s">
                        <tr>
                            <td><span class="badge bg-label-secondary font-monospace">${s.skuCode}</span></td>
                            <td><strong>${s.color}</strong></td>
                            <td class="text-center">${s.storageGb}GB</td>
                            <td class="text-center">${s.ramGb}GB</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${s.status=='ACTIVE'}">
                                        <span class="badge bg-label-success">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-label-secondary">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty skus}">
                        <tr><td colspan="5" class="text-center p-5 text-muted">No variants found matching your criteria.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <%-- Pagination --%>
        <div class="card-footer d-flex justify-content-between align-items-center px-0 pb-0 pt-4">
            <div class="text-muted small">
                Page <strong>${cp}</strong> of <strong>${tp}</strong>
            </div>
            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <%-- Prev Button --%>
                    <li class="page-item ${cp <= 1 ? 'disabled' : ''}">
                        <c:url var="pL" value="/home">
                            <c:param name="p" value="variant-matrix"/><c:param name="productId" value="${param.productId}"/><c:param name="color" value="${param.color}"/><c:param name="storage" value="${param.storage}"/><c:param name="ram" value="${param.ram}"/><c:param name="status" value="${param.status}"/><c:param name="sku" value="${param.sku}"/><c:param name="page" value="${cp - 1}"/>
                        </c:url>
                        <a class="page-link" href="${cp > 1 ? pL : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                    </li>

                    <c:set var="ws" value="${cp - 1 > 1 ? cp - 1 : 1}" />
                    <c:set var="we" value="${ws + 2 < tp ? ws + 2 : tp}" />
                    <c:if test="${we == tp}">
                        <c:set var="ws" value="${we - 2 > 1 ? we - 2 : 1}" />
                    </c:if>

                    <c:if test="${ws > 1}">
                        <c:url var="u1" value="/home">
                            <c:param name="p" value="variant-matrix"/><c:param name="productId" value="${param.productId}"/><c:param name="color" value="${param.color}"/><c:param name="storage" value="${param.storage}"/><c:param name="ram" value="${param.ram}"/><c:param name="status" value="${param.status}"/><c:param name="sku" value="${param.sku}"/><c:param name="page" value="1"/>
                        </c:url>
                        <li class="page-item"><a class="page-link" href="${u1}">1</a></li>
                        <c:if test="${ws > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    </c:if>

                    <c:forEach var="i" begin="${ws}" end="${we}">
                        <c:url var="uiI" value="/home">
                            <c:param name="p" value="variant-matrix"/><c:param name="productId" value="${param.productId}"/><c:param name="color" value="${param.color}"/><c:param name="storage" value="${param.storage}"/><c:param name="ram" value="${param.ram}"/><c:param name="status" value="${param.status}"/><c:param name="sku" value="${param.sku}"/><c:param name="page" value="${i}"/>
                        </c:url>
                        <li class="page-item ${i == cp ? 'active' : ''}">
                            <a class="page-link" href="${uiI}">${i}</a>
                        </li>
                    </c:forEach>

                    <c:if test="${we < tp}">
                        <c:if test="${we < tp - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                        <c:url var="uLast" value="/home">
                            <c:param name="p" value="variant-matrix"/><c:param name="productId" value="${param.productId}"/><c:param name="color" value="${param.color}"/><c:param name="storage" value="${param.storage}"/><c:param name="ram" value="${param.ram}"/><c:param name="status" value="${param.status}"/><c:param name="sku" value="${param.sku}"/><c:param name="page" value="${tp}"/>
                        </c:url>
                        <li class="page-item"><a class="page-link" href="${uLast}">${tp}</a></li>
                    </c:if>

                    <%-- Next Button --%>
                    <li class="page-item ${cp >= tp ? 'disabled' : ''}">
                        <c:url var="nL" value="/home">
                            <c:param name="p" value="variant-matrix"/><c:param name="productId" value="${param.productId}"/><c:param name="color" value="${param.color}"/><c:param name="storage" value="${param.storage}"/><c:param name="ram" value="${param.ram}"/><c:param name="status" value="${param.status}"/><c:param name="sku" value="${param.sku}"/><c:param name="page" value="${cp + 1}"/>
                        </c:url>
                        <a class="page-link" href="${cp < tp ? nL : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</div>