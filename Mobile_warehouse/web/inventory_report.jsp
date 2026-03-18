<%-- 
    Document   : inventory_report
    Created on : Mar 16, 2026, 7:54:36 AM
    Author     : Lanhlanh
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<%-- Using app.css for all styling --%>

<div class="page-wrap">

    <div class="topbar mb-24">
        <div class="d-flex align-center gap-12">
            <a href="${ctx}/home?p=dashboard" class="btn">← Back</a>
            <h1 class="h1">Inventory Report</h1>
            <span class="muted font-sm">(Import / Export / Stock)</span>
        </div>
    </div>

    <c:if test="${not empty err}">
        <div class="alert alert-danger mb-16">
            ${fn:escapeXml(err)}
        </div>
    </c:if>

    <!-- Filters -->
    <form method="get" action="${ctx}/inventory-report" class="filters mb-24">
        <input type="hidden" name="page" value="1"/>
        
        <div class="filter-group">
            <label>From Date</label>
            <input class="input" type="date" name="from" value="${fn:escapeXml(from)}"/>
        </div>

        <div class="filter-group">
            <label>To Date</label>
            <input class="input" type="date" name="to" value="${fn:escapeXml(to)}"/>
        </div>

        <div class="filter-group">
            <label>Brand</label>
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
            <label>Keyword</label>
            <input class="input" type="text" name="keyword" value="${fn:escapeXml(keyword)}"
                   placeholder="Product name or code..."/>
        </div>

        <div class="filter-actions h-38">
            <button type="submit" class="btn btn-primary">Apply</button>
            <a href="${ctx}/inventory-report" class="btn">Reset</a>
        </div>
    </form>

    <div class="stats-grid">

        <div class="stat-card info">
            <div class="stat-label">Opening Stock</div>
            <div class="stat-value">${fn:escapeXml(summary.totalOpening)}</div>
            <div class="muted font-xs mt-4">Calculated start balance</div>
        </div>

        <div class="stat-card success">
            <div class="stat-label">Stock In</div>
            <div class="stat-value text-success">+${fn:escapeXml(summary.totalImport)}</div>
            <div class="muted font-xs mt-4">Total import in period</div>
        </div>

        <div class="stat-card warning">
            <div class="stat-label">Stock Out</div>
            <div class="stat-value text-warning">-${fn:escapeXml(summary.totalExport)}</div>
            <div class="muted font-xs mt-4">Total export in period</div>
        </div>

        <div class="stat-card primary">
            <div class="stat-label">Closing Stock</div>
            <div class="stat-value text-primary">${fn:escapeXml(summary.totalClosing)}</div>
            <div class="muted font-xs mt-4">Stock at end of period</div>
        </div>

        <div class="stat-card danger">
            <div class="stat-label">Needs Reorder</div>
            <div class="stat-value text-danger border-none">${fn:escapeXml(summary.totalBelowRop)}</div>
            <div class="muted font-xs mt-4">${fn:escapeXml(summary.totalOutOfStock)} out of stock</div>
        </div>

    </div>

    <div class="d-flex align-center justify-between mb-12">
        <h2 class="h2 mb-0">Inventory Details</h2>
        <span class="muted font-sm">
            Showing ${totalItems} product(s)
        </span>
    </div>

    <div class="card mb-20">
        <div class="card-body p-0">
            <table class="table">
                <thead>
                    <tr>
                        <th style="min-width: 120px;">Product Code</th>
                        <th>Product Name</th>
                        <th>Brand</th>
                        <th class="text-right bg-success-light text-success" style="width: 80px;">Opening</th>
                        <th class="text-right bg-success-light text-success" style="width: 80px;">Import</th>
                        <th class="text-right bg-warning-light text-warning" style="width: 80px;">Export</th>
                        <th class="text-right bg-primary-light text-primary" style="width: 100px;">Closing</th>
                        <th class="text-right text-muted" style="width: 60px;" title="Reorder Point">ROP</th>
                        <th class="text-center" style="width: 120px;">Status</th>
                    </tr>
                </thead>
                <tbody>

                <c:if test="${empty rows}">
                    <tr><td colspan="9" class="empty-row">
                            No data found for the selected period. Please adjust the filters and try again.
                        </td></tr>
                </c:if>

                <c:set var="lastBrand" value=""/>
                <c:set var="sumOpen"   value="${0}"/>
                <c:set var="sumImp"    value="${0}"/>
                <c:set var="sumExp"    value="${0}"/>
                <c:set var="sumClose"  value="${0}"/>

                <c:forEach var="r" items="${rows}">

                    <c:if test="${r.brandName != lastBrand}">
                        <tr class="group-hdr">
                            <td colspan="9">${fn:escapeXml(r.brandName)}</td>
                        </tr>
                        <c:set var="lastBrand" value="${r.brandName}"/>
                    </c:if>

                    <c:set var="sumOpen"  value="${sumOpen  + r.openingQty}"/>
                    <c:set var="sumImp"   value="${sumImp   + r.importQty}"/>
                    <c:set var="sumExp"   value="${sumExp   + r.exportQty}"/>
                    <c:set var="sumClose" value="${sumClose + r.closingQty}"/>

                    <tr>
                        <td class="fw-700">${fn:escapeXml(r.productCode)}</td>
                        <td>
                            <a class="link" href="${ctx}/inventory-details?productCode=${fn:escapeXml(r.productCode)}">
                                ${fn:escapeXml(r.productName)}
                            </a>
                        </td>
                        <td>${fn:escapeXml(r.brandName)}</td>

                        <td class="text-right bg-success-light">${r.openingQty}</td>

                        <td class="text-right bg-success-light text-success fw-600">
                            <c:if test="${r.importQty > 0}">+</c:if>${r.importQty}
                        </td>

                        <td class="text-right bg-warning-light text-warning fw-600">
                            <c:if test="${r.exportQty > 0}">-</c:if>${r.exportQty}
                        </td>

                        <td class="text-right bg-primary-light text-primary fw-700">${r.closingQty}</td>

                        <td class="text-right text-muted fw-600">${r.rop}</td>

                        <td class="text-center">
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
                    <tr class="fw-800 bg-primary-light text-primary">
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

        <c:if test="${totalPages > 1}">
            <div class="paging-footer align-center justify-center p-20">
                <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}&brandId=${brandId}&keyword=${fn:escapeXml(keyword)}"/>
                <div class="paging">
                    <c:choose>
                        <c:when test="${page > 1}">
                            <a class="paging-btn" href="${ctx}/inventory-report?${qsBase}&page=${page - 1}">← Prev</a>
                        </c:when>
                        <c:otherwise>
                            <span class="paging-btn disabled">← Prev</span>
                        </c:otherwise>
                    </c:choose>

                    <c:forEach begin="1" end="${totalPages}" var="pg">
                        <c:choose>
                            <c:when test="${pg == page}">
                                <span class="paging-btn active">${pg}</span>
                            </c:when>
                            <c:otherwise>
                                <a class="paging-btn" href="${ctx}/inventory-report?${qsBase}&page=${pg}">${pg}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <c:choose>
                        <c:when test="${page < totalPages}">
                            <a class="paging-btn" href="${ctx}/inventory-report?${qsBase}&page=${page + 1}">Next →</a>
                        </c:when>
                        <c:otherwise>
                            <span class="paging-btn disabled">Next →</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>
    </div>

    <div class="d-flex flex-wrap gap-12 align-center mt-12 font-sm muted">
        <strong class="text-primary">Legend:</strong>
        <span class="badge badge-success">OK</span> Stock > ROP
        <span class="badge badge-info">At ROP Level</span> Stock = ROP
        <span class="badge badge-warning">Reorder Needed</span> Stock < ROP
        <span class="badge badge-danger">Out of Stock</span> Stock = 0
    </div>
</div>
