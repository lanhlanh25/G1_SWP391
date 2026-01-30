<%-- 
    Document   : homepage
    Created on : Jan 13, 2026
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User u = (User) session.getAttribute("authUser");
    if (u == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String ctx = request.getContextPath();

    String sidebarPage = (String) request.getAttribute("sidebarPage");
    String contentPage = (String) request.getAttribute("contentPage");
    String currentPage = (String) request.getAttribute("currentPage");

    String roleName = (String) session.getAttribute("roleName");
    if (roleName == null) roleName = "";

    // defaults
    if (sidebarPage == null || sidebarPage.isBlank()) sidebarPage = "sidebar_staff.jsp";
    if (contentPage == null || contentPage.isBlank()) contentPage = "content.jsp";
    if (currentPage == null || currentPage.isBlank()) currentPage = "dashboard";

    // ✅ FIX: remove leading slash to avoid absolute include "/xxx.jsp"
    if (sidebarPage.startsWith("/")) sidebarPage = sidebarPage.substring(1);
    if (contentPage.startsWith("/")) contentPage = contentPage.substring(1);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home</title>
    <style>
        body {
            font-family: Arial;
            margin: 0;
            background: #f6f6f6;
        }
        .top {
            padding: 14px 18px;
            background: #fff;
            border-bottom: 1px solid #ddd;
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:12px;
            flex-wrap:wrap;
        }
        .layout {
            display: flex;
            min-height: calc(100vh - 64px);
        }
        .side {
            width: 260px;
            background: #fff;
            border-right: 1px solid #ddd;
            padding: 14px;
        }
        .main {
            flex: 1;
            background: #fff;
            margin: 14px;
            border: 1px solid #ddd;
            padding: 16px;
        }
        .hello {
            margin-top: 6px;
        }
        .hello a {
            margin-left: 10px;
        }
        .badge {
            display: inline-block;
            padding: 2px 8px;
            border: 1px solid #ccc;
            border-radius: 10px;
            font-size: 12px;
        }
        .small {
            font-size: 12px;
            color:#666;
        }
    </style>
</head>
<body>

    <div class="top">
        <div>
            <h2 style="margin:0;">HOME PAGE</h2>
            <div class="small">
                Hello: <b><%= u.getFullName() %></b> |
                Role: <b><%= roleName.toUpperCase() %></b> |
                Page: <span class="badge"><%= currentPage %></span>
            </div>
        </div>

        <div>
            <a href="<%=ctx%>/logout" onclick="return confirm('Are you sure you want to log out?');">Logout</a>
        </div>
    </div>

    <div class="layout">
        <!-- Sidebar do HomeServlet chọn theo role -->
        <div class="side">
            <jsp:include page="<%= sidebarPage %>" />
        </div>

        <!-- Content do HomeServlet chọn theo role + p -->
        <div class="main">
            <jsp:include page="<%= contentPage %>" />
        </div>
    </div>

</body>
</html>
