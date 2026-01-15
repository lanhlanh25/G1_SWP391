<%-- 
    Document   : role_detail
    Created on : Jan 14, 2026, 12:47:45 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
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
    </style>
</head>
<body>

<div class="topbar">
    <a class="btn" href="<%=request.getContextPath()%>/role_list">Back</a>
    <a class="btn" href="<%=request.getContextPath()%>/home">Home</a>
</div>

<div class="wrap">

    <%
        // Lấy role_id từ URL (để demo hiển thị)
        String roleIdStr = request.getParameter("role_id");
        if (roleIdStr == null) roleIdStr = "";

        // Demo role name (sau này bạn load từ DB bằng servlet/DAO rồi setAttribute)
        String roleName = (String) request.getAttribute("roleName");
        if (roleName == null || roleName.isBlank()) {
            roleName = "Admin"; // demo
        }

        // Demo danh sách permission của role (chỉ những quyền role đang có)
        // Sau này bạn thay bằng: List<String> perms = (List<String>) request.getAttribute("rolePerms");
        List<String> perms = (List<String>) request.getAttribute("rolePerms");
        if (perms == null) {
            perms = new ArrayList<>();
            perms.add("Manage Users");
            perms.add("View User List");
            perms.add("Add User");
            perms.add("View Role List");
            perms.add("Edit Role Permissions");
        }
    %>

    <div class="panel">
        <h2><%= roleName %></h2>
        <div style="margin-bottom:6px;"><b>Permissions</b></div>

        <div class="right">
            <button class="btn" type="button">Update</button>
        </div>

        <table>
            <tr>
                <th style="width:70px;">Status</th>
                <th>Permission</th>
            </tr>

            <%
                if (perms.isEmpty()) {
            %>
                <tr>
                    <td colspan="2" style="text-align:center;">This role has no permissions.</td>
                </tr>
            <%
                } else {
                    for (String p : perms) {
            %>
                <tr>
                    <td style="text-align:center;"><span class="tick">✓</span></td>
                    <td><%= p %></td>
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
