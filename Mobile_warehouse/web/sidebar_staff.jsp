<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% String ctx = request.getContextPath(); %>

<div class="section-title">Overview</div>
<ul>
  <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
</ul>

<div class="section-title">Receipts</div>
<ul>
  <li>
    <details open>
      <summary>Import</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=import-request-list">Import Requests</a></li>
        <li><a href="<%=ctx%>/home?p=create-import-receipt">Create Import Receipt</a></li>
        <li><a href="<%=ctx%>/import-receipt-list">Import Receipts</a></li>
      </ul>
    </details>
  </li>

  <li>
    <details open>
      <summary>Export</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=export-request-list">Export Requests</a></li>
        <li><a href="<%=ctx%>/home?p=create-export-receipt">Create Export Receipt</a></li>
        <li><a href="<%=ctx%>/home?p=export-receipt-list">Export Receipts</a></li>
      </ul>
    </details>
  </li>
</ul>

<div class="section-title">Inventory</div>
<ul>
  <li><a href="<%=ctx%>/inventory">Inventory Management</a></li>
  <li><a href="<%=ctx%>/inventory-count">Inventory Count</a></li>
</ul>

<div class="section-title">Master data</div>
<ul>
  <li><a href="<%=ctx%>/home?p=view_supplier">Suppliers</a></li>
  <li><a href="<%=ctx%>/home?p=brand-list">Brands</a></li>
</ul>
