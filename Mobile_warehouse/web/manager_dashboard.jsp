<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    String approvalType = request.getParameter("approvalType");
    if (approvalType == null || approvalType.isBlank()) approvalType = "import";
%>

<div class="page-wrap-md manager-dashboard">

    <div class="topbar mb-20">
        <div>
            <h1 class="h1 m-0">Manager Dashboard</h1>
<!--            <div class="small muted">Review approvals, monitor stock risks, and track warehouse operations.</div>-->
        </div>
        <a href="#" class="btn btn-primary">Export Report</a>
    </div>

    <!-- KPI -->
    <section class="kpi-grid">
        <div class="card kpi-card">
            <div class="kpi-label">Pending Approvals</div>
            <div class="kpi-value">${pendingApprovals}</div>
            <div class="kpi-note">New import and export requests</div>
        </div>

        

        <div class="card kpi-card">
            <div class="kpi-label">Low-stock Products</div>
            <div class="kpi-value">${lowStockProducts}</div>
            <div class="kpi-note">At or below reorder point</div>
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
    <section class="kpi-grid mb-20">
        <div class="card kpi-card border-l-muted">
            <div class="kpi-label">Opening Stock</div>
            <div class="kpi-value text-muted">${invTotalOpening}</div>
            <div class="kpi-note">${invMonthLabel} — beginning</div>
        </div>
        <div class="card kpi-card border-l-success">
            <div class="kpi-label">Total Import</div>
            <div class="kpi-value text-success">+${invTotalImport}</div>
            <div class="kpi-note">Confirmed receipts</div>
        </div>
        <div class="card kpi-card border-l-warning">
            <div class="kpi-label">Total Export</div>
            <div class="kpi-value text-warning">-${invTotalExport}</div>
            <div class="kpi-note">Issued in period</div>
        </div>
        <div class="card kpi-card border-l-primary">
            <div class="kpi-label">Closing Stock</div>
            <div class="kpi-value text-primary">${invTotalClosing}</div>
            <div class="kpi-note">Current on-hand</div>
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
                <c:choose>
                    <c:when test="${param.approvalType eq 'export'}">
                        <a href="<%=ctx%>/home?p=export-request-list&status=NEW" class="link-lite">View All &gt;</a>
                    </c:when>
                    <c:otherwise>
                        <a href="<%=ctx%>/home?p=import-request-list&status=NEW" class="link-lite">View All &gt;</a>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="card-body">
                <div class="tab-group mb-12">
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
                                            <td colspan="5" class="empty-state">No import requests found.</td>
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
                                                <td><span class="badge badge-active">${r.status}</span></td>
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
                                            <td colspan="5" class="empty-state">No export requests found.</td>
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
            <%--<div class="card">
                <div class="card-header">
                    <div>
                        <div class="h2">Top Exported Products</div>
                        <div class="card-subtitle">Best-performing exported products in the selected period.</div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="empty-state">Coming soon</div>
                </div>
            </div>--%>

            <div class="card">
                <div class="card-header">
                    <div class="h2">Quick Actions</div>
                </div>
                <div class="card-body">
                    <div class="quick-actions">
                        <a href="<%=ctx%>/home?p=import-request-list" class="btn btn-primary">Review Import Requests</a>
                        <a href="<%=ctx%>/home?p=export-request-list" class="btn btn-outline">Review Export Requests</a>
                        <a href="<%=ctx%>/home?p=brand-list" class="btn btn-outline">Manage Brands</a>
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

            <div class="card-body p-0">
                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Supplier</th>
                                <th>Stock</th>
                                <th>ROP</th>
                                <th>Status</th>
                                <th>Suggested Qty</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty dashboardLowStockRows}">
                                    <c:forEach var="item" items="${dashboardLowStockRows}">
                                        <tr>
                                            <td>
                                                <div><b>${item.productName}</b></div>
                                                <div class="small">${item.productCode}</div>
                                            </td>
                                            <td>${item.supplierName}</td>
                                            <td>${item.currentStock}</td>
                                            <td>${item.rop}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${item.ropStatus == 'Out Of Stock'}">
                                                        <span class="badge badge-danger">Out Of Stock</span>
                                                    </c:when>
                                                    <c:when test="${item.ropStatus == 'Reorder Needed'}">
                                                        <span class="badge badge-warning">Reorder Needed</span>
                                                    </c:when>
                                                    <c:when test="${item.ropStatus == 'At ROP Level'}">
                                                        <span class="badge badge-info">At ROP Level</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-active">OK</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${item.suggestedReorderQty}</td>
                                            <td>
                                                <a class="btn btn-sm"
                                                   href="<%=ctx%>/home?p=product-detail&id=${item.productId}">
                                                    View
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="empty-state">No low stock products found.</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
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
            <div class="card-body p-0">
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
