<%-- 
    Document   : homepage
    Created on : Jan 13, 2026, 2:59:50 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%--<%
    User u = (User) session.getAttribute("authUser");
    if (u == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Lấy roleName từ session (LoginServlet nên set)
    String roleName = (String) session.getAttribute("roleName");
    if (roleName == null || roleName.isBlank()) {
        // fallback theo roleId (đổi nếu DB bạn khác)
        int rid = u.getRoleId();
        if (rid == 1) roleName = "ADMIN";
        else if (rid == 2) roleName = "MANAGER";
        else if (rid == 3) roleName = "STAFF";
        else if (rid == 4) roleName = "SALE";
        else roleName = "STAFF";
    }
    roleName = roleName.toUpperCase();
%>--%>
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


    if (sidebarPage == null || sidebarPage.isBlank()) sidebarPage = "sidebar_staff.jsp";
    if (contentPage == null || contentPage.isBlank()) contentPage = "content.jsp";
    if (currentPage == null) currentPage = "dashboard";
%>
<%--<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>--%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Home</title>
        <style>
            body {
                font-family: Arial;
                margin:0;
                background:#f6f6f6;
            }
            .top {
                padding: 14px 18px;
                background:#fff;
                border-bottom:1px solid #ddd;
            }
            .layout {
                display:flex;
                min-height: calc(100vh - 64px);
            }
            .side {
                width:260px;
                background:#fff;
                border-right:1px solid #ddd;
                padding:14px;
            }
            .main {
                flex:1;
                background:#fff;
                margin:14px;
                border:1px solid #ddd;
                padding:16px;
            }
            .hello {
                margin-top:6px;
            }
            .hello a {
                margin-left:10px;
            }
            .badge {
                display:inline-block;
                padding:2px 8px;
                border:1px solid #ccc;
                border-radius:10px;
                font-size:12px;
            }
        </style>
    </head>
    <body>
        <%--/////////
        <h2>HOME PAGE</h2>
        <p>
            Hello: <b><%=u.getFullName()%></b> |
            Role: <b><%=roleName%></b>
        <%-- Nếu chưa có logout servlet thì comment dòng dưới /////////--%>
        <%--/////////| <a href="<%=request.getContextPath()%>/logout"
             onclick="return confirm('Are you sure you want to log out?');">
            Logout</a>
    </p>

<hr>

<h3><%=roleName%> MENU</h3>
<ul>
    <!-- 1) Dashboard -->
    <li>
        <a href="<%=request.getContextPath()%>/home">Dashboard</a>
    </li>

    <!-- 2) User List -->
    <li>
        <a href="<%=request.getContextPath()%>/admin/users">User List</a>
    </li>

    <!-- 3) Add User -->
    <li>
        <a href="<%=request.getContextPath()%>/admin/user-add">Add User</a>
    </li>

    <!-- 4) Role List -->
    <li>
        <a href="<%=request.getContextPath()%>/role_list">Role List</a>
    </li>

    <!-- 5) My Profile -->
    <li>
        <a href="<%=request.getContextPath()%>/profile">My Profile</a>
    </li>

    <!-- 6) Change Password -->
    <li>
        <a href="<%=request.getContextPath()%>/change_password">Change Password</a>
    </li>
</ul>

<hr>

        <%-- OPTIONAL: nếu bạn muốn hiện content theo ?p (dashboard/profile/denied) ////////--%>
        <%--<%
            String p = request.getParameter("p");
            if (p == null || p.isBlank()) p = "dashboard";
            p = p.toLowerCase();
        %>--%>
        <div class="top">
            <h2 style="margin:0;">HOME PAGE</h2>
            <div class="hello">
                Hello: <b><%= u.getFullName() %></b> |
                Role: <b><%= roleName.toUpperCase() %></b> |
                Page: <span class="badge"><%= currentPage %></span>
                | <a href="<%=ctx%>/logout" onclick="return confirm('Are you sure you want to log out?');">Logout</a>
            </div>
        </div>

        <div class="layout">
            <!-- Sidebar do HomeServlet chọn theo role -->
            <div class="side">
                <jsp:include page="${sidebarPage}" />
            </div>

            <!-- Content do HomeServlet chọn theo role + p -->
            <div class="main">
                <jsp:include page="${contentPage}" />
            </div>
        </div>
    </body>
</html>
