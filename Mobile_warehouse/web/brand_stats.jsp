<%-- 
    Document   : brand_stats
    Created on : Jan 29, 2026, 12:24:52 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="roleName" value="${sessionScope.roleName}" />

<style>
    .page-wrap{
        padding:16px;
    }
    .topbar{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:12px;
    }
    .title{
        font-size:22px;
        font-weight:700;
    }
    .btn{
        display:inline-block;
        padding:6px 14px;
        border:1px solid #333;
        background:#f6f6f6;
        text-decoration:none;
        color:#111;
        border-radius:3px;
    }
    .btn:hover{
        background:#eee;
    }
    .btn-row{
        display:flex;
        gap:10px;
        align-items:center;
    }
    .cards{
        display:flex;
        gap:18px;
        margin:14px 0 16px;
    }
    .card{
        flex:1;
        border:1px solid #333;
        height:78px;
        display:flex;
        flex-direction:column;
        align-items:center;
        justify-content:center;
    }
    .card .label{
        font-size:13px;
        color:#222;
        margin-bottom:6px;
    }
    .card .value{
        font-size:18px;
        font-weight:700;
    }
    .filters{
        display:grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap:12px 18px;
        align-items:end;
        margin-bottom:10px;
    }
    .filters .field label{
        display:block;
        font-size:12px;
        margin-bottom:4px;
        color:#333;
    }
    .filters .field select, .filters .field input{
        width:100%;
        padding:6px;
        border:1px solid #aaa;
        border-radius:3px;
    }
    .sort-row{
        display:grid;
        grid-template-columns: 2fr 1fr auto auto;
        gap:12px;
        align-items:end;
        margin:10px 0 14px;
    }
    table{
        width:100%;
        border-collapse:collapse;
    }
    th, td{
        border:1px solid #333;
        padding:8px;
        text-align:left;
    }
    th{
        background:#f1f1f1;
    }
    .muted{
        color:#666;
        font-size:12px;
    }
    .paging{
        margin-top:12px;
        display:flex;
        gap:10px;
        justify-content:center;
        align-items:center;
    }
    .paging a{
        padding:4px 10px;
        border:1px solid #ccc;
        text-decoration:none;
        color:#111;
    }
    .paging b{
        padding:4px 10px;
        border:1px solid #333;
    }
    .msg-ok{
        color:green;
        margin:8px 0;
    }
    .msg-err{
        color:red;
        margin:8px 0;
    }
    .badge{
        padding:2px 8px;
        border:1px solid #999;
        border-radius:10px;
        font-size:12px;
        display:inline-block;
    }
    .badge-active{
        border-color:#2e7d32;
        color:#2e7d32;
    }
    .badge-inactive{
        border-color:#777;
        color:#777;
    }
    .row-inactive{
        opacity:0.55;
        font-style:italic;
    }
</style>

