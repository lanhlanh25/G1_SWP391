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

    </head>
    <body>
        <style>
            body {
                font-family: Arial;
                background:#f2f2f2;
                margin:0;
            }

            .mw-topbar {
                padding:10px;
            }

            .mw-btn{
                display:inline-block;
                padding:6px 14px;
                border:2px solid #1f4aa8;
                background:#4a86d4;
                color:#000;
                text-decoration:none;
                font-weight:600;
                margin-right:8px;
                cursor:pointer;
            }
            .mw-btn:hover{
                opacity:0.9;
            }

            .mw-wrap{
                padding:30px 60px;
            }

            .mw-searchbar{
                margin:10px 0 18px;
            }
            .mw-searchbar input{
                width:320px;
                padding:8px;
                border:1px solid #000;
                outline:none;
            }

            .mw-table{
                border-collapse:collapse;
                width:900px;
                background:#fff;
            }
            .mw-table th, .mw-table td{
                border:1px solid #000;
                padding:12px 10px;
                text-align:center;
                vertical-align:middle;
            }
            .mw-table th{
                background:#fafafa;
                font-weight:700;
            }

            .mw-btn-action{
                padding:6px 18px;
                border:2px solid #1f4aa8;
                background:#4a86d4;
                cursor:pointer;
                font-weight:600;
            }
            .mw-btn-action:hover{
                opacity:0.9;
            }
        </style>
        <div class="mw-topbar">
            <a class="mw-btn" href="${pageContext.request.contextPath}/admin/users">Back</a>
            <a class="mw-btn" href="${pageContext.request.contextPath}/home">Home</a>
        </div>

        <div class="mw-wrap">
            <h2>Active / Deactive</h2>

            <form class="mw-searchbar" method="get" action="${pageContext.request.contextPath}/admin/users/active-page">
                <input type="text" name="q" value="${param.q}" placeholder="Search....">
                <button class="mw-btn" type="submit">Search</button>
                <button class="mw-btn" type="button"
                        onclick="window.location.href = '${pageContext.request.contextPath}/admin/users/active-page'">
                    Clear
                </button>
            </form>

            <table class="mw-table">
                <thead>
                    <tr>
                        <th style="width:100px;">ID</th>
                        <th style="width:260px;">Username</th>
                        <th style="width:320px;">Fullname</th>
                        <th style="width:240px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty users}">
                        <tr>
                            <td colspan="4">No users found.</td>
                        </tr>
                    </c:if>

                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>${u.userId}</td>
                            <td>${u.username}</td>
                            <td>${u.fullName}</td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/admin/users/toggle" style="margin:0; display:inline;">
                                    <input type="hidden" name="user_id" value="${u.userId}">
                                    <input type="hidden" name="cur_status" value="${u.status}">
                                    <c:choose>
                                        <c:when test="${u.status == 1}">
                                            <button class="mw-btn-action" type="submit"
                                                    onclick="return confirm('Deactivate user ${u.username}?');">
                                                Deactive
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="mw-btn-action" type="submit"
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