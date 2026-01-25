<%-- 
    Document   : user_add
    Created on : Jan 14, 2026, 12:46:58 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <title>Add User</title>
</head>
<body>

<a href="${pageContext.request.contextPath}/admin/users"
   style="display:inline-block; padding:6px 10px; border:1px solid #000; text-decoration:none; color:#000;">
   ← Back
</a>
&nbsp;&nbsp;
<a href="${pageContext.request.contextPath}/home"
   style="display:inline-block; padding:6px 10px; border:1px solid #000; text-decoration:none; color:#000;">
   Home
</a>

<br><br>

<h1>Add User</h1>
<h4>CREATE NEW USER</h4>

<c:if test="${not empty error}">
    <p style="color:red;"><b>${error}</b></p>
</c:if>

<form method="post" action="${pageContext.request.contextPath}/admin/user-add">


    <input type="hidden" name="status" value="1"/>

    <table border="1" cellpadding="8" cellspacing="0" style="min-width:900px;">
        <tr>
            <td style="width:200px;"><b>Username *</b></td>
            <td><input name="username" value="" placeholder="a01" style="width:350px;">${requestScope.errorU}</td>
        </tr>
        <tr>
            <td><b>Password *</b></td>
            <td><input type="password" name="password" placeholder="123456" style="width:350px;"></td>
        </tr>
        <tr>
            <td><b>Full name *</b></td>
            <td><input name="full_name" value="" placeholder="Nguyen Van A" style="width:350px;"></td>
        </tr>
        <tr>
            <td><b>Email</b></td>
            <td><input name="email" value="" placeholder="a@gmail.com" style="width:350px;">${requestScope.errorE}</td>
        </tr>
        <tr>
            <td><b>Phone</b></td>
            <td><input name="phone" value="" placeholder="090xxxxxxx" style="width:350px;"></td>
        </tr>
        <tr>
            <td><b>Role *</b></td>
            <td>
                <select name="role_id" style="width:360px;">
                    <option value="0">-- Choose role --</option>
                    <c:forEach var="r" items="${roles}">
                        <option value="${r.roleId}"
                                <c:if test="${v_role_id == r.roleId}">selected</c:if>>
                            ${r.roleName}
                        </option>
                    </c:forEach>
                </select>
            </td>
        </tr>

        <tr>
            <td><b>Status</b></td>
            <td><b>Active</b></td>
        </tr>
    </table>

    <br>
    <button type="submit"
            style="background:#1447E6;color:white;padding:6px 16px;border:1px solid #000;">
        Create
    </button>
</form>

</body>
</html>
