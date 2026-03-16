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
/* Centered Glassmorphism Login with Warehouse Background */
body, html {
  margin: 0;
  padding: 0;
  min-height: 100vh;
  font-family: 'Poppins', 'Nunito Sans', sans-serif;
  background: url('<%=ctx%>/assets/images/warehouse_bg.png') center/cover no-repeat;
  background-attachment: fixed;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Dark overlay to make glass effect visible */
.overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 0;
}

.glass-card {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 580px;
  background: rgba(15, 15, 20, 0.65);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 24px;
  padding: 60px 60px;
  box-shadow: 0 30px 60px rgba(0, 0, 0, 0.6);
  color: #fff;
  text-align: center;
}

.glass-card h1 {
  font-size: 38px;
  font-weight: 700;
  margin: 0 0 50px 0;
  letter-spacing: 0.5px;
}

.input-grp {
  position: relative;
  margin-bottom: 30px;
}

.input-grp input {
  width: 100%;
  padding: 16px 50px 16px 24px;
  border-radius: 30px;
  background: #f1f5f9; /* Màu trắng đục ngả xanh nhẹ giống hình */
  border: 2px solid transparent;
  color: #1e293b;
  font-size: 15px;
  font-weight: 500;
  outline: none;
  transition: all 0.3s ease;
  box-sizing: border-box;
}

.input-grp input::placeholder {
  color: #64748b;
}

.input-grp input:focus {
  background: #ffffff;
  border-color: #3b82f6;
  box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
}

.input-grp .icon {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  fill: #94a3b8; /* Chuyển icon sang màu tối để hợp nền input sáng */
  width: 20px;
  height: 20px;
}

.row-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  font-size: 13.5px;
}

.remember-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.remember-label input {
  width: 15px;
  height: 15px;
  cursor: pointer;
  accent-color: #fff;
}

.forgot-link {
  color: #fff;
  text-decoration: none;
  transition: opacity 0.2s;
}

.forgot-link:hover {
  opacity: 0.8;
  text-decoration: underline;
}

.btn-login {
  width: 100%;
  padding: 16px;
  border-radius: 30px;
  border: none;
  background: #fff;
  color: #222;
  font-size: 17px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.2s, transform 0.1s;
  margin-bottom: 30px;
}

.btn-login:hover {
  background: #e2e8f0;
}

.btn-login:active {
  transform: scale(0.98);
}

.register-row {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.7);
}

.register-row a {
  color: #fff;
  font-weight: 700;
  text-decoration: none;
  margin-left: 5px;
}

.register-row a:hover {
  text-decoration: underline;
}

.msg-err {
  background: rgba(220, 38, 38, 0.8);
  color: #fff;
  padding: 12px;
  border-radius: 10px;
  font-size: 14px;
  margin-bottom: 25px;
}
  </style>
</head>
<body>

<div class="overlay"></div>

<div class="glass-card">
  <h1>Login</h1>

  <%
    String err = (String) request.getAttribute("err");
    String usernameVal = (String) request.getAttribute("usernameVal");
    if (usernameVal == null) usernameVal = "";
    if (err != null && !err.isBlank()) {
  %>
    <div class="msg-err"><%= err %></div>
  <% } %>

  <form action="<%=ctx%>/login" method="post" autocomplete="on">
    
    <div class="input-grp">
      <input type="text" name="username" placeholder="Username" value="<%= usernameVal %>" required>
      <svg class="icon" viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
    </div>

    <div class="input-grp">
      <input type="password" name="password" placeholder="Password" required>
      <svg class="icon" viewBox="0 0 24 24"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zM9 8V6c0-1.66 1.34-3 3-3s3 1.34 3 3v2H9z"/></svg>
    </div>

    <div class="row-options">
      <label class="remember-label">
        <input type="checkbox" checked>
        Remember me
      </label>
      <a href="#" class="forgot-link">Forgot password?</a>
    </div>

    <button type="submit" class="btn-login">Login</button>

    <div class="register-row">
      Don't have an account? <a href="#">Register</a>
    </div>

  </form>
</div>

</body>
</html>