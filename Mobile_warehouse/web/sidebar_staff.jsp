<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";

    String uri = request.getRequestURI();
    if (uri == null) uri = "";

    boolean inventoryOverviewActive = uri.equals(ctx + "/inventory");
    boolean inventoryCountActive = uri.equals(ctx + "/inventory-count");
%>


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
</ul>

<div class="section-title">Transactions</div>

<details <%= (
    "create-import-receipt".equals(currentPage) ||
    "import-receipt-list".equals(currentPage) ||
    "import-receipt-detail".equals(currentPage) ||
    "request-delete-import-receipt".equals(currentPage) ||
    "request-delete-import-receipt-list".equals(currentPage) ||
    "import-request-list".equals(currentPage) ||
    "import-request-detail".equals(currentPage)
) ? "open" : "" %>>
    <summary>Import Receipts</summary>
    <ul>
        <li>
            <a class="<%= "import-request-list".equals(currentPage) || "import-request-detail".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=import-request-list">
                Import Requests
            </a>
        </li>
        <li>
            <a class="<%= "create-import-receipt".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=create-import-receipt">
                Create Receipt
            </a>
        </li>
        <li>
            <a class="<%= "import-receipt-list".equals(currentPage) || "import-receipt-detail".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=import-receipt-list">
                Receipt List
            </a>
        </li>
        <li>
            <a class="<%= "request-delete-import-receipt".equals(currentPage) || "request-delete-import-receipt-list".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=request-delete-import-receipt-list">
                Delete Requests
            </a>
        </li>
    </ul>
</details>

<details <%= (
    "create-export-receipt".equals(currentPage) ||
    "export-receipt-list".equals(currentPage) ||
    "export-receipt-detail".equals(currentPage) ||
    "export-request-list".equals(currentPage) ||
    "export-request-detail".equals(currentPage)
) ? "open" : "" %>>
    <summary>Export Receipts</summary>
    <ul>
        <li>
            <a class="<%= "export-request-list".equals(currentPage) || "export-request-detail".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=export-request-list">
                Export Requests
            </a>
        </li>
        <li>
            <a class="<%= "create-export-receipt".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=create-export-receipt">
                Create Receipt
            </a>
        </li>
        <li>
            <a class="<%= "export-receipt-list".equals(currentPage) || "export-receipt-detail".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=export-receipt-list">
                Receipt List
            </a>
        </li>
    </ul>
</details>

<div class="section-title">Master Data</div>

<details <%= (
    "view_supplier".equals(currentPage) ||
    "supplier_detail".equals(currentPage)
) ? "open" : "" %>>
    <summary>Suppliers</summary>
    <ul>
        <li>
            <a class="<%= "view_supplier".equals(currentPage) || "supplier_detail".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=view_supplier">
                Supplier List
            </a>
        </li>
    </ul>
</details>

<details <%= (
    "brand-list".equals(currentPage) ||
    "brand-detail".equals(currentPage)
) ? "open" : "" %>>
    <summary>Brands</summary>
    <ul>
        <li>
            <a class="<%= "brand-list".equals(currentPage) || "brand-detail".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=brand-list">
                Brand List
            </a>
        </li>
    </ul>
</details>