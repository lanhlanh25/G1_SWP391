
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
  <%-- Styles moved to app.css --%>
</head>
<body class="auth-body">

<div class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <div class="auth-brand">MW</div>
            <h1 class="h1">Forgot Password?</h1>
            <p class="muted">Enter your email. If your request is approved by Admin, a new password will be sent.</p>
        </div>

        <% if (err != null) { %>
            <div class="alert alert-danger mb-20">⚠ <%= err %></div>
        <% } %>
        <% if (msg != null) { %>
            <div class="alert alert-success mb-20">✓ <%= msg %></div>
        <% } %>

        <form method="post" action="<%= ctx %>/forgot-password">
            <div class="form-group mb-24">
                <label class="form-label" for="email">Email address</label>
                <input
                    class="input"
                    type="email"
                    id="email"
                    name="email"
                    value="<%= emailVal != null ? emailVal : "" %>"
                    placeholder="Enter your registered email"
                    required
                    autocomplete="email"
                />
            </div>

            <button type="submit" class="btn btn-primary w-100 p-14 h-auto">
                Send Reset Request
            </button>
        </form>

        <div class="text-center mt-24">
            <a href="<%= ctx %>/login" class="link-muted fw-700 font-sm">← Back to Login</a>
        </div>
    </div>
</div>

</body>
</html>
