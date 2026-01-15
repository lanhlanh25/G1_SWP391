<%-- 
    Document   : homepage
    Created on : Jan 13, 2026, 2:59:50 PM
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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>

<h2>HOME PAGE</h2>
<p>
    Hello: <b><%=u.getFullName()%></b> |
    Role: <b><%=roleName%></b>
    <%-- Nếu chưa có logout servlet thì comment dòng dưới --%>
    | <a href="<%=request.getContextPath()%>/logout"
         onclick="return confirm('Are you sure you want to log out?');">
        Logout</a>
</p>

<hr>

<h3>ADMIN MENU</h3>
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

<%-- OPTIONAL: nếu bạn muốn hiện content theo ?p (dashboard/profile/denied) --%>
<%
    String p = request.getParameter("p");
    if (p == null || p.isBlank()) p = "dashboard";
    p = p.toLowerCase();
%>

</body>
</html>
