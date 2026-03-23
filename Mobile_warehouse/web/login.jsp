<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en" class="light-style customizer-hide" dir="ltr" data-theme="theme-default" data-assets-path="<%=ctx%>/assets/" data-template="vertical-menu-template-free">
<head>
    <meta charset="utf-8" />
    <title>Login - DTLA Mobile WMS</title>
    <%@ include file="/WEB-INF/jspf/common_head.jspf" %>
    <!-- Page CSS -->
    <link rel="stylesheet" href="<%=ctx%>/assets/vendor/css/pages/page-auth.css" />
    <style>
        body {
            background-image: linear-gradient(rgba(13, 27, 42, 0.4), rgba(13, 27, 42, 0.4)), url('<%=ctx%>/assets/images/warehouse_bg.png');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            min-height: 100vh;
        }
        .authentication-wrapper.authentication-basic .authentication-inner {
            max-width: 450px;
        }
        .card {
            background: rgba(255, 255, 255, 0.92) !important;
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.4);
            border-radius: 20px;
            box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.25);
            padding: 1rem;
        }
        .form-label {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #566a7f;
            margin-bottom: 0.5rem;
        }
        .form-control {
            background: rgba(245, 247, 249, 0.7) !important;
            border: 1.5px solid rgba(67, 89, 113, 0.1) !important;
            border-radius: 10px !important;
            padding: 0.75rem 1rem !important;
            transition: all 0.2s ease-in-out !important;
        }
        .form-control:focus {
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
            box-shadow: 0 4px 15px rgba(105, 108, 255, 0.35) !important;
            transition: all 0.2s ease !important;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(105, 108, 255, 0.45) !important;
            background: linear-gradient(135deg, #7b7eff 0%, #4c53fa 100%) !important;
        }
        .authentication-wrapper.authentication-basic .authentication-inner:before,
        .authentication-wrapper.authentication-basic .authentication-inner:after {
            display: none; /* Hide default Sneat background decorations */
        }
    </style>
</head>
<body>
<%
  String err = (String) request.getAttribute("err");
  String usernameVal = (String) request.getAttribute("usernameVal");
  if (usernameVal == null) usernameVal = "";
%>

<div class="container-xxl">
    <div class="authentication-wrapper authentication-basic container-p-y">
        <div class="authentication-inner">
            <!-- Register -->
            <div class="card">
                <div class="card-body">
                    <!-- Logo -->
                    <div class="app-brand justify-content-center">
                        <a href="<%=ctx%>/" class="app-brand-link gap-2">
                            <span class="app-brand-logo demo">
                                <i class="fa-solid fa-warehouse text-primary fs-3"></i>
                            </span>
                            <span class="app-brand-text demo text-body fw-bolder">DTLA WMS</span>
                        </a>
                    </div>
                    <!-- /Logo -->
                    <h4 class="mb-2">Welcome to DTLA WMS! </h4>


                    <% if (err != null && !err.isBlank()) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bx bx-error me-1"></i> <%= err %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <form id="formAuthentication" class="mb-3" action="<%=ctx%>/login" method="POST">
                        <div class="mb-3">
                            <label for="login-username" class="form-label">Username</label>
                            <input type="text" class="form-control" id="login-username" name="username" placeholder="Enter your username" value="<%= usernameVal %>" autofocus required />
                        </div>
                        <div class="mb-3 form-password-toggle">
                            <div class="d-flex justify-content-between">
                                <label class="form-label" for="login-password">Password</label>
                                <a href="<%=ctx%>/forgot-password">
                                    <small>Forgot Password?</small>
                                </a>
                            </div>
                            <div class="input-group input-group-merge">
                                <input type="password" id="login-password" class="form-control" name="password" placeholder="············" aria-describedby="password" required />
                                <span class="input-group-text cursor-pointer"><i class="bx bx-hide"></i></span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="remember-me" name="remember" />
                                <label class="form-check-label" for="remember-me"> Remember Me </label>
                            </div>
                        </div>
                        <div class="mb-3">
                            <button class="btn btn-primary d-grid w-100" type="submit">Sign in</button>
                        </div>
                    </form>
                </div>
            </div>
            <!-- /Register -->
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/common_scripts.jspf" %>
</body>
</html>

