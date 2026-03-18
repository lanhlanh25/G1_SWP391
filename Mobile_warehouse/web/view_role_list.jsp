<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Role"%>

<%
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    String q = request.getParameter("q") != null ? request.getParameter("q") : "";
    String statusParam = request.getParameter("status");
    if (statusParam == null) statusParam = "";
%>

<div class="page-wrap">
    <div class="topbar mb-20">
        <div class="d-flex align-center gap-10">
            <a class="btn btn-outline" href="<%=request.getContextPath()%>/home?p=dashboard">← Back</a>
            <h1 class="h1 m-0">Role List</h1>
        </div>

        <div class="d-flex gap-8 flex-wrap">
            <a class="btn btn-outline" href="<%=request.getContextPath()%>/home?p=role-toggle">Active/Deactive</a>
            <a class="btn btn-primary" href="<%=request.getContextPath()%>/home?p=role-add">Add Role</a>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="h2 mb-6">Manage roles and permissions</div>
            <div class="muted mb-14">Filter roles by name and status.</div>

            <form action="<%=request.getContextPath()%>/home" method="get" class="filters grid-role-filter">
                <input type="hidden" name="p" value="role-list"/>

                <div>
                    <label>Search Role Name</label>
                    <input class="input" type="text" name="q" value="<%= q %>" placeholder="e.g. ADMIN">
                </div>

                <div>
                    <label>Status</label>
                    <select class="select" name="status">
                        <option value=""  <%= statusParam.isEmpty() ? "selected" : "" %>>All</option>
                        <option value="1" <%= "1".equals(statusParam) ? "selected" : "" %>>Active</option>
                        <option value="0" <%= "0".equals(statusParam) ? "selected" : "" %>>Inactive</option>
                    </select>
                </div>

                <div class="d-flex gap-8">
                    <button class="btn btn-primary" type="submit">Filter</button>
                    <a class="btn" href="<%=request.getContextPath()%>/home?p=role-list">Reset</a>
                </div>
            </form>

            <table class="table">
                <thead>
                    <tr>
                        <th>Role ID</th>
                        <th>Role Name</th>
                        <th>Description</th>
                        <th>Users</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (roles == null || roles.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="6" class="text-center">No roles found.</td>
                    </tr>
                    <%
                        } else {
                            for (Role r : roles) {
                    %>
                    <tr>
                        <td><%= r.getRoleId() %></td>
                        <td><b><%= r.getRoleName() %></b></td>
                        <td><%= r.getDescription() == null ? "" : r.getDescription() %></td>
                        <td><%= r.getUserCount() %></td>
                        <td>
                            <% if (r.getStatus() == 1) { %>
                                <span class="badge badge-active">ACTIVE</span>
                            <% } else { %>
                                <span class="badge badge-inactive">INACTIVE</span>
                            <% } %>
                        </td>
                        <td>
                            <a class="btn btn-sm btn-outline"
                               href="<%=request.getContextPath()%>/home?p=role-detail&roleId=<%=r.getRoleId()%>">
                                View Role Detail
                            </a>
                        </td>
                    </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>