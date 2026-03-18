<%--
    Document   : inventory_report
    Created on : Mar 16, 2026
    Author     : Lanhlanh
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

    <div class="topbar mb-20">
        <div class="d-flex align-center gap-10">
            <a href="${ctx}/home?p=dashboard" class="btn btn-outline">Back</a>
            <div>
                <h1 class="h1 m-0">Inventory Report</h1>
                <div class="card-subtitle mt-4">Import / Export / Stock</div>
            </div>
        </div>
    </div>

    <c:if test="${not empty err}">
        <div class="alert alert-danger mb-16">
            ${fn:escapeXml(err)}
        </div>
    </c:if>

    <div class="card mb-14">
        <div class="card-body">
            <form method="get" action="${ctx}/inventory-report">
                <input type="hidden" name="page" value="1"/>

                <div class="filters inventory-report-filters">
                    <div class="filter-group">
                        <label class="label">From Date</label>
                        <input class="input" type="date" name="from" value="${fn:escapeXml(from)}"/>
                    </div>

                    <div class="filter-group">
                        <label class="label">To Date</label>
                        <input class="input" type="date" name="to" value="${fn:escapeXml(to)}"/>
                    </div>

                    <div class="filter-group">
                        <label class="label">Brand</label>
                        <select class="select" name="brandId">
                            <option value="">All Brands</option>
                            <c:forEach var="b" items="${brands}">
                                <option value="${b.id}" ${brandId == b.id ? 'selected' : ''}>
                                    ${fn:escapeXml(b.name)}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label class="label">Keyword</label>
                        <input class="input" type="text" name="keyword" value="${fn:escapeXml(keyword)}"
                               placeholder="Product name or code..."/>
                    </div>

                    <div class="d-flex align-end">
                        <button type="submit" class="btn btn-primary btn-sm btn-equal">Apply</button>
                    </div>

                    <div class="d-flex align-end">
                        <a href="${ctx}/inventory-report" class="btn btn-outline btn-sm btn-equal">Reset</a>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="stat-cards mb-14">
        <div class="card stat-card-item report-stat-card report-tone-info">
            <div class="small muted">Opening Stock</div>
            <div class="stat-value">${fn:escapeXml(summary.totalOpening)}</div>
            <div class="small muted mt-4">Calculated start balance</div>
        </div>

        <div class="card stat-card-item report-stat-card report-tone-success">
            <div class="small muted">Stock In</div>
            <div class="stat-value text-success">+${fn:escapeXml(summary.totalImport)}</div>
            <div class="small muted mt-4">Total import in period</div>
        </div>

        <div class="card stat-card-item report-stat-card report-tone-warning">
            <div class="small muted">Stock Out</div>
            <div class="stat-value text-warning">-${fn:escapeXml(summary.totalExport)}</div>
            <div class="small muted mt-4">Total export in period</div>
        </div>

        <div class="card stat-card-item report-stat-card report-tone-primary">
            <div class="small muted">Closing Stock</div>
            <div class="stat-value text-primary">${fn:escapeXml(summary.totalClosing)}</div>
            <div class="small muted mt-4">Stock at end of period</div>
        </div>

        <div class="card stat-card-item report-stat-card report-tone-danger">
            <div class="small muted">Needs Reorder</div>
            <div class="stat-value text-danger">${fn:escapeXml(summary.totalBelowRop)}</div>
            <div class="small muted mt-4">${fn:escapeXml(summary.totalOutOfStock)} out of stock</div>
        </div>
    </div>

    <c:set var="safeTotalItems" value="${empty totalItems ? 0 : totalItems}"/>
    <c:set var="fromItem" value="${safeTotalItems == 0 ? 0 : ((page - 1) * pageSize + 1)}"/>
    <c:set var="toItem" value="${page * pageSize > safeTotalItems ? safeTotalItems : page * pageSize}"/>

    <div class="d-flex align-center justify-between mb-12 flex-wrap gap-8">
        <h2 class="h2 mb-0">Inventory Details</h2>
        <span class="muted font-sm">
            Showing ${fromItem}-${toItem} of ${safeTotalItems} product(s)
        </span>
    </div>

    <div class="card overflow-hidden mb-20">
        <div class="card-body p-0">
            <div class="inventory-report-table-wrap">
                <table class="table inventory-report-table">
                    <colgroup>
                        <col class="report-col-code"/>
                        <col class="report-col-name"/>
                        <col class="report-col-brand"/>
                        <col class="report-col-open"/>
                        <col class="report-col-import"/>
                        <col class="report-col-export"/>
                        <col class="report-col-closing"/>
                        <col class="report-col-rop"/>
                        <col class="report-col-status"/>
                    </colgroup>
                    <thead>
                        <tr>
                            <th>Product Code</th>
                            <th>Product Name</th>
                            <th>Brand</th>
                            <th class="text-right report-metric-head report-metric-open">Opening</th>
                            <th class="text-right report-metric-head report-metric-import">Import</th>
                            <th class="text-right report-metric-head report-metric-export">Export</th>
                            <th class="text-right report-metric-head report-metric-closing">Closing</th>
                            <th class="text-right" title="Reorder Point">ROP</th>
                            <th class="text-center">Status</th>
                        </tr>
                    </thead>
                    <tbody>

                        <c:if test="${empty rows}">
                            <tr>
                                <td colspan="9" class="empty-row">
                                    No data found for the selected period. Please adjust the filters and try again.
                                </td>
                            </tr>
                        </c:if>

                        <c:set var="lastBrand" value=""/>
                        <c:set var="sumOpen" value="${0}"/>
                        <c:set var="sumImp" value="${0}"/>
                        <c:set var="sumExp" value="${0}"/>
                        <c:set var="sumClose" value="${0}"/>

                        <c:forEach var="r" items="${rows}">

                            <c:if test="${r.brandName != lastBrand}">
                                <tr class="group-hdr">
                                    <td colspan="9">${fn:escapeXml(r.brandName)}</td>
                                </tr>
                                <c:set var="lastBrand" value="${r.brandName}"/>
                            </c:if>

                            <c:set var="sumOpen" value="${sumOpen + r.openingQty}"/>
                            <c:set var="sumImp" value="${sumImp + r.importQty}"/>
                            <c:set var="sumExp" value="${sumExp + r.exportQty}"/>
                            <c:set var="sumClose" value="${sumClose + r.closingQty}"/>

                            <c:url var="detailUrl" value="/inventory-details">
                                <c:param name="productCode" value="${r.productCode}"/>
                            </c:url>

                            <tr>
                                <td class="report-code fw-700">${fn:escapeXml(r.productCode)}</td>
                                <td class="report-name">
                                    <a class="text-primary text-underline" href="${detailUrl}">
                                        ${fn:escapeXml(r.productName)}
                                    </a>
                                </td>
                                <td class="report-brand">${fn:escapeXml(r.brandName)}</td>

                                <td class="text-right report-cell report-cell-open">${r.openingQty}</td>

                                <td class="text-right report-cell report-cell-import text-success fw-600">
                                    <c:if test="${r.importQty > 0}">+</c:if>${r.importQty}
                                </td>

                                <td class="text-right report-cell report-cell-export text-warning fw-600">
                                    <c:if test="${r.exportQty > 0}">-</c:if>${r.exportQty}
                                </td>

                                <td class="text-right report-cell report-cell-closing text-primary fw-700">${r.closingQty}</td>

                                <td class="text-right report-rop text-muted fw-600">${r.rop}</td>

                                <td class="text-center report-status">
                                    <c:choose>
                                        <c:when test="${r.ropStatus eq 'Out Of Stock'}">
                                            <span class="badge badge-danger">Out of Stock</span>
                                        </c:when>
                                        <c:when test="${r.ropStatus eq 'Reorder Needed'}">
                                            <span class="badge badge-warning" title="Suggested: ${r.suggestedReorderQty}">Reorder Needed</span>
                                        </c:when>
                                        <c:when test="${r.ropStatus eq 'At ROP Level'}">
                                            <span class="badge badge-info">At ROP Level</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-success">OK</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${not empty rows}">
                            <tr class="report-total-row">
                                <td colspan="3" class="text-right">Page Total</td>
                                <td class="text-right">${sumOpen}</td>
                                <td class="text-right">+${sumImp}</td>
                                <td class="text-right">-${sumExp}</td>
                                <td class="text-right">${sumClose}</td>
                                <td class="text-right"></td>
                                <td></td>
                            </tr>
                        </c:if>

                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <c:if test="${totalPages > 1}">
        <div class="paging-footer">
            <div class="paging-info">
                Showing ${fromItem}-${toItem} of ${safeTotalItems} product(s)
            </div>

            <div class="paging">
                <c:choose>
                    <c:when test="${page <= 1}">
                        <button class="btn btn-outline btn-sm" disabled>Prev</button>
                    </c:when>
                    <c:otherwise>
                        <c:url var="prevUrl" value="/inventory-report">
                            <c:param name="from" value="${from}"/>
                            <c:param name="to" value="${to}"/>
                            <c:param name="brandId" value="${brandId}"/>
                            <c:param name="keyword" value="${keyword}"/>
                            <c:param name="page" value="${page - 1}"/>
                        </c:url>
                        <a class="btn btn-outline btn-sm" href="${prevUrl}">Prev</a>
                    </c:otherwise>
                </c:choose>

                <c:set var="startPage" value="${page - 2 > 1 ? page - 2 : 1}"/>
                <c:set var="endPage" value="${page + 2 < totalPages ? page + 2 : totalPages}"/>

                <c:if test="${startPage > 1}">
                    <c:url var="firstUrl" value="/inventory-report">
                        <c:param name="from" value="${from}"/>
                        <c:param name="to" value="${to}"/>
                        <c:param name="brandId" value="${brandId}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="page" value="1"/>
                    </c:url>
                    <a class="btn btn-outline btn-sm" href="${firstUrl}">1</a>
                    <c:if test="${startPage > 2}">
                        <span class="align-self-center px-4">...</span>
                    </c:if>
                </c:if>

                <c:forEach var="pg" begin="${startPage}" end="${endPage}">
                    <c:url var="pageUrl" value="/inventory-report">
                        <c:param name="from" value="${from}"/>
                        <c:param name="to" value="${to}"/>
                        <c:param name="brandId" value="${brandId}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="page" value="${pg}"/>
                    </c:url>
                    <c:choose>
                        <c:when test="${pg == page}">
                            <button class="btn btn-primary btn-sm" disabled>${pg}</button>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-outline btn-sm" href="${pageUrl}">${pg}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:if test="${endPage < totalPages}">
                    <c:if test="${endPage < totalPages - 1}">
                        <span class="align-self-center px-4">...</span>
                    </c:if>
                    <c:url var="lastUrl" value="/inventory-report">
                        <c:param name="from" value="${from}"/>
                        <c:param name="to" value="${to}"/>
                        <c:param name="brandId" value="${brandId}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="page" value="${totalPages}"/>
                    </c:url>
                    <a class="btn btn-outline btn-sm" href="${lastUrl}">${totalPages}</a>
                </c:if>

                <c:choose>
                    <c:when test="${page >= totalPages}">
                        <button class="btn btn-outline btn-sm" disabled>Next</button>
                    </c:when>
                    <c:otherwise>
                        <c:url var="nextUrl" value="/inventory-report">
                            <c:param name="from" value="${from}"/>
                            <c:param name="to" value="${to}"/>
                            <c:param name="brandId" value="${brandId}"/>
                            <c:param name="keyword" value="${keyword}"/>
                            <c:param name="page" value="${page + 1}"/>
                        </c:url>
                        <a class="btn btn-outline btn-sm" href="${nextUrl}">Next</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>

    <div class="card">
        <div class="card-body report-legend">
            <span class="report-legend-label">Legend</span>
            <span class="report-legend-item">
                <span class="badge badge-success">OK</span>
                Stock &gt; ROP
            </span>
            <span class="report-legend-item">
                <span class="badge badge-info">At ROP Level</span>
                Stock = ROP
            </span>
            <span class="report-legend-item">
                <span class="badge badge-warning">Reorder Needed</span>
                Stock &lt; ROP
            </span>
            <span class="report-legend-item">
                <span class="badge badge-danger">Out of Stock</span>
                Stock = 0
            </span>
        </div>
    </div>
</div>
