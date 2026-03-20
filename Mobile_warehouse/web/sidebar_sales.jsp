<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";

    String uri = request.getRequestURI();
    if (uri == null) uri = "";

    boolean inventoryOverviewActive = uri.equals(ctx + "/inventory");
%>


<%--<div class="section-title">Overview</div>
<ul>
    <li>
        <a class="<%= "dashboard".equals(currentPage) ? "active" : "" %>"
           href="<%=ctx%>/home?p=dashboard">
            Dashboard
        </a>
    </li>
</ul>--%>

<div class="section-title">Warehouse</div>
<ul>
    <li>
        <a class="<%= inventoryOverviewActive ? "active" : "" %>"
           href="<%=ctx%>/inventory">
            Inventory Overview
        </a>
    </li>
</ul>

<div class="section-title">Requests</div>

<details <%= (
    "create-export-request".equals(currentPage) ||
    "export-request-list".equals(currentPage) ||
    "export-request-detail".equals(currentPage) ||
    "export-request-edit".equals(currentPage)
) ? "open" : "" %>>
    <summary>Export Requests</summary>
    <ul>
        <li>
            <a class="<%= "create-export-request".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=create-export-request">
                Create Request
            </a>
        </li>
        <li>
            <a class="<%= "export-request-list".equals(currentPage) || "export-request-detail".equals(currentPage) || "export-request-edit".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=export-request-list">
                Request List
            </a>
        </li>
    </ul>
</details>

<details <%= (
    "create-import-request".equals(currentPage) ||
    "import-request-list".equals(currentPage) ||
    "import-request-detail".equals(currentPage)
) ? "open" : "" %>>
    <summary>Import Requests</summary>
    <ul>
        <li>
            <a class="<%= "create-import-request".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=create-import-request">
                Create Request
            </a>
        </li>
        <li>
            <a class="<%= "import-request-list".equals(currentPage) || "import-request-detail".equals(currentPage) ? "active" : "" %>"
               href="<%=ctx%>/home?p=import-request-list">
                Request List
            </a>
        </li>
    </ul>
</details>

<div class="section-title">Master Data</div>
<ul>
    <li>
        <a class="<%= "brand-list".equals(currentPage) ? "active" : "" %>"
           href="<%=ctx%>/home?p=brand-list">
            Brand List
        </a>
    </li>
    <li>
        <a class="<%= "view_supplier".equals(currentPage) ? "active" : "" %>"
           href="<%=ctx%>/home?p=view_supplier">
            Supplier List
        </a>
    </li>
</ul>