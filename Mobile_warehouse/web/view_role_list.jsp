<%-- 
    Document   : view_role_list
    Created on : Jan 11, 2026, 10:51:23 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Role"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Role List</title>
</head>
<body>

<a href="<%=request.getContextPath()%>/home"
   style="display:inline-block; padding:6px 10px; border:1px solid #000; text-decoration:none; color:#000;">
   ← Back
</a>
<br><br>

<h1>Role List</h1>
<h4>Manage roles and permissions</h4>

<form action="<%=request.getContextPath()%>/role_list" method="get">
    Search Role Name:
    <input type="text" name="q"
           value="<%= request.getAttribute("q") != null ? request.getAttribute("q") : "" %>"
           placeholder="e.g. ADMIN">

    Status:
    <select name="status">
        <%
            String status = (String) request.getAttribute("status");
        %>
        <option value="" <%= (status == null || status.isEmpty()) ? "selected" : "" %>>All</option>
        <option value="1" <%= "1".equals(status) ? "selected" : "" %>>Active</option>
        <option value="0" <%= "0".equals(status) ? "selected" : "" %>>Inactive</option>
    </select>

    <button type="submit">Filter</button>
</form>

<br>

<!-- ✅ Nút Active + Add Role ở trên table -->
<div style="width:900px; text-align:right; margin-bottom:8px;">
    <a href="<%=request.getContextPath()%>/admin/role/active-page"
   style="display:inline-block; padding:6px 14px; border:2px solid #1f4aa8; background:#4a86d4;
          color:#000; text-decoration:none; font-weight:600;">
    Active/Deactive
</a>



    <a href="<%=request.getContextPath()%>/add_role.jsp"
       style="display:inline-block; padding:6px 14px; border:2px solid #1f4aa8; background:#4a86d4; color:#000; text-decoration:none; font-weight:600; margin-left:8px;">
        Add Role
    </a>
</div>

<table border="1" cellpadding="8" cellspacing="0" style="min-width:900px;">
    <tr>
        <th>Role ID</th>
        <th>Role Name</th>
        <th>Description</th>
        <th>Users</th>
        <th>Status</th>
        <th>Actions</th>
    </tr>

    <%
        List<Role> roles = (List<Role>) request.getAttribute("roles");
        if (roles == null || roles.isEmpty()) {
    %>
        <tr>
            <td colspan="6">No roles found.</td>
        </tr>
    <%
        } else {
            for (Role r : roles) {
    %>
        <tr>
            <td><%= r.getRoleId() %></td>
            <td><%= r.getRoleName() %></td>
            <td><%= r.getDescription() == null ? "" : r.getDescription() %></td>
            <td><%= r.getUserCount() %></td>
            <td><%= (r.getStatus() == 1 ? "ACTIVE" : "INACTIVE") %></td>
          <td>
    <a href="<%=request.getContextPath()%>/admin/role-detail?roleId=<%=r.getRoleId()%>">
        View Role Detail
    </a>
</td>

        </tr>
    <%
            }
        }
    %>
</table>

</body>
</html>
