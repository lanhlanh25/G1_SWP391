<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User pu = (User) request.getAttribute("profileUser");
    if (pu == null) pu = (User) session.getAttribute("authUser");
    if (pu == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    String roleName = (String) session.getAttribute("roleName");
    if (roleName == null || roleName.isBlank()) {
        int rid = pu.getRoleId();
        if (rid == 1) roleName = "ADMIN";
        else if (rid == 2) roleName = "MANAGER";
        else if (rid == 3) roleName = "STAFF";
        else if (rid == 4) roleName = "SALE";
        else roleName = "STAFF";
    }
    String avatar  = pu.getAvatar();
    if (avatar == null || avatar.isBlank()) avatar = "assets/default-avatar.jpg";
    String address = pu.getAddress();
    if (address == null) address = "";
    long v = System.currentTimeMillis();
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <title>My Profile</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css"/>
</head>
<body>
<div class="layout">
  <div class="main">
    <div class="page-wrap">

      <div class="topbar">
        <div class="title">My Profile</div>
        <a class="btn" href="javascript:history.back()">← Back</a>
      </div>

      <div style="display:grid; grid-template-columns: 280px 1fr; gap:16px;">

        <div class="card">
          <div class="card-body" style="text-align:center;">
            <img src="<%=request.getContextPath()%>/<%=avatar%>?v=<%=v%>"
                 alt="avatar"
                 style="width:160px; height:160px; border-radius:12px; object-fit:cover; border:1px solid var(--border);"/>
            <div class="small muted" style="margin-top:8px;">Avatar</div>
          </div>
        </div>

        <div class="card">
          <div class="card-header"><span class="h2">User Information</span></div>
          <div class="card-body" style="padding:0;">
            <table class="table">
              <tr><td class="label" style="width:160px;">User ID</td><td><%=pu.getUserId()%></td></tr>
              <tr><td class="label">Username</td><td><%=pu.getUsername()%></td></tr>
              <tr><td class="label">Full Name</td><td><%=pu.getFullName()%></td></tr>
              <tr><td class="label">Email</td><td><%=pu.getEmail()%></td></tr>
              <tr><td class="label">Phone</td><td><%=pu.getPhone()%></td></tr>
              <tr><td class="label">Address</td><td><%=address.isBlank() ? "-" : address%></td></tr>
              <tr><td class="label">Role</td><td><%=roleName%></td></tr>
              <tr>
                <td class="label">Status</td>
                <td>
                  <% if (pu.getStatus() == 1) { %>
                    <span class="badge badge-active">ACTIVE</span>
                  <% } else { %>
                    <span class="badge badge-inactive">INACTIVE</span>
                  <% } %>
                </td>
              </tr>
            </table>
          </div>
        </div>

      </div>
    </div>
  </div>
</div>
</body>
</html>