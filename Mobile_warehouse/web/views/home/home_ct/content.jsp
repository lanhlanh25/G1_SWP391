<%-- 
    Document   : content
    Created on : Jan 13, 2026, 1:47:57 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    User u = (User) session.getAttribute("authUser");
    if (u == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String role = u.getRoleName();
    if (role == null) role = "STAFF";
    role = role.toUpperCase();

    String p = (String) request.getAttribute("page");
    if (p == null) p = "dashboard";
%>

<h3>CONTENT</h3>
<p>Role: <b><%=role%></b> | Page: <b><%=p%></b></p>

<%-- ===== COMMON PAGES (mọi role) ===== --%>
<% if ("dashboard".equals(p)) { %>
<p>Dashboard (chung)</p>

<% } else if ("profile".equals(p)) { %>
<jsp:include page="/views/profile/view_profile.jsp" />

<% } else if ("change-password".equals(p)) { %>
<p>Change Password page (sẽ làm sau)</p>

<% } else if ("denied".equals(p)) { %>
<p style="color:red;">Access Denied!</p>




<%-- ===== ADMIN PAGES ===== --%>
<% } else if ("ADMIN".equals(role) && "user-list".equals(p)) { %>
<p>ADMIN - User List</p>

<% } else if ("ADMIN".equals(role) && "user-add".equals(p)) { %>
<p>ADMIN - Add User</p>

<% } else if ("ADMIN".equals(role) && "user-update".equals(p)) { %>
<p>ADMIN - Update User</p>

<% } else if ("ADMIN".equals(role) && "user-toggle".equals(p)) { %>
<p>ADMIN - Active/Deactive User</p>

<% } else if ("ADMIN".equals(role) && "role-list".equals(p)) { %>
<p>ADMIN - Role List</p>

<% } else if ("ADMIN".equals(role) && "role-update".equals(p)) { %>
<p>ADMIN - Update Role</p>

<% } else if ("ADMIN".equals(role) && "role-toggle".equals(p)) { %>
<p>ADMIN - Active/Deactive Role</p>

<% } else if ("ADMIN".equals(role) && "role-perm-view".equals(p)) { %>
<p>ADMIN - View Role Permissions</p>

<% } else if ("ADMIN".equals(role) && "role-perm-edit".equals(p)) { %>
<p>ADMIN - Edit Role Permissions</p>




<%-- ===== MANAGER PAGES ===== --%>
<% } else if ("MANAGER".equals(role) && "reports".equals(p)) { %>
<p>MANAGER - Weekly Reports</p>

<% } else if ("MANAGER".equals(role) && "user-list".equals(p)) { %>
<p>MANAGER - View User List</p>

<% } else if ("MANAGER".equals(role) && "user-detail".equals(p)) { %>
<p>MANAGER - View User Detail</p>




<%-- ===== STAFF PAGES ===== --%>
<% } else if ("STAFF".equals(role) && "inbound".equals(p)) { %>
<p>STAFF - Inbound (GRN)</p>

<% } else if ("STAFF".equals(role) && "outbound".equals(p)) { %>
<p>STAFF - Outbound (GIN)</p>

<% } else if ("STAFF".equals(role) && "stock-count".equals(p)) { %>
<p>STAFF - Stock Count</p>




<%-- ===== SALE PAGES ===== --%>
<% } else if ("SALE".equals(role) && "inventory".equals(p)) { %>
<p>SALE - View Inventory</p>

<% } else if ("SALE".equals(role) && "create-out".equals(p)) { %>
<p>SALE - Create Outbound Request</p>

<% } else { %>
<p>Page not found!</p>
<% } %>
