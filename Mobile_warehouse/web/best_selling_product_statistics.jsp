<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="page-wrap">
    <div class="topbar">
        <div>
            <div class="title">View Best-selling Product Statistics</div>
            <div class="small">Manager can view the products with the highest exported quantity in a selected reporting period.</div>
        </div>
        <div>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=dashboard">Back</a>
        </div>
    </div>

    <c:if test="${not empty msg}">
        <div class="msg-ok">${msg}</div>
    </c:if>
    <c:if test="${not empty err}">
        <div class="msg-err">${err}</div>
    </c:if>

    <div class="stat-cards" style="margin-bottom:16px;">
        <div class="card stat-card-item">
            <div class="small">Best Product</div>
            <div class="stat-value">
                <c:choose>
                    <c:when test="${bestProduct != null}">
                        ${bestProduct.productName}
                    </c:when>
                    <c:otherwise>—</c:otherwise>
                </c:choose>
            </div>
            <div class="small">
                Units:
                <c:choose>
                    <c:when test="${bestProduct != null}">
                        ${bestProduct.unitsSold}
                    </c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="card stat-card-item">
            <div class="small">Total Units Sold</div>
            <div class="stat-value">${totalUnitsSold}</div>
            <div class="small">${fromDate} → ${toDate}</div>
        </div>
    </div>

    <div class="card" style="margin-bottom:16px;">
        <div class="card-header">
            <h2 class="h2">Filters</h2>
        </div>
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/home">
                <input type="hidden" name="p" value="best-selling-product-statistics"/>

                <div class="filters" style="grid-template-columns: 1.2fr 1fr 1fr 1fr 1fr auto auto;">
                    <div>
                        <label>Period Type</label>
                        <select class="select" name="periodType" id="periodType" onchange="togglePeriodFields()">
                            <option value="week" ${periodType == 'week' ? 'selected' : ''}>Week</option>
                            <option value="month" ${periodType == 'month' ? 'selected' : ''}>Month</option>
                            <option value="quarter" ${periodType == 'quarter' ? 'selected' : ''}>Quarter</option>
                            <option value="year" ${periodType == 'year' ? 'selected' : ''}>Year</option>
                            <option value="custom" ${periodType == 'custom' ? 'selected' : ''}>Custom Range</option>
                        </select>
                    </div>

                    <div id="yearGroup">
                        <label>Year</label>
                        <input class="input" type="number" name="year" min="2000" max="2100"
                               value="${not empty param.year ? param.year : fromDate.year}">
                    </div>

                    <div id="weekGroup">
                        <label>Week</label>
                        <select class="select" name="week">
                            <c:forEach begin="1" end="53" var="w">
                                <option value="${w}" ${param.week == w.toString() ? 'selected' : ''}>Week ${w}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div id="monthGroup">
                        <label>Month</label>
                        <select class="select" name="month">
                            <c:forEach begin="1" end="12" var="m">
                                <option value="${m}" ${param.month == m.toString() ? 'selected' : ''}>${m}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div id="quarterGroup">
                        <label>Quarter</label>
                        <select class="select" name="quarter">
                            <option value="1" ${param.quarter == '1' ? 'selected' : ''}>Q1</option>
                            <option value="2" ${param.quarter == '2' ? 'selected' : ''}>Q2</option>
                            <option value="3" ${param.quarter == '3' ? 'selected' : ''}>Q3</option>
                            <option value="4" ${param.quarter == '4' ? 'selected' : ''}>Q4</option>
                        </select>
                    </div>

                    <div id="fromGroup">
                        <label>From Date</label>
                        <input class="input" type="date" name="from" value="${param.from}">
                    </div>

                    <div id="toGroup">
                        <label>To Date</label>
                        <input class="input" type="date" name="to" value="${param.to}">
                    </div>

                    <div>
                        <label>Top N</label>
                        <select class="select" name="topN">
                            <option value="10" ${topN == 10 ? 'selected' : ''}>10</option>
                            <option value="20" ${topN == 20 ? 'selected' : ''}>20</option>
                            <option value="50" ${topN == 50 ? 'selected' : ''}>50</option>
                            <option value="100" ${topN == 100 ? 'selected' : ''}>100</option>
                        </select>
                    </div>

                    <div>
                        <label>Sort Order</label>
                        <select class="select" name="sortOrder">
                            <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>Desc</option>
                            <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>Asc</option>
                        </select>
                    </div>

                    <div>
                        <label>&nbsp;</label>
                        <button type="submit" class="btn btn-primary">Apply</button>
                    </div>

                    <div>
                        <label>&nbsp;</label>
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=best-selling-product-statistics">Reset</a>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <h2 class="h2">Best-selling Product List</h2>
            <div class="small">Sorted by units sold in selected period</div>
        </div>
        <div class="card-body">
            <div class="table-wrap">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width:60px;">#</th>
                            <th>Product Code</th>
                            <th>Product Name</th>
                            <th>Brand</th>
                            <th style="width:140px;">Units Sold</th>
                            <th style="width:180px;">Last Sold</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty stats}">
                                <c:forEach items="${stats}" var="item" varStatus="loop">
                                    <tr>
                                        <td>${loop.index + 1}</td>
                                        <td>${item.productCode}</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/home?p=product-detail&id=${item.productId}">
                                                ${item.productName}
                                            </a>
                                        </td>
                                        <td>
                                            <c:out value="${empty item.brandName ? '—' : item.brandName}"/>
                                        </td>
                                        <td>${item.unitsSold}</td>
                                        <td>
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
                                    <td colspan="6" class="empty-state">No data found for the selected period.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
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

    togglePeriodFields();
</script>