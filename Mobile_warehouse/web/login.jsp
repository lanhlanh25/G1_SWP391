<%-- 
    Document   : login.jsp
    Created on : Jan 13, 2026, 2:56:12 PM
    Author     : Admin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>System Login - WMS</title>
  <%@ include file="/WEB-INF/jspf/common_head.jspf" %>
  <%-- Styles moved to app.css --%>
</head>
<body class="auth-body">

<div class="auth-container">
  <div class="auth-card">
    <div class="auth-header">
      <div class="auth-brand">MW</div>
      <h1 class="h1">Sign in</h1>
      <p class="muted">Enter your details to access your account</p>
    </div>

    <%
      String err = (String) request.getAttribute("err");
      String usernameVal = (String) request.getAttribute("usernameVal");
      String passwordVal = (String) request.getAttribute("passwordVal");
      String rememberVal = (String) request.getAttribute("rememberVal");
      if (usernameVal == null) usernameVal = "";
      if (passwordVal == null) passwordVal = "";
      if (rememberVal == null) rememberVal = "";
      if (err != null && !err.isBlank()) {
    %>
      <div class="alert alert-danger mb-24"><%= err %></div>
    <% } %>

    <form action="<%=ctx%>/login" method="post" autocomplete="on">
      
      <div class="form-group mb-24">
        <label class="form-label">Username</label>
        <input class="input" type="text" name="username" placeholder="Enter your username" value="<%= usernameVal %>" required>
      </div>

      <div class="form-group mb-24">
        <label class="form-label">Password</label>
        <input class="input" type="password" name="password" placeholder="••••••••" value="<%= passwordVal %>" required>
      </div>

      <div class="d-flex justify-between align-center mb-24 font-sm">
        <label class="d-flex align-center gap-8 muted fw-600 pointer">
          <input type="checkbox" name="remember" value="true" <%= rememberVal %>>
          Keep me signed in
        </label>
        <a href="<%=ctx%>/forgot-password" class="link fw-700">Forgot password?</a>
      </div>

      <button type="submit" class="btn btn-primary w-100 p-14 h-auto">Login to Account</button>
    </form>
  </div>
</div>

</body>
</html>