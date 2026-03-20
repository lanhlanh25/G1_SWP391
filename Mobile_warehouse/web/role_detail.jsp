<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.Permission"%>

<%
    String error = (String) request.getAttribute("error");
    String msg = request.getParameter("msg");
    Integer roleId = (Integer) request.getAttribute("roleId");
    String roleName = (String) request.getAttribute("roleName");
    List<Permission> rolePerms = (List<Permission>) request.getAttribute("rolePerms");

    if (rolePerms == null) rolePerms = new ArrayList<>();
    if (roleName == null) roleName = "";
%>

<div class="page-wrap-md">
    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Role Detail</h1>
        </div>

        <div class="d-flex gap-8 align-center">
            <a class="btn btn-primary"
               href="<%=request.getContextPath()%>/home?p=role-permissions&roleId=<%=roleId%>">
                Update Permissions
            </a>
            <a class="btn btn-outline" href="<%=request.getContextPath()%>/home?p=role-list">← Back</a>
        </div>
    </div>

    <% if (error != null) { %>
        <div class="msg-err"><%= error %></div>
    <% } %>

    <% if (msg != null && !msg.isBlank()) { %>
        <div class="msg-ok"><%= msg %></div>
    <% } %>

    <div class="card">
        <div class="card-body">
            <div class="h2 mb-4 uppercase text-muted fs-12">Role Name</div>
            <div class="h1 mb-24"><%= roleName %></div>
            
            <div class="h2 mb-12">Assigned Permissions</div>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width:120px;" class="text-center">Status</th>
                        <th>Permission Name</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (rolePerms.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="2" style="text-align:center;">This role has no permissions.</td>
                    </tr>
                    <%
                        } else {
                            for (Permission p : rolePerms) {
                    %>
                    <tr>
                        <td class="text-center">
                            <span class="badge badge-active">Active</span>
                        </td>
                        <td><%= p.getName() %></td>
                    </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>

            <div class="field-hint" style="margin-top:12px;">
                This table shows only permissions currently assigned to this role.
            </div>
        </div>
    </div>
</div>