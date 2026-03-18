<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=dashboard">← Back</a>
            <div>
                <h1 class="h1" style="margin:0;">Low Stock Report</h1>
                <div class="small">Monitor products that are at or below reorder point.</div>
            </div>
        </div>
    </div>

    <c:if test="${not empty err}">
        <div class="msg-err">${err}</div>
    </c:if>
    <c:if test="${not empty param.err}">
        <div class="msg-err">${param.err}</div>
    </c:if>

    <div class="stat-cards" style="margin-bottom:16px;">
        <div class="card stat-card-item">
            <div class="muted-label">Products Below ROP</div>
            <div class="stat-value">${summary.productsBelowRop}</div>
        </div>
        <div class="card stat-card-item">
            <div class="muted-label">Out Of Stock</div>
            <div class="stat-value">${summary.outOfStock}</div>
        </div>
        <div class="card stat-card-item">
            <div class="muted-label">Reorder Needed</div>
            <div class="stat-value">${summary.reorderNeeded}</div>
        </div>
        <div class="card stat-card-item">
            <div class="muted-label">Total Products</div>
            <div class="stat-value">${summary.totalProducts}</div>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/home">
                <input type="hidden" name="p" value="low-stock-report"/>

                <div class="filters">
                    <div>
                        <label>Search by Product</label>
                        <input class="input" type="text" name="q" value="${q}" placeholder="Product name or code"/>
                    </div>

                    <div>
                        <label>Supplier</label>
                        <select class="select" name="supplierId">
                            <option value="">All</option>
                            <c:forEach var="s" items="${suppliers}">
                                <option value="${s.id}" <c:if test="${supplierId == '' + s.id}">selected</c:if>>
                                    ${s.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div>
                        <label>ROP Status</label>
                        <select class="select" name="ropStatus">
                            <option value="">All Low Stock</option>
                            <option value="All" ${ropStatus == 'All' ? 'selected' : ''}>All</option>
                            <option value="Out Of Stock" ${ropStatus == 'Out Of Stock' ? 'selected' : ''}>Out Of Stock</option>
                            <option value="Reorder Needed" ${ropStatus == 'Reorder Needed' ? 'selected' : ''}>Reorder Needed</option>
                            <option value="At ROP Level" ${ropStatus == 'At ROP Level' ? 'selected' : ''}>At ROP Level</option>
                            <option value="OK" ${ropStatus == 'OK' ? 'selected' : ''}>OK</option>
                        </select>
                    </div>

                    <div>
                        <label>Min Stock</label>
                        <input class="input" type="number" min="0" name="minStock" value="${minStock}"/>
                    </div>

                    <div>
                        <label>Max Stock</label>
                        <input class="input" type="number" min="0" name="maxStock" value="${maxStock}"/>
                    </div>

                    <div>
                        <button class="btn btn-primary" type="submit">Apply</button>
                    </div>

                    <div>
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=low-stock-report">Reset</a>
                    </div>
                </div>
            </form>

            <div class="showing-line">
                Showing <b>${totalItems}</b> item(s)
            </div>

            <div class="table-wrap">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Supplier</th>
                            <th>Current Stock</th>
                            <th>Avg Daily Sales</th>
                            <th>Lead Time</th>
                            <th>Safety Stock</th>
                            <th>ROP</th>
                            <th>Status</th>
                            <th>Suggested Qty</th>
                            <th style="width:220px;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty rows}">
                                <tr>
                                    <td colspan="10"><div class="empty-state">No low stock products found.</div></td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="item" items="${rows}">
                                    <tr>
                                        <td>
                                            <div><b>${item.productName}</b></div>
                                            <div class="small">${item.productCode}</div>
                                        </td>
                                        <td>${item.supplierName}</td>
                                        <td>${item.currentStock}</td>
                                        <td>${item.avgDailySales}</td>
                                        <td>${item.leadTimeDays}</td>
                                        <td>${item.safetyStock}</td>
                                        <td>${item.rop}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${item.ropStatus == 'Out Of Stock'}">
                                                    <span class="badge badge-danger">Out Of Stock</span>
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
                                        <td><b>${item.suggestedReorderQty}</b></td>
                                        <td>
                                            <div style="display:flex; gap:8px; flex-wrap:wrap;">
                                                <a class="btn btn-sm"
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
                                                        <span class="btn btn-sm paging-btn disabled">Requested</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="btn btn-sm paging-btn disabled">Create Request</span>
                                                    </c:otherwise>
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
                <div class="paging-footer">
                    <div class="paging-info">Page <b>${page}</b> of <b>${totalPages}</b></div>

                    <div class="paging">
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
                                <a class="paging-btn" href="${prevUrl}">Prev</a>
                            </c:when>
                            <c:otherwise>
                                <span class="paging-btn disabled">Prev</span>
                            </c:otherwise>
                        </c:choose>

                        <c:set var="pgStart" value="${page - 2 > 1 ? page - 2 : 1}"/>
                        <c:set var="pgEnd" value="${page + 2 < totalPages ? page + 2 : totalPages}"/>

                        <c:if test="${pgStart > 1}">
                            <c:url var="firstUrl" value="/home">
                                <c:param name="p" value="low-stock-report"/>
                                <c:param name="page" value="1"/>
                                <c:param name="q" value="${q}"/>
                                <c:param name="supplierId" value="${supplierId}"/>
                                <c:param name="ropStatus" value="${ropStatus}"/>
                                <c:param name="minStock" value="${minStock}"/>
                                <c:param name="maxStock" value="${maxStock}"/>
                            </c:url>
                            <a class="paging-btn" href="${firstUrl}">1</a>
                            <c:if test="${pgStart > 2}">
                                <span class="paging-ellipsis">&hellip;</span>
                            </c:if>
                        </c:if>

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
                                    <span class="paging-btn active">${pg}</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="paging-btn" href="${pageUrl}">${pg}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:if test="${pgEnd < totalPages}">
                            <c:if test="${pgEnd < totalPages - 1}">
                                <span class="paging-ellipsis">&hellip;</span>
                            </c:if>
                            <c:url var="lastUrl" value="/home">
                                <c:param name="p" value="low-stock-report"/>
                                <c:param name="page" value="${totalPages}"/>
                                <c:param name="q" value="${q}"/>
                                <c:param name="supplierId" value="${supplierId}"/>
                                <c:param name="ropStatus" value="${ropStatus}"/>
                                <c:param name="minStock" value="${minStock}"/>
                                <c:param name="maxStock" value="${maxStock}"/>
                            </c:url>
                            <a class="paging-btn" href="${lastUrl}">${totalPages}</a>
                        </c:if>

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
                                <a class="paging-btn" href="${nextUrl}">Next</a>
                            </c:when>
                            <c:otherwise>
                                <span class="paging-btn disabled">Next</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>
