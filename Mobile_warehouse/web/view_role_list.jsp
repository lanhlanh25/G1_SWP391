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
    <a href="<%=request.getContextPath()%>/index.html"
   style="display:inline-block; padding:6px 10px; border:1px solid #000; text-decoration:none; color:#000;">
   ← Back
</a>
<br><br>

    <title>Role List</title>
</head>
<body>

    <h1>Role List</h1>
    <h4>Manage roles and permissions</h4>

    <form action="<%=request.getContextPath()%>/role_list" method="get">
        Search Role Name:
        <input type="text" name="q" value="<%= request.getAttribute("q") != null ? request.getAttribute("q") : "" %>"
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
                    <!-- View Permissions (demo link) -->
                    <a href="<%=request.getContextPath()%>/role_permissions?roleId=<%=r.getRoleId()%>">View Permissions</a>

                    &nbsp; | &nbsp;

                    <!-- Toggle Active/Inactive -->
                    <form action="<%=request.getContextPath()%>/role_toggle" method="post" style="display:inline;">
                        <input type="hidden" name="roleId" value="<%=r.getRoleId()%>">
                        <button type="submit">
                            <%= (r.getStatus() == 1 ? "Deactivate" : "Activate") %>
                        </button>
                    </form>
                </td>
            </tr>
        <%
                }
            }
        %>
    </table>

</body>
</html>
