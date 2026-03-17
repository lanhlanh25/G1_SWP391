<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<div class="page-wrap">
    <div class="topbar">
        <div>
            <div class="title">Stock Movement History</div>
            <div class="small">View confirmed import/export stock movements by product</div>
        </div>
    </div>

    <c:if test="${not empty err}">
        <div class="msg-err">${err}</div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <div class="h2">Filters</div>
        </div>

        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/home">
                <input type="hidden" name="p" value="stock-movement-history"/>

                <div class="filters" style="grid-template-columns: 1.2fr 1fr 1fr 1fr 1fr 1fr auto auto;">
                    <div>
                        <label>Keyword</label>
                        <input type="text"
                               name="keyword"
                               value="${keyword}"
                               class="input"
                               placeholder="Product code or product name">
                    </div>

                    <div>
                        <label>From Date</label>
                        <input type="date"
                               name="from"
                               value="${from}"
                               class="input">
                    </div>

                    <div>
                        <label>To Date</label>
                        <input type="date"
                               name="to"
                               value="${to}"
                               class="input">
                    </div>

                    <div>
                        <label>Movement Type</label>
                        <select name="movementType" class="select">
                            <option value="ALL" ${movementType eq 'ALL' ? 'selected' : ''}>All</option>
                            <option value="IMPORT" ${movementType eq 'IMPORT' ? 'selected' : ''}>Import</option>
                            <option value="EXPORT" ${movementType eq 'EXPORT' ? 'selected' : ''}>Export</option>
                        </select>
                    </div>

                    <div>
                        <label>Reference Code</label>
                        <input type="text"
                               name="referenceCode"
                               value="${referenceCode}"
                               class="input"
                               placeholder="IR / ER code">
                    </div>

                    <div>
                        <label>Performed By</label>
                        <input type="text"
                               name="performedBy"
                               value="${performedBy}"
                               class="input"
                               placeholder="User full name">
                    </div>

                    <div>
                        <label>&nbsp;</label>
                        <button type="submit" class="btn btn-primary">Apply</button>
                    </div>

                    <div>
                        <label>&nbsp;</label>
                        <a href="${pageContext.request.contextPath}/home?p=stock-movement-history"
                           class="btn btn-outline">Reset</a>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div style="height: 16px;"></div>

    <div class="card">
        <div class="card-header">
            <div>
                <div class="h2">Movement List</div>
                <div class="small">Total records: <b>${totalItems}</b></div>
            </div>
        </div>

        <div class="card-body">
            <div class="table-wrap">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Date / Time</th>
                            <th>Product Code</th>
                            <th>Product Name</th>
                            <th>Type</th>
                            <th style="text-align:right;">Qty Change</th>
                            <th>Reference Code</th>
                            <th>Performed By</th>
                            <th>Header Note</th>
                            <th>Line Note</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty rows}">
                            <tr>
                                <td colspan="9" style="text-align:center; color:#64748b;">
                                    No stock movement found.
                                </td>
                            </tr>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="r" items="${rows}">
                                <tr>
                                    <td>
                                <fmt:formatDate value="${r.movementTime}" pattern="yyyy-MM-dd HH:mm"/>
                                </td>
                                <td>${r.productCode}</td>
                                <td>${r.productName}</td>
                                <td>
                                <c:choose>
                                    <c:when test="${r.movementType eq 'IMPORT'}">
                                        <span class="badge badge-active">Import</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-inactive">Export</span>
                                    </c:otherwise>
                                </c:choose>
                                </td>
                                <td style="text-align:right; font-weight:700;">
                                <c:choose>
                                    <c:when test="${r.qtyChange gt 0}">
                                        <span style="color:#16a34a;">+${r.qtyChange}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:#dc2626;">${r.qtyChange}</span>
                                    </c:otherwise>
                                </c:choose>
                                </td>
                                <td>
                                <c:choose>
                                    <c:when test="${r.movementType eq 'IMPORT'}">
                                        <a href="${pageContext.request.contextPath}/home?p=import-receipt-detail&id=${r.referenceId}">
                                            ${r.referenceCode}
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/home?p=export-receipt-detail&id=${r.referenceId}">
                                            ${r.referenceCode}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                                </td>
                                <td>${r.performedBy}</td>
                                <td>${r.headerNote}</td>
                                <td>${r.lineNote}</td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="paging">
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
                            <a href="${baseUrl}&page=${page - 1}">Prev</a>
                        </c:when>
                        <c:otherwise>
                            <span class="paging-btn disabled">Prev</span>
                        </c:otherwise>
                    </c:choose>

                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:choose>
                            <c:when test="${i == page}">
                                <b>${i}</b>
                            </c:when>
                            <c:otherwise>
                                <a href="${baseUrl}&page=${i}">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <c:choose>
                        <c:when test="${page < totalPages}">
                            <a href="${baseUrl}&page=${page + 1}">Next</a>
                        </c:when>
                        <c:otherwise>
                            <span class="paging-btn disabled">Next</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
    </div>
</div>