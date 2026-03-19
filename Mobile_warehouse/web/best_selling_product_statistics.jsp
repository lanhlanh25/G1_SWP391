<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="page-wrap">
    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <div>
                <h1 class="h1">Best-selling Products</h1>
                <div class="text-muted fs-13">Ranked by export quantity in selected reporting period</div>
            </div>
        </div>
        <div class="d-flex gap-8 align-center">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=dashboard">← Dashboard</a>
        </div>
    </div>

    <c:if test="${not empty msg}">
        <div class="msg-ok mb-16">${msg}</div>
    </c:if>
    <c:if test="${not empty err}">
        <div class="msg-err mb-16">${err}</div>
    </c:if>

    <!-- Stats -->
    <div class="grid-12 gap-16 mb-16">
        <div class="col-8">
            <div class="card p-20 d-flex justify-between align-center h-full">
                <div>
                    <div class="muted fs-12 uppercase mb-4 text-primary">👑 Top Performer</div>
                    <div class="h2 m-0">
                        <c:choose>
                            <c:when test="${bestProduct != null}">
                                ${bestProduct.productName}
                            </c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="fs-10 text-muted mt-4">Units Sold: <b>${not empty bestProduct ? bestProduct.unitsSold : 0}</b></div>
                </div>
            </div>
        </div>

        <div class="col-4">
            <div class="card p-20 d-flex justify-between align-center h-full">
                <div>
                    <div class="muted fs-12 uppercase mb-4">Cumulative Sales</div>
                    <div class="h2 m-0 text-primary">${totalUnitsSold}</div>
                    <div class="fs-10 text-muted mt-4">${fromDate} → ${toDate}</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="card mb-16">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/home">
                <input type="hidden" name="p" value="best-selling-product-statistics"/>

                <div class="grid-12 gap-16 align-end">
                    <div class="col-2">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Period Type</label>
                        <select class="select" name="periodType" id="periodType" onchange="togglePeriodFields()">
                            <option value="week" ${periodType == 'week' ? 'selected' : ''}>Week</option>
                            <option value="month" ${periodType == 'month' ? 'selected' : ''}>Month</option>
                            <option value="quarter" ${periodType == 'quarter' ? 'selected' : ''}>Quarter</option>
                            <option value="year" ${periodType == 'year' ? 'selected' : ''}>Year</option>
                            <option value="custom" ${periodType == 'custom' ? 'selected' : ''}>Custom Range</option>
                        </select>
                    </div>

                    <div class="col-2" id="yearGroup">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Year</label>
                        <input class="input" type="number" name="year" min="2000" max="2100"
                               value="${not empty param.year ? param.year : fromDate.year}">
                    </div>

                    <div class="col-2" id="weekGroup">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Week</label>
                        <select class="select" name="week">
                            <c:forEach begin="1" end="53" var="w">
                                <option value="${w}" ${param.week == w.toString() ? 'selected' : ''}>Week ${w}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-2" id="monthGroup">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Month</label>
                        <select class="select" name="month">
                            <c:forEach begin="1" end="12" var="m">
                                <option value="${m}" ${param.month == m.toString() ? 'selected' : ''}>Month ${m}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-2" id="quarterGroup">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Quarter</label>
                        <select class="select" name="quarter">
                            <option value="1" ${param.quarter == '1' ? 'selected' : ''}>Q1</option>
                            <option value="2" ${param.quarter == '2' ? 'selected' : ''}>Q2</option>
                            <option value="3" ${param.quarter == '3' ? 'selected' : ''}>Q3</option>
                            <option value="4" ${param.quarter == '4' ? 'selected' : ''}>Q4</option>
                        </select>
                    </div>

                    <div class="col-2" id="fromGroup">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">From Date</label>
                        <input class="input" type="date" name="from" value="${param.from}">
                    </div>

                    <div class="col-2" id="toGroup">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">To Date</label>
                        <input class="input" type="date" name="to" value="${param.to}">
                    </div>

                    <div class="col-1">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Top N</label>
                        <select class="select" name="topN">
                            <option value="10" ${topN == 10 ? 'selected' : ''}>10</option>
                            <option value="20" ${topN == 20 ? 'selected' : ''}>20</option>
                            <option value="50" ${topN == 50 ? 'selected' : ''}>50</option>
                            <option value="100" ${topN == 100 ? 'selected' : ''}>100</option>
                        </select>
                    </div>

                    <div class="col-1">
                        <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Sort</label>
                        <select class="select" name="sortOrder">
                            <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>Desc</option>
                            <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>Asc</option>
                        </select>
                    </div>

                    <div class="col-4 d-flex gap-8">
                        <button type="submit" class="btn btn-primary">Apply</button>
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=best-selling-product-statistics">Reset</a>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="d-flex justify-between align-center mb-16">
                <div class="h2">Sales Rankings</div>
                <div class="text-muted fs-14">Showing top <b>${topN}</b> products</div>
            </div>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width:60px;">#</th>
                        <th>Product Info</th>
                        <th>Brand</th>
                        <th class="text-center" style="width:140px;">Units Sold</th>
                        <th class="text-right" style="width:180px;">Last Export Date</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty stats}">
                            <c:forEach items="${stats}" var="item" varStatus="loop">
                                <tr>
                                    <td class="text-muted fs-13">${loop.index + 1}</td>
                                    <td>
                                        <div class="d-flex flex-column">
                                            <a class="fw-600 text-primary" href="${pageContext.request.contextPath}/home?p=product-detail&id=${item.productId}">
                                                ${item.productName}
                                            </a>
                                            <span class="mono-text fs-11 text-muted">${item.productCode}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <c:out value="${empty item.brandName ? '—' : item.brandName}"/>
                                    </td>
                                    <td class="text-center fw-700 text-primary">${item.unitsSold}</td>
                                    <td class="text-right text-muted fs-13">
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
                                <td colspan="5">
                                    <div class="p-40 text-center text-muted">No sales data found for this period.</div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
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