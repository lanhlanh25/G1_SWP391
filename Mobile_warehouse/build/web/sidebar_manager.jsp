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

    <!-- ✅ IMPORT RECEIPT -->
    <li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Import Receipt</summary>
            <ul style="margin-top:6px;">
                <li><a href="<%=ctx%>/import-receipt-list">View Import Receipt List</a></li>

                <li><a href="<%=ctx%>/home?p=create-import-receipt">Create Import Receipt</a></li>
            </ul>
        </details>
    </li>


    <li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Export Receipt</summary>
            <ul style="margin-top:6px;">
                <li><a href="<%=ctx%>/home?p=export-receipt-list">View Export Receipt List</a></li>
                
            </ul>
        </details>
    </li>

    <li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Brand Management</summary>
            <ul style="margin-top:6px;">
                <li><a href="<%=ctx%>/home?p=brand-add">Add New Brand</a></li>
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
            </ul>
        </details>
    </li>

    <li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Product Management</summary>
            <ul style="margin-top:6px;">
                <li><a href="<%=ctx%>/home?p=product-add">Add Product</a></li>
                <li><a href="<%=ctx%>/home?p=sku-add">Add SKU</a></li>
                <li><a href="<%=ctx%>/home?p=product-list">List Product</a></li>
            </ul>
        </details>
    </li>

    <li style="list-style:none;">
        <details open>
            <summary style="cursor:pointer;">Export Request Management</summary>
            <ul style="margin-top:6px;">
                
                <li><a href="<%=ctx%>/home?p=export-request-list">View Export Request List</a></li>
                <li><a href="<%=ctx%>/home?p=import-request-list">View Import Request List</a></li>
            </ul>
        </details>
    </li>
</li>
<li><a href="<%=ctx%>/home?p=my-profile">My Profile</a></li>
<li><a href="<%=ctx%>/home?p=change-password">Change Password</a></li>
</ul>
