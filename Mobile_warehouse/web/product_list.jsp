<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Product List</h5>
        <c:choose>
            <c:when test="${role == 'MANAGER' || role == 'manager' || role == 'ADMIN' || role == 'admin'}">
                <a href="${ctx}/home?p=product-add" class="btn btn-primary btn-sm"><i class="bx bx-plus me-1"></i> Add Product</a>
            </c:when>
        </c:choose>
    </div>

    <div class="card-body">
        <form action="${ctx}/home" method="get" class="row g-3">
            <input type="hidden" name="p" value="product-list"/>
            <div class="col-md-4">
                <input type="text" name="q" class="form-control" placeholder="Search product name or code..." value="${fn:escapeXml(q)}"/>
            </div>
            <div class="col-md-3">
                <select name="brandId" class="form-select">
                    <option value="">All Brands</option>
                    <c:forEach var="b" items="${brands}">
                        <option value="${b.brandId}" ${b.brandId == brandId ? 'selected' : ''}>${fn:escapeXml(b.brandName)}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-3">
                <select name="status" class="form-select">
                    <option value="">All Status</option>
                    <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100">Filter</button>
            </div>
        </form>
    </div>

    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Brand</th>
                    <th class="text-center">Status</th>
                    <th class="text-center">Added At</th>
                    <th class="text-center">Actions</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:if test="${empty products}">
                    <tr><td colspan="5" class="text-center p-4 text-muted">No products found.</td></tr>
                </c:if>
                <c:forEach var="p" items="${products}">
                    <tr>
                        <td>
                            <div class="d-flex flex-column">
                                <span class="fw-bold">${fn:escapeXml(p.productName)}</span>
                                <small class="text-muted font-monospace">${fn:escapeXml(p.productCode)}</small>
                            </div>
                        </td>
                        <td>${fn:escapeXml(p.brandName)}</td>
                        <td class="text-center">
                            <c:set var="isActive" value="${p.isActive()}" />
                            <span class="badge ${isActive ? 'bg-label-success' : 'bg-label-secondary'}">
                                ${isActive ? 'Active' : 'Inactive'}
                            </span>
                        </td>
                        <td class="text-center"><small>${p.createdAt}</small></td>
                        <td class="text-center">
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown"><i class="bx bx-dots-vertical-rounded"></i></button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="${ctx}/home?p=product-detail&id=${p.productId}"><i class="bx bx-show me-1"></i> View</a>
                                    <c:choose>
                                        <c:when test="${role == 'MANAGER' || role == 'manager'}">
                                            <a class="dropdown-item" href="${ctx}/manager/product/update?id=${p.productId}"><i class="bx bx-edit-alt me-1"></i> Edit</a>
                                            <a class="dropdown-item text-danger" href="${ctx}/manager/product/delete?id=${p.productId}"><i class="bx bx-trash me-1"></i> Delete</a>
                                        </c:when>
                                    </c:choose>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <c:set var="cp" value="${empty curPage ? (empty page ? 1 : page) : curPage}" />
    <c:set var="tp" value="${empty totalPages ? 1 : totalPages}" />

    <div class="card-footer d-flex justify-content-between align-items-center">
        <div class="text-muted small">
            Page <strong>${cp}</strong> of <strong>${tp}</strong>
        </div>

        <nav aria-label="Page navigation">
            <ul class="pagination pagination-sm mb-0">
                <%-- Prev Button --%>
                <li class="page-item ${cp <= 1 ? 'disabled' : ''}">
                    <c:url var="prevLink" value="/home">
                        <c:param name="p" value="product-list"/>
                        <c:param name="q" value="${q}"/>
                        <c:param name="brandId" value="${brandId}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="page" value="${cp - 1}"/>
                    </c:url>
                    <a class="page-link" href="${cp > 1 ? prevLink : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                </li>
                
                <%-- Sliding Window logic --%>
                <c:set var="winStart" value="${cp - 1 > 1 ? cp - 1 : 1}" />
                <c:set var="winEnd" value="${winStart + 2 < tp ? winStart + 2 : tp}" />
                <c:if test="${winEnd == tp}">
                    <c:set var="winStart" value="${winEnd - 2 > 1 ? winEnd - 2 : 1}" />
                </c:if>

                <c:if test="${winStart > 1}">
                    <c:url var="urlFirst" value="/home">
                        <c:param name="p" value="product-list"/><c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/><c:param name="status" value="${status}"/><c:param name="page" value="1"/>
                    </c:url>
                    <li class="page-item"><a class="page-link" href="${urlFirst}">1</a></li>
                    <c:if test="${winStart > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                </c:if>

                <c:forEach var="i" begin="${winStart}" end="${winEnd}">
                    <c:url var="urlLoop" value="/home">
                        <c:param name="p" value="product-list"/><c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/><c:param name="status" value="${status}"/><c:param name="page" value="${i}"/>
                    </c:url>
                    <li class="page-item ${i == cp ? 'active' : ''}">
                        <a class="page-link" href="${urlLoop}">${i}</a>
                    </li>
                </c:forEach>

                <c:if test="${winEnd < tp}">
                    <c:if test="${winEnd < tp - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    <c:url var="urlLastP" value="/home">
                        <c:param name="p" value="product-list"/><c:param name="q" value="${q}"/><c:param name="brandId" value="${brandId}"/><c:param name="status" value="${status}"/><c:param name="page" value="${tp}"/>
                    </c:url>
                    <li class="page-item"><a class="page-link" href="${urlLastP}">${tp}</a></li>
                </c:if>

                <%-- Next Button --%>
                <li class="page-item ${cp >= tp ? 'disabled' : ''}">
                    <c:url var="nextLink" value="/home">
                        <c:param name="p" value="product-list"/>
                        <c:param name="q" value="${q}"/>
                        <c:param name="brandId" value="${brandId}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="page" value="${cp + 1}"/>
                    </c:url>
                    <a class="page-link" href="${cp < tp ? nextLink : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                </li>
            </ul>
        </nav>
    </div>
</div>
