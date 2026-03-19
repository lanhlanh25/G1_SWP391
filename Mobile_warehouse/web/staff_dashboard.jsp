<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<div class="page-wrap">
    <div class="topbar">
        <div>
            <h1 class="h1 m-0">Staff Dashboard</h1>
            <!--<div class="muted">Jump straight into inventory operations, receipt handling and warehouse checks.</div>-->
        </div>
    </div>

    <div class="stats-grid">
        <div class="stat-card primary">
            <div class="stat-label">Inventory</div>
            <div class="h2 mb-8">Inventory Management</div>
            <!--<div class="muted">Review current stock balances, statuses and SKU detail in one view.</div>-->
            <div class="hero-actions mt-16">
                <a class="btn btn-primary" href="<%=ctx%>/inventory">Open Inventory</a>
            </div>
        </div>

        <div class="stat-card warning">
            <div class="stat-label">Audit</div>
            <div class="h2 mb-8">Inventory Count</div>
            <div class="muted">Perform physical counting and compare counted quantity against system stock.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/inventory-count">Start Counting</a>
            </div>
        </div>

        <div class="stat-card success">
            <div class="stat-label">Inbound</div>
            <div class="h2 mb-8">Import Receipts</div>
            <div class="muted">Create or review inbound receipts and their IMEI details.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=import-receipt-list">Receipt List</a>
                <a class="btn btn-outline" href="<%=ctx%>/home?p=create-import-receipt">Create Receipt</a>
            </div>
        </div>

        <div class="stat-card info">
            <div class="stat-label">Outbound</div>
            <div class="h2 mb-8">Export Receipts</div>
            <div class="muted">Prepare outbound receipts and follow warehouse handoff progress.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=export-receipt-list">Receipt List</a>
                <a class="btn btn-outline" href="<%=ctx%>/home?p=create-export-receipt">Create Receipt</a>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div>
                <div class="h2">Quick Access</div>
                <div class="card-subtitle">Common warehouse shortcuts for day-to-day execution.</div>
            </div>
        </div>
        <div class="card-body">
            <div class="hero-actions">
                <a class="btn btn-primary" href="<%=ctx%>/inventory">Inventory Overview</a>
                <a class="btn btn-outline" href="<%=ctx%>/inventory-count">Inventory Count</a>
                <a class="btn btn-outline" href="<%=ctx%>/home?p=view_supplier">Supplier List</a>
                <a class="btn btn-outline" href="<%=ctx%>/home?p=my-profile">My Profile</a>
            </div>
        </div>
    </div>
</div>
