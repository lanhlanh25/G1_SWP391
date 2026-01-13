<%-- 
    Document   : role_list
    Created on : Jan 13, 2026, 2:10:51 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
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
        <h2>Role list (#12) + Active/Deactive role (#15)</h2>
        <c:if test="${param.msg == 'updated'}">
            <div class="msg" style="color:green;">Updated successfully!</div>
        </c:if>
        <c:if test="${param.msg == 'failed'}">
            <div class="msg" style="color:red;">Update failed! (Maybe ADMIN role cannot be disabled)</div>
        </c:if>
        <table>
            <tr>
                <th>ID</th>
                <th>Role name</th>
                <th>Description</th>
                <th>Status</th>
                <th>Action</th>
            </tr>

            <c:choose>
                <c:when test="${empty roles}">
                    <tr><td colspan="5">No role found</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="r" items="${roles}">
                        <tr>
                            <td>${r.roleId}</td>
                            <td>${fn:escapeXml(r.roleName)}</td>
                            <td>${fn:escapeXml(r.description)}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.isActive == 1}">
                                        <span class="ok">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="off">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.isActive == 1}">
                                        <form method="post" action="${ctx}/admin/role/toggle" style="display:inline;">
                                            <input type="hidden" name="id" value="${r.roleId}">
                                            <input type="hidden" name="active" value="0">
                                            <button class="btn btn-off" type="submit"
                                                    onclick="return confirm('Deactivate this role?');">
                                                Deactivate
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post" action="${ctx}/admin/role/toggle" style="display:inline;">
                                            <input type="hidden" name="id" value="${r.roleId}">
                                            <input type="hidden" name="active" value="1">
                                            <button class="btn btn-on" type="submit"
                                                    onclick="return confirm('Activate this role?');">
                                                Activate
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </table>
    </body>
</html>
