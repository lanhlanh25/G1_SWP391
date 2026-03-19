<%-- 
    Document   : brand_stats
    Created on : Jan 29, 2026, 12:24:52 AM
    Author     : ADMIN
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="roleName" value="${sessionScope.roleName}" />

<div class="page-wrap brand-stats-page">

    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <div>
                <h1 class="h1">Brand Statistics</h1>
                <div class="text-muted fs-13">Track products, stock units and movement by brand</div>
            </div>
        </div>

        <div class="d-flex gap-8 align-center">
            <c:if test="${sessionScope.roleName != null && fn:toUpperCase(sessionScope.roleName) == 'MANAGER'}">
                <c:url var="exportPdfUrl" value="/manager/brand-stats-export-pdf">
                    <c:param name="q" value="${q}"/>
                    <c:param name="status" value="${status}"/>
                    <c:param name="brandId" value="${brandId}"/>
                    <c:param name="sortBy" value="${sortBy}"/>
                    <c:param name="sortOrder" value="${sortOrder}"/>
                    <c:param name="range" value="${range}"/>
                </c:url>
                <a class="btn btn-outline" href="${exportPdfUrl}">Export PDF</a>
            </c:if>
            <a class="btn btn-outline" href="${ctx}/home?p=dashboard">← Dashboard</a>
        </div>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="msg-ok mb-16">${param.msg}</div>
    </c:if>
    <c:if test="${not empty param.err}">
        <div class="msg-err mb-16">${param.err}</div>
    </c:if>

    <!-- Stat Cards -->
    <div class="grid-12 gap-16 mb-16">
        <div class="col-2">
            <div class="card p-16 h-full d-flex flex-column justify-center">
                <div class="muted fs-11 uppercase mb-4">Total Brands</div>
                <div class="h2 m-0">${summary.totalBrands}</div>
            </div>
        </div>
        <div class="col-2">
            <div class="card p-16 h-full d-flex flex-column justify-center">
                <div class="muted fs-11 uppercase mb-4">Product Types</div>
                <div class="h2 m-0">${summary.totalProducts}</div>
            </div>
        </div>
        <div class="col-2">
            <div class="card p-16 h-full d-flex flex-column justify-center">
                <div class="muted fs-11 uppercase mb-4">Stock Units</div>
                <div class="h2 m-0 text-primary">${summary.totalStockUnits}</div>
            </div>
        </div>
        <div class="col-2">
            <div class="card p-16 h-full d-flex flex-column justify-center">
                <div class="muted fs-11 uppercase mb-4 text-danger">Low Stock</div>
                <div class="h2 m-0 text-danger">${summary.lowStockProducts}</div>
            </div>
        </div>
        <div class="col-2">
            <div class="card p-16 h-full d-flex flex-column justify-center">
                <div class="muted fs-11 uppercase mb-4 text-info">Imported (Range)</div>
                <div class="h2 m-0 text-info">${summary.importedUnitsInRange}</div>
            </div>
        </div>
        <div class="col-2">
            <div class="card p-16 h-full d-flex flex-column justify-center">
                <div class="muted fs-11 uppercase mb-4 text-info">Exported (Range)</div>
                <div class="h2 m-0 text-info">${summary.exportedUnitsInRange}</div>
            </div>
        </div>
    </div>

    <div class="card mb-16">
        <div class="card-body">
            <form method="get" action="${ctx}/home">
                <input type="hidden" name="p" value="brand-stats"/>

                <div class="grid-12 gap-16 align-end">
                    <div class="col-3">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Data Range</label>
                        <select class="select" name="range">
                            <option value="all" ${empty range || range=='all' ? 'selected' : ''}>All Time</option>
                            <option value="today" ${range=='today' ? 'selected' : ''}>Today</option>
                            <option value="last7" ${range=='last7' ? 'selected' : ''}>Last 7 Days</option>
                            <option value="last30" ${range=='last30' ? 'selected' : ''}>Past 30 Days</option>
                            <option value="last90" ${range=='last90' ? 'selected' : ''}>Past 90 Days (Quarter)</option>
                            <option value="month" ${range=='month' ? 'selected' : ''}>This Month</option>
                            <option value="lastMonth" ${range=='lastMonth' ? 'selected' : ''}>Last Month</option>
                        </select>
                    </div>

                    <div class="col-3">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Brand</label>
                        <select class="select" name="brandId">
                            <option value="" ${empty brandId ? 'selected' : ''}>All Brands</option>
                            <c:forEach items="${allBrands}" var="b">
                                <option value="${b.brandId}" ${not empty brandId && brandId == (b.brandId) ? 'selected' : ''}>
                                    ${b.brandName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-3">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Status</label>
                        <select class="select" name="status">
                            <option value="" ${empty status ? 'selected' : ''}>All Status</option>
                            <option value="active" ${status=='active' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${status=='inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>

                    <div class="col-3">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Keyword</label>
                        <input class="input" type="text" name="q" value="${q}" placeholder="Brand name..."/>
                    </div>

                    <div class="col-3">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Sort By</label>
                        <select class="select" name="sortBy">
                            <option value="stock"    ${sortBy=='stock' ? 'selected' : ''}>Total Stock</option>
                            <option value="products" ${sortBy=='products' ? 'selected' : ''}>Product Types</option>
                            <option value="low"      ${sortBy=='low' ? 'selected' : ''}>Low Stock</option>
                            <option value="import"   ${sortBy=='import' ? 'selected' : ''}>Imported Units</option>
                            <option value="export"   ${sortBy=='export' ? 'selected' : ''}>Exported Units</option>
                            <option value="name"     ${sortBy=='name' ? 'selected' : ''}>Brand Name</option>
                        </select>
                    </div>

                    <div class="col-3">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Order</label>
                        <select class="select" name="sortOrder">
                            <option value="DESC" ${sortOrder=='DESC' ? 'selected' : ''}>Descending</option>
                            <option value="ASC"  ${sortOrder=='ASC' ? 'selected' : ''}>Ascending</option>
                        </select>
                    </div>

                    <div class="col-6 d-flex gap-8">
                        <button class="btn btn-primary" type="submit">Apply Filters</button>
                        <a class="btn btn-outline" href="${ctx}/home?p=brand-stats">Reset Filters</a>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Results -->
    <div class="card">
        <div class="card-body">
            <div class="d-flex justify-between align-center mb-16">
                <div class="h2">Brand Ranking</div>
                <div class="text-muted fs-14">Found: <b class="text-primary">${totalItems}</b> brands</div>
            </div>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width:50px;">#</th>
                        <th>Brand Name</th>
                        <th class="text-center" style="width:120px;">Product Types</th>
                        <th class="text-center" style="width:120px;">Total Stock</th>
                        <th class="text-center" style="width:120px;">Low Stock</th>
                        <th class="text-center" style="width:120px;">Imported</th>
                        <th class="text-center" style="width:120px;">Exported</th>
                        <th class="text-right" style="width:120px;">Action</th>
                    </tr>
                </thead>

                <tbody>
                    <c:forEach items="${rows}" var="r" varStatus="st">
                        <tr>
                            <td class="text-muted fs-13">${(page - 1) * pageSize + st.index + 1}</td>

                            <td>
                                <div class="d-flex align-center gap-8">
                                    <span class="fw-600 text-primary">${r.brandName}</span>
                                    <span class="badge ${r.active ? 'badge-active' : 'badge-inactive'}">
                                        ${r.active ? 'Active' : 'Inactive'}
                                    </span>
                                </div>
                            </td>

                            <td class="text-center">${r.totalProducts}</td>
                            <td class="text-center fw-600">${r.totalStockUnits}</td>
                            <td class="text-center ${r.lowStockProducts > 0 ? 'text-danger fw-700' : 'text-muted'}">
                                ${r.lowStockProducts}
                            </td>
                            <td class="text-center text-info">${r.importedUnits}</td>
                            <td class="text-center text-info">${r.exportedUnits}</td>

                            <td class="text-right">
                                <c:url var="detailUrl" value="/home">
                                    <c:param name="p" value="brand-stats-detail"/>
                                    <c:param name="brandId" value="${r.brandId}"/>
                                    <c:param name="listQ" value="${q}"/>
                                    <c:param name="listStatus" value="${status}"/>
                                    <c:param name="listBrandId" value="${brandId}"/>
                                    <c:param name="listSortBy" value="${sortBy}"/>
                                    <c:param name="listSortOrder" value="${sortOrder}"/>
                                    <c:param name="listRange" value="${range}"/>
                                    <c:param name="listPage" value="${page}"/>
                                </c:url>
                                <a class="btn btn-outline btn-sm" href="${detailUrl}">View</a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty rows}">
                        <tr>
                            <td colspan="8">
                                <div class="p-40 text-center text-muted">No brands match your filters.</div>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

            <c:if test="${totalPages > 1}">
                <div class="d-flex justify-between align-center mt-20">
                    <div class="fs-13 text-muted">Page <b>${page}</b> of <b>${totalPages}</b></div>
                    <div class="d-flex gap-4">
                        <c:url var="baseUrl" value="/home">
                            <c:param name="p" value="brand-stats"/>
                            <c:param name="q" value="${q}"/>
                            <c:param name="status" value="${status}"/>
                            <c:param name="brandId" value="${brandId}"/>
                            <c:param name="sortBy" value="${sortBy}"/>
                            <c:param name="sortOrder" value="${sortOrder}"/>
                            <c:param name="range" value="${range}"/>
                        </c:url>

                        <c:choose>
                            <c:when test="${page > 1}">
                                <a class="btn btn-sm btn-outline" href="${baseUrl}&page=${page-1}">Prev</a>
                            </c:when>
                            <c:otherwise>
                                <span class="btn btn-sm btn-outline disabled">Prev</span>
                            </c:otherwise>
                        </c:choose>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:choose>
                                <c:when test="${i == page}">
                                    <span class="btn btn-sm btn-primary">${i}</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="btn btn-sm btn-outline" href="${baseUrl}&page=${i}">${i}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:choose>
                            <c:when test="${page < totalPages}">
                                <a class="btn btn-sm btn-outline" href="${baseUrl}&page=${page+1}">Next</a>
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