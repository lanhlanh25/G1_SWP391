<%-- 
    Document   : product_list
    Created on : Jan 31, 2026, 10:16:26 PM
    Author     : Lanhlanh
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<style>
.wrap {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.title {
    font-size: 22px;
    font-weight: bold;
}

.btn-add {
    padding: 8px 14px;
    background: #28a745;
    color: #fff;
    border-radius: 6px;
    text-decoration: none;
}

.filters {
    display: flex;
    gap: 10px;
    margin-bottom: 15px;
    align-items: center;
}

.searchBox input {
    padding: 8px 10px;
    border-radius: 6px;
    border: 1px solid #ccc;
}

.searchBox button {
    padding: 8px 14px;
    border-radius: 6px;
    border: none;
    background: #007bff;
    color: #fff;
}

.filters select {
    padding: 8px 10px;
    border-radius: 6px;
    border: 1px solid #ccc;
}

.table-wrap table {
    width: 100%;
    border-collapse: collapse;
}

.table-wrap th {
    background: #f8f9fa;
    padding: 10px;
    text-align: left;
    border-bottom: 2px solid #ddd;
}

.table-wrap td {
    padding: 10px;
    border-bottom: 1px solid #eee;
}

.table-wrap tr:hover {
    background: #f5f5f5;
}

.action a {
    margin-right: 6px;
}

.paging {
    margin-top: 15px;
    display: flex;
    justify-content: space-between;
}

.page-btns a {
    padding: 6px 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    text-decoration: none;
    margin-right: 4px;
}

.page-btns a.active {
    background: #007bff;
    color: #fff;
    border-color: #007bff;
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
                              <a href="${pageContext.request.contextPath}/home?p=product-detail&id=${x.productId}">
                                View
                            </a>

                            <a href="${pageContext.request.contextPath}/manager/product/update?id=${x.productId}">
                                Update
                            </a>

                            <a href="${pageContext.request.contextPath}/manager/product/delete?id=${x.productId}">
                                Delete
                            </a>
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