<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";

    String uri = request.getRequestURI();
    if (uri == null) uri = "";

    boolean inventoryOverviewActive = uri.equals(ctx + "/inventory");
    boolean inventoryCountActive = uri.equals(ctx + "/inventory-count");
    boolean inventoryReportActive = uri.equals(ctx + "/inventory-report");
    boolean importReportActive = uri.equals(ctx + "/import-receipt-report");
    boolean exportReportActive = uri.equals(ctx + "/export-receipt-report");
    
    boolean importActive = "import-receipt-list".equals(currentPage) ||
                          "create-import-receipt".equals(currentPage) ||
                          "import-receipt-detail".equals(currentPage) ||
                          "request-delete-import-receipt-list".equals(currentPage) ||
                          importReportActive;
                          
    boolean exportActive = "export-receipt-list".equals(currentPage) ||
                          "export-receipt-detail".equals(currentPage) ||
                          exportReportActive;
                          
    boolean importReqActive = "import-request-list".equals(currentPage) ||
                             "import-request-detail".equals(currentPage);
                             
    boolean exportReqActive = "export-request-list".equals(currentPage) ||
                             "export-request-detail".equals(currentPage);
                             
    boolean brandActive = "brand-add".equals(currentPage) ||
                         "brand-list".equals(currentPage) ||
                         "brand-detail".equals(currentPage) ||
                         "brand-update".equals(currentPage) ||
                         "brand-stats".equals(currentPage) ||
                         "brand-stats-detail".equals(currentPage);
                         
    boolean supplierActive = "add_supplier".equals(currentPage) ||
                            "view_supplier".equals(currentPage) ||
                            "supplier_detail".equals(currentPage) ||
                            "update_supplier".equals(currentPage) ||
                            "supplier_inactive".equals(currentPage) ||
                            "view_history".equals(currentPage);
                            
    boolean productActive = "product-add".equals(currentPage) ||
                           "product-list".equals(currentPage) ||
                           "product-detail".equals(currentPage) ||
                           "sku-add".equals(currentPage);
%>

<li class="menu-item <%= "dashboard".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=dashboard" class="menu-link">
        <div data-i18n="Dashboard">Dashboard</div>
    </a>
</li>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Warehouse</span>
</li>

<li class="menu-item <%= inventoryOverviewActive ? "active" : "" %>">
    <a href="<%=ctx%>/inventory" class="menu-link">
        <div data-i18n="Inventory">Inventory Management</div>
    </a>
</li>

<li class="menu-item <%= inventoryReportActive ? "active" : "" %>">
    <a href="<%=ctx%>/inventory-report" class="menu-link">
        <div data-i18n="Inventory Report">Inventory Report</div>
    </a>
</li>

<li class="menu-item <%= inventoryCountActive ? "active" : "" %>">
    <a href="<%=ctx%>/inventory-count" class="menu-link">
        <div data-i18n="Inventory Count">Inventory Count</div>
    </a>
</li>

<li class="menu-item <%= "variant-matrix".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=variant-matrix" class="menu-link">
        <div data-i18n="Variant Matrix">Variant Matrix</div>
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
        <li class="menu-item <%= "import-receipt-list".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=import-receipt-list" class="menu-link">
                <div data-i18n="Receipt List">Receipt List</div>
            </a>
        </li>
        <li class="menu-item <%= importReportActive ? "active" : "" %>">
            <a href="<%=ctx%>/import-receipt-report" class="menu-link">
                <div data-i18n="Reports">Reports</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-item <%= exportActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Export Receipts">Export Receipts</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "export-receipt-list".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=export-receipt-list" class="menu-link">
                <div data-i18n="Receipt List">Receipt List</div>
            </a>
        </li>
        <li class="menu-item <%= exportReportActive ? "active" : "" %>">
            <a href="<%=ctx%>/export-receipt-report" class="menu-link">
                <div data-i18n="Reports">Reports</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Requests</span>
</li>

<li class="menu-item <%= importReqActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Import Requests">Import Requests</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "import-request-list".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=import-request-list" class="menu-link">
                <div data-i18n="Request List">Request List</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-item <%= exportReqActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Export Requests">Export Requests</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "export-request-list".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=export-request-list" class="menu-link">
                <div data-i18n="Request List">Request List</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Master Data</span>
</li>

<li class="menu-item <%= brandActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Brands">Brands</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= "brand-list".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=brand-list" class="menu-link">
                <div data-i18n="Brand List">Brand List</div>
            </a>
        </li>
        <li class="menu-item <%= "brand-add".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=brand-add" class="menu-link">
                <div data-i18n="Add Brand">Add Brand</div>
            </a>
        </li>
        <li class="menu-item <%= ("brand-stats".equals(currentPage) || "brand-stats-detail".equals(currentPage)) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=brand-stats" class="menu-link">
                <div data-i18n="Brand Statistics">Brand Statistics</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-item <%= supplierActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Suppliers">Suppliers</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= ("view_supplier".equals(currentPage) || "supplier_detail".equals(currentPage)) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=view_supplier" class="menu-link">
                <div data-i18n="Supplier List">Supplier List</div>
            </a>
        </li>
        <li class="menu-item <%= "add_supplier".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=add_supplier" class="menu-link">
                <div data-i18n="Add Supplier">Add Supplier</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-item <%= productActive ? "active open" : "" %>">
    <a href="javascript:void(0);" class="menu-link menu-toggle">
        <div data-i18n="Products">Products</div>
    </a>
    <ul class="menu-sub">
        <li class="menu-item <%= ("product-list".equals(currentPage) || "product-detail".equals(currentPage)) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=product-list" class="menu-link">
                <div data-i18n="Product List">Product List</div>
            </a>
        </li>
        <li class="menu-item <%= "product-add".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=product-add" class="menu-link">
                <div data-i18n="Add Product">Add Product</div>
            </a>
        </li>
        <li class="menu-item <%= "sku-add".equals(currentPage) ? "active" : "" %>">
            <a href="<%=ctx%>/home?p=sku-add" class="menu-link">
                <div data-i18n="Add SKU">Add SKU</div>
            </a>
        </li>
    </ul>
</li>

<li class="menu-header small text-uppercase">
    <span class="menu-header-text">Advanced</span>
</li>

<li class="menu-item <%= "export-center".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=export-center" class="menu-link">
        <div data-i18n="Export Center">Export Center</div>
    </a>
</li>

<li class="menu-item <%= "low-stock-report".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=low-stock-report" class="menu-link">
        <div data-i18n="Low Stock Report">Low Stock Report</div>
    </a>
</li>

<li class="menu-item <%= "best-selling-product-statistics".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=best-selling-product-statistics" class="menu-link">
        <div data-i18n="Best-selling Products">Best-selling Products</div>
    </a>
</li>

<li class="menu-item <%= "stock-movement-history".equals(currentPage) ? "active" : "" %>">
    <a href="<%=ctx%>/home?p=stock-movement-history" class="menu-link">
        <div data-i18n="Stock Movement">Stock Movement</div>
    </a>
</li>

