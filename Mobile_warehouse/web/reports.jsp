<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<div class="page-wrap">
    <div class="topbar">
        <div>
            <h1 class="h1 m-0">Reports Center</h1>
            <div class="muted">Open operational analytics, stock summaries and transaction reports from one hub.</div>
        </div>
    </div>

    <div class="dash-grid">
        <div class="dash-card">
            <div class="dash-label">Inventory</div>
            <div class="h2 mb-8">Inventory Report</div>
            <div class="muted">Opening, import, export and closing stock by product and date range.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-primary" href="<%=ctx%>/inventory-report">Open Report</a>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-label">Inbound</div>
            <div class="h2 mb-8">Import Receipt Report</div>
            <div class="muted">Track suppliers, quantities and inbound receipt volume over time.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-primary" href="<%=ctx%>/import-receipt-report">Open Report</a>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-label">Outbound</div>
            <div class="h2 mb-8">Export Receipt Report</div>
            <div class="muted">Review export performance, issued quantities and warehouse handoff activity.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-primary" href="<%=ctx%>/export-receipt-report">Open Report</a>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-label">Replenishment</div>
            <div class="h2 mb-8">Low Stock Report</div>
            <div class="muted">Spot products below reorder level and jump directly into replenishment actions.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=low-stock-report">View Low Stock</a>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-label">Brand</div>
            <div class="h2 mb-8">Brand Statistics</div>
            <div class="muted">Compare sales, import and inventory performance by brand.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=brand-stats">Open Brand Stats</a>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-label">Sales Trend</div>
            <div class="h2 mb-8">Best Selling Products</div>
            <div class="muted">See which products are moving fastest and where demand is concentrated.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=best-selling-product-statistics">Open Ranking</a>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-label">Movement</div>
            <div class="h2 mb-8">Stock Movement History</div>
            <div class="muted">Audit stock changes and follow item movement across time.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=stock-movement-history">View History</a>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-label">Export</div>
            <div class="h2 mb-8">Export Center</div>
            <div class="muted">Preview and export consolidated data to Excel or PDF from one shared screen.</div>
            <div class="hero-actions mt-16">
                <a class="btn btn-outline" href="<%=ctx%>/home?p=export-center">Open Center</a>
            </div>
        </div>
    </div>
</div>
