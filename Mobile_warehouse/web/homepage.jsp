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

    if (sidebarPage == null || sidebarPage.isBlank()) sidebarPage = "sidebar_staff.jsp";
    if (contentPage == null || contentPage.isBlank()) contentPage = "content.jsp";
    if (currentPage == null || currentPage.isBlank()) currentPage = "dashboard";

    if (sidebarPage.startsWith("/")) sidebarPage = sidebarPage.substring(1);
    if (contentPage.startsWith("/")) contentPage = contentPage.substring(1);
    
    // Avatar URL for topbar + sidebar
    String avatarPath = (u.getAvatar() == null) ? "" : u.getAvatar().trim();
    String avatarUrl = avatarPath.isBlank()
            ? (ctx + "/assets/default-avatar.jpg")
            : (ctx + "/" + avatarPath);

    long v = System.currentTimeMillis(); // chống cache
    // Initials for avatar
    String fullName = u.getFullName() == null ? "User" : u.getFullName().trim();
    String initials = "U";
    if (!fullName.isBlank()) {
        String[] parts = fullName.split("\\s+");
        if (parts.length == 1) initials = ("" + parts[0].charAt(0)).toUpperCase();
        else initials = ("" + parts[0].charAt(0) + parts[parts.length-1].charAt(0)).toUpperCase();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Home</title>
        <%@ include file="/WEB-INF/jspf/common_head.jspf" %>
    </head>
    <body>
        <div class="app layout">

            <!-- TOPBAR -->
            <div class="top">
                <div class="top-left">
                    <a class="brand" href="<%=ctx%>/home?p=dashboard">
                        <span class="brand-mark">MW</span>
                        <span>
                            <div class="brand-title">DTLA Mobile WMS</div>
                            <div class="brand-sub">Warehouse Management System</div>
                        </span>
                    </a>

                    <span class="page-pill"><%= currentPage %></span>
                </div>

                <div class="top-right">
                    <details class="top-user">
                        <summary class="top-user-summary" title="Account">
                            <div><%= roleName %></div>
                            <span class="top-avatar">
                                <img src="<%=avatarUrl%>?v=<%=v%>" alt="avatar"
                                     onerror="this.style.display='none'; this.parentNode.textContent='<%= initials %>';">
                            
                            </span>
                            
                        </summary>

                        <div class="top-user-menu">
                            <a href="<%=ctx%>/home?p=my-profile">My profile</a>
                            <a href="<%=ctx%>/home?p=change-password">Change password</a>
                            <a class="logout"
                               href="<%=ctx%>/logout"
                               onclick="return confirm('Are you sure you want to log out?');">Log out</a>
                        </div>
                    </details>
                </div>
            </div>

            <!-- BODY -->
            <div class="layout">

                <!-- SIDEBAR -->
                <aside class="side">
                    <div class="side-header">
                        <div class="section-title">Navigation</div>
                    </div>

                    <div class="side-scroll">
                        <jsp:include page="<%= sidebarPage %>" />
                    </div>

                    <!-- Profile pinned bottom -->
                    <div class="side-footer">

                        <a class="side-user-link" href="<%=ctx%>/home?p=my-profile">
                            <div class="side-avatar">
                                <img src="<%= avatarUrl %>?v=<%= v %>"
                                     alt="avatar"
                                     onerror="this.style.display='none'; this.parentNode.textContent='<%= initials %>';">
                            </div>
                            <div class="user-meta">
                                <div class="user-name"><%= fullName %></div>
                                <div class="user-role"><%= roleName %></div>
                            </div>
                        </a>





                    </div>
                </aside>
                            <div class="content-wrap">
                <!-- MAIN -->
                <main class="main">
                    <jsp:include page="<%= contentPage %>" />
                </main>
                
            

            <!-- FOOTER -->
            <%@ include file="/WEB-INF/jspf/footer.jspf" %>
            </div>
        </div>
    
        </body>
</html>