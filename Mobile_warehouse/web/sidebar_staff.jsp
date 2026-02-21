<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>STAFF MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
<li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Export Receipt</summary>
            <ul style="margin-top:6px;">
    <li><a href="<%=ctx%>/home?p=create-import-receipt">Create Import Receipt</a></li>
    <li><a href="<%=ctx%>/import-receipt-list">View Import Receipt List</a></li>
            </ul>
        </details>
    </li>


<li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Export Receipt</summary>
            <ul style="margin-top:6px;">
                    <li><a href="<%=ctx%>/home?p=export-request-listt">View Export Request List</a></li>
    <li><a href="<%=ctx%>/home?p=create-export-receipt">Create Export Receipt</a></li>
<li><a href="<%=ctx%>/home?p=export-receipt-list">View Export Receipt List</a></li>
            </ul>
        </details>
    </li>


    <li><a href="<%=ctx%>/inventory">Inventory Management</a></li>
    <li><a href="<%=ctx%>/inventory-count">Conduct Inventory Count</a></li>

    <li><a href="<%=ctx%>/home?p=view_supplier">View Supplier List</a></li>
    <li><a href="<%=ctx%>/home?p=brand-list">Brand Management</a></li>

    <li><a href="<%=ctx%>/home?p=profile">My Profile</a></li>
    <li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>

