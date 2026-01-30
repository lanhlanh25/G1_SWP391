
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
    
    <li><a href="<%=ctx%>/home?p=add_supplier">Add New Supplier</a></li>
    
    <li><a href="<%=ctx%>/home?p=view_supplier">View Supplier List</a></li>
    
    <li><a href="<%=ctx%>/home?p=update_supplier">Update Supplier Information</a></li>
    
    <li><a href="<%=ctx%>/home?p=supplier_inactive">Delete Supplier</a></li>
    
    <li><a href="<%=ctx%>/home?p=view_history">View Transaction history with Supplier</a></li>
    
    <li><a href="<%=ctx%>/home?p=rate_supplier">Rate Supplier</a></li>
    
    <li><a href="<%=ctx%>/home?p=profile">My Profile</a></li>
    
    <li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>
