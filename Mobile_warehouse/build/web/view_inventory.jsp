<%-- 
    Document   : view_inventory
    Created on : Jan 27, 2026, 12:39:12 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>View Inventory</title>
    <style>
        :root{
            --blue:#2f6fb1;
            --blue2:#3b7ec7;
            --border:#1d4f8b;
            --bg:#f7f7f7;
            --gray:#e9e9e9;
        }
        body{
            margin:0;
            font-family: Arial, Helvetica, sans-serif;
            background:#ffffff;
            color:#111;
        }
        .page{
            padding:14px 18px 24px;
        }

        /* Top bar */
        .topbar{
            display:flex;
            align-items:center;
            gap:14px;
            margin-bottom:10px;
        }
        .btn-back{
            border:1px solid #333;
            background:#d9d9d9;
            padding:6px 14px;
            border-radius:2px;
            cursor:pointer;
            font-weight:600;
        }
        .title{
            font-size:18px;
            font-weight:700;
        }

        /* Summary cards */
        .cards{
            display:flex;
            gap:18px;
            margin:10px 0 16px;
            flex-wrap:wrap;
        }
        .card{
            width:210px;
            background:var(--blue2);
            color:#fff;
            border:2px solid var(--border);
            padding:10px 12px;
            box-sizing:border-box;
        }
        .card .label{
            font-weight:700;
            font-size:14px;
            margin-bottom:8px;
        }
        .card .value{
            font-size:16px;
            font-weight:700;
        }

        /* Search box */
        .panel{
            border:2px solid var(--border);
            padding:12px;
            margin-bottom:16px;
        }
        .panel-title{
            font-weight:700;
            margin-bottom:10px;
        }
        .search-row{
            display:grid;
            grid-template-columns: 320px 180px 160px 180px 90px 90px;
            gap:12px;
            align-items:center;
        }
        .search-row input[type="text"], .search-row select{
            height:34px;
            border:1px solid #999;
            padding:0 10px;
            outline:none;
            background:#fff;
        }
        .btn{
            height:34px;
            border:1px solid #333;
            background:#d9d9d9;
            cursor:pointer;
            font-weight:700;
        }

        /* Table */
        .table-wrap{
            border:2px solid var(--border);
        }
        table{
            width:100%;
            border-collapse:collapse;
            table-layout:fixed;
        }
        thead th{
            background:#d9d9d9;
            border-bottom:2px solid var(--border);
            border-right:2px solid var(--border);
            padding:10px 8px;
            text-align:center;
            font-weight:800;
        }
        thead th:last-child{ border-right:none; }

        tbody td{
            border-top:2px solid var(--border);
            border-right:2px solid var(--border);
            padding:10px 8px;
            height:42px;
            vertical-align:middle;
            background:#fff;
            overflow:hidden;
            text-overflow:ellipsis;
            white-space:nowrap;
        }
        tbody td:last-child{ border-right:none; }

        .col-code{ width:140px; }
        .col-name{ width:260px; }
        .col-brand{ width:160px; }
        .col-qty{ width:160px; text-align:center; }
        .col-status{ width:150px; text-align:center; }
        .col-updated{ width:160px; text-align:center; }

        .product-link{
            color:#0b55d6;
            text-decoration:underline;
            font-weight:700;
        }

        .badge{
            display:inline-block;
            min-width:90px;
            padding:6px 10px;
            border:2px solid #333;
            font-weight:900;
            font-size:12px;
            border-radius:2px;
            text-align:center;
        }
        .ok{ background:#2bdc2b; }
        .low{ background:#ffe44d; }
        .out{ background:#ff4040; color:#000; }

        /* Pagination bar */
        .pager{
            display:flex;
            align-items:center;
            justify-content:space-between;
            padding:12px;
            border-top:2px solid var(--border);
            background:#fff;
        }
        .pager-left{
            font-weight:700;
        }
        .pager-mid{
            display:flex;
            align-items:center;
            gap:10px;
        }
        .pager-mid .nav{
            width:34px;
            height:30px;
            border:2px solid var(--border);
            background:#d9d9d9;
            cursor:pointer;
            font-weight:900;
        }
        .pager-mid .page{
            padding:6px 12px;
            border:1px solid #bbb;
            background:#fff;
        }
        .pager-right{
            display:flex;
            align-items:center;
            gap:10px;
            font-weight:700;
        }
        .rows-select{
            height:30px;
            border:1px solid #999;
        }

        /* small note */
        .hint{
            margin-top:10px;
            font-size:12px;
            color:#666;
        }
    </style>
</head>
<body>
<div class="page">

    <!-- Top bar -->
    <div class="topbar">
       <a class="btn-back" href="${pageContext.request.contextPath}/home?p=dashboard">Back</a>

        <div class="title">Inventory Management</div>
    </div>

    <!-- Summary cards -->
    <div class="cards">
        <div class="card">
            <div class="label">Total SKUs</div>
            <div class="value">
                <c:out value="${totalSkus != null ? totalSkus : 0}"/>
            </div>
        </div>
        <div class="card">
            <div class="label">Total Units<br/>On Hand</div>
            <div class="value">
                <c:out value="${totalUnitsOnHand != null ? totalUnitsOnHand : 0}"/>
            </div>
        </div>
        <div class="card">
            <div class="label">Low Stock Items</div>
            <div class="value">
                <c:out value="${lowStockItems != null ? lowStockItems : 0}"/>
            </div>
        </div>
        <div class="card">
            <div class="label">Out of Stock Items</div>
            <div class="value">
                <c:out value="${outOfStockItems != null ? outOfStockItems : 0}"/>
            </div>
        </div>
    </div>

    <!-- Search Criteria -->
    <div class="panel">
        <div class="panel-title">Search Criteria</div>

        <form method="get" action="${pageContext.request.contextPath}/home">
            <!-- giữ đúng flow của bạn: /home?p=inventory -->
            <input type="hidden" name="p" value="inventory"/>

            <div class="search-row">
                <input type="text" name="q"
                       placeholder="Product name, SKU,..."
                       value="${param.q != null ? param.q : ''}"/>

                <select name="categoryId">
                    <option value="">All Categories</option>
                    <c:forEach items="${categories}" var="c">
                        <option value="${c.id}" <c:if test="${param.categoryId == c.id}">selected</c:if>>
                            <c:out value="${c.name}"/>
                        </option>
                    </c:forEach>
                </select>

                <select name="brandId">
                    <option value="">All Brands</option>
                    <c:forEach items="${brands}" var="b">
                        <option value="${b.id}" <c:if test="${param.brandId == b.id}">selected</c:if>>
                            <c:out value="${b.name}"/>
                        </option>
                    </c:forEach>
                </select>

                <select name="stockStatus">
                    <option value="">Stock Status</option>
                    <option value="OK" <c:if test="${param.stockStatus == 'OK'}">selected</c:if>>OK</option>
                    <option value="LOW" <c:if test="${param.stockStatus == 'LOW'}">selected</c:if>>Low Stock</option>
                    <option value="OUT" <c:if test="${param.stockStatus == 'OUT'}">selected</c:if>>Out Of Stock</option>
                </select>

                <button type="submit" class="btn">Search</button>
                <a class="btn" style="display:inline-flex;align-items:center;justify-content:center;text-decoration:none;color:#000;"
                   href="${pageContext.request.contextPath}/home?p=inventory">Reset</a>
            </div>
        </form>
    </div>

    <!-- Table -->
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th class="col-code">Product Code</th>
                <th class="col-name">Product Name</th>
                <th class="col-brand">Brand</th>
                <th class="col-qty">Quantity</th>
                <th class="col-status">Status</th>
                <th class="col-updated">Last Updated</th>
            </tr>
            </thead>

            <tbody>
            <c:choose>
                <c:when test="${empty inventoryModels}">
                    <tr>
                        <td colspan="6" style="text-align:center; font-weight:700; color:#666;">
                            No data found.
                        </td>
                    </tr>
                </c:when>

                <c:otherwise>
                    <c:forEach items="${inventoryModels}" var="m">
                        <tr>
                            <td class="col-code"><c:out value="${m.productCode}"/></td>

                            <!-- Click name -> Inventory Detail page -->
                            <td class="col-name">
                                <a class="product-link"
                                   href="${pageContext.request.contextPath}/home?p=inventory-detail&productCode=${m.productCode}">
                                    <c:out value="${m.productName}"/>
                                </a>
                            </td>

                            <td class="col-brand"><c:out value="${m.brandName}"/></td>

                            <!-- Quantity is total units across SKUs/IMEIs under this model -->
                            <td class="col-qty">
                                <c:out value="${m.totalQty}"/>
                            </td>

                            <td class="col-status">
                                <c:choose>
                                    <c:when test="${m.status == 'OK'}">
                                        <span class="badge ok">OK</span>
                                    </c:when>
                                    <c:when test="${m.status == 'LOW'}">
                                        <span class="badge low">Low Stock</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge out">Out Of Stock</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <td class="col-updated">
                                <c:out value="${m.lastUpdated}"/>
                                <%-- nếu bạn có kiểu Date, có thể format:
                                <fmt:formatDate value="${m.lastUpdated}" pattern="yyyy-MM-dd"/>
                                --%>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>

        <!-- Pagination (mô phỏng giống ảnh) -->
        <div class="pager">
            <div class="pager-left">
                Page <c:out value="${pageNumber != null ? pageNumber : 1}"/>
            </div>

            <div class="pager-mid">
                <form method="get" action="${pageContext.request.contextPath}/home" style="display:flex; gap:10px; align-items:center;">
                    <input type="hidden" name="p" value="inventory"/>
                    <input type="hidden" name="q" value="${param.q}"/>
                    <input type="hidden" name="categoryId" value="${param.categoryId}"/>
                    <input type="hidden" name="brandId" value="${param.brandId}"/>
                    <input type="hidden" name="stockStatus" value="${param.stockStatus}"/>
                    <input type="hidden" name="pageSize" value="${pageSize != null ? pageSize : 10}"/>

                    <button class="nav" type="submit" name="page" value="${(pageNumber != null && pageNumber > 1) ? (pageNumber-1) : 1}">&lt;</button>

                    <span class="page"><c:out value="${pageNumber != null ? pageNumber : 1}"/></span>

                    <button class="nav" type="submit" name="page" value="${(pageNumber != null) ? (pageNumber+1) : 2}">&gt;</button>
                </form>
            </div>

            <div class="pager-right">
                Show
                <form method="get" action="${pageContext.request.contextPath}/home" style="display:inline-flex; gap:8px; align-items:center;">
                    <input type="hidden" name="p" value="inventory"/>
                    <input type="hidden" name="q" value="${param.q}"/>
                    <input type="hidden" name="categoryId" value="${param.categoryId}"/>
                    <input type="hidden" name="brandId" value="${param.brandId}"/>
                    <input type="hidden" name="stockStatus" value="${param.stockStatus}"/>
                    <input type="hidden" name="page" value="${pageNumber != null ? pageNumber : 1}"/>

                    <select class="rows-select" name="pageSize" onchange="this.form.submit()">
                        <option value="10" <c:if test="${pageSize == 10}">selected</c:if>>10 Row</option>
                        <option value="20" <c:if test="${pageSize == 20}">selected</c:if>>20 Row</option>
                        <option value="50" <c:if test="${pageSize == 50}">selected</c:if>>50 Row</option>
                    </select>
                </form>
            </div>
        </div>
    </div>

    <div class="hint">
        Note: Quantity is aggregated by Product Code (model). Click the Product Name to view SKU variants (Color/RAM/Storage) and IMEI-level details.
    </div>

</div>
</body>
</html>
