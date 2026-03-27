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

            <form class="filters" method="get" action="${pageContext.request.contextPath}/home"
                  style="grid-template-columns: 1fr auto auto; margin-bottom:16px;">
                <input type="hidden" name="p" value="role-toggle"/>
                <input type="hidden" name="page" value="1"/>

                <div>
                    <label>Search</label>
                    <input class="input" type="text" name="q" value="${q}"
                           placeholder="Search role name...">
                </div>

                <div style="display:flex; align-items:end;">
                    <button class="btn btn-primary" type="submit">Search</button>
                </div>

                <div style="display:flex; align-items:end;">
                    <a class="btn" href="${pageContext.request.contextPath}/home?p=role-toggle">Clear</a>
                </div>
            </form>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width:90px;">#</th>
                        <th>Role</th>
                        <th>Users</th>
                        <th>Status</th>
                        <th style="width:160px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty roles}">
                        <tr>
                            <td colspan="5" style="text-align:center;">No roles found.</td>
                        </tr>
                    </c:if>

                    <c:forEach var="r" items="${roles}" varStatus="stt">
                        <tr>
                            <td>${(page - 1) * pageSize + stt.index + 1}</td>
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
                                    <input type="hidden" name="role_id" value="${r.roleId}">
                                    <input type="hidden" name="cur_status" value="${r.status}">
                                    <input type="hidden" name="page" value="${page}">
                                    <input type="hidden" name="q" value="${q}">
                                    <input type="hidden" name="status" value="${status}">

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

            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px;">
                <div>
                    Page ${page} of ${totalPages}
                </div>

                <div style="display:flex; gap:6px; align-items:center;">
                    <c:if test="${page > 1}">
                        <a class="btn"
                           href="${pageContext.request.contextPath}/home?p=role-toggle&page=${page - 1}&q=${q}&status=${status}">
                            &lt;
                        </a>
                    </c:if>

                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <a class="btn ${i == page ? 'btn-primary' : ''}"
                           href="${pageContext.request.contextPath}/home?p=role-toggle&page=${i}&q=${q}&status=${status}">
                            ${i}
                        </a>
                    </c:forEach>

                    <c:if test="${page < totalPages}">
                        <a class="btn"
                           href="${pageContext.request.contextPath}/home?p=role-toggle&page=${page + 1}&q=${q}&status=${status}">
                            &gt;
                        </a>
                    </c:if>
                </div>
            </div>

        </div>
    </div>
</div>