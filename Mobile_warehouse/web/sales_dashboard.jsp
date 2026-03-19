<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<div class="page-wrap">
    <div class="topbar">
        <div>
            <h1 class="h1 m-0">Sales Dashboard</h1>
            <!--<div class="muted">Fast access to request creation, follow-up and supplier information.</div>-->
        </div>
    </div>

    <div class="stats-grid">
        <div class="stat-card primary">
            <div class="stat-label">Outbound</div>
            <div class="h2 mb-8">Create Export Request</div>
            <!--<div class="muted">Start a new outbound request for warehouse processing.</div>-->
            <div class="hero-actions mt-16">
                <a class="btn btn-primary" href="<%=ctx%>/home?p=create-export-request">Create Request</a>
            </div>
        </div>

        <div class="stat-card info">
            <div class="stat-label">Tracking</div>
            <div class="h2 mb-8">Export Request List</div>
            <!--<div class="muted">Monitor request progress and see which orders are ready for fulfillment.</div>-->
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=export-request-list">Open List</a>
            </div>
        </div>

        <div class="stat-card warning">
            <div class="stat-label">Inbound</div>
            <div class="h2 mb-8">Create Import Request</div>
            <!--<div class="muted">Request replenishment when stock or forecasted demand requires it.</div>-->
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=create-import-request">Create Request</a>
            </div>
        </div>

        <div class="stat-card success">
            <div class="stat-label">Reference</div>
            <div class="h2 mb-8">Supplier Directory</div>
            <!--<div class="muted">Browse supplier contacts and review supplier detail history.</div>-->
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=view_supplier">View Suppliers</a>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <div>
                <div class="h2">Today&apos;s Workflow</div>
                <div class="card-subtitle">A simple launchpad for the most common sales actions.</div>
            </div>
        </div>
        <div class="card-body">
            <div class="hero-actions">
                <a class="btn btn-primary" href="<%=ctx%>/home?p=create-export-request">New Export Request</a>
                <a class="btn btn-outline" href="<%=ctx%>/home?p=export-request-list">Review Export Requests</a>
                <a class="btn btn-outline" href="<%=ctx%>/home?p=create-import-request">New Import Request</a>
                <a class="btn btn-outline" href="<%=ctx%>/home?p=import-request-list">Review Import Requests</a>
                <a class="btn btn-outline" href="<%=ctx%>/home?p=my-profile">My Profile</a>
            </div>
        </div>
    </div>
</div>
