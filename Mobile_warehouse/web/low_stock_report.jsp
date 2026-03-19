<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap">
    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Low Stock Report</h1>
            <span class="text-muted fs-14 mt-4">Inventory below reorder levels</span>
        </div>
        <div class="d-flex gap-8 align-center">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=dashboard">← Dashboard</a>
        </div>
    </div>

    <c:if test="${not empty err}">
        <div class="msg-err mb-16">${err}</div>
    </c:if>
    <c:if test="${not empty param.err}">
        <div class="msg-err mb-16">${param.err}</div>
    </c:if>

    <div class="grid-12 gap-16 mb-16">
        <div class="col-3">
            <div class="card p-20 d-flex justify-between align-center h-full">
                <div>
                    <div class="muted fs-12 uppercase mb-4">Urgent Attention</div>
                    <div class="h2 m-0 text-danger">${summary.outOfStock}</div>
                    <div class="fs-10 text-muted mt-4">Totally Out of Stock</div>
                </div>
            </div>
        </div>
        <div class="col-3">
            <div class="card p-20 d-flex justify-between align-center h-full">
                <div>
                    <div class="muted fs-12 uppercase mb-4">Below ROP</div>
                    <div class="h2 m-0 text-warning">${summary.productsBelowRop}</div>
                    <div class="fs-10 text-muted mt-4">Action Required</div>
                </div>
            </div>
        </div>
        <div class="col-3">
            <div class="card p-20 d-flex justify-between align-center h-full">
                <div>
                    <div class="muted fs-12 uppercase mb-4">Pending Reorder</div>
                    <div class="h2 m-0 text-primary">${summary.reorderNeeded}</div>
                    <div class="fs-10 text-muted mt-4">In Pipeline</div>
                </div>
            </div>
        </div>
        <div class="col-3">
            <div class="card p-20 d-flex justify-between align-center h-full">
                <div>
                    <div class="muted fs-12 uppercase mb-4">Total Monitor</div>
                    <div class="h2 m-0">${summary.totalProducts}</div>
                    <div class="fs-10 text-muted mt-4">In Active Catalog</div>
                </div>
            </div>
        </div>
    </div>

    <div class="card mb-16">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/home">
                <input type="hidden" name="p" value="low-stock-report"/>

                <div class="d-flex gap-16 align-end flex-wrap mb-16">
                    <div style="flex:1; min-width:200px;">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Search by Product</label>
                        <input class="input" type="text" name="q" value="${q}" placeholder="Product name or code"/>
                    </div>

                    <div style="width:180px;">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Supplier</label>
                        <select class="select" name="supplierId">
                            <option value="">All Suppliers</option>
                            <c:forEach var="s" items="${suppliers}">
                                <option value="${s.id}" <c:if test="${supplierId == '' + s.id}">selected</c:if>>
                                    ${s.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div style="width:180px;">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">ROP Status</label>
                        <select class="select" name="ropStatus">
                            <option value="">All Low Stock</option>
                            <option value="All" ${ropStatus == 'All' ? 'selected' : ''}>All Products</option>
                            <option value="Out Of Stock" ${ropStatus == 'Out Of Stock' ? 'selected' : ''}>Out Of Stock</option>
                            <option value="Reorder Needed" ${ropStatus == 'Reorder Needed' ? 'selected' : ''}>Reorder Needed</option>
                            <option value="At ROP Level" ${ropStatus == 'At ROP Level' ? 'selected' : ''}>At ROP Level</option>
                            <option value="OK" ${ropStatus == 'OK' ? 'selected' : ''}>Standard Level</option>
                        </select>
                    </div>

                    <div style="width:100px;">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Min Stock</label>
                        <input class="input" type="number" min="0" name="minStock" value="${minStock}"/>
                    </div>

                    <div style="width:100px;">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Max Stock</label>
                        <input class="input" type="number" min="0" name="maxStock" value="${maxStock}"/>
                    </div>

                    <div class="d-flex gap-8">
                        <button class="btn btn-primary" type="submit">Apply Filters</button>
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=low-stock-report">Reset</a>
                    </div>
                </div>
            </form>

            <div class="text-muted fs-13 mb-12">
                Showing <b class="text-dark">${totalItems}</b> products requiring attention
            </div>

            <div class="table-wrap">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Product Information</th>
                            <th>Supplier</th>
                            <th class="text-center">Current</th>
                            <th class="text-center">Avg/Day</th>
                            <th class="text-center">LT</th>
                            <th class="text-center">Safety</th>
                            <th class="text-center">ROP</th>
                            <th>Status</th>
                            <th class="text-center">Suggested</th>
                            <th class="text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty rows}">
                                <tr>
                                    <td colspan="10">
                                        <div class="p-40 text-center text-muted">
                                            No low stock products found matching these criteria.
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="item" items="${rows}">
                                    <tr>
                                        <td>
                                            <div class="fw-600">${item.productName}</div>
                                            <div class="fs-12 text-muted mono-text">${item.productCode}</div>
                                        </td>
                                        <td>${item.supplierName}</td>
                                        <td class="text-center fw-600">${item.currentStock}</td>
                                        <td class="text-center text-muted">${item.avgDailySales}</td>
                                        <td class="text-center text-muted">${item.leadTimeDays}d</td>
                                        <td class="text-center text-muted">${item.safetyStock}</td>
                                        <td class="text-center fw-600">${item.rop}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${item.ropStatus == 'Out Of Stock'}">
                                                    <span class="badge badge-inactive">Out Of Stock</span>
                                                </c:when>
                                                <c:when test="${item.ropStatus == 'Reorder Needed'}">
                                                    <span class="badge badge-warning">Reorder Needed</span>
                                                </c:when>
                                                <c:when test="${item.ropStatus == 'At ROP Level'}">
                                                    <span class="badge badge-info">At ROP Level</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-active">OK</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center text-primary fw-600">${item.suggestedReorderQty}</td>
                                        <td class="text-right">
                                            <div class="d-flex gap-8 justify-end">
                                                <a class="btn btn-sm btn-outline"
                                                   href="${pageContext.request.contextPath}/home?p=product-detail&id=${item.productId}">
                                                    View
                                                </a>

                                                <c:choose>
                                                    <c:when test="${item.ropStatus != 'OK' && !item.hasActiveImportRequest}">
                                                        <a class="btn btn-sm btn-primary"
                                                           href="${pageContext.request.contextPath}/home?p=create-import-request&productId=${item.productId}">
                                                            Create Request
                                                        </a>
                                                    </c:when>
                                                    <c:when test="${item.hasActiveImportRequest}">
                                                        <span class="badge badge-info fs-10">Requested</span>
                                                    </c:when>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="d-flex justify-between align-center mt-20">
                    <div class="fs-13 text-muted">Page <b>${page}</b> of <b>${totalPages}</b></div>

                    <div class="d-flex gap-4">
                        <c:url var="prevUrl" value="/home">
                            <c:param name="p" value="low-stock-report"/>
                            <c:param name="page" value="${page - 1}"/>
                            <c:param name="q" value="${q}"/>
                            <c:param name="supplierId" value="${supplierId}"/>
                            <c:param name="ropStatus" value="${ropStatus}"/>
                            <c:param name="minStock" value="${minStock}"/>
                            <c:param name="maxStock" value="${maxStock}"/>
                        </c:url>
                        <c:choose>
                            <c:when test="${page > 1}">
                                <a class="btn btn-sm btn-outline" href="${prevUrl}">Prev</a>
                            </c:when>
                            <c:otherwise>
                                <span class="btn btn-sm btn-outline disabled">Prev</span>
                            </c:otherwise>
                        </c:choose>

                        <c:set var="pgStart" value="${page - 2 > 1 ? page - 2 : 1}"/>
                        <c:set var="pgEnd" value="${page + 2 < totalPages ? page + 2 : totalPages}"/>

                        <c:forEach begin="${pgStart}" end="${pgEnd}" var="pg">
                            <c:url var="pageUrl" value="/home">
                                <c:param name="p" value="low-stock-report"/>
                                <c:param name="page" value="${pg}"/>
                                <c:param name="q" value="${q}"/>
                                <c:param name="supplierId" value="${supplierId}"/>
                                <c:param name="ropStatus" value="${ropStatus}"/>
                                <c:param name="minStock" value="${minStock}"/>
                                <c:param name="maxStock" value="${maxStock}"/>
                            </c:url>
                            <c:choose>
                                <c:when test="${pg == page}">
                                    <span class="btn btn-sm btn-primary">${pg}</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="btn btn-sm btn-outline" href="${pageUrl}">${pg}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:url var="nextUrl" value="/home">
                            <c:param name="p" value="low-stock-report"/>
                            <c:param name="page" value="${page + 1}"/>
                            <c:param name="q" value="${q}"/>
                            <c:param name="supplierId" value="${supplierId}"/>
                            <c:param name="ropStatus" value="${ropStatus}"/>
                            <c:param name="minStock" value="${minStock}"/>
                            <c:param name="maxStock" value="${maxStock}"/>
                        </c:url>
                        <c:choose>
                            <c:when test="${page < totalPages}">
                                <a class="btn btn-sm btn-outline" href="${nextUrl}">Next</a>
                            </c:when>
                            <c:otherwise>
                                <span class="btn btn-sm btn-outline disabled">Next</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>
