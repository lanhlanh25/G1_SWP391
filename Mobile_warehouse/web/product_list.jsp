<%-- 
    Document   : product_list
    Created on : Jan 31, 2026, 10:16:26 PM
    Author     : Lanhlanh
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<style>
    * { box-sizing: border-box; }

    .wrap {
        width: 100%;
        max-width: 980px;
        margin: 16px auto;
        background: #f1f1f1;
        padding: 18px;
    }

    .top {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
        margin-bottom: 10px;
    }

    .title {
        font-size: 40px;
        font-weight: 900;
        margin: 0;
        line-height: 1.1;
    }

    .btn-add {
        padding: 10px 16px;
        border: 2px solid #2b4ea2;
        background: #2f6fb9;
        color: #000;
        font-weight: 700;
        text-decoration: none;
        white-space: nowrap;
    }

    .filters {
        display: flex;
        gap: 12px;
        align-items: center;
        flex-wrap: wrap;
        margin: 12px 0 14px;
    }

    .searchBox {
        display: flex;
        gap: 10px;
        align-items: center;
        flex: 1 1 360px;
        min-width: 280px;
    }

    .searchBox input {
        flex: 1 1 auto;
        min-width: 220px;
        height: 40px;
        border: 2px solid #2b4ea2;
        padding: 0 10px;
        background: #fff;
    }

    .searchBox button {
        height: 40px;
        padding: 0 16px;
        border: 2px solid #2b4ea2;
        background: #2f6fb9;
        font-weight: 700;
        cursor: pointer;
        white-space: nowrap;
    }

    .filters select {
        height: 40px;
        border: 1px solid #999;
        padding: 0 10px;
        font-weight: 600;
        background: #fff;
        flex: 0 0 200px;
        min-width: 180px;
    }

    .table-wrap {
        width: 100%;
        overflow-x: auto;
        background: #fff;
        border: 2px solid #999;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        min-width: 820px;
    }

    th, td {
        border: 2px solid #999;
        padding: 10px 8px;
        text-align: center;
        white-space: nowrap;
    }

    th {
        background: #eee;
        font-weight: 800;
    }

    .action a { margin: 0 10px; }

    .paging {
        margin-top: 12px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }

    .page-btns a {
        display: inline-block;
        padding: 6px 10px;
        margin-left: 6px;
        background: #ccc;
        color: #000;
        text-decoration: none;
    }

    .page-btns .active { background: #999; }

    @media (max-width: 768px) {
        .wrap { max-width: 100%; padding: 14px; }
        .title { font-size: 30px; }
        .filters select { flex: 1 1 180px; }
        table { min-width: 760px; }
    }

    @media (max-width: 480px) {
        .title { font-size: 26px; }
        .searchBox { flex: 1 1 100%; }
        .searchBox button { padding: 0 12px; }
    }
</style>
<div class="wrap">
    <div class="top">
        <div class="title">View Product List</div>
        <a class="btn-add" href="${pageContext.request.contextPath}/home?p=product-add">Add product</a>
    </div>

    <form method="get" action="${pageContext.request.contextPath}/home">
        <input type="hidden" name="p" value="product-list"/>

        <div class="filters">
            <div class="searchBox">
                <input type="text" name="q" value="${q != null ? q : ''}"/>
                <button type="submit">SEARCH</button>
            </div>

            <select name="brandId" onchange="this.form.submit()">
                <option value="">All Brand</option>
                <c:forEach var="b" items="${allBrands}">
                    <option value="${b.brandId}" ${brandId == (''+b.brandId) ? 'selected' : ''}>${b.brandName}</option>
                </c:forEach>
            </select>

            <select name="status" onchange="this.form.submit()">
                <option value="">Status</option>
                <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
            </select>
        </div>
    </form>

    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Product Code</th>
                    <th>Product Name</th>
                    <th>Brand</th>
                    <th>Status</th>
                    <th>Created_At</th>
                    <th>Action</th>
                </tr>
            </thead>

            <tbody>
                <c:forEach var="x" items="${products}">
                    <tr>
                        <td>${x.productCode}</td>
                        <td>${x.productName}</td>
                        <td>${x.brandName}</td>
                        <td>${x.status}</td>
                        <td><fmt:formatDate value="${x.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                        <td class="action">
                            <a href="${pageContext.request.contextPath}/home?p=product-detail&id=${x.productId}">View</a>
                            <a href="${pageContext.request.contextPath}/home?p=product-delete&id=${x.productId}">Delete</a>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty products}">
                    <tr><td colspan="6">No data</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <div class="paging">
        <div>${page}</div>

        <div class="page-btns">
            <c:set var="base" value="${pageContext.request.contextPath}/home?p=product-list&q=${q}&brandId=${brandId}&status=${status}"/>

            <c:if test="${page > 1}">
                <a href="${base}&page=${page-1}">Prev</a>
            </c:if>

            <c:forEach var="i" begin="1" end="${totalPages}">
                <a href="${base}&page=${i}" class="${i == page ? 'active' : ''}">${i}</a>
            </c:forEach>

            <c:if test="${page < totalPages}">
                <a href="${base}&page=${page+1}">Next</a>
            </c:if>
        </div>
    </div>
</div>
