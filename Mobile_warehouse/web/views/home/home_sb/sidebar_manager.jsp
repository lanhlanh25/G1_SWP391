<%-- 
    Document   : sidebar_manager
    Created on : Jan 13, 2026, 1:47:24 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>MANAGER MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
    <li><a href="<%=ctx%>/home?p=reports">Weekly Reports</a></li>

    <li><a href="<%=ctx%>/home?p=user-list">View User List</a></li>
    <li><a href="<%=ctx%>/home?p=user-detail">View User Detail</a></li>

    <li><a href="<%=ctx%>/home?p=profile">My Profile</a></li>
    <li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>
