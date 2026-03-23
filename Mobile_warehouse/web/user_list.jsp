<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page import="java.net.URLEncoder"%>

<%
    Integer pageObj = (Integer) request.getAttribute("page");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");

    int curPage = (pageObj == null) ? 1 : pageObj;
    int totalPages = (totalPagesObj == null) ? 1 : totalPagesObj;

    String q = (String) request.getAttribute("q");
    String st = (String) request.getAttribute("status");
    Integer totalItemsObj = (Integer) request.getAttribute("totalItems");
    Integer pageSizeObj = (Integer) request.getAttribute("pageSize");

    if (q == null) q = "";
    if (st == null) st = "";
    int totalItems = (totalItemsObj == null) ? 0 : totalItemsObj;
    int pageSize = (pageSizeObj == null) ? 5 : pageSizeObj;

    String base = request.getContextPath() + "/home?p=user-list"
            + (!q.isEmpty() ? "&q=" + URLEncoder.encode(q, "UTF-8") : "")
            + (!st.isEmpty() ? "&status=" + st : "");
%>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">User /</span> User Management
</h4>

<c:if test="${not empty param.msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        <c:choose>
            <c:when test="${param.msg == 'updated'}">User updated successfully.</c:when>
            <c:when test="${param.msg == 'invalid'}">Invalid user id.</c:when>
            <c:when test="${param.msg == 'notfound'}">User not found.</c:when>
            <c:otherwise>${param.msg}</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="card mb-4">
    <div class="card-body">
        <form action="<%=request.getContextPath()%>/home" method="get" class="row g-3">
            <input type="hidden" name="p" value="user-list"/>
            <input type="hidden" name="page" value="1"/>

            <div class="col-md-6 col-lg-5">
                <label class="form-label">Search User</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control" name="q" value="<%= q %>" placeholder="username, email, fullname..."/>
                </div>
            </div>

            <div class="col-md-3 col-lg-3">
                <label class="form-label">Status</label>
                <select class="form-select" name="status">
                    <option value="" <%= st.isEmpty() ? "selected" : "" %>>All Status</option>
                    <option value="1" <%= "1".equals(st) ? "selected" : "" %>>Active</option>
                    <option value="0" <%= "0".equals(st) ? "selected" : "" %>>Inactive</option>
                </select>
            </div>

            <div class="col-md-3 col-lg-4 d-flex align-items-end gap-2">
                <button class="btn btn-primary" type="submit">Search</button>
                <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/home?p=user-list"><i class="bx bx-refresh"></i></a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">User List</h5>
        <div class="d-flex gap-2">
            <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/home?p=user-toggle"><i class="bx bx-toggle-right me-1"></i> Quick Toggle</a>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/home?p=user-add"><i class="bx bx-plus me-1"></i> Add User</a>
        </div>
    </div>
    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th class="text-center" style="width: 80px;">ID</th>
                    <th>Username</th>
                    <th class="text-center">Status</th>
                    <th class="text-center">Action</th>
                </tr>
            </thead>
            <tbody class="table-border-bottom-0">
                <c:if test="${empty users}">
                    <tr>
                        <td colspan="4" class="text-center p-4">No users found matching your search.</td>
                    </tr>
                </c:if>

                <c:forEach var="u" items="${users}">
                    <tr>
                        <td class="text-center"><span class="fw-semibold text-muted">${u.userId}</span></td>
                        <td><strong>${fn:escapeXml(u.username)}</strong></td>
                        <td class="text-center">
                            <span class="badge ${u.status == 1 ? 'bg-label-success' : 'bg-label-secondary'}">
                                ${u.status == 1 ? 'Active' : 'Inactive'}
                            </span>
                        </td>
                        <td class="text-center">
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>
                                <div class="dropdown-menu">
                                    <c:choose>
                                        <c:when test="${sessionScope.roleName == 'ADMIN'}">
                                            <a class="dropdown-item" href="${ctx}/home?p=user-view&id=${u.userId}"><i class="bx bx-show-alt me-1"></i> View Details</a>
                                            <a class="dropdown-item" href="${ctx}/home?p=user-update&id=${u.userId}"><i class="bx bx-edit-alt me-1"></i> Edit Account</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="dropdown-item" href="${ctx}/home?p=user-detail&id=${u.userId}"><i class="bx bx-show-alt me-1"></i> View</a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <div class="card-footer d-flex justify-content-between align-items-center">
        <div class="text-muted small">
            Page <strong><%= curPage %></strong> of <strong><%= totalPages %></strong>
        </div>

        <nav aria-label="Page navigation">
            <ul class="pagination pagination-sm mb-0">
                <%-- Prev Button --%>
                <% if (curPage > 1) { %>
                    <li class="page-item"><a class="page-link" href="<%= base %>&page=<%= (curPage - 1) %>"><i class="bx bx-chevron-left"></i></a></li>
                <% } else { %>
                    <li class="page-item disabled"><span class="page-link"><i class="bx bx-chevron-left"></i></span></li>
                <% } %>

                <%-- Sliding Window logic --%>
                <% 
                    int start = Math.max(1, curPage - 1);
                    int end = Math.min(totalPages, start + 2);
                    if (end == totalPages) {
                        start = Math.max(1, end - 2);
                    }
                %>
                
                <% if (start > 1) { %>
                    <li class="page-item"><a class="page-link" href="<%= base %>&page=1">1</a></li>
                    <% if (start > 2) { %><li class="page-item disabled"><span class="page-link">...</span></li><% } %>
                <% } %>

                <% for (int i = start; i <= end; i++) { %>
                    <li class="page-item <%= i == curPage ? "active" : "" %>">
                        <a class="page-link" href="<%= base %>&page=<%= i %>"><%= i %></a>
                    </li>
                <% } %>

                <% if (end < totalPages) { %>
                    <% if (end < totalPages - 1) { %><li class="page-item disabled"><span class="page-link">...</span></li><% } %>
                    <li class="page-item"><a class="page-link" href="<%= base %>&page=<%= totalPages %>"><%= totalPages %></a></li>
                <% } %>

                <%-- Next Button --%>
                <% if (curPage < totalPages) { %>
                    <li class="page-item"><a class="page-link" href="<%= base %>&page=<%= (curPage + 1) %>"><i class="bx bx-chevron-right"></i></a></li>
                <% } else { %>
                    <li class="page-item disabled"><span class="page-link"><i class="bx bx-chevron-right"></i></span></li>
                <% } %>
            </ul>
        </nav>
    </div>
</div>