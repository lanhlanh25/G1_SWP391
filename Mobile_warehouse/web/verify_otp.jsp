<%-- 
    Document   : verify_otp
    Created on : Jan 16, 2026, 2:46:08 AM
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
    <title>Verify OTP</title>
</head>
<body>
<h2>Verify OTP</h2>

<% if (err != null) { %>
<p style="color:red;"><%=err%></p>
<% } %>

<form method="post" action="<%=ctx%>/verify-otp">
    <p>Enter OTP (6 digits):</p>
    <input type="text" name="otp" maxlength="6" required>
    <p><button type="submit">Verify</button></p>
</form>

<p><a href="<%=ctx%>/forgot-password">Back</a></p>
</body>
</html>
