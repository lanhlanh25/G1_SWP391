<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Admin - View Role Details</title>
  <style>
    body{font-family:Arial;background:#f5f6f8;}
    .wrap{max-width:1000px;margin:24px auto;background:#fff;border-radius:10px;padding:20px;box-shadow:0 2px 10px rgba(0,0,0,.08)}
    .row{display:flex;gap:16px;flex-wrap:wrap}
    .card{flex:1;min-width:280px;border:1px solid #eee;border-radius:10px;padding:16px;background:#fafafa}
    .label{color:#666;font-size:12px;margin-bottom:6px}
    .val{font-size:16px;font-weight:600}
    .badge{padding:4px 10px;border-radius:999px;font-size:12px;display:inline-block}
    .on{background:#e7fff0;color:#0b6b2f}
    .off{background:#ffe5e5;color:#b00020}
    .err{background:#ffe5e5;color:#b00020;padding:12px;border-radius:10px;margin:12px 0;}
  </style>
</head>
<body>
<div class="wrap">
  <h2>VIEW ROLE DETAILS</h2>

  <c:if test="${not empty error}">
    <div class="err">${error}</div>
  </c:if>

  <c:if test="${empty error}">
    <c:set var="u" value="${detail.user}" />
    <c:set var="r" value="${detail.role}" />

    <h3>User Information</h3>
    <div class="row">
      <div class="card">
        <div class="label">User ID</div>
        <div class="val">${u.userId}</div>
      </div>
      <div class="card">
        <div class="label">Username</div>
        <div class="val">${u.username}</div>
      </div>
      <div class="card">
        <div class="label">Full name</div>
        <div class="val">${u.fullName}</div>
      </div>
      <div class="card">
        <div class="label">Email</div>
        <div class="val">${u.email}</div>
      </div>
      <div class="card">
        <div class="label">User Status</div>
        <div class="val">
          <c:choose>
            <c:when test="${u.status == 1}">
              <span class="badge on">ACTIVE</span>
            </c:when>
            <c:otherwise>
              <span class="badge off">INACTIVE</span>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>

    <h3 style="margin-top:16px;">Role Information</h3>
    <div class="row">
      <div class="card">
        <div class="label">Role ID</div>
        <div class="val">${r.roleId}</div>
      </div>
      <div class="card">
        <div class="label">Role Name</div>
        <div class="val">${r.roleName}</div>
      </div>
      <div class="card">
        <div class="label">Role Status</div>
        <div class="val">
          <c:choose>
            <c:when test="${r.isActive == 1}">
              <span class="badge on">ACTIVE</span>
            </c:when>
            <c:otherwise>
              <span class="badge off">INACTIVE</span>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>

    <div class="card" style="margin-top:16px;">
      <div class="label">Role Description</div>
      <div class="val" style="font-weight:400;">
        <c:out value="${r.description}" default="(No description)"/>
      </div>
    </div>
  </c:if>

</div>
</body>
</html>
