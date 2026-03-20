<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.ResetRequest"%>
<%
    String ctx = request.getContextPath();
    List<ResetRequest> pending = (List<ResetRequest>) request.getAttribute("pendingRequests");
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
    if (message != null) session.removeAttribute("message");
    if (error != null) session.removeAttribute("error");
    int totalPending = pending == null ? 0 : pending.size();
%>

<div class="page-wrap">
    <div class="topbar">
        <div>
            <h1 class="h1 m-0">Password Reset Requests</h1>
            <div class="muted">Review, approve or reject pending password reset requests from one queue.</div>
        </div>
        <div class="actions">
            <span class="badge badge-info"><%= totalPending %> pending</span>
            <a class="btn btn-outline" href="<%=ctx%>/home?p=dashboard">Back to Dashboard</a>
        </div>
    </div>

    <% if (message != null && !message.isBlank()) { %>
        <div class="msg-ok"><%= message %></div>
    <% } %>
    <% if (error != null && !error.isBlank()) { %>
        <div class="msg-err"><%= error %></div>
    <% } %>

    <div class="card">
        <div class="card-header">
            <div>
                <div class="h2">Pending Approvals</div>
                <div class="card-subtitle">Only requests with status PENDING are shown here.</div>
            </div>
        </div>
        <div class="card-body">
            <% if (pending == null || pending.isEmpty()) { %>
                <div class="empty-state">No pending password reset requests.</div>
            <% } else { %>
                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width:80px;">ID</th>
                                <th style="width:150px;">Username</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th style="width:180px;">Requested At</th>
                                <th style="width:180px;">Approve</th>
                                <th style="width:320px;">Reject</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (ResetRequest r : pending) { %>
                                <tr>
                                    <td><%= r.getRequestId() %></td>
                                    <td class="fw-700"><%= r.getUsername() %></td>
                                    <td><%= r.getFullName() %></td>
                                    <td><%= r.getEmail() %></td>
                                    <td class="text-2"><%= r.getCreatedAt() %></td>
                                    <td>
                                        <form method="post"
                                              action="<%=ctx%>/admin/reset-requests/action"
                                              class="d-flex align-center gap-8 mb-0"
                                              onsubmit="return confirm('Approve this request and send a generated password to the user?');">
                                            <input type="hidden" name="requestId" value="<%= r.getRequestId() %>">
                                            <input type="hidden" name="action" value="APPROVE">
                                            <button class="btn btn-primary btn-sm" type="submit">Approve</button>
                                        </form>
                                    </td>
                                    <td>
                                        <form method="post"
                                              action="<%=ctx%>/admin/reset-requests/action"
                                              class="d-flex align-end gap-8 flex-wrap mb-0"
                                              onsubmit="return confirm('Reject this request?');">
                                            <input type="hidden" name="requestId" value="<%= r.getRequestId() %>">
                                            <input type="hidden" name="action" value="REJECT">
                                            <input class="input w-240" type="text" name="reason" placeholder="Reason for rejection">
                                            <button class="btn btn-danger btn-sm" type="submit">Reject</button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>
</div>
