
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
<body class="app">

<div class="login-page">
    <div class="login-card">

        <!-- Brand -->
        <div class="login-brand">
            <div class="brand-mark">DTLA</div>
            <div>
                <div class="brand-title">DTLA Mobile WMS</div>
            </div>
        </div>

        <!-- Icon -->
        <div style="display:flex; justify-content:center; margin-bottom:16px;">
            <div class="auth-icon">
                <svg width="26" height="26" fill="none" stroke="currentColor" stroke-width="2.2"
                     stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
                    <rect x="3" y="11" width="18" height="11" rx="2"/>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
            </div>
        </div>

        <!-- Heading -->
        <div class="login-head">
            <h1>Forgot Password?</h1>
            <p>Enter your registered email. If your request is approved by Admin,<br>
               a new 8-character password will be sent to your email.</p>
        </div>

        <!-- Messages -->
        <% if (err != null) { %>
            <div class="msg-err" style="text-align:center; margin-bottom:10px;">
                ⚠ <%= err %>
            </div>
        <% } %>
        <% if (msg != null) { %>
            <div class="msg-ok" style="text-align:center; margin-bottom:10px;">
                ✓ <%= msg %>
            </div>
        <% } %>

        <!-- Form -->
        <form method="post" action="<%= ctx %>/forgot-password" class="login-form">

            <div>
                <label class="label" for="email">Email address</label>
                <input
                    class="input"
                    type="email"
                    id="email"
                    name="email"
                    value="<%= emailVal != null ? emailVal : "" %>"
                    placeholder="you@example.com"
                    required
                    autocomplete="email"
                    style="margin-top:6px;"
                />
            </div>

            <div class="login-actions">
                <button type="submit" class="btn btn-primary btn-block">
                    Send Request to Admin
                </button>
            </div>

        </form>

        <!-- Back to login -->
        <div style="text-align:center; margin-top:18px;">
            <a href="<%= ctx %>/login" class="muted" style="font-weight:700; font-size:13.5px;">
                ← Back to Login
            </a>
        </div>

    </div>
</div>

</body>
</html>
