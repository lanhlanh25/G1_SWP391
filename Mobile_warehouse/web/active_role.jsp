<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=role-list">← Back</a>
            <h1 class="h1">Active / Deactive Roles</h1>
        </div>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="msg-ok">
            <c:choose>
                <c:when test="${param.msg == 'ok'}">Role status updated successfully.</c:when>
                <c:otherwise>${param.msg}</c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <div class="muted" style="margin-bottom:14px;">Manage role activation status.</div>

            <table class="table">
                <thead>
                    <tr>
                        <th>Role</th>
                        <th>Users</th>
                        <th>Status</th>
                        <th style="width:160px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty roles}">
                        <tr>
                            <td colspan="4" style="text-align:center;">No roles found.</td>
                        </tr>
                    </c:if>

                    <c:forEach var="r" items="${roles}">
                        <tr>
                            <td><b>${r.roleName}</b></td>
                            <td>${r.userCount} user(s)</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status == 1}">
                                        <span class="badge badge-active">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-inactive">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <form method="post"
                                      action="${pageContext.request.contextPath}/admin/role/toggle"
                                      style="margin:0; display:inline;">
                                    <%-- ✅ Dùng đúng tên param mà RoleToggle đọc --%>
                                    <input type="hidden" name="role_id"    value="${r.roleId}">
                                    <input type="hidden" name="cur_status" value="${r.status}">

                                    <c:choose>
                                        <c:when test="${r.status == 1}">
                                            <button class="btn btn-danger btn-sm" type="submit"
                                                    onclick="return confirm('Deactivate role ${r.roleName}?');">
                                                Deactive
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn btn-primary btn-sm" type="submit"
                                                    onclick="return confirm('Activate role ${r.roleName}?');">
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
