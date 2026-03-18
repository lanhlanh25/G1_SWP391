<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User pu = (User) request.getAttribute("profileUser");
    if (pu == null) pu = (User) session.getAttribute("authUser");
    if (pu == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

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
    if (avatar == null || avatar.isBlank()) avatar = "assets/default-avatar.jpg";

    String address = pu.getAddress();
    if (address == null) address = "";

    String msg = request.getParameter("msg");
    long v = System.currentTimeMillis();
%>

<div class="page-wrap-sm profile-page">
    <div class="topbar mb-20">
        <div>
            <h1 class="h1 m-0">My Profile</h1>
            <div class="muted">Your personal information and current account status.</div>
        </div>
        <a class="btn btn-outline" href="javascript:history.back()">&larr; Back</a>
    </div>

    <% if ("avatar_updated".equals(msg)) { %>
        <div class="msg-ok">Avatar updated successfully.</div>
    <% } else if ("nofile".equals(msg)) { %>
        <div class="msg-err">Please choose an image before uploading.</div>
    <% } else if ("badtype".equals(msg)) { %>
        <div class="msg-err">Only JPG, JPEG, PNG or WEBP images are allowed.</div>
    <% } else if ("dbfail".equals(msg)) { %>
        <div class="msg-err">Could not save the avatar right now. Please try again.</div>
    <% } %>

    <div class="grid-profile gap-16">
        <div class="card">
            <div class="card-body text-center">
                <img src="<%=request.getContextPath()%>/<%=avatar%>?v=<%=v%>"
                     alt="avatar"
                     class="avatar-xl"/>
                <div class="small muted mt-8">Avatar</div>
            </div>
        </div>

        <div class="card overflow-hidden">
            <div class="card-header"><span class="h2">User Information</span></div>
            <div class="card-body p-0">
                <table class="table">
                    <tr><td class="label w-160">User ID</td><td><%=pu.getUserId()%></td></tr>
                    <tr><td class="label">Username</td><td><%=pu.getUsername()%></td></tr>
                    <tr><td class="label">Full Name</td><td><%=pu.getFullName()%></td></tr>
                    <tr><td class="label">Email</td><td><%=pu.getEmail()%></td></tr>
                    <tr><td class="label">Phone</td><td><%=pu.getPhone()%></td></tr>
                    <tr><td class="label">Address</td><td><%=address.isBlank() ? "-" : address%></td></tr>
                    <tr><td class="label">Role</td><td><%=roleName%></td></tr>
                    <tr>
                        <td class="label">Status</td>
                        <td>
                            <% if (pu.getStatus() == 1) { %>
                                <span class="badge badge-active">ACTIVE</span>
                            <% } else { %>
                                <span class="badge badge-inactive">INACTIVE</span>
                            <% } %>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>
