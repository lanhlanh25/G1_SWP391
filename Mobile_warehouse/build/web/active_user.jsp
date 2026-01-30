<%-- 
    Document   : active_user.jsp
    Created on : Jan 15, 2026, 1:03:17 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Active/Deactive Users</title>
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
        .btn:hover { opacity:0.9; }

        .wrap { padding: 30px 60px; }
        h2 { margin:0 0 8px; }

        table { border-collapse:collapse; width: 820px; background:#fff; }
        th, td { border:1px solid #000; padding:10px; text-align:center; }
        th { background:#fff; font-weight:700; }

        .btn-action {
            padding:6px 18px;
            border:2px solid #1f4aa8;
            background:#4a86d4;
            cursor:pointer;
            font-weight:600;
        }
        .btn-action:hover { opacity:0.9; }
    </style>
</head>
<body>

<div class="topbar">
    <a class="btn" href="${pageContext.request.contextPath}/admin/users">Back</a>
    <a class="btn" href="${pageContext.request.contextPath}/home">Home</a>
</div>

<div class="wrap">
    <h2>Active / Deactive</h2>

    <table>
        <thead>
        <tr>
            <th style="width:100px;">ID</th>
            <th style="width:300px;">Username</th>
            <th style="width:420px;">Action</th>
        </tr>
        </thead>

        <tbody>
        <c:if test="${empty users}">
            <tr>
                <td colspan="3">No users found.</td>
            </tr>
        </c:if>

        <c:forEach var="u" items="${users}">
            <tr>
                <td>${u.userId}</td>
                <td>${u.username}</td>
                <td>
                    <form method="post"
                          action="${pageContext.request.contextPath}/admin/users/toggle"
                          style="margin:0; display:inline;">
                        <input type="hidden" name="user_id" value="${u.userId}">
                        <input type="hidden" name="cur_status" value="${u.status}">
                        <c:choose>
                            <c:when test="${u.status == 1}">
                                <button class="btn-action" type="submit"
                                        onclick="return confirm('Deactivate user ${u.username}?');">
                                    Deactive
                                </button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn-action" type="submit"
                                        onclick="return confirm('Activate user ${u.username}?');">
                                    Active
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </form>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>

</body>
</html>