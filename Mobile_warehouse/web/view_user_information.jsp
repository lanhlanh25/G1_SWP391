<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="page-wrap-md">
    <div class="topbar mb-20">
        <div class="d-flex align-center gap-10">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=user-list">← Back</a>
            <h1 class="h1 m-0">View User Information</h1>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="d-flex gap-18 align-center mb-18 flex-wrap">
                <img src="${pageContext.request.contextPath}/${empty user.avatar ? 'assets/default-avatar.jpg' : user.avatar}?v=<fmt:formatDate value='${now}' pattern='yyyyMMddHHmmssSSS'/>"
                     class="avatar-lg">

                <div>
                    <div class="h2 m-0">${user.fullName}</div>
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

            <div class="form-actions mt-20">
                <a class="btn btn-primary"
                   href="${pageContext.request.contextPath}/home?p=user-update&id=${user.userId}">
                    Update
                </a>
            </div>
        </div>
    </div>
</div>