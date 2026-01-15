<%-- 
    Document   : login.jsp
    Created on : Jan 13, 2026, 2:56:12 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String err = (String) request.getAttribute("err");
    String usernameVal = (String) request.getAttribute("usernameVal");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login</title>
</head>
<body>

<h2>LOGIN</h2>

<% if (err != null) { %>
    <p style="color:red;"><%= err %></p>
<% } %>

<form method="post" action="<%=ctx%>/login">
    <p>
        Username:
        <input type="text" name="username" value="<%= usernameVal != null ? usernameVal : "" %>" required>
    </p>
    <p>
        Password:
        <input type="password" name="password" required>
    </p>
    <p>
        <button type="submit">Login</button>
    </p>
</form>

<p>
    <a href="<%=ctx%>/forgot-password">Forgot password?</a>
</p>

</body>
</html>