<%-- 
    Document   : homepage
    Created on : Jan 13, 2026, 1:46:06 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User u = (User) session.getAttribute("authUser");
    if (u == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String sidebarPage = (String) request.getAttribute("sidebarPage");
    String contentPage = (String) request.getAttribute("contentPage");

    if (sidebarPage == null) sidebarPage = "/views/home/home_sb/sidebar_staff.jsp";
    if (contentPage == null) contentPage = "/views/home/home_ct/content_staff.jsp";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>

<h2>HOME</h2>
<p>
    Hello: <b><%=u.getFullName()%></b>
    | Role: <b><%=u.getRoleName()%></b>
    | <a href="<%=request.getContextPath()%>/logout">Logout</a>
</p>

<hr>
<jsp:include page="<%=sidebarPage%>" />

<hr>
<jsp:include page="<%=contentPage%>" />

</body>
</html>