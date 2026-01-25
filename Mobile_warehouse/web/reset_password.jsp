<%-- 
    Document   : reset_password
    Created on : Jan 16, 2026, 2:46:31 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    String ctx = request.getContextPath();
    String err = (String) request.getAttribute("err");
    User u = (User) request.getAttribute("user");
    Integer uid = (Integer) request.getAttribute("uid");
    String token = (String) request.getAttribute("token");
%>

<!DOCTYPE html>
<html>
    <head><meta charset="UTF-8"><title>Reset Password</title></head>
    <body>

        <h2>Reset Password</h2>

        <% if (u != null) { %>
        <p>Hello <b><%=u.getFullName()%></b> (<%=u.getUsername()%>), please set your new password.</p>
        <% } %>

        <% if (err != null) { %>
        <p style="color:red;"><%=err%></p>
        <% } %>

        <form method="post" action="<%=ctx%>/reset-password">
            <input type="hidden" name="uid" value="<%= uid != null ? uid : "" %>">
            <input type="hidden" name="token" value="<%= token != null ? token : "" %>">

            <p>New password:</p>
            <input type="password" name="new_password" required>

            <p>Confirm password:</p>
            <input type="password" name="confirm_password" required>

            <p><button type="submit">Update Password</button></p>
        </form>

        <p><a href="<%=ctx%>/login">Back to login</a></p>
    </body>
</html>

