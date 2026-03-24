<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";

    String uri = request.getRequestURI();
    if (uri == null) uri = "";

    boolean inventoryOverviewActive = uri.equals(ctx + "/inventory");
    
    boolean exportReqActive = "create-export-request".equals(currentPage) ||
                             "export-request-list".equals(currentPage) ||
                             "export-request-detail".equals(currentPage) ||
                             "export-request-edit".equals(currentPage);
                             
    boolean importReqActive = "create-import-request".equals(currentPage) ||
                             "import-request-list".equals(currentPage) ||
                             "import-request-detail".equals(currentPage);
%>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Warehouse</span>
</li>

<li class="menu-item <%= inventoryOverviewActive ? "active" : "" %>">
    <a href="<%=ctx%>/inventory" class="menu-link">
        <div data-i18n="Inventory">Inventory Overview</div>
    </a>
</li>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Requests</span>
</li>

<li class="menu-item <%= exportReqActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Export Requests">Export Requests</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "create-export-request".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=create-export-request" class="menu-link">
                <div data-i18n="Create Request">Create Request</div>
            </a>
        </li>
        <li class="menu-item <%= "export-request-list".equals(currentPage) || "export-request-detail".equals(currentPage) || "export-request-edit".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=export-request-list" class="menu-link">
                <div data-i18n="Request List">Request List</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-item <%= importReqActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Import Requests">Import Requests</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "create-import-request".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=create-import-request" class="menu-link">
                <div data-i18n="Create Request">Create Request</div>
            </a>
        </li>
        <li class="menu-item <%= "import-request-list".equals(currentPage) || "import-request-detail".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=import-request-list" class="menu-link">
                <div data-i18n="Request List">Request List</div>
            </a>
        </li>
    </ul>
</li>

<%--<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Master Data</span>
</li>

<li class="menu-item <%= "brand-list".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=brand-list" class="menu-link">
        <div data-i18n="Brands">Brand List</div>
    </a>
</li>

<li class="menu-item <%= "view_supplier".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=view_supplier" class="menu-link">
        <div data-i18n="Suppliers">Supplier List</div>
    </a>
</li>
--%>
