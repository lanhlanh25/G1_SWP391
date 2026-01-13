<%-- 
    Document   : user_edit
    Created on : Jan 13, 2026, 12:51:36 PM
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
    <body>
        <h2>Edit user (#11)</h2>
        <c:if test="${param.msg == 'invalid'}">
            <div class="msg">Full name is required.</div>
        </c:if>
        <form method="post" action="${ctx}/admin/user/edit">
            <input type="hidden" name="id" value="${user.userId}" />

            <label>Username (cannot change)</label>
            <input type="text" value="${fn:escapeXml(user.username)}" disabled /><br>
            
            <label>Full name</label>
            <input type="text" name="fullName" value="${fn:escapeXml(user.fullName)}" required />

            <div class="row">
                <div>
                    <label>Email</label>
                    <input type="text" name="email" value="${fn:escapeXml(user.email)}" />
                </div>
                <div>
                    <label>Phone</label>
                    <input type="text" name="phone" value="${fn:escapeXml(user.phone)}" />
                </div>
            </div>

            <div class="row">
                <div>
                    <label>Role</label>
                    <select name="roleId">
                        <c:forEach var="r" items="${roles}">
                            <option value="${r.roleId}" ${r.roleId == user.roleId ? 'selected' : ''}>
                                ${fn:escapeXml(r.roleName)}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label>Status</label>
                    <select name="status">
                        <option value="1" ${user.status == 1 ? 'selected' : ''}>Active</option>
                        <option value="0" ${user.status == 0 ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>
            </div>

            <div class="btns">
                <button type="submit">Save</button>
                <a href="${ctx}/admin/users">Cancel</a>
            </div>
        </form>
    </body>
</html>
