
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
    <style>
        body {
            background-image: linear-gradient(rgba(13, 27, 42, 0.4), rgba(13, 27, 42, 0.4)), url('<%=ctx%>/assets/images/warehouse_bg.png');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .auth-card {
            background: rgba(255, 255, 255, 0.92) !important;
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.4);
            border-radius: 20px;
            box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.25);
            padding: 2.5rem;
            width: 100%;
            max-width: 450px;
        }
        .auth-brand {
            font-weight: 800;
            color: #696cff;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .h1 {
            font-size: 1.5rem;
            font-weight: 700;
            color: #32475c;
            margin-bottom: 0.5rem;
        }
        .muted {
            font-size: 0.85rem;
            color: #566a7f;
            margin-bottom: 1.5rem;
            line-height:1.4;
        }
        .form-label {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #566a7f;
            margin-bottom: 0.5rem;
            display: block;
        }
        .input {
            background: rgba(245, 247, 249, 0.7) !important;
            border: 1.5px solid rgba(67, 89, 113, 0.1) !important;
            border-radius: 10px !important;
            padding: 0.75rem 1rem !important;
            transition: all 0.2s ease-in-out !important;
            width: 100%;
            outline: none;
            box-sizing: border-box;
        }
        .input:focus {
            background: #fff !important;
            border-color: #696cff !important;
            box-shadow: 0 0 0 0.25rem rgba(105, 108, 255, 0.12) !important;
            transform: translateY(-1px);
        }
        .btn-primary {
            background: linear-gradient(135deg, #696cff 0%, #3b42f6 100%) !important;
            border: none !important;
            border-radius: 10px !important;
            padding: 0.8rem !important;
            font-weight: 600 !important;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            color: #fff !important;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(105, 108, 255, 0.35) !important;
            transition: all 0.2s ease !important;
            width: 100%;
            margin-top: 1rem;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(105, 108, 255, 0.45) !important;
            background: linear-gradient(135deg, #7b7eff 0%, #4c53fa 100%) !important;
        }
        .mt-24 { margin-top: 1.5rem; }
        .text-center { text-align: center; }
        .link-muted { color: #696cff; text-decoration: none; font-weight: 600; font-size: 0.9rem; }
        .link-muted:hover { text-decoration: underline; }
    </style>

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

            <button type="submit" class="btn-primary">
                Send Reset Request
            </button>
        </form>

        <div class="text-center mt-24">
            <a href="<%= ctx %>/login" class="link-muted">← Back to Login</a>
        </div>
    </div>
</div>

</body>
</html>
