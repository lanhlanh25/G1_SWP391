<%-- 
    Document   : content
    Created on : Jan 13, 2026, 3:00:16 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User u = (User) session.getAttribute("authUser");
    if (u == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    String role = (String) session.getAttribute("roleName");
    if (role == null || role.isBlank()) {
        int rid = u.getRoleId();
        if (rid == 1) role = "ADMIN";
        else if (rid == 2) role = "MANAGER";
        else if (rid == 3) role = "STAFF";
        else if (rid == 4) role = "SALE";
        else role = "STAFF";
    }
    role = role.toUpperCase();
    String p = (String) request.getAttribute("currentPage");
    if (p == null) p = "dashboard";
    String ctx = request.getContextPath();
%>

<div class="page-wrap">

  <% if ("dashboard".equals(p)) { %>
    <div class="topbar">
      <div class="title">Dashboard</div>
      <span class="badge badge-info"><%=role%></span>
    </div>
    <div class="card">
      <div class="card-body">
        <p class="small">You are logged in as <b><%=role%></b>. Select a menu item on the left to get started.</p>
      </div>
    </div>

  <% } else if ("profile".equals(p)) { %>
    <jsp:include page="/view_profile.jsp" />

  <% } else if ("change-password".equals(p)) { %>
    <div class="topbar"><div class="title">Change Password</div></div>
    <div class="card">
      <div class="card-body">
        <a class="btn btn-primary" href="<%=ctx%>/changepassword">Open Change Password</a>
      </div>
    </div>

  <% } else if ("denied".equals(p)) { %>
    <div class="topbar"><div class="title">Access Denied</div></div>
    <div class="card">
      <div class="card-body">
        <p class="msg-err">You do not have permission to access this page.</p>
      </div>
    </div>

  <% } else if ("ADMIN".equals(role) && "role-list".equals(p)) { %>
    <div class="topbar"><div class="title">Role List</div></div>
    <div class="card">
      <div class="card-body">
        <a class="btn btn-primary" href="<%=ctx%>/role_list">Open Role List</a>
      </div>
    </div>

  <% } else if ("ADMIN".equals(role) && "role-perm-edit".equals(p)) { %>
    <div class="topbar"><div class="title">Role Permissions</div></div>
    <div class="card">
      <div class="card-body">
        <p class="small">Go to Role List and click <b>View Permissions</b> to edit permissions.</p>
        <a class="btn btn-outline" href="<%=ctx%>/role_list">→ Go to Role List</a>
      </div>
    </div>

  <% } else { %>
    <div class="topbar"><div class="title">Not Found</div></div>
    <div class="card">
      <div class="card-body"><p class="msg-err">Page not found!</p></div>
    </div>
  <% } %>

</div>