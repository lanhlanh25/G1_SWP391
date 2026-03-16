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
  <style>
/* Modern Phoenix Theme Login */
body, html {
  margin: 0;
  padding: 0;
  min-height: 100vh;
  font-family: 'Nunito Sans', sans-serif;
  background: radial-gradient(circle, rgba(241, 245, 249, 0.6) 0%, rgba(203, 213, 225, 0.7) 100%), 
              url('<%=ctx%>/assets/images/warehouse_bg.png') center/cover no-repeat;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login-container {
  width: 100%;
  max-width: 440px;
  padding: 20px;
}

.login-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 48px 40px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.login-brand {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  background: var(--primary);
  color: #fff;
  border-radius: 12px;
  font-weight: 900;
  font-size: 18px;
  margin-bottom: 16px;
}

.login-header h1 {
  font-size: 24px;
  font-weight: 800;
  color: var(--text);
  margin: 0;
  letter-spacing: -0.025em;
}

.login-header p {
  font-size: 14px;
  color: var(--text-2);
  margin: 8px 0 0;
}

.input-grp {
  margin-bottom: 24px;
  position: relative;
}

.input-grp label {
  display: block;
  font-size: 13px;
  font-weight: 700;
  color: var(--text);
  margin-bottom: 8px;
}

.input-grp input {
  width: 100%;
  padding: 12px 16px;
  border-radius: 10px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  color: var(--text);
  font-size: 14px;
  font-family: inherit;
  outline: none;
  transition: all 0.2s ease;
  box-sizing: border-box;
}

.input-grp input:focus {
  background: #fff;
  border-color: var(--primary);
  box-shadow: 0 0 0 4px rgba(60, 80, 224, 0.1);
}

.row-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  font-size: 13px;
}

.remember-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  color: var(--text-2);
  font-weight: 600;
}

.remember-label input {
  width: 16px;
  height: 16px;
  cursor: pointer;
  accent-color: var(--primary);
}

.forgot-link {
  color: var(--primary);
  font-weight: 700;
  text-decoration: none;
}

.forgot-link:hover {
  text-decoration: underline;
}

.btn-login {
  width: 100%;
  padding: 14px;
  border-radius: 10px;
  border: none;
  background: var(--primary);
  color: #fff;
  font-size: 15px;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 6px -1px rgba(60, 80, 224, 0.2);
}

.btn-login:hover {
  background: var(--primary-2);
  transform: translateY(-1px);
  box-shadow: 0 10px 15px -3px rgba(60, 80, 224, 0.3);
}

.btn-login:active {
  transform: translateY(0);
}

.msg-err {
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #dc2626;
  padding: 12px;
  border-radius: 8px;
  font-size: 13.5px;
  font-weight: 600;
  margin-bottom: 24px;
  text-align: left;
}
  </style>
</head>
<body>

<div class="login-container">
  <div class="login-card">
    <div class="login-header">
      <div class="login-brand">MW</div>
      <h1>Sign in</h1>
      <p>Enter your details to access your account</p>
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
      <div class="msg-err"><%= err %></div>
    <% } %>

    <form action="<%=ctx%>/login" method="post" autocomplete="on">
      
      <div class="input-grp">
        <label>Username</label>
        <input type="text" name="username" placeholder="Enter your username" value="<%= usernameVal %>" required>
      </div>

      <div class="input-grp">
        <label>Password</label>
        <input type="password" name="password" placeholder="••••••••" value="<%= passwordVal %>" required>
      </div>

      <div class="row-options">
        <label class="remember-label">
          <input type="checkbox" name="remember" value="true" <%= rememberVal %>>
          Keep me signed in
        </label>
        <a href="<%=ctx%>/forgot-password" class="forgot-link">Forgot password?</a>
      </div>

      <button type="submit" class="btn-login">Login to Account</button>
    </form>
  </div>
</div>

</body>
</html>