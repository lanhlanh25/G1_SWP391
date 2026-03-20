<%--
    Document   : login.jsp
    Created on : Jan 13, 2026, 2:56:12 PM
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
</head>
<body class="auth-body auth-login-glass">
<%
  String err = (String) request.getAttribute("err");
  String usernameVal = (String) request.getAttribute("usernameVal");
  String passwordVal = (String) request.getAttribute("passwordVal");
  String rememberVal = (String) request.getAttribute("rememberVal");
  if (usernameVal == null) usernameVal = "";
  if (passwordVal == null) passwordVal = "";
  if (rememberVal == null) rememberVal = "";
%>

<div class="login-frost-scene">
  <span class="login-orb orb-top"></span>
  <span class="login-orb orb-left"></span>
  <span class="login-orb orb-bottom"></span>
  <span class="login-orb orb-right"></span>

  <div class="login-frost-card">
    <div class="login-frost-inner">
      <div class="login-frost-brand">MW</div>
      <h1 class="login-frost-title">LOGIN</h1>

      <% if (err != null && !err.isBlank()) { %>
        <div class="login-frost-alert"><%= err %></div>
      <% } %>

      <form class="login-frost-form" action="<%=ctx%>/login" method="post" autocomplete="on">
        <div class="login-frost-field">
          <label class="login-frost-label" for="login-username">Username</label>
          <input id="login-username"
                 class="login-frost-input"
                 type="text"
                 name="username"
                 placeholder="Enter your username"
                 value="<%= usernameVal %>"
                 required>
        </div>

        <div class="login-frost-field">
          <label class="login-frost-label" for="login-password">Password</label>
          <div class="login-password-shell">
            <input id="login-password"
                   class="login-frost-input login-password-input"
                   type="password"
                   name="password"
                   placeholder="Enter your password"
                   value="<%= passwordVal %>"
                   required>
            <button class="login-password-toggle"
                    type="button"
                    aria-label="Show password"
                    aria-pressed="false"
                    onclick="toggleLoginPassword()">
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M2 12s3.8-6 10-6 10 6 10 6-3.8 6-10 6S2 12 2 12Z"></path>
                <circle cx="12" cy="12" r="3.2"></circle>
              </svg>
            </button>
          </div>
        </div>

        <div class="login-frost-row">
   
          <a href="<%=ctx%>/forgot-password" class="login-frost-link">Forgot password?</a>
        </div>

        <button type="submit" class="login-frost-submit">SIGN IN</button>
      </form>
    </div>
  </div>
</div>

<script>
  function toggleLoginPassword() {
    const input = document.getElementById('login-password');
    const btn = document.querySelector('.login-password-toggle');
    if (!input || !btn) return;

    const nextType = input.type === 'password' ? 'text' : 'password';
    input.type = nextType;
    const isVisible = nextType === 'text';
    btn.setAttribute('aria-pressed', isVisible ? 'true' : 'false');
    btn.setAttribute('aria-label', isVisible ? 'Hide password' : 'Show password');
    btn.classList.toggle('is-active', isVisible);
  }
</script>
</body>
</html>
