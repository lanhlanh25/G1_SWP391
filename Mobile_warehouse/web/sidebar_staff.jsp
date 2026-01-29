
<%-- 
    Document   : sidebar_staff
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>STAFF MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>
    <li><a href="<%=ctx%>/home?p=inbound">Create Import Receipt</a></li>
    <li><a href="<%=ctx%>/home?p=outbound"> Create Export Receipt</a></li>

   
  
<li> <a href="${pageContext.request.contextPath}/inventory">Inventory Management</a></li>

    <li><a href="<%=ctx%>/inventory-count">Conduct Inventory Count</a></li>

    <li><a href="<%=ctx%>/home?p=brand-list">Brand Management</a></li>
    <li><a href="<%=ctx%>/profile">My Profile</a></li>
    <li><a href="<%=ctx%>/change_password">Change Password</a></li>
</ul>

