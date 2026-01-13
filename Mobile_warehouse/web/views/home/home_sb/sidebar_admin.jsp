<%-- 
    Document   : sidebar_admin
    Created on : Jan 13, 2026, 1:47:14 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>ADMIN MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>

    <li><a href="<%=ctx%>/home?p=user-list">User List</a></li>
    <li><a href="<%=ctx%>/home?p=user-add">Add User</a></li>
    <li><a href="<%=ctx%>/home?p=user-update">Update User</a></li>
    <li><a href="<%=ctx%>/home?p=user-toggle">Active/Deactive User</a></li>

    <li><a href="<%=ctx%>/home?p=role-list">Role List</a></li>
    <li><a href="<%=ctx%>/home?p=role-update">Update Role</a></li>
    <li><a href="<%=ctx%>/home?p=role-toggle">Active/Deactive Role</a></li>

    <li><a href="<%=ctx%>/home?p=role-perm-view">View Role Permissions</a></li>
    <li><a href="<%=ctx%>/home?p=role-perm-edit">Edit Role Permissions</a></li>

    <li><a href="<%=ctx%>/home?p=profile">My Profile</a></li>
    <li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>
