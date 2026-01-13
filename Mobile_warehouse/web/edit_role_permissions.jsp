<%-- 
    Document   : edit_role_permissions
    Created on : Jan 11, 2026, 10:53:09 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.Permission"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Edit Role Permissions</title>
</head>
<body>

<a href="<%=request.getContextPath()%>/role_list">← Back</a>
<br><br>

<h1>Edit Role Permissions</h1>

<%
  Integer roleId = (Integer) request.getAttribute("roleId");
  String roleName = (String) request.getAttribute("roleName");
  String msg = (String) request.getAttribute("msg");
  List<Permission> allPerms = (List<Permission>) request.getAttribute("allPerms");
  Set<Integer> checked = (Set<Integer>) request.getAttribute("checked");
%>

<p><b>Role:</b> <%= roleName %> (#<%= roleId %>)</p>

<% if (msg != null && !msg.isEmpty()) { %>
  <p style="color:green;"><%= msg %></p>
<% } %>

<button type="button" onclick="selectAll()">Select All</button>
<button type="button" onclick="clearAll()">Clear All</button>

<br><br>

<form action="<%=request.getContextPath()%>/role_permissions" method="post">
  <input type="hidden" name="roleId" value="<%= roleId %>"/>

  <table border="1" cellpadding="8" cellspacing="0" style="min-width:900px;">
    <tr>
      <th>Module</th>
      <th>Permission</th>
      <th>Allow</th>
    </tr>

    <%
      if (allPerms != null) {
        for (Permission p : allPerms) {
          boolean isChecked = checked != null && checked.contains(p.getPermissionId());
    %>
      <tr>
        <td><%= p.getModule() %></td>
        <td>
          <b><%= p.getName() %></b>
          <div style="font-size:12px;color:#555;"><%= p.getCode() %> - <%= p.getDescription() %></div>
        </td>
        <td style="text-align:center;">
          <input class="permCheck" type="checkbox" name="permId"
                 value="<%= p.getPermissionId() %>" <%= isChecked ? "checked" : "" %> />
        </td>
      </tr>
    <%
        }
      }
    %>
  </table>

  <br>
  <button type="submit">Save</button>
  <a href="<%=request.getContextPath()%>/role_list">Cancel</a>
</form>

<script>
  function selectAll(){ document.querySelectorAll(".permCheck").forEach(cb => cb.checked = true); }
  function clearAll(){ document.querySelectorAll(".permCheck").forEach(cb => cb.checked = false); }
</script>

</body>
</html>
