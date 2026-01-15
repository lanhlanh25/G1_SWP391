<%-- 
    Document   : active_role
    Created on : Jan 15, 2026, 2:29:40 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Role"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Active/Deactive Roles</title>
    <style>
        body { font-family: Arial; background:#f2f2f2; margin:0; }
        .topbar { padding:10px; }
        .btn {
            display:inline-block;
            padding:6px 14px;
            border:2px solid #1f4aa8;
            background:#4a86d4;
            color:#000;
            text-decoration:none;
            font-weight:600;
            margin-right:8px;
        }
        .wrap { padding: 20px 60px; }
        table { border-collapse:collapse; width:900px; background:#fff; }
        th, td { border:1px solid #000; padding:10px; text-align:center; }
        th { background:#fafafa; }
        .btn-act {
            padding:6px 16px;
            border:2px solid #1f4aa8;
            background:#4a86d4;
            font-weight:700;
            cursor:pointer;
        }
    </style>
</head>
<body>

<div class="topbar">
    <a class="btn" href="<%=request.getContextPath()%>/role_list">Back</a>
    <a class="btn" href="<%=request.getContextPath()%>/home">Home</a>
</div>

<div class="wrap">
    <h2>Active / Deactive Roles</h2>

    <%
        List<Role> roles = (List<Role>) request.getAttribute("roles");
    %>

    <table>
        <tr>
            <th>Role</th>
            <th>Users</th>
            <th>Action</th>
        </tr>

        <%
            if (roles == null || roles.isEmpty()) {
        %>
            <tr><td colspan="3">No roles found.</td></tr>
        <%
            } else {
                for (Role r : roles) {
        %>
            <tr>
                <td><%= r.getRoleName() %></td>
                <td><%= r.getUserCount() %> user(s)</td>
                <td>
                    <form method="post" action="<%=request.getContextPath()%>/admin/role/toggle" style="margin:0;">
                        <input type="hidden" name="roleId" value="<%= r.getRoleId() %>">
                        <%
                            if (r.getStatus() == 1) {
                        %>
                            <button class="btn-act" type="submit"
                                    onclick="return confirm('Deactivate role <%=r.getRoleName()%>?');">
                                Deactive
                            </button>
                        <%
                            } else {
                        %>
                            <button class="btn-act" type="submit"
                                    onclick="return confirm('Activate role <%=r.getRoleName()%>?');">
                                Active
                            </button>
                        <%
                            }
                        %>
                    </form>
                </td>
            </tr>
        <%
                }
            }
        %>
    </table>
</div>

</body>
</html>
