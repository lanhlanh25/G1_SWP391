<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    String approvalType = request.getParameter("approvalType");
    if (approvalType == null || approvalType.isBlank()) approvalType = "import";
%>

<div class="page-wrap manager-dashboard">

    <div class="topbar">
        <div>
            <div class="title">Manager Dashboard</div>
            <div class="small">Review approvals, monitor stock risks, and track warehouse operations.</div>
        </div>
        <a href="#" class="btn btn-primary">Export Report</a>
    </div>

    <!-- KPI -->
    <section class="kpi-grid">
        <div class="card kpi-card">
            <div class="kpi-label">Pending Approvals</div>
            <div class="kpi-value">${pendingApprovals}</div>
            <div class="kpi-note">Requests waiting</div>
        </div>

        <div class="card kpi-card">
            <div class="kpi-label">Overdue Approvals</div>
            <div class="kpi-value">${overdueApprovals}</div>
            <div class="kpi-note">Waiting more than 24 hours</div>
        </div>

        <div class="card kpi-card">
            <div class="kpi-label">Low-stock Products</div>
            <div class="kpi-value">—</div>
            <div class="kpi-note">Coming soon</div>
        </div>

        <div class="card kpi-card">
            <div class="kpi-label">Today Imported Units</div>
            <div class="kpi-value">${todayImportedUnits}</div>
            <div class="kpi-note">Inbound units received today</div>
        </div>

        <div class="card kpi-card">
            <div class="kpi-label">Today Exported Units</div>
            <div class="kpi-value">${todayExportedUnits}</div>
            <div class="kpi-note">Outbound units issued today</div>
        </div>
    </section>

    <!-- Inventory Summary (month-to-date) -->
    <section class="kpi-grid" style="margin-bottom:20px;">
        <div class="card kpi-card" style="border-left:4px solid #64748b;">
            <div class="kpi-label">Opening Stock</div>
            <div class="kpi-value" style="color:#475569;">${invTotalOpening}</div>
            <div class="kpi-note">${invMonthLabel} — beginning</div>
        </div>
        <div class="card kpi-card" style="border-left:4px solid #22c55e;">
            <div class="kpi-label">Total Import</div>
            <div class="kpi-value" style="color:#16a34a;">+${invTotalImport}</div>
            <div class="kpi-note">Confirmed receipts</div>
        </div>
        <div class="card kpi-card" style="border-left:4px solid #f59e0b;">
            <div class="kpi-label">Total Export</div>
            <div class="kpi-value" style="color:#d97706;">-${invTotalExport}</div>
            <div class="kpi-note">Issued in period</div>
        </div>
        <div class="card kpi-card" style="border-left:4px solid #3b82f6;">
            <div class="kpi-label">Closing Stock</div>
            <div class="kpi-value" style="color:#2563eb;">${invTotalClosing}</div>
            <div class="kpi-note">Current on-hand</div>
        </div>
        <div class="card kpi-card" style="border-left:4px solid #a855f7; grid-column: span 1;">
            <div class="kpi-label">View Full Report</div>
            <div class="kpi-value" style="font-size:14px; font-weight:500; margin-top:8px;">
                <a href="<%=ctx%>/inventory-report" class="btn btn-outline" style="width:100%; text-align:center;">
                    Inventory Report
                </a>
            </div>
            <div class="kpi-note">${invMonthLabel}</div>
        </div>
    </section>

    <section class="dashboard-main">
        <!-- Approval Center -->
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="h2">Approval Center</div>
                    <div class="card-subtitle">
                        Select a request type to view only the approval queue for that category.
                    </div>
                </div>
                <a href="<%=ctx%>/home?p=<%=approvalType%>-receipt-list" class="link-lite">View All &gt;</a>
            </div>

            <div class="card-body">
                <div class="tab-group" style="margin-bottom:14px;">
                    <button type="button"
                            class="tab-btn <%= "import".equals(approvalType) ? "active" : "" %>"
                            data-target="import">
                        Import Requests
                    </button>
                    <button type="button"
                            class="tab-btn <%= "export".equals(approvalType) ? "active" : "" %>"
                            data-target="export">
                        Export Requests
                    </button>
                </div>

                <div class="showing-line">
                    Showing:
                    <b>
                        <c:choose>
                            <c:when test="${param.approvalType eq 'export'}">Export Requests</c:when>
                            <c:otherwise>Import Requests</c:otherwise>
                        </c:choose>
                    </b>
                </div>

                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Requested By</th>
                                <th>Requested Time</th>
                                <th>Waiting Time</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>

                            <c:if test="${empty param.approvalType || param.approvalType eq 'import'}">
                                <c:choose>
                                    <c:when test="${not empty dashboardImportRequests}">
                                        <c:forEach var="r" items="${dashboardImportRequests}">
                                            <tr>
                                                <td>${r.code}</td>
                                                <td>${r.requestedBy}</td>
                                                <td>${r.requestedTime}</td>
                                                <td>${r.waitingTime}</td>
                                                <td>
                                                    <span class="badge ${r.priority eq 'High' ? 'badge-warning' : 'badge-info'}">
                                                        ${r.priority}
                                                    </span>
                                                </td>
                                                <td><span class="badge badge-muted">${r.status}</span></td>
                                                <td>
                                                    <a class="btn btn-sm" href="<%=ctx%>/home?p=import-request-detail&id=${r.id}">
                                                        View Detail
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="empty-state">No import requests found.</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                            <c:if test="${param.approvalType eq 'export'}">
                                <c:choose>
                                    <c:when test="${not empty dashboardExportRequests}">
                                        <c:forEach var="r" items="${dashboardExportRequests}">
                                            <tr>
                                                <td>${r.code}</td>
                                                <td>${r.requestedBy}</td>
                                                <td>${r.requestedTime}</td>
                                                <td>${r.waitingTime}</td>
                                                <td>
                                                    <span class="badge ${r.priority eq 'High' ? 'badge-warning' : 'badge-info'}">
                                                        ${r.priority}
                                                    </span>
                                                </td>
                                                <td><span class="badge badge-muted">${r.status}</span></td>
                                                <td>
                                                    <a class="btn btn-sm" href="<%=ctx%>/home?p=export-request-detail&id=${r.id}">
                                                        View Detail
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="empty-state">No export requests found.</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                            <c:if test="${param.approvalType eq 'delete'}">
                                <c:choose>
                                    <c:when test="${not empty dashboardDeleteRequests}">
                                        <c:forEach var="r" items="${dashboardDeleteRequests}">
                                            <tr>
                                                <td>${r.code}</td>
                                                <td>${r.requestedBy}</td>
                                                <td>${r.requestedTime}</td>
                                                <td>${r.waitingTime}</td>
                                                <td>
                                                    <span class="badge ${r.priority eq 'High' ? 'badge-warning' : 'badge-info'}">
                                                        ${r.priority}
                                                    </span>
                                                </td>
                                                <td><span class="badge badge-muted">${r.status}</span></td>
                                                <td>
                                                    <a class="btn btn-sm" href="<%=ctx%>/home?p=request-delete-import-receipt-list">
                                                        Open List
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="empty-state">No delete requests found.</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Right side -->
        <div class="section-stack">
            <div class="card">
                <div class="card-header">
                    <div class="h2">Alerts</div>
                </div>
                <div class="card-body">
                    <div class="empty-state">Coming soon</div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <div class="h2">Quick Actions</div>
                </div>
                <div class="card-body">
                    <div class="quick-actions">
                        <a href="<%=ctx%>/home?p=import-request-list" class="btn btn-primary">Review Import Requests</a>
                        <a href="<%=ctx%>/home?p=export-request-list" class="btn btn-outline">Review Export Requests</a>
                        <a href="<%=ctx%>/inventory-count" class="btn btn-outline">Start Inventory Count</a>
                        <a href="<%=ctx%>/inventory-report" class="btn btn-outline">Inventory Report</a>
                        <a href="<%=ctx%>/home?p=low-stock-report" class="btn btn-outline">Low Stock Report</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="dashboard-bottom">
        <!-- Low stock -->
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="h2">Low Stock List</div>
                    <div class="card-subtitle">Products that have reached or fallen below the reorder point.</div>
                </div>
                <a href="<%=ctx%>/home?p=low-stock-report" class="link-lite">View All &gt;</a>
            </div>
            <div class="card-body">
                <div class="empty-state">Coming soon</div>
            </div>
        </div>

        <!-- Recent activities -->
        <div class="card">
            <div class="card-header">
                <div>
                    <div class="h2">Recent Activities</div>
                    <div class="card-subtitle">Latest import and export transactions.</div>
                </div>
            </div>
            <div class="card-body" style="padding-top:0;">
                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>Transaction Type</th>
                                <th>Reference Code</th>
                                <th>Units</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty dashboardRecentActivities}">
                                    <c:forEach var="a" items="${dashboardRecentActivities}">
                                        <tr>
                                            <td>${a.time}</td>
                                            <td>${a.type}</td>
                                            <td>${a.referenceCode}</td>
                                            <td>${a.units}</td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" class="empty-state">No recent activities found.</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </section>
</div>

<script>
    document.querySelectorAll('.tab-btn[data-target]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const target = btn.getAttribute('data-target');
            const url = new URL(window.location.href);
            url.searchParams.set('p', 'dashboard');
            url.searchParams.set('approvalType', target);
            window.location.href = url.toString();
        });
    });
</script>
