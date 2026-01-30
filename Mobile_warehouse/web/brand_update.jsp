<%-- 
    Document   : brand_update
    Created on : Jan 27, 2026, 11:20:19 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();
%>

<h2>Update Brand</h2>

<% if (request.getParameter("err") != null) { %>
  <p style="color:red;"><%=request.getParameter("err")%></p>
<% } %>

<form method="post" action="<%=ctx%>/manager/brand-update">
  <input type="hidden" name="id" value="${brand.brandId}"/>

  Brand Name (*): <br/>
  <input name="brandName" value="${brand.brandName}" maxlength="100" required/><br/><br/>

  Description: <br/>
  <input name="description" value="${brand.description}" maxlength="255"/><br/><br/>

  Status:
  <select name="isActive">
    <option value="1" ${brand.active ? 'selected' : ''}>Active</option>
    <option value="0" ${!brand.active ? 'selected' : ''}>Inactive</option>
  </select>
  <br/><br/>

  <button type="submit">Update</button>
  <a href="<%=ctx%>/home?p=brand-list">Cancel</a>
</form>
