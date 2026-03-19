<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<div class="page-wrap">
    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Stock Movement History</h1>
            <span class="text-muted fs-14 mt-4">View confirmed stock movements</span>
        </div>
        <div class="d-flex gap-8 align-center">
            <a href="${pageContext.request.contextPath}/home?p=dashboard" class="btn btn-outline btn-sm">← Dashboard</a>
        </div>
    </div>

    <c:if test="${not empty err}">
        <div class="msg-err">${err}</div>
    </c:if>

    <div class="card mb-16">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/home" class="filters grid-5">
                <input type="hidden" name="p" value="stock-movement-history"/>

                <div class="filter-group">
                    <label>Search Keyword</label>
                    <input type="text" name="keyword" value="${keyword}" class="input" placeholder="Product name or code">
                </div>

                <div class="filter-group">
                    <label>From Date</label>
                    <input type="date" name="from" value="${from}" class="input">
                </div>

                <div class="filter-group">
                    <label>To Date</label>
                    <input type="date" name="to" value="${to}" class="input">
                </div>

                <div class="filter-group">
                    <label>Type</label>
                    <select name="movementType" class="select">
                        <option value="ALL" ${movementType eq 'ALL' ? 'selected' : ''}>All Types</option>
                        <option value="IMPORT" ${movementType eq 'IMPORT' ? 'selected' : ''}>Import</option>
                        <option value="EXPORT" ${movementType eq 'EXPORT' ? 'selected' : ''}>Export</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label>Ref Code</label>
                    <input type="text" name="referenceCode" value="${referenceCode}" class="input" placeholder="IR... / ER...">
                </div>

                <div class="filter-actions d-flex gap-8">
                    <button type="submit" class="btn btn-primary">Apply</button>
                    <a href="${pageContext.request.contextPath}/home?p=stock-movement-history" class="btn btn-outline">Reset</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card list-card">
        <div class="card-header">
            <div class="h2">Movement List</div>
            <div class="paging-info">
               Showing <b>${totalItems == 0 ? 0 : (page - 1) * pageSize + 1}</b>–<b>${page * pageSize < totalItems ? page * pageSize : totalItems}</b> of <b>${totalItems}</b>
            </div>
        </div>
        <div class="card-body p-0">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width:140px;">Date / Time</th>
                        <th style="width:125px;">Product Code</th>
                        <th>Product Name</th>
                        <th style="width:100px;" class="text-center">Type</th>
                        <th style="width:80px;" class="text-center">Qty</th>
                        <th style="width:130px;">Ref Code</th>
                        <th style="width:140px;">In Charge</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty rows}">
                            <tr>
                                <td colspan="7" class="empty-state">
                                    No stock movement found.
                                </td>
                            </tr>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="r" items="${rows}">
                                <tr>
                                    <td class="text-muted fs-12">
                                        <fmt:formatDate value="${r.movementTime}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td class="mono-text fs-12 text-primary">${r.productCode}</td>
                                    <td class="fw-700">${r.productName}</td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${r.movementType eq 'IMPORT'}">
                                                <span class="badge badge-active">Import</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-info">Export</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center fw-700">
                                        <c:choose>
                                            <c:when test="${r.qtyChange gt 0}">
                                                <span class="text-success">+${r.qtyChange}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-warning">${r.qtyChange}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="mono-text fs-12">
                                        <c:choose>
                                            <c:when test="${r.movementType eq 'IMPORT'}">
                                                <a class="text-primary text-underline" href="${pageContext.request.contextPath}/home?p=import-receipt-detail&id=${r.referenceId}">
                                                    ${r.referenceCode}
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="text-primary text-underline" href="${pageContext.request.contextPath}/home?p=export-receipt-detail&id=${r.referenceId}">
                                                    ${r.referenceCode}
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="fs-12 text-muted fw-600">${r.performedBy}</td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <c:if test="${totalPages > 1}">
            <div class="paging-footer p-16 border-t">
                <div class="paging-info text-muted">
                    Page <b>${page}</b> of <b>${totalPages}</b>
                </div>

                <div class="paging d-flex gap-4">
                    <c:url var="baseUrl" value="/home">
                        <c:param name="p" value="stock-movement-history"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="from" value="${from}"/>
                        <c:param name="to" value="${to}"/>
                        <c:param name="movementType" value="${movementType}"/>
                        <c:param name="referenceCode" value="${referenceCode}"/>
                        <c:param name="performedBy" value="${performedBy}"/>
                    </c:url>

                    <c:choose>
                        <c:when test="${page > 1}">
                            <a class="btn btn-sm btn-outline" href="${baseUrl}&page=${page - 1}">Prev</a>
                        </c:when>
                        <c:otherwise>
                            <span class="btn btn-sm btn-outline disabled">Prev</span>
                        </c:otherwise>
                    </c:choose>

                    <c:set var="pgStart" value="${page - 1 < 1 ? 1 : page - 1}" />
                    <c:set var="pgEnd" value="${pgStart + 2 > totalPages ? totalPages : pgStart + 2}" />
                    <c:if test="${pgEnd == totalPages}">
                        <c:set var="pgStart" value="${pgEnd - 2 < 1 ? 1 : pgEnd - 2}" />
                    </c:if>

                    <c:forEach begin="${pgStart}" end="${pgEnd}" var="i">
                        <c:choose>
                            <c:when test="${i == page}">
                                <span class="btn btn-sm btn-primary active">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a class="btn btn-sm btn-outline" href="${baseUrl}&page=${i}">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <c:choose>
                        <c:when test="${page < totalPages}">
                            <a class="btn btn-sm btn-outline" href="${baseUrl}&page=${page + 1}">Next</a>
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