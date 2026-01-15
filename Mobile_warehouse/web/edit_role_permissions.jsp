<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.Permission"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Role Permissions</title>
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
            cursor:pointer;
        }
        .btn:hover { opacity:0.9; }
        .wrap { padding: 20px 60px; }
        .panel {
            width: 900px;
            background: #f4f1ea;
            padding: 18px 22px;
            box-sizing: border-box;
        }
        .actions { text-align: right; margin-top: 22px; }
        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px 60px;
            margin-top: 10px;
            padding: 10px 0;
        }
        .item { font-size: 16px; }
        .muted { font-size: 12px; color: #555; margin-left: 6px; }
        .msg-success { color: green; font-weight: 700; margin-bottom: 10px; }
        .msg-fail { color: red; font-weight: 700; margin-bottom: 10px; }
    </style>
</head>
<body>

<%
    Integer roleId = (Integer) request.getAttribute("roleId");
    String roleName = (String) request.getAttribute("roleName");
    List<Permission> allPerms = (List<Permission>) request.getAttribute("allPerms");
    Set<Integer> checked = (Set<Integer>) request.getAttribute("checked");

    if (roleId == null) {
        try { roleId = Integer.parseInt(request.getParameter("roleId")); }
        catch (Exception e) { roleId = 0; }
    }
    if (allPerms == null) allPerms = new ArrayList<>();
    if (checked == null) checked = new HashSet<>();
    if (roleName == null) roleName = "";

    // ✅ nhận msg theo cả 2 kiểu: forward(setAttribute) hoặc redirect(parameter)
    String msg = (String) request.getAttribute("msg");
    if (msg == null || msg.trim().isEmpty()) {
        msg = request.getParameter("msg");
    }
    boolean isSuccess = (msg != null && msg.toLowerCase().contains("success"));
%>

<div class="topbar">
    <a class="btn" href="<%=request.getContextPath()%>/role_list">Back</a>
    <a class="btn" href="<%=request.getContextPath()%>/home">Home</a>
</div>

<div class="wrap">
    <div class="panel">
        <div style="font-weight:700; margin-bottom: 8px;">
            <%= roleName %> - Permissions
        </div>

        <%-- ✅ Hiện message sau khi update --%>
        <% if (msg != null && !msg.trim().isEmpty()) { %>
            <div class="<%= isSuccess ? "msg-success" : "msg-fail" %>">
                <%= msg %>
            </div>
        <% } %>

        <form method="post" action="<%=request.getContextPath()%>/role_permissions">
            <input type="hidden" name="roleId" value="<%=roleId%>"/>

            <div class="grid">
                <% for (Permission p : allPerms) { %>
                    <label class="item">
                        <input type="checkbox" name="permId" value="<%=p.getPermissionId()%>"
                               <%= checked.contains(p.getPermissionId()) ? "checked" : "" %> />
                        <%= p.getName() %>
                        <span class="muted">(<%= p.getCode() %>)</span>
                    </label>
                <% } %>
            </div>

            <div class="actions">
                <button class="btn" type="submit">Update</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>
