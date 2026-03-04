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
  <title>Sign in - DTLA Mobile WMS</title>
  <%@ include file="/WEB-INF/jspf/common_head.jspf" %>
  <%-- Nếu common_head.jspf chưa link app.css thì bật dòng dưới --%>
  <%-- <link rel="stylesheet" href="<%=ctx%>/assets/css/app.css"> --%>
</head>
<body>

<div class="login-page">
  <div class="login-card">

    <!-- Brand -->
    <div class="login-brand">
      <span class="brand-mark">H</span>
      <div>
        <div class="brand-title">DTLA Mobile WMS</div>
        <div class="brand-sub">Warehouse Management System</div>
      </div>
    </div>

    <!-- Heading -->
    <div class="login-head">
      <h1>Sign in to your account</h1>
      <p>Enter your credentials to access your dashboard</p>
    </div>

    <!-- Error message -->
    <%
      String err = (String) request.getAttribute("err");
      String usernameVal = (String) request.getAttribute("usernameVal");
      if (usernameVal == null) usernameVal = "";
      if (err != null && !err.isBlank()) {
    %>
      <div class="msg-err" style="text-align:center;"><%= err %></div>
    <% } %>

    <!-- Form -->
    <form class="login-form" action="<%=ctx%>/login" method="post" autocomplete="on">

      <div>
        <label class="label" for="username">Username</label>
        <input class="input"
               id="username"
               name="username"
               type="text"
               placeholder="Enter your username"
               value="<%= usernameVal %>"
               required>
      </div>

      <div>
        <div class="login-row">
          <label class="label" for="password" style="margin:0;">Password</label>
          <a class="login-forgot" href="<%=ctx%>/forgot_password.jsp">Forgot password?</a>
        </div>

        <div class="input-wrap">
          <input class="input"
                 id="password"
                 name="password"
                 type="password"
                 placeholder="Enter your password"
                 required>
          <button class="eye-btn" type="button" id="togglePw" aria-label="Show password">👁</button>
        </div>
      </div>

      <label class="check-row">
        <input type="checkbox" name="remember" value="1">
        Keep me signed in
      </label>

      <div class="login-actions">
        <button class="btn btn-primary btn-block" type="submit">Sign in</button>
      </div>



    </form>

  </div>
</div>

<script>
  (function () {
    const pw = document.getElementById('password');
    const btn = document.getElementById('togglePw');
    if (!pw || !btn) return;

    btn.addEventListener('click', function () {
      const isPw = pw.getAttribute('type') === 'password';
      pw.setAttribute('type', isPw ? 'text' : 'password');
      btn.textContent = isPw ? '🙈' : '👁';
      btn.setAttribute('aria-label', isPw ? 'Hide password' : 'Show password');
    });
  })();
</script>

</body>
</html>