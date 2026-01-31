<%-- 
    Document   : view_profile
    Created on : Jan 13, 2026, 3:00:47 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User pu = (User) request.getAttribute("profileUser");
    if (pu == null) pu = (User) session.getAttribute("authUser");
    if (pu == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String roleName = (String) session.getAttribute("roleName");
    if (roleName == null || roleName.isBlank()) {
        int rid = pu.getRoleId();
        if (rid == 1) roleName = "ADMIN";
        else if (rid == 2) roleName = "MANAGER";
        else if (rid == 3) roleName = "STAFF";
        else if (rid == 4) roleName = "SALE";
        else roleName = "STAFF";
    }
    
    String avatar = pu.getAvatar();
    if (avatar == null || avatar.isBlank()) {
        avatar = "assets/default-avatar.jpg"; 
    }
    String address = pu.getAddress();
    if (address == null) address = "";
    
    long v = System.currentTimeMillis();
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>My Profile</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background:#f5f6f8;
                margin:0;
            }
            .container {
                max-width: 1100px;
                margin: 0 auto;
                padding: 24px;
            }

            
            .topbar {
                display:flex;
                align-items:center;
                justify-content:space-between;
                margin-bottom: 18px;
            }
            .btn {
                background:#4f79c7;
                color:#000;
                border:2px solid #2a4f97;
                padding:10px 18px;
                font-weight:700;
                cursor:pointer;
                text-decoration:none;
                display:inline-block;
            }
            .btn:hover {
                filter: brightness(0.95);
            }
            .btn.secondary {
                background:#e8eefc;
                border-color:#b8c8f0;
            }
            .title {
                font-size: 28px;
                font-weight: 800;
                margin: 0;
            }

            
            .grid {
                display:grid;
                grid-template-columns: 320px 1fr;
                gap:18px;
            }
            .card {
                background:#fff;
                border:1px solid #ddd;
                border-radius:10px;
                padding:18px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            }
            .avatarWrap {
                text-align:center;
            }
            .avatar {
                width:160px;
                height:160px;
                border-radius:12px;
                object-fit:cover;
                border:1px solid #ddd;
            }
            .small {
                color:#666;
                font-size: 13px;
                margin-top:8px;
            }

            table {
                width:100%;
                border-collapse:collapse;
            }
            td {
                padding:12px;
                border-bottom:1px solid #eee;
            }
            td:first-child {
                width:180px;
                color:#444;
                font-weight:700;
            }
            .badge {
                display:inline-block;
                padding:6px 10px;
                border-radius:999px;
                font-weight:700;
                font-size: 12px;
            }
            .active {
                background:#e7f7ee;
                color:#0b6b33;
                border:1px solid #bfe8cf;
            }
            .inactive {
                background:#fdecec;
                color:#b00020;
                border:1px solid #f5c2c7;
            }

            
            @media (max-width: 900px) {
                .grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>

        <div class="container">

            <div class="topbar">
                <a class="btn" href="javascript:history.back()">Back</a>
                <h1 class="title">My Profile</h1>


            </div>

            <div class="grid">
                
                <div class="card">
                    <div class="avatarWrap">
                        <img class="avatar" src="<%=request.getContextPath()%>/<%=avatar%>?v=<%=v%>" alt="avatar">
                        <div class="small">Avatar</div>
                    </div>
                </div>

                
                <div class="card">
                    <table>
                        <tr><td>User ID</td><td><%= pu.getUserId() %></td></tr>
                        <tr><td>Username</td><td><%= pu.getUsername() %></td></tr>
                        <tr><td>Full Name</td><td><%= pu.getFullName() %></td></tr>
                        <tr><td>Email</td><td><%= pu.getEmail() %></td></tr>
                        <tr><td>Phone</td><td><%= pu.getPhone() %></td></tr>
                        <tr><td>Address</td><td><%= address.isBlank() ? "-" : address %></td></tr>
                        <tr><td>Role</td><td><%= roleName %></td></tr>
                        <tr>
                            <td>Status</td>
                            <td>
                                <% if (pu.getStatus() == 1) { %>
                                <span class="badge active">ACTIVE</span>
                                <% } else { %>
                                <span class="badge inactive">INACTIVE</span>
                                <% } %>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

        </div>
    </body>
</html>