<%-- 
    Document   : view_profile
    Created on : Jan 13, 2026, 3:00:47 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User pu = (User) request.getAttribute("profileUser");
    if (pu == null) pu = (User) session.getAttribute("authUser");
    if (pu == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String roleName = (String) session.getAttribute("roleName");
    if (roleName == null || roleName.isBlank()) {
        int rid = pu.getRoleId();
        if (rid == 1) roleName = "ADMIN";
        else if (rid == 2) roleName = "MANAGER";
        else if (rid == 3) roleName = "STAFF";
        else if (rid == 4) roleName = "SALE";
        else roleName = "STAFF";
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>My Profile</title>
    </head>
    <body>


        <a href="javascript:history.back()">Back</a>

        <h3>My Profile</h3>

        <table border="1" cellpadding="6" cellspacing="0">
            <tr><td>User ID</td><td><%= pu.getUserId() %></td></tr>
            <tr><td>Username</td><td><%= pu.getUsername() %></td></tr>
            <tr><td>Full Name</td><td><%= pu.getFullName() %></td></tr>
            <tr><td>Email</td><td><%= pu.getEmail() %></td></tr>
            <tr><td>Phone</td><td><%= pu.getPhone() %></td></tr>
            <tr><td>Role</td><td><%= roleName %></td></tr>
            <tr><td>Status</td><td><%= pu.getStatus() == 1 ? "ACTIVE" : "INACTIVE" %></td></tr>
        </table>

    </body>
</html>