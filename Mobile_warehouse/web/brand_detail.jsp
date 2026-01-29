<%-- 
    Document   : brand_detail
    Created on : Jan 27, 2026, 11:19:55 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
  String ctx = request.getContextPath();
%>
<c:set var="role" value="${sessionScope.roleName}" />

<h2>Brand Detail</h2>

<c:if test="${not empty param.msg}">
    <p style="color:green;">${param.msg}</p>
</c:if>

<p><b>Name:</b> ${brand.brandName}</p>
<p><b>Description:</b> ${brand.description}</p>
<p><b>Status:</b> <c:choose><c:when test="${brand.active}">Active</c:when><c:otherwise>Inactive</c:otherwise></c:choose></p>
<p><b>Created At:</b> ${brand.createdAt}</p>
<p><b>Updated At:</b> ${brand.updatedAt}</p>

<p>
    <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
        <a href="<%=ctx%>/home?p=brand-update&id=${brand.brandId}">Update</a>| 

    </c:if>
    <a href="<%=ctx%>/home?p=brand-list">Back</a>
</p>

