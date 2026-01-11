<%-- 
    Document   : change_password
    Created on : Jan 11, 2026, 3:51:54 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <a href="<%=request.getContextPath()%>/index.html"
   style="display:inline-block; padding:6px 10px; border:1px solid #000; text-decoration:none; color:#000;">
   ← Back
</a>
<br><br>

    </head>
    <body>
        
        <h1>Change Password</h1>
        <h4>Update your password to keep your account secure</h4>
        <form action="/change_password" method="post">
            Current Password<br><input type="password" name="current_password" placeholder="Enter current password"><br>
            New Password<br><input type="password" name="new_password" placeholder="Enter new password" ><br>
            Confirm New Password<br><input type="password" name="confirm_new_password" placeholder="Confirm new password" ><br>
            <button class="btn" type="submit" style="background-color: #1447E6; color: white">Save Password</button>
        </form>
        <% if (request.getAttribute("error") != null) { %>
  <p style="color:red;"><%= request.getAttribute("error") %></p>
<% } %>

<% if (request.getAttribute("success") != null) { %>
  <p style="color:green;"><%= request.getAttribute("success") %></p>
<% } %>

    </body>
</html>
