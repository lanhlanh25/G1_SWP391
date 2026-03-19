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
    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <a class="btn" href="<%=request.getContextPath()%>/home?p=dashboard">← Back</a>
            <h1 class="h1">Role Management</h1>
        </div>

        <div class="d-flex gap-8 align-center">
            <a class="btn btn-outline" href="<%=request.getContextPath()%>/home?p=role-toggle">Toggle Status</a>
            <a class="btn btn-primary" href="<%=request.getContextPath()%>/home?p=role-add">+ Add Role</a>
        </div>
    </div>

    <div class="card mb-16">
        <div class="card-body">
            <form action="<%=request.getContextPath()%>/home" method="get" class="filters">
                <input type="hidden" name="p" value="role-list"/>

                <div class="filter-group">
                    <label class="label">Search</label>
                    <input class="input" type="text" name="q" value="<%= q %>" placeholder="Role name...">
                </div>

                <div class="filter-group">
                    <label class="label">Status</label>
                    <select class="input" name="status">
                        <option value=""  <%= statusParam.isEmpty() ? "selected" : "" %>>All Statuses</option>
                        <option value="1" <%= "1".equals(statusParam) ? "selected" : "" %>>Active</option>
                        <option value="0" <%= "0".equals(statusParam) ? "selected" : "" %>>Inactive</option>
                    </select>
                </div>

                <div class="filter-actions d-flex gap-8 align-end">
                    <button class="btn btn-primary" type="submit">Apply</button>
                    <a class="btn btn-outline" href="<%=request.getContextPath()%>/home?p=role-list">Reset</a>
                </div>
            </form>
        </div>
    </div>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width:100px;">ID</th>
                        <th style="width:200px;">Role Name</th>
                        <th>Description</th>
                        <th style="width:100px;" class="text-center">Users</th>
                        <th style="width:120px;" class="text-center">Status</th>
                        <th style="width:160px;" class="text-center">Action</th>
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
                        <td class="fw-600"><%= r.getRoleName() %></td>
                        <td><%= r.getDescription() == null ? "" : r.getDescription() %></td>
                        <td class="text-center"><%= r.getUserCount() %></td>
                        <td class="text-center">
                            <% if (r.getStatus() == 1) { %>
                                <span class="badge badge-active">Active</span>
                            <% } else { %>
                                <span class="badge badge-inactive">Inactive</span>
                            <% } %>
                        </td>
                        <td>
                            <div class="d-flex justify-center">
                                <a class="btn btn-sm btn-info"
                                   href="<%=request.getContextPath()%>/home?p=role-detail&roleId=<%=r.getRoleId()%>">
                                    View Detail
                                </a>
                            </div>
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