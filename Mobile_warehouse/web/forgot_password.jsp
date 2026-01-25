<%-- 
    Document   : forget_password
    Created on : Jan 16, 2026, 2:45:43 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String err = (String) request.getAttribute("err");
    String emailVal = (String) request.getAttribute("emailVal");
    String msg = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Forgot Password</title>
</head>
<body>
<h2>Forgot Password</h2>

<% if (err != null) { %>
<p style="color:red;"><%=err%></p>
<% } %>
<% if (msg != null) { %>
  <p style="color:green;"><%=msg%></p>
<% } %>

<form method="post" action="<%=ctx%>/forgot-password">
    <p>Email:</p>
    <input type="email" name="email" value="<%= emailVal != null ? emailVal : "" %>" required>
    <p><button type="submit">Send Request to Admin</button></p>
</form>

<p><a href="<%=ctx%>/login">Back to login</a></p>
</body>
</html>
