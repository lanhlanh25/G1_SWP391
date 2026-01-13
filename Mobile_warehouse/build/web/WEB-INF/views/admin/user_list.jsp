<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Admin - User List</title>
  <style>
    body{font-family:Arial;background:#f5f6f8;}
    .wrap{max-width:1000px;margin:24px auto;background:#fff;border-radius:10px;padding:20px;box-shadow:0 2px 10px rgba(0,0,0,.08)}
    table{width:100%;border-collapse:collapse}
    th,td{padding:10px;border-bottom:1px solid #eee;text-align:left}
    th{background:#fafafa}
    .badge{padding:4px 10px;border-radius:999px;font-size:12px;display:inline-block}
    .on{background:#e7fff0;color:#0b6b2f}
    .off{background:#ffe5e5;color:#b00020}
    .btn{padding:8px 12px;border:0;border-radius:8px;cursor:pointer}
    .btn-on{background:#dc3545;color:#fff}   /* deactivate */
    .btn-off{background:#198754;color:#fff}  /* activate */
    .msg{margin:10px 0;padding:10px;border-radius:8px;background:#eef3ff}
    a{color:#0d6efd;text-decoration:none}
  </style>
</head>
<body>
<div class="wrap">
  <h2>USER LIST (Admin)</h2>

  <c:if test="${not empty param.msg}">
    <div class="msg">MSG: ${param.msg}</div>
  </c:if>

  <p>
    <a href="${pageContext.request.contextPath}/admin/user-add">+ Add new user</a>
  </p>

  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>Username</th>
        <th>Full name</th>
        <th>Email</th>
        <th>Role</th>
        <th>Status</th>
        <th>Action (Task #10)</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="u" items="${users}">
        <tr>
          <td>${u.userId}</td>
          <td>${u.username}</td>
          <td>${u.fullName}</td>
          <td>${u.email}</td>
          <td>${u.roleName}</td>

          <td>
            <c:choose>
              <c:when test="${u.status == 1}">
                <span class="badge on">Active</span>
              </c:when>
              <c:otherwise>
                <span class="badge off">Inactive</span>
              </c:otherwise>
            </c:choose>
          </td>

          <td>
            <c:choose>
              <c:when test="${u.status == 1}">
                <!-- Deactivate -->
                <form method="post" action="${pageContext.request.contextPath}/admin/user-toggle" style="margin:0">
                  <input type="hidden" name="user_id" value="${u.userId}">
                  <input type="hidden" name="status" value="0">
                  <button class="btn btn-on" type="submit"
                          onclick="return confirm('Deactivate user ${u.username}?');">
                    Deactivate
                  </button>
                </form>
              </c:when>

              <c:otherwise>
                <!-- Activate -->
                <form method="post" action="${pageContext.request.contextPath}/admin/user-toggle" style="margin:0">
                  <input type="hidden" name="user_id" value="${u.userId}">
                  <input type="hidden" name="status" value="1">
                  <button class="btn btn-off" type="submit"
                          onclick="return confirm('Activate user ${u.username}?');">
                    Activate
                  </button>
                </form>
              </c:otherwise>
            </c:choose>
          </td>

        </tr>
      </c:forEach>
    </tbody>
  </table>
</div>
</body>
</html>
