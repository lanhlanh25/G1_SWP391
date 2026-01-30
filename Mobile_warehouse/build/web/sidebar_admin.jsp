<%-- 
    Document   : sidebar_admin
    Created on : Jan 13, 2026, 3:01:59 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>ADMIN MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
    <li><a href="<%=ctx%>/admin/reset-requests">Password Reset Requests</a></li>

    <li><a href="<%=ctx%>/home?p=user-list">User List</a></li>
    <li><a href="<%=ctx%>/home?p=user-add">Add User</a></li>
    
    

    <%--<li><a href="<%=ctx%>/role_list">Role List</a></li>--%>
    <li><a href="<%=ctx%>/home?p=role-list">Role List</a></li>
    <%--<li><a href="<%=ctx%>/home?p=role-update">Update Role</a></li>--%>
   



    <li><a href="${pageContext.request.contextPath}/home?p=my-profile">My Profile</a></li>
    <li><a href="${pageContext.request.contextPath}/home?p=change-password">Change Password</a></li>

    <%--<li><a href="<%=ctx%>/profile">My Profile</a></li>
    <li><a href="<%=ctx%>/change_password">Change Password</a></li>--%>
</ul>

