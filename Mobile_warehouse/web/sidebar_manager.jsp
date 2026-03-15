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
    boolean importReportActive = uri.equals(ctx + "/import-receipt-report");
    boolean exportReportActive = uri.equals(ctx + "/export-receipt-report");
%>

<div>

    <div class="section-title">Overview</div>
    <ul>
        <li>
            <a class="<%= "dashboard".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=dashboard">
                Dashboard
            </a>
        </li>
    </ul>

    <div class="section-title">Warehouse</div>
    <ul>
        <li>
            <a class="<%= inventoryOverviewActive ? "active" : "" %>"
               href="<%=ctx%>/inventory">
                Inventory Overview
            </a>
        </li>
        <li>
            <a class="<%= inventoryCountActive ? "active" : "" %>"
               href="<%=ctx%>/inventory-count">
                Inventory Count
            </a>
        </li>
        <li>
            <a class="<%= "variant-matrix".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=variant-matrix">
                Variant Matrix
            </a>
        </li>
    </ul>

    <div class="section-title">Transactions</div>

    <details <%= (
        "import-receipt-list".equals(currentPage) ||
        "create-import-receipt".equals(currentPage) ||
        "import-receipt-detail".equals(currentPage) ||
        "request-delete-import-receipt-list".equals(currentPage) ||
        importReportActive
    ) ? "open" : "" %>>
        <summary>Import Receipts</summary>
        <ul>
            <li>
                <a class="<%= "import-receipt-list".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=import-receipt-list">
                    Receipt List
                </a>
            </li>
            <li>
                <a class="<%= "create-import-receipt".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=create-import-receipt">
                    Create Receipt
                </a>
            </li>
            <li>
                <a class="<%= "request-delete-import-receipt-list".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=request-delete-import-receipt-list">
                    Delete Requests
                </a>
            </li>
            <li>
                <a class="<%= importReportActive ? "active" : "" %>"
                   href="<%=ctx%>/import-receipt-report">
                    Reports
                </a>
            </li>
        </ul>
    </details>

    <details <%= (
        "export-receipt-list".equals(currentPage) ||
        "export-receipt-detail".equals(currentPage) ||
        exportReportActive
    ) ? "open" : "" %>>
        <summary>Export Receipts</summary>
        <ul>
            <li>
                <a class="<%= "export-receipt-list".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=export-receipt-list">
                    Receipt List
                </a>
            </li>
            <li>
                <a class="<%= exportReportActive ? "active" : "" %>"
                   href="<%=ctx%>/export-receipt-report">
                    Reports
                </a>
            </li>
        </ul>
    </details>

    <div class="section-title">Requests</div>

    <details <%= (
        "import-request-list".equals(currentPage) ||
        "import-request-detail".equals(currentPage)
    ) ? "open" : "" %>>
        <summary>Import Requests</summary>
        <ul>
            <li>
                <a class="<%= "import-request-list".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=import-request-list">
                    Request List
                </a>
            </li>
        </ul>
    </details>

    <details <%= (
        "export-request-list".equals(currentPage) ||
        "export-request-detail".equals(currentPage)
    ) ? "open" : "" %>>
        <summary>Export Requests</summary>
        <ul>
            <li>
                <a class="<%= "export-request-list".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=export-request-list">
                    Request List
                </a>
            </li>
        </ul>
    </details>

    <div class="section-title">Master Data</div>

    <details <%= (
        "brand-add".equals(currentPage) ||
        "brand-list".equals(currentPage) ||
        "brand-detail".equals(currentPage) ||
        "brand-update".equals(currentPage) ||
        "brand-disable".equals(currentPage) ||
        "brand-stats".equals(currentPage) ||
        "brand-stats-detail".equals(currentPage)
    ) ? "open" : "" %>>
        <summary>Brands</summary>
        <ul>
            <li>
                <a class="<%= "brand-add".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=brand-add">
                    Add Brand
                </a>
            </li>
            <li>
                <a class="<%= "brand-list".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=brand-list">
                    Brand List
                </a>
            </li>
            <li>
                <a class="<%= ("brand-stats".equals(currentPage) || "brand-stats-detail".equals(currentPage)) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=brand-stats">
                    Brand Statistics
                </a>
            </li>
        </ul>
    </details>

    <details <%= (
        "add_supplier".equals(currentPage) ||
        "view_supplier".equals(currentPage) ||
        "supplier_detail".equals(currentPage) ||
        "update_supplier".equals(currentPage) ||
        "supplier_inactive".equals(currentPage) ||
        "view_history".equals(currentPage)
    ) ? "open" : "" %>>
        <summary>Suppliers</summary>
        <ul>
            <li>
                <a class="<%= "add_supplier".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=add_supplier">
                    Add Supplier
                </a>
            </li>
            <li>
                <a class="<%= ("view_supplier".equals(currentPage) || "supplier_detail".equals(currentPage)) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=view_supplier">
                    Supplier List
                </a>
            </li>
        </ul>
    </details>

    <details <%= (
        "product-add".equals(currentPage) ||
        "product-list".equals(currentPage) ||
        "product-detail".equals(currentPage) ||
        "sku-add".equals(currentPage)
    ) ? "open" : "" %>>
        <summary>Products</summary>
        <ul>
            <li>
                <a class="<%= "product-add".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=product-add">
                    Add Product
                </a>
            </li>
            <li>
                <a class="<%= "sku-add".equals(currentPage) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=sku-add">
                    Add SKU
                </a>
            </li>
            <li>
                <a class="<%= ("product-list".equals(currentPage) || "product-detail".equals(currentPage)) ? "active" : "" %>"
                   href="<%=ctx%>/home?p=product-list">
                    Product List
                </a>
            </li>
        </ul>
    </details>
    <a class="${currentPage == 'low-stock-report' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/home?p=low-stock-report">
        Low Stock Report
    </a>                

</div>