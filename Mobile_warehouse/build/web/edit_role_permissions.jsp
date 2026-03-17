<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.Permission"%>
<%
    Integer roleId   = (Integer) request.getAttribute("roleId");
    String roleName  = (String)  request.getAttribute("roleName");
    List<Permission> allPerms = (List<Permission>) request.getAttribute("allPerms");
    Set<Integer> checked      = (Set<Integer>)    request.getAttribute("checked");

    if (roleId == null) {
        try { roleId = Integer.parseInt(request.getParameter("roleId")); }
        catch (Exception e) { roleId = 0; }
    }
    if (allPerms == null) allPerms = new ArrayList<>();
    if (checked  == null) checked  = new HashSet<>();
    if (roleName == null) roleName = "";

    // ✅ Đọc msg từ cả request attribute lẫn query param
    String msg = (String) request.getAttribute("msg");
    if (msg == null || msg.trim().isEmpty()) {
        msg = request.getParameter("msg");
    }
    boolean isSuccess = (msg != null && msg.toLowerCase().contains("success"));
%>

<div class="page-wrap-md">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="<%=request.getContextPath()%>/home?p=role-detail&roleId=<%=roleId%>">← Back</a>
            <h1 class="h1">Edit Role Permissions</h1>
        </div>
    </div>

    <% if (msg != null && !msg.trim().isEmpty()) { %>
        <div class="<%= isSuccess ? "msg-ok" : "msg-err" %>"><b><%= msg %></b></div>
    <% } %>

    <div class="card">
        <div class="card-body">
            <div class="h2" style="margin-bottom:14px;"><%= roleName %> - Permissions</div>

            <form method="post" action="<%=request.getContextPath()%>/role_permissions">
                <input type="hidden" name="roleId" value="<%=roleId%>"/>

                <div class="perm-grid">
                    <% for (Permission p : allPerms) { %>
                        <label class="perm-item">
                            <input type="checkbox" name="permId" value="<%=p.getPermissionId()%>"
                                   <%= checked.contains(p.getPermissionId()) ? "checked" : "" %> />
                            <span>
                                <%= p.getName() %>
                                <span class="muted">(<%=p.getCode()%>)</span>
                            </span>
                        </label>
                    <% } %>
                </div>

                <div class="form-actions">
                    <a class="btn" href="<%=request.getContextPath()%>/home?p=role-detail&roleId=<%=roleId%>">Cancel</a>
                    <button class="btn btn-primary" type="submit">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>
