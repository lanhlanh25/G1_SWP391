
<%-- 
    Document   : forgot_password
    Created on : Jan 16, 2026, 2:45:43 AM
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password – DTLA Mobile WMS</title>
    <link rel="stylesheet" href="<%= ctx %>/assets/css/app.css">
</head>
  <style>
/* Modern Phoenix Theme - Forgot Password */
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
  margin-bottom: 32px;
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
  margin: 12px 0 0;
  line-height: 1.5;
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

.btn-primary {
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

.btn-primary:hover {
  background: var(--primary-2);
  transform: translateY(-1px);
  box-shadow: 0 10px 15px -3px rgba(60, 80, 224, 0.3);
}

.msg-err {
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #dc2626;
  padding: 12px;
  border-radius: 8px;
  font-size: 13.5px;
  font-weight: 600;
  margin-bottom: 20px;
}

.msg-ok {
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
  color: #16a34a;
  padding: 12px;
  border-radius: 8px;
  font-size: 13.5px;
  font-weight: 600;
  margin-bottom: 20px;
}

.back-link {
  text-align: center;
  margin-top: 24px;
}

.back-link a {
  color: var(--text-2);
  font-weight: 700;
  font-size: 13px;
  text-decoration: none;
}

.back-link a:hover {
  color: var(--primary);
  text-decoration: underline;
}
  </style>
</head>
<body>

<div class="login-container">
    <div class="login-card">
        <div class="login-header">
            <div class="login-brand">MW</div>
            <h1>Forgot Password?</h1>
            <p>Enter your email. If your request is approved by Admin, a new password will be sent.</p>
        </div>

        <% if (err != null) { %>
            <div class="msg-err">⚠ <%= err %></div>
        <% } %>
        <% if (msg != null) { %>
            <div class="msg-ok">✓ <%= msg %></div>
        <% } %>

        <form method="post" action="<%= ctx %>/forgot-password">
            <div class="input-grp">
                <label for="email">Email address</label>
                <input
                    type="email"
                    id="email"
                    name="email"
                    value="<%= emailVal != null ? emailVal : "" %>"
                    placeholder="Enter your registered email"
                    required
                    autocomplete="email"
                />
            </div>

            <button type="submit" class="btn-primary">
                Send Reset Request
            </button>
        </form>

        <div class="back-link">
            <a href="<%= ctx %>/login">← Back to Login</a>
        </div>
    </div>
</div>

</body>
</html>
