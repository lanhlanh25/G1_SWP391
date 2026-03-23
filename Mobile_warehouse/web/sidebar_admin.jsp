<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";

    boolean usersActive = "user-list".equals(currentPage) ||
                         "user-add".equals(currentPage) ||
                         "user-update".equals(currentPage) ||
                         "user-toggle".equals(currentPage);
                         
    boolean accessActive = "role-list".equals(currentPage) ||
                          "role-update".equals(currentPage) ||
                          "role-toggle".equals(currentPage) ||
                          "role-perm-view".equals(currentPage);
                          
    boolean resetActive = "admin/reset-requests".equals(currentPage);
%>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">User Administration</span>
</li>

<li class="menu-item <%= usersActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Users">Users</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "user-list".equals(currentPage) || "user-update".equals(currentPage) || "user-toggle".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=user-list" class="menu-link">
                <div data-i18n="User List">User List</div>
            </a>
        </li>
        <li class="menu-item <%= "user-add".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=user-add" class="menu-link">
                <div data-i18n="Add User">Add User</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Access & Security</span>
</li>

<li class="menu-item <%= accessActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Roles & Permissions">Roles & Permissions</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= accessActive ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=role-list" class="menu-link">
                <div data-i18n="Role List">Role List</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-item <%= resetActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Password Resets">Password Resets</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= resetActive ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=admin/reset-requests" class="menu-link">
                <div data-i18n="Reset Requests">Reset Requests</div>
            </a>
        </li>
    </ul>
</li>


