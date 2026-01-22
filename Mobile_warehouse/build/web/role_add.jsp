<%-- 
    Document   : role_add
    Created on : Jan 16, 2026, 12:50:53 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Add Role</title>
    </head>
    <body>

        <a href="<%=request.getContextPath()%>/role_list"
           style="display:inline-block; padding:6px 10px; border:1px solid #000; text-decoration:none; color:#000;">
            ← Back
        </a>
        &nbsp;&nbsp;
        <a href="<%=request.getContextPath()%>/home"
           style="display:inline-block; padding:6px 10px; border:1px solid #000; text-decoration:none; color:#000;">
            Home
        </a>

        <br><br>

        <h1>Add Role</h1>
        <h4>Create new role (Demo)</h4>

        <c:if test="${not empty error}">
            <p style="color:red;"><b>${error}</b></p>
                </c:if>

        <c:if test="${not empty success}">
            <p style="color:green;"><b>${success}</b></p>
                </c:if>

        <form method="post" action="<%=request.getContextPath()%>/role_add">
            <table border="1" cellpadding="8" cellspacing="0" style="min-width:900px;">
                <tr>
                    <td style="width:220px;"><b>Role Name *</b></td>
                    <td>
                        <input name="role_name" value="${v_role_name}" placeholder="e.g. AUDITOR" style="width:350px;">
                    </td>
                </tr>

                <tr>
                    <td><b>Description</b></td>
                    <td>
                        <input name="description" value="${v_description}" placeholder="Role description..." style="width:600px;">
                    </td>
                </tr>

                <tr>
                    <td><b>Users</b></td>
                    <td>
                        <b>0 users</b>
                        <input type="hidden" name="user_count" value="0">

                    </td>
                </tr>

                <tr>
                    <td><b>Status</b></td>
                    <td>
                        <b>Deactive</b>
                        <input type="hidden" name="is_active" value="0">
                    </td>
                </tr>

                <tr>
                    <td><b>Permissions</b></td>
                    <td>
                        <i>New role will have no permissions by default. Add permissions later in Update Role Information.</i>
                    </td>
                </tr>
            </table>

            <br>
            <button type="submit"
                    style="background:#1447E6;color:white;padding:6px 16px;border:1px solid #000;">
                Create
            </button>
        </form>

    </body>
</html>