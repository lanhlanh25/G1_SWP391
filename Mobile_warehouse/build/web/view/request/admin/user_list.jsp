<%-- 
    Document   : user_list
    Created on : Jan 11, 2026, 2:21:24 PM
    Author     : Admin
--%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <style>
        table, th, td{
            border: 1px solid black
        }
    </style>
    <body>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />
        <table>
            <tr>
                <th>ID</th>
                <th>Username</th>
                <th>Full name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            <c:choose>
                <c:when test="${empty users}">
                    <tr>
                        <td>No user found</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>${u.userId}</td>
                            <td>${fn:escapeXml(u.username)}</td>
                            <td>${fn:escapeXml(u.fullName)}</td>
                            <td>${fn:escapeXml(u.email)}</td>
                            <td>${fn:escapeXml(u.roleName)}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.status == 1}">
                                        <span>Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span>Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <a href="${ctx}/admin/user/edit?id=${u.userId}">Edit</a>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </table>
    </body>
</html>
