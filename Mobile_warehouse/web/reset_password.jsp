<%-- 
    Document   : reset_password
    Created on : Jan 16, 2026, 2:46:31 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String err = (String) request.getAttribute("err");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reset Password</title>
</head>
<body>
<h2>Reset Password</h2>

<% if (err != null) { %>
<p style="color:red;"><%=err%></p>
<% } %>

<form method="post" action="<%=ctx%>/reset-password">
    <p>New password:</p>
    <input type="password" name="new_password" required>

    <p>Confirm new password:</p>
    <input type="password" name="confirm_password" required>

    <p><button type="submit">Reset Password</button></p>
</form>

<p><a href="<%=ctx%>/login">Back to login</a></p>
</body>
</html>
