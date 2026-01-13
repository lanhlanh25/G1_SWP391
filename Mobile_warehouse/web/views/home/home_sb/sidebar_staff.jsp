<%-- 
    Document   : sidebar_staff
    Created on : Jan 13, 2026, 1:47:36 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>STAFF MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
    <li><a href="<%=ctx%>/home?p=inbound">Inbound (GRN)</a></li>
    <li><a href="<%=ctx%>/home?p=outbound">Outbound (GIN)</a></li>
    <li><a href="<%=ctx%>/home?p=stock-count">Stock Count</a></li>

    <li><a href="<%=ctx%>/home?p=profile">My Profile</a></li>
    <li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>
