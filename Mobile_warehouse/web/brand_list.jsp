<%-- 
    Document   : brand_list
    Created on : Jan 27, 2026, 11:19:16 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
  String ctx = request.getContextPath();
%>
<c:set var="role" value="${sessionScope.roleName}" />


<h2>Brand List</h2>

<c:if test="${not empty param.msg}">
    <p style="color:green;">${param.msg}</p>
</c:if>
<c:if test="${not empty param.err}">
    <p style="color:red;">${param.err}</p>
</c:if>

<form method="get" action="${pageContext.request.contextPath}/home">
    <input type="hidden" name="p" value="brand-list"/>

    Search: <input name="q" value="${q}" placeholder="brand name"/>
    Status:
    <select name="status">
        <option value="" ${empty status ? 'selected' : ''}>All</option>
        <option value="active" ${status=='active' ? 'selected' : ''}>Active</option>
        <option value="inactive" ${status=='inactive' ? 'selected' : ''}>Inactive</option>
    </select>

    Sort:
    <select name="sortBy">
        <option value="name" ${sortBy=='name'?'selected':''}>Name</option>
        <option value="createdAt" ${sortBy=='createdAt'?'selected':''}>Created At</option>
        <option value="status" ${sortBy=='status'?'selected':''}>Status</option>
    </select>
    Order:
    <select name="sortOrder">
        <option value="ASC" ${sortOrder=='ASC'?'selected':''}>ASC</option>
        <option value="DESC" ${sortOrder=='DESC'?'selected':''}>DESC</option>
    </select>

    <button type="submit">Apply</button>
    <a href="${pageContext.request.contextPath}/home?p=brand-list">Reset</a>
</form>

<c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
    <p>
        <a href="<%=ctx%>/home?p=brand-add">+ Add New Brand</a>
    </p>
</c:if>
    </br>
<table border="1" cellpadding="6" cellspacing="0" width="100%">
    <tr>
        <th>#</th>
        <th>Brand Name</th>
        <th>Description</th>
        <th>Status</th>
        <th>Created At</th>
        <th>Action</th>

    </tr>

    <c:forEach items="${brands}" var="b" varStatus="st">
        <tr>
            <td>${(page - 1) * pageSize + st.index + 1}</td>
            <td>${b.brandName}</td>
            <td>${b.description}</td>
            <td>
                <c:choose>
                    <c:when test="${b.active}">Active</c:when>
                    <c:otherwise>Inactive</c:otherwise>
                </c:choose>
            </td>
            <td>${b.createdAt}</td>
            <td>
                <a href="<%=ctx%>/home?p=brand-detail&id=${b.brandId}">Detail</a> 
                <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
                    |
                    <a href="<%=ctx%>/home?p=brand-update&id=${b.brandId}">Update</a> |
                    <c:if test="${b.active}">
                        <a href="<%=ctx%>/home?p=brand-disable&id=${b.brandId}">Disable</a>
                    </c:if>
                </c:if>
            </td>

        </tr>
    </c:forEach>
</table>

<!-- paging -->
<div style="margin-top:12px; display:flex; gap:12px; justify-content:center; align-items:center;">

    <!-- Prev -->
    <c:choose>
        <c:when test="${page <= 1}">
            <span style="color:#999;">&laquo; Prev</span>
        </c:when>
        <c:otherwise>
            <a href="${pageContext.request.contextPath}/home?p=brand-list&page=${page-1}&q=${q}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}">
                &laquo; Prev
            </a>
        </c:otherwise>
    </c:choose>

    <!-- Page numbers -->
    <c:forEach begin="1" end="${totalPages}" var="i">
        <c:choose>
            <c:when test="${i == page}">
                <b style="padding:4px 10px; border:1px solid #333;">${i}</b>
            </c:when>
            <c:otherwise>
                <a style="padding:4px 10px; border:1px solid #ccc; text-decoration:none;"
                   href="${pageContext.request.contextPath}/home?p=brand-list&page=${i}&q=${q}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}">
                    ${i}
                </a>
            </c:otherwise>
        </c:choose>
    </c:forEach>

    <!-- Next -->
    <c:choose>
        <c:when test="${page >= totalPages}">
            <span style="color:#999;">Next &raquo;</span>
        </c:when>
        <c:otherwise>
            <a href="${pageContext.request.contextPath}/home?p=brand-list&page=${page+1}&q=${q}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}">
                Next &raquo;
            </a>
        </c:otherwise>
    </c:choose>
</div>



