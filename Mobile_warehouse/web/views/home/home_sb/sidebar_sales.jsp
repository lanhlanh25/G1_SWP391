<%-- 
    Document   : sidebar_sales
    Created on : Jan 13, 2026, 1:47:48 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>SALE MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
    <li><a href="<%=ctx%>/home?p=inventory">View Inventory</a></li>
    <li><a href="<%=ctx%>/home?p=create-out">Create Outbound Request</a></li>

    <li><a href="<%=ctx%>/home?p=profile">My Profile</a></li>
    <li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>
