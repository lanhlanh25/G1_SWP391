<%-- 
    Document   : brand_disable_confirm
    Created on : Jan 27, 2026, 11:20:37 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();
%>

<h2>Disable Brand Confirmation</h2>

<p>Are you sure you want to disable this brand?</p>
<p><b>Name:</b> ${brand.brandName}</p>
<p><b>Description:</b> ${brand.description}</p>
<p><b>Status:</b> ${brand.active ? "Active" : "Inactive"}</p>

<form method="post" action="<%=ctx%>/manager/brand-disable">
  <input type="hidden" name="id" value="${brand.brandId}"/>
  <button type="submit">Confirm Disable</button>
  <a href="<%=ctx%>/home?p=brand-list">Cancel</a>
</form>

