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

    String avatarPath = (u.getAvatar() == null) ? "" : u.getAvatar().trim();
    String avatarUrl = avatarPath.isBlank()
            ? (ctx + "/assets/default-avatar.jpg")
            : (ctx + "/" + avatarPath);

    long v = System.currentTimeMillis(); 

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
        <link rel="stylesheet" href="<%=ctx%>/assets/css/app.css?v=<%=v%>">
    </head>
    <body>
        <script>
            // Restore sidebar state from localStorage before rendering
            if (localStorage.getItem('sidebarCollapsed') === 'true') {
                document.body.classList.add('sidebar-collapsed');
            }
        </script>
        <div class="app">


            <div class="top">
                <div class="top-left">
                    <button class="sidebar-toggle" id="sidebarToggle" title="Toggle Sidebar">☰</button>
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


            <div class="layout">


                <aside class="side">
                    <div class="side-scroll">
                        <jsp:include page="<%= sidebarPage %>" />
                    </div>
                </aside>

                <!-- Floating sidebar profile -->
                <div class="side-floating-user">
                    <details class="side-user">
                        <summary>
                            <span class="side-avatar">
                                <img src="<%= avatarUrl %>?v=<%= v %>"
                                     alt="avatar"
                                     onerror="this.style.display='none'; this.parentNode.textContent='<%= initials %>';">
                            </span>

                            <div class="user-meta">
                                <div class="user-name"><%= fullName %></div>
                                <div class="user-role"><%= roleName %></div>
                            </div>

                            <span class="caret">▾</span>
                        </summary>

                        <div class="side-user-menu">
                            <a href="<%=ctx%>/home?p=my-profile">My Profile</a>
                            <a href="<%=ctx%>/home?p=change-password">Change Password</a>
                            <a class="logout"
                               href="<%=ctx%>/logout"
                               onclick="return confirm('Are you sure you want to log out?');">
                                Log out
                            </a>
                        </div>
                    </details>
                </div>

                <div class="content-wrap">
                    <main class="main">
                        <div class="page-content-shell">
                            <jsp:include page="<%= contentPage %>" />
                        </div>

                        <%@ include file="/WEB-INF/jspf/footer.jspf" %>
                    </main>
                </div>

            </div>
        </div>

        <script>
            (function() {
                var btn = document.getElementById('sidebarToggle');
                if (btn) {
                    btn.addEventListener('click', function() {
                        document.body.classList.toggle('sidebar-collapsed');
                        var isCollapsed = document.body.classList.contains('sidebar-collapsed');
                        localStorage.setItem('sidebarCollapsed', isCollapsed);
                    });
                }
            })();
        </script>
    </body>
</html>