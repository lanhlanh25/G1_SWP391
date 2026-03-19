<%-- 
    Document   : brand_stats_detail
    Created on : Jan 29, 2026, 12:27:40 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<c:url var="backUrl" value="/home">
    <c:param name="p" value="brand-stats"/>
    <c:param name="q" value="${param.listQ}"/>
    <c:param name="status" value="${param.listStatus}"/>
    <c:param name="brandId" value="${param.listBrandId}"/>
    <c:param name="sortBy" value="${param.listSortBy}"/>
    <c:param name="sortOrder" value="${param.listSortOrder}"/>
    <c:param name="range" value="${param.listRange}"/>
    <c:param name="page" value="${empty param.listPage ? 1 : param.listPage}"/>
</c:url>

<div class="page-wrap brand-stats-detail">
    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Brand Performance Analytics: ${brand.brandName}</h1>
        </div>
        <div class="d-flex gap-8 align-center">
            <a class="btn btn-outline" href="${backUrl}">← Back to List</a>
        </div>
    </div>

    <div class="grid-5 gap-16 mb-24">
        <div class="card p-20 text-center">
            <div class="muted mb-4 fs-12 uppercase">Total Products</div>
            <div class="h2">${detailSummary.totalProducts}</div>
        </div>
        <div class="card p-20 text-center">
            <div class="muted mb-4 fs-12 uppercase">In Stock (Units)</div>
            <div class="h2">${detailSummary.totalStockUnits}</div>
        </div>
        <div class="card p-20 text-center">
            <div class="muted mb-4 fs-12 uppercase">Low Stock Alert</div>
            <div class="h2 text-warning">${detailSummary.lowStockProducts}</div>
        </div>
        <div class="card p-20 text-center">
            <div class="muted mb-4 fs-12 uppercase">Imports (Range)</div>
            <div class="h2 text-success">${detailSummary.importedUnitsInRange}</div>
        </div>
        <div class="card p-20 text-center">
            <div class="muted mb-4 fs-12 uppercase">Exports (Range)</div>
            <div class="h2 text-primary">${detailSummary.exportedUnitsInRange}</div>
        </div>
    </div>

    <div class="card mb-16">
        <div class="card-body">
            <form method="get" action="${ctx}/home" class="filters">
                <input type="hidden" name="p" value="brand-stats-detail"/>
                <input type="hidden" name="brandId" value="${param.brandId}"/>
                <input type="hidden" name="listQ" value="${param.listQ}"/>
                <input type="hidden" name="listStatus" value="${param.listStatus}"/>
                <input type="hidden" name="listBrandId" value="${param.listBrandId}"/>
                <input type="hidden" name="listSortBy" value="${param.listSortBy}"/>
                <input type="hidden" name="listSortOrder" value="${param.listSortOrder}"/>
                <input type="hidden" name="listRange" value="${param.listRange}"/>
                <input type="hidden" name="listPage" value="${empty param.listPage ? 1 : param.listPage}"/>

                <div class="filter-group">
                    <label class="label">Sort By</label>
                    <select class="input" name="dSortBy">
                        <option value="stock"  ${dSortBy=='stock' ? 'selected' : ''}>Total Stock</option>
                        <option value="import" ${dSortBy=='import' ? 'selected' : ''}>Imported Units</option>
                        <option value="export" ${dSortBy=='export' ? 'selected' : ''}>Exported Units</option>
                        <option value="name"   ${dSortBy=='name' ? 'selected' : ''}>Product Name</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label class="label">Order</label>
                    <select class="input" name="dSortOrder">
                        <option value="DESC" ${dSortOrder=='DESC' ? 'selected' : ''}>High to Low</option>
                        <option value="ASC"  ${dSortOrder=='ASC' ? 'selected' : ''}>Low to High</option>
                    </select>
                </div>

                <div class="filter-actions d-flex gap-8 align-end">
                    <button class="btn btn-primary" type="submit">Apply Sorting</button>
                    <a class="btn btn-outline" href="${ctx}/home?p=brand-stats-detail&brandId=${param.brandId}">Reset</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
      <table class="table">
        <thead>
            <tr>
                <th style="width:140px;">Code</th>
                <th>Product Name</th>
                <th style="width:120px;" class="text-center">Stock</th>
                <th style="width:120px;" class="text-center">Imported</th>
                <th style="width:120px;" class="text-center">Exported</th>
                <th style="width:140px;" class="text-center">Status</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${products}" var="p">
                <tr>
                    <td class="fw-600">${p.productCode}</td>
                    <td>${p.productName}</td>
                    <td class="text-center fw-700">${p.totalStockUnits}</td>
                    <td class="text-center text-success fw-600">${p.importedUnits}</td>
                    <td class="text-center text-primary fw-600">${p.exportedUnits}</td>
                    <td class="text-center">
                        <c:choose>
                            <c:when test="${p.stockStatus == 'Out Of Stock'}">
                                <span class="badge badge-inactive">Out of Stock</span>
                            </c:when>
                            <c:when test="${p.stockStatus == 'Reorder Needed'}">
                                <span class="badge badge-warning">Low Stock</span>
                            </c:when>
                            <c:otherwise>
                                <span class="${p.totalStockUnits > 0 ? 'badge badge-active' : 'badge badge-inactive'}">
                                    <c:out value="${p.stockStatus}"/>
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>

            <c:if test="${empty products}">
                <tr>
                    <td colspan="8" style="text-align:center; color:#666;">No products</td>
                </tr>
            </c:if>
        </tbody>
    </table>
</div>