<div class="page-wrap">
    <div class="topbar">
        <div class="title">View Product Statistics By Brand</div>

        <div class="btn-row">
            

            <!-- Export: thường chỉ MANAGER thấy (bạn có thể mở cho STAFF nếu muốn) -->
            <c:if test="${roleName == 'MANAGER'}">
                <a class="btn"
                   href="${ctx}/manager/brand-stats-export?q=${fn:escapeXml(q)}&status=${status}&brandId=${brandId}&sortBy=${sortBy}&sortOrder=${sortOrder}&range=${range}">
                    Export
                </a>

            </c:if>
        </div>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="msg-ok">${param.msg}</div>
    </c:if>
    <c:if test="${not empty param.err}">
        <div class="msg-err">${param.err}</div>
    </c:if>

    <!-- Cards -->
    <div class="cards">
        <div class="card">
            <div class="label">Total Brands</div>
            <div class="value">${summary.totalBrands}</div>
        </div>
        <div class="card">
            <div class="label">Total Products</div>
            <div class="value">${summary.totalProducts}</div>
        </div>
        <div class="card">
            <div class="label">Total Stock Units</div>
            <div class="value">${summary.totalStockUnits}</div>
        </div>
        <div class="card">
            <div class="label">Low Stock Products</div>
            <div class="value">${summary.lowStockProducts}</div>
        </div>
    </div>

    <!-- Filter + Sort form -->
    <form method="get" action="${ctx}/home">
        <input type="hidden" name="p" value="brand-stats"/>

        <div class="filters">
            <!-- (3) Data Range -->
            <div class="field">
                <label>Data Range</label>
                <select name="range">
                    <option value="all"
                            ${empty range || range=='all' ? 'selected' : ''}>
                        AllTime
                    </option>
                    <option value="today" ${range=='today' ? 'selected' : ''}>Today</option>

                    <option value="last7"
                            ${range=='last7' ? 'selected' : ''}>
                        Last 7 Days
                    </option>

                    <option value="last30"
                            ${range=='last30' ? 'selected' : ''}>
                        Last 30 Days
                    </option>

                    <option value="month"
                            ${range=='month' ? 'selected' : ''}>
                        This Month
                    </option>
                    <option value="lastMonth" ${range=='lastMonth' ? 'selected' : ''}>Last Month</option>

                </select>


            </div>

            <!-- (4) Brand combobox -->
            <div class="field">
                <label>Brand</label>
                <select name="brandId">
                    <option value="" ${empty brandId ? 'selected' : ''}>All</option>
                    <c:forEach items="${allBrands}" var="b">
                        <option value="${b.brandId}" ${brandId != null && brandId == b.brandId ? 'selected' : ''}>
                            ${b.brandName}
                        </option>

                    </c:forEach>
                </select>
            </div>

            <!-- (5) Brand Status -->
            <div class="field">
                <label>Brand Status</label>
                <select name="status">
                    <option value="" ${empty status ? 'selected' : ''}>All</option>
                    <option value="active" ${status=='active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${status=='inactive' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>

            <!-- Search -->
            <div class="field">
                <label>Search</label>
                <input type="text" name="q" value="${q}" placeholder="brand name"/>
            </div>
        </div>

        <div class="sort-row">
            <!-- (6) Sort By -->
            <div class="field">
                <label>Sort By</label>
                <select name="sortBy">
                    <option value="stock" ${empty sortBy || sortBy=='stock' ? 'selected' : ''}>Total Stock</option>
                    <option value="products" ${sortBy=='products' ? 'selected' : ''}>Total Product</option>
                    <option value="low" ${sortBy=='low' ? 'selected' : ''}>Low Stock Count</option>
                    <option value="import" ${sortBy=='import' ? 'selected' : ''}>Imported Units</option>
                </select>

            </div>

            <!-- (7) Order -->
            <div class="field">
                <label>Order</label>
                <select name="sortOrder">
                    <option value="DESC" ${empty sortOrder || sortOrder=='DESC' ? 'selected' : ''}>DESC</option>
                    <option value="ASC" ${sortOrder=='ASC' ? 'selected' : ''}>ASC</option>
                </select>
            </div>

            <!-- (8) Apply -->
            <button class="btn" type="submit">Apply</button>

            <!-- Reset (giữ đúng như ảnh) -->
            <a class="btn" href="${ctx}/home?p=brand-stats">Reset</a>
        </div>
    </form>

    <!-- Table (11) -->
    <table>
        <tr>
            <th style="width:60px;">#</th>
            <th>Brand Name</th>
            <th style="width:120px;">#Product<br/><span class="muted">(Number of products under this brand)</span></th>
            <th style="width:120px;">Total Stock</th>
            <th style="width:140px;">Low Stock Count</th>
            <th style="width:140px;">Imported Units</th>
            <th style="width:120px;">Action</th>
        </tr>

        <c:forEach items="${rows}" var="r" varStatus="st">
            <tr class="${r.active ? '' : 'row-inactive'}">
                <td>${(page - 1) * pageSize + st.index + 1}</td>
                <td>
                    ${r.brandName}
                    <span class="badge ${r.active ? 'badge-active' : 'badge-inactive'}">
                        ${r.active ? 'Active' : 'Inactive'}
                    </span>
                </td>
                <td>${r.totalProducts}</td>
                <td>${r.totalStockUnits}</td>
                <td>${r.lowStockProducts}</td>
                <td>${r.importedUnits}</td>
                <td>
                    <!-- (10) View Details -->
                    <a class="btn" style="padding:4px 10px;"
                       href="${ctx}/home?p=brand-stats-detail&brandId=${r.brandId}">
                        View Details
                    </a>
                </td>
            </tr>
        </c:forEach>

        <c:if test="${empty rows}">
            <tr>
                <td colspan="7" style="text-align:center; color:#666;">No data</td>
            </tr>
        </c:if>
    </table>

    <!-- (12) Paging -->
    <div class="paging">
        <c:choose>
            <c:when test="${page <= 1}">
                <span style="color:#999;">&laquo; Prev</span>
            </c:when>
            <c:otherwise>
                <a href="${ctx}/home?p=brand-stats&page=${page-1}&q=${q}&status=${status}&brandId=${brandId}&sortBy=${sortBy}&sortOrder=${sortOrder}&range=${range}">&laquo;&laquo;</a>
            </c:otherwise>
        </c:choose>

        <c:forEach begin="1" end="${totalPages}" var="i">
            <c:choose>
                <c:when test="${i == page}">
                    <b>${i}</b>
                </c:when>
                <c:otherwise>
                    <a href="${ctx}/home?p=brand-stats&page=${i}&q=${q}&status=${status}&brandId=${brandId}&sortBy=${sortBy}&sortOrder=${sortOrder}&range=${range}">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <c:choose>
            <c:when test="${page >= totalPages}">
                <span style="color:#999;">Next &raquo;</span>
            </c:when>
            <c:otherwise>
                <a href="${ctx}/home?p=brand-stats&page=${page+1}&q=${q}&status=${status}&brandId=${brandId}&sortBy=${sortBy}&sortOrder=${sortOrder}&range=${range}">&raquo;&raquo;</a>
            </c:otherwise>
        </c:choose>
    </div>
</div>
