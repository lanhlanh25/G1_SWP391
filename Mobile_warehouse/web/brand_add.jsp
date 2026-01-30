<%-- 
    Document   : brand_add
    Created on : Jan 27, 2026, 11:19:38 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();
%>

<h2>Create New Brand</h2>

<% if (request.getParameter("err") != null) { %>
  <p style="color:red;"><%=request.getParameter("err")%></p>
<% } %>

<form method="post" action="<%=ctx%>/manager/brand-create">
  Brand Name (*): <br/>
  <input name="brandName" maxlength="100" required/><br/><br/>

  Description: <br/>
  <input name="description" maxlength="255"/><br/><br/>

  Status:
  <select name="isActive">
    <option value="1" selected>Active</option>
    <option value="0">Inactive</option>
  </select>
  <br/><br/>

  <button type="submit">Save</button>
  <a href="<%=ctx%>/home?p=brand-list">Cancel</a>
</form>

