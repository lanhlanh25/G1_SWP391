<%-- 
    Document   : admin_reset_requests
    Created on : Jan 22, 2026, 11:24:58 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.ResetRequest"%>
<%
    String ctx = request.getContextPath();
    List<ResetRequest> pending = (List<ResetRequest>) request.getAttribute("pendingRequests");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reset Requests</title>
</head>
<body>
<h2>Password Reset Requests (Pending)</h2>

<% if (pending == null || pending.isEmpty()) { %>
    <p>No pending requests.</p>
<% } else { %>
<table border="1" cellpadding="6" cellspacing="0">
    <tr>
        <th>ID</th>
        <th>User</th>
        <th>Full Name</th>
        <th>Email</th>
        <th>Created At</th>
        <th>Approve</th>
        <th>Reject</th>
    </tr>

    <% for (ResetRequest r : pending) { %>
    <tr>
        <td><%= r.getRequestId() %></td>
        <td><%= r.getUsername() %></td>
        <td><%= r.getFullName() %></td>
        <td><%= r.getEmail() %></td>
        <td><%= r.getCreatedAt() %></td>

        <td>
            <form method="post" action="<%=ctx%>/admin/reset-requests/action"
                  onsubmit="return confirm('Approve this request?');">
                <input type="hidden" name="requestId" value="<%= r.getRequestId() %>">
                <input type="hidden" name="action" value="APPROVE">
                <button type="submit">Approve</button>
            </form>
        </td>

        <td>
            <form method="post" action="<%=ctx%>/admin/reset-requests/action"
                  onsubmit="return confirm('Reject this request?');">
                <input type="hidden" name="requestId" value="<%= r.getRequestId() %>">
                <input type="hidden" name="action" value="REJECT">
                <input type="text" name="reason" placeholder="Reason..." style="width:200px;">
                <button type="submit">Reject</button>
            </form>
        </td>
    </tr>
    <% } %>
</table>
<% } %>

<p style="margin-top:16px;">
    <a href="<%=ctx%>/home">Back to home</a>
</p>

</body>
</html>
