<%-- 
    Document   : sidebar_admin
    Created on : Jan 13, 2026, 3:01:59 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% String ctx = request.getContextPath(); %>

<div class="section-title">Overview</div>
<ul>
  <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
</ul>

<div class="section-title">Users</div>
<ul>
  <li>
    <details open>
      <summary>User Management</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=user-list">User List</a></li>
        <li><a href="<%=ctx%>/home?p=user-add">Add User</a></li>
      </ul>
    </details>
  </li>
</ul>

<div class="section-title">Access & Security</div>
<ul>
  <li><a href="<%=ctx%>/home?p=role-list">Role List</a></li>
  <li><a href="<%=ctx%>/home?p=admin/reset-requests">Password Reset Requests</a></li>
</ul>