<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.Permission"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Role Detail</title>
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
        .btn:hover { opacity:0.9; }
        .wrap { padding: 20px 60px; }
        h2 { margin: 0 0 10px; }
        .panel {
            width: 900px;
            background: #f4f1ea;
            padding: 18px 22px;
            box-sizing: border-box;
        }
        table { border-collapse: collapse; width: 900px; background:#fff; margin-top:10px; }
        th, td { border:1px solid #000; padding:10px; text-align:left; }
        th { text-align:center; font-weight:700; }
        .tick { color: #0aa000; font-weight: 900; font-size: 18px; }
        .right { text-align:right; }
        .msg { color: green; font-weight: 700; margin-bottom: 10px; }
        .error { color: red; font-weight: 700; margin-bottom: 10px; }
    </style>
</head>
<body>

<div class="topbar">
    <a class="btn" href="<%=request.getContextPath()%>/role_list">Back</a>
    <a class="btn" href="<%=request.getContextPath()%>/home">Home</a>
</div>

<div class="wrap">
    <%
        String error = (String) request.getAttribute("error");
        String msg = request.getParameter("msg"); // lấy từ redirect
        Integer roleId = (Integer) request.getAttribute("roleId");
        String roleName = (String) request.getAttribute("roleName");
        List<Permission> rolePerms = (List<Permission>) request.getAttribute("rolePerms");

        if (rolePerms == null) rolePerms = new ArrayList<>();
        if (roleName == null) roleName = "";
    %>

    <% if (error != null) { %>
        <div class="error"><%= error %></div>
    <% } %>

    <% if (msg != null && !msg.isBlank()) { %>
        <div class="msg"><%= msg %></div>
    <% } %>

    <div class="panel">
        <h2><%= roleName %></h2>
        <div style="margin-bottom:6px;"><b>Permissions</b></div>

        <div class="right">
            <a class="btn" href="<%=request.getContextPath()%>/role_permissions?roleId=<%=roleId%>">Update</a>
        </div>

        <table>
            <tr>
                <th style="width:70px;">Status</th>
                <th>Permission</th>
            </tr>

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
                    <td style="text-align:center;"><span class="tick">✓</span></td>
                    <td><%= p.getName() %></td>
                </tr>
            <%
                    }
                }
            %>
        </table>

        <p style="font-size:12px;color:#666;margin-top:8px;">
            * This table shows only permissions currently assigned to this role (not all system permissions).
        </p>
    </div>
</div>
</body>
</html>