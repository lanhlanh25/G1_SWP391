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

<c:url var="exportUrl" value="/manager/brand-stats-export">
    <c:param name="q" value="${q}" />
    <c:param name="status" value="${status}" />
    <c:param name="brandId" value="${brandId}" />
    <c:param name="sortBy" value="${sortBy}" />
    <c:param name="sortOrder" value="${sortOrder}" />
    <c:param name="range" value="${range}" />
</c:url>

<div class="page-wrap-md brand-stats-page">

    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
            <div>
                <h1 class="title" style="margin:0;">Brand Statistics</h1>
                <div class="small">Track products, stock units and movement by brand</div>
            </div>
        </div>

        <div class="actions">
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
        </div>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="msg-ok">${param.msg}</div>
    </c:if>
    <c:if test="${not empty param.err}">
        <div class="msg-err">${param.err}</div>
    </c:if>


<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px;">
    <div class="card" style="margin-bottom:0; padding:20px;">
        <div class="muted">Total Brands</div>
        <div style="font-size:24px; font-weight:700; color:var(--text);">${summary.totalBrands}</div>
    </div>

    <div class="card" style="margin-bottom:0; padding:20px;">
        <div class="muted">Products types</div>
        <div style="font-size:24px; font-weight:700; color:var(--text);">${summary.totalProducts}</div>
    </div>

    <div class="card" style="margin-bottom:0; padding:20px;">
        <div class="muted">Total Stock Units</div>
        <div style="font-size:24px; font-weight:700; color:var(--text);">${summary.totalStockUnits}</div>
    </div>

    <div class="card" style="margin-bottom:0; padding:20px;">
        <div class="muted">Low Stock Products</div>
        <div style="font-size:24px; font-weight:700; color:var(--danger);">${summary.lowStockProducts}</div>
    </div>

    <div class="card" style="margin-bottom:0; padding:20px;">
        <div class="muted">Imported (Range)</div>
        <div style="font-size:24px; font-weight:700; color:var(--info);">${summary.importedUnitsInRange}</div>
    </div>

    <div class="card" style="margin-bottom:0; padding:20px;">
        <div class="muted">Exported (Range)</div>
        <div style="font-size:24px; font-weight:700; color:var(--info);">${summary.exportedUnitsInRange}</div>
    </div>
