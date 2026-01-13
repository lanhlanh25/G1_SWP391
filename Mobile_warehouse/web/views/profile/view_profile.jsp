<%-- 
    Document   : view_profile
    Created on : Jan 13, 2026, 1:46:22 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User pu = (User) request.getAttribute("profileUser"); // ưu tiên lấy từ request
    if (pu == null) {
        pu = (User) session.getAttribute("authUser");     // fallback session
    }
    if (pu == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>

<h3>My Profile</h3>

<table border="1" cellpadding="6" cellspacing="0">
    <tr><td>User ID</td><td><%= pu.getUserId() %></td></tr>
    <tr><td>Username</td><td><%= pu.getUsername() %></td></tr>
    <tr><td>Full Name</td><td><%= pu.getFullName() %></td></tr>
    <tr><td>Email</td><td><%= pu.getEmail() %></td></tr>
    <tr><td>Phone</td><td><%= pu.getPhone() %></td></tr>
    <tr><td>Role</td><td><%= pu.getRoleName() %></td></tr>
    <tr><td>Status</td><td><%= pu.getStatus() == 1 ? "ACTIVE" : "INACTIVE" %></td></tr>
</table>
