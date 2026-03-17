<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="page-wrap-md">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=user-list">← Back</a>
            <h1 class="h1">View User Information</h1>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div style="display:flex; gap:18px; align-items:center; margin-bottom:18px; flex-wrap:wrap;">
                <img src="${pageContext.request.contextPath}/${empty user.avatar ? 'assets/default-avatar.jpg' : user.avatar}?v=<fmt:formatDate value='${now}' pattern='yyyyMMddHHmmssSSS'/>"
                     style="width:88px;height:88px;object-fit:cover;border:1px solid var(--border);border-radius:14px;">

                <div>
                    <div class="h2">${user.fullName}</div>
                    <div class="muted">@${user.username}</div>
                </div>
            </div>

            <div class="form-grid">
                <div class="label">User ID</div>
                <div><input class="input readonly" type="text" value="${user.userId}" readonly></div>

                <div class="label">Username</div>
                <div><input class="input readonly" type="text" value="${user.username}" readonly></div>

                <div class="label">Full Name</div>
                <div><input class="input readonly" type="text" value="${user.fullName}" readonly></div>

                <div class="label">Phone</div>
                <div><input class="input readonly" type="text" value="${user.phone}" readonly></div>

                <div class="label">Address</div>
                <div><input class="input readonly" type="text" value="${user.address}" readonly></div>

                <div class="label">Email</div>
                <div><input class="input readonly" type="text" value="${user.email}" readonly></div>

                <div class="label">Role</div>
                <div><input class="input readonly" type="text" value="${roleName}" readonly></div>

                <div class="label">Status</div>
                <div>
                    <c:choose>
                        <c:when test="${user.status == 1}">
                            <span class="badge badge-active">Active</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-inactive">Inactive</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="form-actions" style="margin-top:20px;">
                <a class="btn btn-primary"
                   href="${pageContext.request.contextPath}/home?p=user-update&id=${user.userId}">
                    Update
                </a>
            </div>
        </div>
    </div>
</div>