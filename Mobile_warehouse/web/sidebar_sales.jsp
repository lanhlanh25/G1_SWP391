
<%-- 
    Document   : sidebar_sales
    Created on : Jan 13, 2026, 3:04:43 PM
    Author     : Admin
--%>


<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<h3>SALE MENU</h3>
<ul>
    <li><a href="<%=ctx%>/home?p=dashboard">Dashboard</a></li>

    <li><a href="${pageContext.request.contextPath}/inventory">Inventory Management</a></li>

   <li> <a href="${ctx}/home?p=create-export-request">Create Export Request</a></li>
 <li><a href="${ctx}/home?p=export-request-list">View Export Request Lists</a></li>


    <li><a href="<%=ctx%>/home?p=profile">My Profile</a></li>
    <li><a href="<%=ctx%>/home?p=change_password">Change Password</a></li>

</ul>