</div>


    <div class="card">
        <div class="card-header">
            <div>
                <div class="h2">Filter & Sort</div>
                <div class="muted">
                    Refine brand statistics by range, brand, status, keyword and sort order.
                </div>
            </div>
        </div>

        <form method="get" action="${ctx}/home" class="card-body">
            <input type="hidden" name="p" value="brand-stats"/>

            <div style="display:grid; grid-template-columns: repeat(4, 1fr); gap: 16px;">
    
                <div style="grid-column: span 2;">
                    <label class="label" style="display:block; margin-bottom:8px; font-weight:600; font-size:14px;">Data Range</label>
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

                <div>
                    <label class="label" style="display:block; margin-bottom:8px; font-weight:600; font-size:14px;">Brand</label>
                    <select class="select" name="brandId" id="brandIdSelect">
                        <option value="" ${empty brandId ? 'selected' : ''}>All Brands</option>
                        <c:forEach items="${allBrands}" var="b">
                            <option value="${b.brandId}" ${not empty brandId && brandId == (b.brandId) ? 'selected' : ''}>
                                ${b.brandName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label class="label" style="display:block; margin-bottom:8px; font-weight:600; font-size:14px;">Brand Status</label>
                    <select class="select" name="status">
                        <option value="" ${empty status ? 'selected' : ''}>All Status</option>
                        <option value="active" ${status=='active' ? 'selected' : ''}>Active</option>
                        <option value="inactive" ${status=='inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>


                <div style="grid-column: span 4; font-size: 13px; color: var(--info); background: var(--primary-light); padding: 8px 12px; border-radius: 6px;">
                    Affects Imported Units and Exported Units only.
                </div>

       
                <div style="grid-column: span 2;">
                    <label class="label" style="display:block; margin-bottom:8px; font-weight:600; font-size:14px;">Search</label>
                    <input
                        class="input"
                        type="text"
                        name="q"
                        id="searchInput"
                        value="${q}"
                        placeholder="Search by brand name"/>
                </div>

                <div>
                    <label class="label" style="display:block; margin-bottom:8px; font-weight:600; font-size:14px;">Sort By</label>
                    <select class="select" name="sortBy">
                        <option value="stock"    ${sortBy=='stock' ? 'selected' : ''}>Total Stock</option>
                        <option value="products" ${sortBy=='products' ? 'selected' : ''}>Product Types</option>
                        <option value="low"      ${sortBy=='low' ? 'selected' : ''}>Low Stock</option>
                        <option value="import"   ${sortBy=='import' ? 'selected' : ''}>Imported Units</option>
                        <option value="export"   ${sortBy=='export' ? 'selected' : ''}>Exported Units</option>
                        <option value="name"     ${sortBy=='name' ? 'selected' : ''}>Brand Name</option>
                    </select>
                </div>

                <div>
                    <label class="label" style="display:block; margin-bottom:8px; font-weight:600; font-size:14px;">Order</label>
                    <select class="select" name="sortOrder">
                        <option value="DESC" ${sortOrder=='DESC' ? 'selected' : ''}>Descending</option>
                        <option value="ASC"  ${sortOrder=='ASC' ? 'selected' : ''}>Ascending</option>
                    </select>
                </div>
            </div>

            <div style="margin-top:20px; display:flex; gap:10px;">
                <button class="btn btn-primary" type="submit">Apply Filters</button>
                <a class="btn btn-outline" href="${ctx}/home?p=brand-stats">Reset</a>
            </div>
        </form>
    </div>


    <c:set var="statusLabel"
           value="${status=='active' ? 'Active'
                    : status=='inactive' ? 'Inactive'
                    : 'All'}" />
    <c:set var="sortLabel"
           value="${sortBy=='name' ? 'Brand Name'
                    : sortBy=='products' ? 'Total Products'
                    : sortBy=='low' ? 'Low Stock Count'
                    : sortBy=='import' ? 'Imported Units'
                    : sortBy=='export' ? 'Exported Units'
                    : 'Total Stock'}" />
    <c:set var="orderLabel" value="${empty sortOrder ? 'DESC' : sortOrder}" />
    <c:set var="brandNameLabel" value="All" />
    <c:if test="${not empty brandId}">
        <c:set var="brandIdNum" value="${brandId}" />
        <c:forEach items="${allBrands}" var="bb">
            <c:if test="${bb.brandId == brandIdNum}">
                <c:set var="brandNameLabel" value="${bb.brandName}" />
            </c:if>
        </c:forEach>
    </c:if>

    <div class="applied-filters">
        <span class="applied-title">Applied Filters</span>

        <span class="filter-chip">
            Range:
            <b>
                <c:choose>
                    <c:when test="${empty range || range=='all'}">All Time</c:when>
                    <c:when test="${range=='today'}">Today</c:when>
                    <c:when test="${range=='last7'}">Last 7 Days</c:when>
                    <c:when test="${range=='last30'}">Past 30 Days</c:when>
                    <c:when test="${range=='last90'}">Past 90 Days (Quarter)</c:when>
                    <c:when test="${range=='month'}">This Month</c:when>
                    <c:when test="${range=='lastMonth'}">Last Month</c:when>
                    <c:otherwise>All Time</c:otherwise>
                </c:choose>
            </b>
        </span>

        <span class="filter-chip">Brand: <b>${brandNameLabel}</b></span>
        <span class="filter-chip">Status: <b>${statusLabel}</b></span>
        <span class="filter-chip">Search: <b>${empty q ? '-' : q}</b></span>
        <span class="filter-chip">Sort: <b>${sortLabel} ${orderLabel}</b></span>
    </div>


    <div class="card card-body brand-table-card">
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width:60px;">#</th>
                        <th>Brand Name</th>
                        <th style="width:140px;">
                            #Product Types<br/>
                        </th>
                        <th style="width:120px;">Total Stock</th>
                        <th style="width:140px;">Low Stock Count</th>
                        <th style="width:140px;">Imported Units</th>
                        <th style="width:140px;">Exported Units</th>
                        <th style="width:140px;">Action</th>
                    </tr>
                </thead>

                <tbody>
                    <c:forEach items="${rows}" var="r" varStatus="st">
                        <tr>
                            <td>${(page - 1) * pageSize + st.index + 1}</td>

                            <td>
                                <div class="brand-name-cell">
                                    <span class="brand-name-text">${r.brandName}</span>
                                    <span class="badge ${r.active ? 'badge-active' : 'badge-inactive'}">
                                        ${r.active ? 'Active' : 'Inactive'}
                                    </span>
                                </div>
                            </td>

                            <td>${r.totalProducts}</td>
                            <td>${r.totalStockUnits}</td>
                            <td>${r.lowStockProducts}</td>
                            <td>${r.importedUnits}</td>
                            <td>${r.exportedUnits}</td>

                            <td>
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
                                <a class="btn btn-outline btn-sm" href="${detailUrl}">View Details</a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty rows}">
                        <tr>
                            <td colspan="8" class="empty-row">No data</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>


    <div class="paging">
        <c:choose>
            <c:when test="${page <= 1}">
                <span class="paging-btn disabled">&laquo; Prev</span>
            </c:when>
            <c:otherwise>
                <c:url var="prevUrl" value="/home">
                    <c:param name="p" value="brand-stats"/>
                    <c:param name="page" value="${page-1}"/>
                    <c:param name="q" value="${q}"/>
                    <c:param name="status" value="${status}"/>
                    <c:param name="brandId" value="${brandId}"/>
                    <c:param name="sortBy" value="${sortBy}"/>
                    <c:param name="sortOrder" value="${sortOrder}"/>
                    <c:param name="range" value="${range}"/>
                </c:url>
                <a href="${prevUrl}">&laquo; Prev</a>
            </c:otherwise>
        </c:choose>

        <c:forEach begin="1" end="${totalPages}" var="i">
            <c:choose>
                <c:when test="${i == page}">
                    <b>${i}</b>
                </c:when>
                <c:otherwise>
                    <c:url var="pageUrl" value="/home">
                        <c:param name="p" value="brand-stats"/>
                        <c:param name="page" value="${i}"/>
                        <c:param name="q" value="${q}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="brandId" value="${brandId}"/>
                        <c:param name="sortBy" value="${sortBy}"/>
                        <c:param name="sortOrder" value="${sortOrder}"/>
                        <c:param name="range" value="${range}"/>
                    </c:url>
                    <a href="${pageUrl}">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <c:choose>
            <c:when test="${page >= totalPages}">
                <span class="paging-btn disabled">Next &raquo;</span>
            </c:when>
            <c:otherwise>
                <c:url var="nextUrl" value="/home">
                    <c:param name="p" value="brand-stats"/>
                    <c:param name="page" value="${page+1}"/>
                    <c:param name="q" value="${q}"/>
                    <c:param name="status" value="${status}"/>
                    <c:param name="brandId" value="${brandId}"/>
                    <c:param name="sortBy" value="${sortBy}"/>
                    <c:param name="sortOrder" value="${sortOrder}"/>
                    <c:param name="range" value="${range}"/>
                </c:url>
                <a href="${nextUrl}">Next &raquo;</a>
            </c:otherwise>
        </c:choose>
    </div>
</div>