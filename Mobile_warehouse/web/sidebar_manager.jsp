
<%-- 
    Document   : sidebar_manager
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>MANAGER MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
    
    <li><a href="<%=ctx%>/home?p=reports">Weekly Reports</a></li>


    <li><a href="<%=ctx%>/view_inventory.jsp">View Inventory</a></li>

    <li><a href="<%=ctx%>/conduct_inventory_count.jsp">Conduct Inventory Count</a></li>


    <li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Brand Management</summary>
            <ul style="margin-top:6px;">
                <li><a href="<%=ctx%>/home?p=brand-list">Brand List</a></li>
                <li><a href="<%=ctx%>/home?p=brand-stats">Product Statistics By Brand</a></li>
            </ul>
        </details>
    </li>
    <li><a href="<%=ctx%>/home?p=my-profile">My Profile</a></li>
    <li><a href="<%=ctx%>/change_password">Change Password</a></li>
</ul>
