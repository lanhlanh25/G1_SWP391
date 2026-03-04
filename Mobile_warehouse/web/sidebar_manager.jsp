<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% String ctx = request.getContextPath(); %>

<div class="section-title">Overview</div>
<ul>
  <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
  <li><a href="<%=ctx%>/home?p=reports">Weekly Reports</a></li>
</ul>

<div class="section-title">Receipts</div>
<ul>
  <li>
    <details open>
      <summary>Import</summary>
      <ul>
        <li><a href="<%=ctx%>/import-receipt-list">Import Receipts</a></li>
        <li><a href="<%=ctx%>/home?p=create-import-receipt">Create Import Receipt</a></li>
      </ul>
    </details>
  </li>

  <li>
    <details open>
      <summary>Export</summary>
      <ul>
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
  <li>
    <details open>
      <summary>Brands</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=brand-add">Add Brand</a></li>
        <li><a href="<%=ctx%>/home?p=brand-list">Brand List</a></li>
        <li><a href="<%=ctx%>/home?p=brand-stats">Brand Statistics</a></li>
      </ul>
    </details>
  </li>

  <li>
    <details open>
      <summary>Suppliers</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=add_supplier">Add Supplier</a></li>
        <li><a href="<%=ctx%>/home?p=view_supplier">Supplier List</a></li>
      </ul>
    </details>
  </li>
</ul>

<div class="section-title">Products</div>
<ul>
  <li>
    <details open>
      <summary>Product Management</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=product-add">Add Product</a></li>
        <li><a href="<%=ctx%>/home?p=sku-add">Add SKU</a></li>
        <li><a href="<%=ctx%>/home?p=product-list">Product List</a></li>
      </ul>
    </details>
  </li>
</ul>

<div class="section-title">Requests</div>
<ul>
  <li>
    <details open>
      <summary>Receipt Requests</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=export-request-list">Export Requests</a></li>
        <li><a href="<%=ctx%>/home?p=import-request-list">Import Requests</a></li>
      </ul>
    </details>
  </li>
</ul>
