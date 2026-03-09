
<%-- 
    Document   : sidebar_sales
    Created on : Jan 13, 2026, 3:04:43 PM
    Author     : Admin
--%>


<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% String ctx = request.getContextPath(); %>

<div class="section-title">Overview</div>
<ul>
  <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
</ul>

<div class="section-title">Inventory</div>
<ul>
  <li><a href="<%=ctx%>/inventory">Inventory Management</a></li>
</ul>

<div class="section-title">Requests</div>
<ul>
  <li>
    <details open>
      <summary>Export Requests</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=create-export-request">Create Export Request</a></li>
        <li><a href="<%=ctx%>/home?p=export-request-list">Export Request List</a></li>
      </ul>
    </details>
  </li>

  <li>
    <details open>
      <summary>Import Requests</summary>
      <ul>
        <li><a href="<%=ctx%>/home?p=create-import-request">Create Import Request</a></li>
        <li><a href="<%=ctx%>/home?p=import-request-list">Import Request List</a></li>
      </ul>
    </details>
  </li>
</ul>