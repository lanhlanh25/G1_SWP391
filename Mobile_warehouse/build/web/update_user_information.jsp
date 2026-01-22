<%-- 
    Document   : update_user_information
    Created on : Jan 15, 2026, 2:29:18 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update User Information</title>
    <style>
        body { font-family: Arial; background:#f2f2f2; margin:0; }
        .topbar { padding:10px; }
        .btn {
            display:inline-block;
            padding:6px 14px;
            border:2px solid #1f4aa8;
            background:#4a86d4;
            color:#000;
            text-decoration:none;
            font-weight:600;
            margin-right:8px;
        }
        .wrap { padding: 20px 60px; }
        table { border-collapse:collapse; width:900px; background:#fff; }
        td { border:1px solid #000; padding:10px; }
        .label { width:220px; font-weight:700; background:#fafafa; }
        input, select { width:360px; padding:6px; }
        .msg { color:red; margin:10px 0; }
    </style>
</head>
<body>

<div class="topbar">
    <a class="btn" href="<%=request.getContextPath()%>/admin/users">Back</a>
    <a class="btn" href="<%=request.getContextPath()%>/home">Home</a>
</div>

<div class="wrap">
    <h2>Update User Information</h2>

    <c:if test="${not empty error}">
        <div class="msg"><b>${error}</b></div>
    </c:if>

    <%-- 
      Controller sẽ set:
      - request.setAttribute("user", userObj)
      - request.setAttribute("roles", roleList)
      - request.setAttribute("roleName", ...) (optional)
    --%>

    <form method="post" action="<%=request.getContextPath()%>/admin/user/update">
        <table>
            <tr>
                <td class="label">User ID</td>
                <td>
                    <input type="text" name="user_id" value="${user.userId}" readonly>
                </td>
            </tr>

            <tr>
                <td class="label">Username</td>
                <td>
                    <input type="text" name="username" value="${user.username}" readonly>
                </td>
            </tr>

            <tr>
                <td class="label">Full Name</td>
                <td>
                    <input type="text" name="full_name" value="${user.fullName}">
                </td>
            </tr>

            <tr>
                <td class="label">Email</td>
                <td>
                    <input type="text" name="email" value="${user.email}">
                </td>
            </tr>

            <tr>
                <td class="label">Phone</td>
                <td>
                    <input type="text" name="phone" value="${user.phone}">
                </td>
            </tr>

            <tr>
                <td class="label">Role</td>
                <td>
                    <select name="role_id">
                        <c:forEach var="r" items="${roles}">
                            <option value="${r.roleId}"
                                <c:if test="${user.roleId == r.roleId}">selected</c:if>>
                                ${r.roleName}
                            </option>
                        </c:forEach>
                    </select>
                </td>
            </tr>

            <tr>
                <td class="label">Status</td>
                <td>
                    <%-- luôn active --%>
                    <b>Active</b>
                    <input type="hidden" name="status" value="1">
                </td>
            </tr>
        </table>

        <br>
        <button class="btn" type="submit">Save</button>
    </form>
</div>

</body>
</html>

