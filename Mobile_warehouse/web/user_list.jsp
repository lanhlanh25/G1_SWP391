<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.net.URLEncoder"%>

<%
    Integer pageObj = (Integer) request.getAttribute("page");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");

    int curPage = (pageObj == null) ? 1 : pageObj;
    int totalPages = (totalPagesObj == null) ? 1 : totalPagesObj;

    String q = (String) request.getAttribute("q");
    String st = (String) request.getAttribute("status");

    if (q == null) q = "";
    if (st == null) st = "";

    String base = request.getContextPath() + "/home?p=user-list"
            + (!q.isEmpty() ? "&q=" + URLEncoder.encode(q, "UTF-8") : "")
            + (!st.isEmpty() ? "&status=" + st : "");
%>

<div class="page-wrap">

    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <a class="btn" href="<%=request.getContextPath()%>/home?p=dashboard">← Back</a>
            <h1 class="h1">User Management</h1>
        </div>

        <div class="d-flex gap-8 flex-wrap">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=user-toggle">Status Toggle</a>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/home?p=user-add">+ Add User</a>
        </div>
    </div>
<c:if test="${not empty param.msg}">
    <div class="msg-ok">
        <c:choose>
            <c:when test="${param.msg == 'updated'}">User updated successfully.</c:when>
            <c:when test="${param.msg == 'invalid'}">Invalid user id.</c:when>
            <c:when test="${param.msg == 'notfound'}">User not found.</c:when>
            <c:otherwise>${param.msg}</c:otherwise>
        </c:choose>
    </div>
</c:if>
    <div class="card">
        <div class="card-body">

            <div class="h2" style="margin-bottom:6px;">Manage users</div>
            <div class="muted" style="margin-bottom:14px;">Search and filter user accounts in the system.</div>

            <form action="<%=request.getContextPath()%>/home" method="get" class="filters" style="grid-template-columns: 2fr 1fr auto auto;">
                <input type="hidden" name="p" value="user-list"/>
                <input type="hidden" name="page" value="1"/>

                <div>
                    <label>Search User</label>
                    <input class="input" type="text" name="q"
                           value="<%= q %>"
                           placeholder="e.g. username, email, fullname...">
                </div>

                <div>
                    <label>Status</label>
                    <select class="select" name="status">
                        <option value="" <%= st.isEmpty() ? "selected" : "" %>>All</option>
                        <option value="1" <%= "1".equals(st) ? "selected" : "" %>>Active</option>
                        <option value="0" <%= "0".equals(st) ? "selected" : "" %>>Inactive</option>
                    </select>
                </div>

                <div style="display:flex; align-items:end;">
                    <button class="btn btn-primary" type="submit">Search</button>
                </div>

                <div style="display:flex; align-items:end;">
                    <a class="btn" href="<%=request.getContextPath()%>/home?p=user-list">Reset</a>
                </div>
            </form>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width:80px;" class="text-center">ID</th>
                        <th>Username</th>
                        <th style="width:140px;" class="text-center">Status</th>
                        <th style="width:220px;" class="text-center">Action</th>
                    </tr>
                </thead>

                <tbody>
                    <c:if test="${empty users}">
                        <tr>
                            <td colspan="4" style="text-align:center;">No users found.</td>
                        </tr>
                    </c:if>

                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td class="text-center text-muted">${u.userId}</td>
                            <td class="fw-600">${fn:escapeXml(u.username)}</td>
                            <td class="text-center">
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
                                <div class="d-flex gap-8 align-center justify-center">
                                    <c:choose>
                                        <c:when test="${sessionScope.roleName == 'ADMIN'}">
                                            <a class="btn btn-sm btn-info"
                                               href="${pageContext.request.contextPath}/home?p=user-view&id=${u.userId}">
                                                View
                                            </a>
                                            <a class="btn btn-sm btn-warning"
                                               href="${pageContext.request.contextPath}/home?p=user-update&id=${u.userId}">
                                                Update
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="btn btn-sm btn-info"
                                               href="${pageContext.request.contextPath}/home?p=user-detail&id=${u.userId}">
                                                View
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <c:if test="${totalPages > 1}">
                <div class="paging-footer">
                    <div class="paging-info">Page <b><%= curPage %></b> of <b><%= totalPages %></b></div>
                    <div class="paging">
                        <% if (curPage > 1) { %>
                            <a class="paging-btn" href="<%= base %>&page=<%= (curPage - 1) %>">Prev</a>
                        <% } else { %>
                            <span class="paging-btn disabled">Prev</span>
                        <% } %>

                        <% for (int i = 1; i <= totalPages; i++) { %>
                            <% if (i == curPage) { %>
                                <span class="paging-btn active"><%= i %></span>
                            <% } else { %>
                                <a class="paging-btn" href="<%= base %>&page=<%= i %>"><%= i %></a>
                            <% } %>
                        <% } %>

                        <% if (curPage < totalPages) { %>
                            <a class="paging-btn" href="<%= base %>&page=<%= (curPage + 1) %>">Next</a>
                        <% } else { %>
                            <span class="paging-btn disabled">Next</span>
                        <% } %>
                    </div>
                </div>
            </c:if>

        </div>
    </div>
</div>