<%-- 
    Document   : sidebar_staff
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>STAFF MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>

    <li><a href="<%=ctx%>/home?p=inbound">Create Import Receipt</a></li>
    <li><a href="<%=ctx%>/home?p=outbound">Create Export Receipt</a></li>

    <!-- Inventory -->
    <li><a href="<%=ctx%>/inventory">Inventory Management</a></li>
    <li><a href="<%=ctx%>/inventory-count">Conduct Inventory Count</a></li>

    <!-- Supplier (view-only) -->
    <li><a href="<%=ctx%>/home?p=view_supplier">View Supplier List</a></li>

    <!-- Brand -->
    <li><a href="<%=ctx%>/home?p=brand-list">Brand Management</a></li>

    <!-- Profile / Password -->
    <li><a href="<%=ctx%>/home?p=profile">My Profile</a></li>
    <li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>
