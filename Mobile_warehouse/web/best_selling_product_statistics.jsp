<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- Breadcrumb --%>
<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Reports /</span> Best-selling Products
</h4>

<%-- Alerts --%>
<c:if test="${not empty msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        ${msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        ${err}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<!-- Summary Cards -->
<div class="row mb-4">
    <div class="col-md-8">
        <div class="card h-100">
            <div class="card-body d-flex align-items-center">
                <div class="avatar flex-shrink-0 me-3">
                    <span class="avatar-initial rounded bg-label-primary"><i class="bx bx-trophy"></i></span>
                </div>
                <div>
                    <span class="d-block mb-1 text-muted">👑 Top Performer</span>
                    <h4 class="card-title mb-0">
                        <c:choose>
                            <c:when test="${bestProduct != null}">
                                ${bestProduct.productName}
                            </c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </h4>
                    <small class="text-muted">Units Sold: <strong>${not empty bestProduct ? bestProduct.unitsSold : 0}</strong></small>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card h-100">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-start">
                    <div class="avatar flex-shrink-0">
                        <span class="avatar-initial rounded bg-label-info"><i class="bx bx-pulse"></i></span>
                    </div>
                </div>
                <div class="mt-3">
                    <span class="d-block mb-1 text-muted">Cumulative Sales</span>
                    <h4 class="card-title mb-1">${totalUnitsSold}</h4>
                    <small class="text-muted">${fromDate} → ${toDate}</small>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Filter Card -->
<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${pageContext.request.contextPath}/home">
            <input type="hidden" name="p" value="best-selling-product-statistics"/>
            
            <div class="row g-3 align-items-end">
                <div class="col-md-2">
                    <label class="form-label" for="periodType">Period Type</label>
                    <select class="form-select" name="periodType" id="periodType" onchange="togglePeriodFields()">
                        <option value="week" ${periodType == 'week' ? 'selected' : ''}>Week</option>
                        <option value="month" ${periodType == 'month' ? 'selected' : ''}>Month</option>
                        <option value="quarter" ${periodType == 'quarter' ? 'selected' : ''}>Quarter</option>
                        <option value="year" ${periodType == 'year' ? 'selected' : ''}>Year</option>
                        <option value="custom" ${periodType == 'custom' ? 'selected' : ''}>Custom Range</option>
                    </select>
                </div>

                <div class="col-md-2" id="yearGroup">
                    <label class="form-label">Year</label>
                    <input class="form-control" type="number" name="year" min="2000" max="2100"
                           value="${not empty param.year ? param.year : fromDate.year}">
                </div>

                <div class="col-md-2" id="weekGroup">
                    <label class="form-label">Week</label>
                    <select class="form-select" name="week">
                        <c:forEach begin="1" end="53" var="w">
                            <option value="${w}" ${param.week == w.toString() ? 'selected' : ''}>Week ${w}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-2" id="monthGroup">
                    <label class="form-label">Month</label>
                    <select class="form-select" name="month">
                        <c:forEach begin="1" end="12" var="m">
                            <option value="${m}" ${param.month == m.toString() ? 'selected' : ''}>Month ${m}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-2" id="quarterGroup">
                    <label class="form-label">Quarter</label>
                    <select class="form-select" name="quarter">
                        <option value="1" ${param.quarter == '1' ? 'selected' : ''}>Q1</option>
                        <option value="2" ${param.quarter == '2' ? 'selected' : ''}>Q2</option>
                        <option value="3" ${param.quarter == '3' ? 'selected' : ''}>Q3</option>
                        <option value="4" ${param.quarter == '4' ? 'selected' : ''}>Q4</option>
                    </select>
                </div>

                <div class="col-md-2" id="fromGroup">
                    <label class="form-label">From Date</label>
                    <input class="form-control" type="date" name="from" value="${param.from}">
                </div>

                <div class="col-md-2" id="toGroup">
                    <label class="form-label">To Date</label>
                    <input class="form-control" type="date" name="to" value="${param.to}">
                </div>

                <div class="col-md-1">
                    <label class="form-label">Top N</label>
                    <select class="form-select" name="topN">
                        <option value="10" ${topN == 10 ? 'selected' : ''}>10</option>
                        <option value="20" ${topN == 20 ? 'selected' : ''}>20</option>
                        <option value="50" ${topN == 50 ? 'selected' : ''}>50</option>
                        <option value="100" ${topN == 100 ? 'selected' : ''}>100</option>
                    </select>
                </div>

                <div class="col-md-1">
                    <label class="form-label">Sort</label>
                    <select class="form-select" name="sortOrder">
                        <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>Desc</option>
                        <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>Asc</option>
                    </select>
                </div>

                <div class="col-md-2 d-flex gap-2">
                    <button type="submit" class="btn btn-primary w-100">Apply</button>
                    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/home?p=best-selling-product-statistics"><i class="bx bx-refresh"></i></a>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Rankings Table -->
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Sales Rankings</h5>
        <span class="badge bg-label-secondary">Showing top ${topN} products</span>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th style="width: 60px;">#</th>
                    <th>Product Info</th>
                    <th>Brand</th>
                    <th class="text-center">Units Sold</th>
                    <th class="text-end">Last Export Date</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:choose>
                    <c:when test="${not empty stats}">
                        <c:forEach items="${stats}" var="item" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td>
                                    <div class="d-flex flex-column">
                                        <a class="fw-bold" href="${pageContext.request.contextPath}/home?p=product-detail&id=${item.productId}">
                                            ${item.productName}
                                        </a>
                                        <small class="text-muted">${item.productCode}</small>
                                    </div>
                                </td>
                                <td>
                                    <span class="text-muted"><c:out value="${empty item.brandName ? '—' : item.brandName}"/></span>
                                </td>
                                <td class="text-center"><span class="badge bg-label-primary">${item.unitsSold}</span></td>
                                <td class="text-end text-muted">
                                    <c:choose>
                                        <c:when test="${item.lastSold != null}">
                                            <fmt:formatDate value="${item.lastSold}" pattern="yyyy-MM-dd HH:mm"/>
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="5" class="text-center p-5">
                                <i class="bx bx-info-circle fs-2 mb-2 d-block text-muted"></i>
                                No sales data found for this period.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<script>
    function togglePeriodFields() {
        const type = document.getElementById("periodType").value;

        document.getElementById("yearGroup").style.display = "none";
        document.getElementById("weekGroup").style.display = "none";
        document.getElementById("monthGroup").style.display = "none";
        document.getElementById("quarterGroup").style.display = "none";
        document.getElementById("fromGroup").style.display = "none";
        document.getElementById("toGroup").style.display = "none";

        if (type === "week") {
            document.getElementById("yearGroup").style.display = "block";
            document.getElementById("weekGroup").style.display = "block";
        } else if (type === "month") {
            document.getElementById("yearGroup").style.display = "block";
            document.getElementById("monthGroup").style.display = "block";
        } else if (type === "quarter") {
            document.getElementById("yearGroup").style.display = "block";
            document.getElementById("quarterGroup").style.display = "block";
        } else if (type === "year") {
            document.getElementById("yearGroup").style.display = "block";
        } else if (type === "custom") {
            document.getElementById("fromGroup").style.display = "block";
            document.getElementById("toGroup").style.display = "block";
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        togglePeriodFields();
    });
</script>