<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";
%>


<div class="section-title">Overview</div>
<ul>
    <li>
        <a class="<%= "dashboard".equals(currentPage) ? "active" : "" %>"
           href="<%=ctx%>/home?p=dashboard">
            Dashboard
        </a>
    </li>
</ul>

<div class="section-title">User Administration</div>

<details <%= (
    "user-list".equals(currentPage) ||
    "user-add".equals(currentPage) ||
    "user-update".equals(currentPage) ||
    "user-toggle".equals(currentPage)
) ? "open" : "" %>>
    <summary>Users</summary>
    <ul>
        <li>
            <a class="<%= "user-list".equals(currentPage) || "user-update".equals(currentPage) || "user-toggle".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=user-list">
                User List
            </a>
        </li>
        <li>
            <a class="<%= "user-add".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=user-add">
                Add User
            </a>
        </li>
    </ul>
</details>

<div class="section-title">Access & Security</div>

<details <%= (
    "role-list".equals(currentPage) ||
    "role-update".equals(currentPage) ||
    "role-toggle".equals(currentPage) ||
    "role-perm-view".equals(currentPage)
) ? "open" : "" %>>
    <summary>Roles & Permissions</summary>
    <ul>
        <li>
            <a class="<%= "role-list".equals(currentPage) || "role-update".equals(currentPage) || "role-toggle".equals(currentPage) || "role-perm-view".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=role-list">
                Role List
            </a>
        </li>
    </ul>
</details>

<details <%= "admin/reset-requests".equals(currentPage) ? "open" : "" %>>
    <summary>Password Resets</summary>
    <ul>
        <li>
            <a class="<%= "admin/reset-requests".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=admin/reset-requests">
                Reset Requests
            </a>
        </li>
    </ul>
</details>