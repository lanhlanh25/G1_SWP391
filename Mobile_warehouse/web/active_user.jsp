<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=user-list">← Back</a>
            <h1 class="h1">Active / Deactive Users</h1>
        </div>
    </div>
            <c:if test="${not empty param.msg}">
    <div class="msg-ok">
        <c:choose>
            <c:when test="${param.msg == 'ok'}">User status updated successfully.</c:when>
            <c:otherwise>${param.msg}</c:otherwise>
        </c:choose>
    </div>
</c:if>

    <div class="card">
        <div class="card-body">
         <form class="filters" method="get" action="${pageContext.request.contextPath}/home" style="grid-template-columns: 1fr auto auto;">
    <input type="hidden" name="p" value="user-toggle"/>

    <div>
        <label>Search</label>
        <input class="input" type="text" name="q" value="${param.q}" placeholder="Search username or fullname...">
    </div>

    <div style="display:flex; align-items:end;">
        <button class="btn btn-primary" type="submit">Search</button>
    </div>

    <div style="display:flex; align-items:end;">
        <a class="btn" href="${pageContext.request.contextPath}/home?p=user-toggle">Clear</a>
    </div>
</form>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width:100px;">ID</th>
                        <th>Username</th>
                        <th>Fullname</th>
                        <th>Status</th>
                        <th style="width:180px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty users}">
                        <tr>
                            <td colspan="5" style="text-align:center;">No users found.</td>
                        </tr>
                    </c:if>

                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>${u.userId}</td>
                            <td><b>${u.username}</b></td>
                            <td>${u.fullName}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.status == 1}">
                                        <span class="badge badge-active">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-inactive">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/admin/users/toggle" style="margin:0; display:inline;">
                                    <input type="hidden" name="user_id" value="${u.userId}">
                                    <input type="hidden" name="cur_status" value="${u.status}">

                                    <c:choose>
                                        <c:when test="${u.status == 1}">
                                            <button class="btn btn-danger btn-sm" type="submit"
                                                    onclick="return confirm('Deactivate user ${u.username}?');">
                                                Deactive
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn btn-primary btn-sm" type="submit"
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
    </div>
</div>