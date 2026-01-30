<%-- Document: sidebar_manager --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>MANAGER MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
    <li><a href="<%=ctx%>/home?p=reports">Weekly Reports</a></li>

    <li><a href="<%=ctx%>/inventory">Inventory Management</a></li>
    <li><a href="<%=ctx%>/inventory-count">Conduct Inventory Count</a></li>

    <li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Brand Management</summary>
            <ul style="margin-top:6px;">
                <li><a href="<%=ctx%>/home?p=brand-list">Brand List</a></li>
                <li><a href="<%=ctx%>/home?p=brand-stats">Product Statistics By Brand</a></li>
            </ul>
        </details>
    </li>

    <li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Supplier Management</summary>
            <ul style="margin-top:6px;">
                <li><a href="<%=ctx%>/home?p=add_supplier">Add New Supplier</a></li>
                <li><a href="<%=ctx%>/home?p=view_supplier">View Supplier List</a></li>
                <%-- Update/Inactive phải làm ở List/Detail vì cần id --%>
            </ul>
        </details>
    </li>

    <li><a href="<%=ctx%>/home?p=my-profile">My Profile</a></li>
    <li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>
