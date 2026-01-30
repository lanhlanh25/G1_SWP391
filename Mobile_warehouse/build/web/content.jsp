<%-- 
    Document   : content
    Created on : Jan 13, 2026, 3:00:16 PM
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

    // Lấy roleName từ session, fallback map roleId
    String role = (String) session.getAttribute("roleName");
    if (role == null || role.isBlank()) {
        int rid = u.getRoleId();
        if (rid == 1) role = "ADMIN";
        else if (rid == 2) role = "MANAGER";
        else if (rid == 3) role = "STAFF";
        else if (rid == 4) role = "SALE";
        else role = "STAFF";
    }
    role = role.toUpperCase();

    String p = (String) request.getAttribute("currentPage");
    if (p == null) p = "dashboard";
    String ctx = request.getContextPath();
%>

<h3>CONTENT</h3>
<p>Role: <b><%=role%></b> | Page: <b><%=p%></b></p>


<% if ("dashboard".equals(p)) { %>
    <p>Dashboard (chung)</p>

<% } else if ("profile".equals(p)) { %>
    <jsp:include page="/view_profile.jsp" />

<% } else if ("change-password".equals(p)) { %>
    <p>
        <a href="<%=ctx%>/changepassword">Open Change Password</a>
    </p>

<% } else if ("denied".equals(p)) { %>
    <p style="color:red;">Access Denied!</p>


<% } else if ("ADMIN".equals(role) && "role-list".equals(p)) { %>
    <p>
        <a href="<%=ctx%>/role_list">Open Role List</a>
    </p>

<% } else if ("ADMIN".equals(role) && "role-perm-edit".equals(p)) { %>
    <p>
        Bạn hãy vào Role List và bấm View Permissions để edit permissions.
        <br>
        <a href="<%=ctx%>/role_list">Go to Role List</a>
    </p>

<% } else { %>
    <p>Page not found!</p>
<% } %>
