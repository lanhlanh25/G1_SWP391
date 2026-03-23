<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";

    String uri = request.getRequestURI();
    if (uri == null) uri = "";

    boolean inventoryOverviewActive = uri.equals(ctx + "/inventory");
    boolean inventoryCountActive = uri.equals(ctx + "/inventory-count");
    
    boolean importActive = "create-import-receipt".equals(currentPage) ||
                          "import-receipt-list".equals(currentPage) ||
                          "import-receipt-detail".equals(currentPage) ||
                          "request-delete-import-receipt".equals(currentPage) ||
                          "request-delete-import-receipt-list".equals(currentPage) ||
                          "import-request-list".equals(currentPage) ||
                          "import-request-detail".equals(currentPage);
                          
    boolean exportActive = "create-export-receipt".equals(currentPage) ||
                          "export-receipt-list".equals(currentPage) ||
                          "export-receipt-detail".equals(currentPage) ||
                          "export-request-list".equals(currentPage) ||
                          "export-request-detail".equals(currentPage);
                          
    boolean masterDataActive = "view_supplier".equals(currentPage) ||
                              "supplier_detail".equals(currentPage) ||
                              "brand-list".equals(currentPage) ||
                              "brand-detail".equals(currentPage) ||
                              "product-list".equals(currentPage) ||
                              "product-detail".equals(currentPage) ||
                              "variant-matrix".equals(currentPage);
%>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Warehouse</span>
</li>

<li class="menu-item <%= inventoryOverviewActive ? "active" : "" %>">
    <a href="<%=ctx%>/inventory" class="menu-link">
        <div data-i18n="Inventory">Inventory Management</div>
    </a>
</li>

<li class="menu-item <%= inventoryCountActive ? "active" : "" %>">
    <a href="<%=ctx%>/inventory-count" class="menu-link">
        <div data-i18n="Inventory Count">Inventory Count</div>
    </a>
</li>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Transactions</span>
</li>

<li class="menu-item <%= importActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Import Receipts">Import Receipts</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "import-request-list".equals(currentPage) || "import-request-detail".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=import-request-list" class="menu-link">
                <div data-i18n="Import Requests">Import Requests</div>
            </a>
        </li>
        <li class="menu-item <%= "create-import-receipt".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=create-import-receipt" class="menu-link">
                <div data-i18n="Create Receipt">Create Receipt</div>
            </a>
        </li>
        <li class="menu-item <%= "import-receipt-list".equals(currentPage) || "import-receipt-detail".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=import-receipt-list" class="menu-link">
                <div data-i18n="Receipt List">Receipt List</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-item <%= exportActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Export Receipts">Export Receipts</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "export-request-list".equals(currentPage) || "export-request-detail".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=export-request-list" class="menu-link">
                <div data-i18n="Export Requests">Export Requests</div>
            </a>
        </li>
        <li class="menu-item <%= "create-export-receipt".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=create-export-receipt" class="menu-link">
                <div data-i18n="Create Receipt">Create Receipt</div>
            </a>
        </li>
        <li class="menu-item <%= "export-receipt-list".equals(currentPage) || "export-receipt-detail".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=export-receipt-list" class="menu-link">
                <div data-i18n="Receipt List">Receipt List</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Master Data</span>
</li>

<li class="menu-item <%= "view_supplier".equals(currentPage) || "supplier_detail".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=view_supplier" class="menu-link">
        <div data-i18n="Suppliers">Suppliers</div>
    </a>
</li>

<li class="menu-item <%= "brand-list".equals(currentPage) || "brand-detail".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=brand-list" class="menu-link">
        <div data-i18n="Brands">Brands</div>
    </a>
</li>

<li class="menu-item <%= "product-list".equals(currentPage) || "product-detail".equals(currentPage) || "variant-matrix".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=product-list" class="menu-link">
        <div data-i18n="Products">Products</div>
    </a>
</li>
