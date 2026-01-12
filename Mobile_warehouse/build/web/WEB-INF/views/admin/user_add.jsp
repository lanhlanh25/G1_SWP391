<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <title>Admin - Add New User</title>
    <style>
        body{font-family:Arial;background:#f5f6f8;}
        .wrap{max-width:760px;margin:24px auto;background:#fff;border-radius:10px;padding:20px;box-shadow:0 2px 10px rgba(0,0,0,.08)}
        .row{display:flex;gap:12px;margin:10px 0;align-items:center}
        label{width:170px;font-weight:600}
        input,select{flex:1;padding:10px;border:1px solid #ddd;border-radius:8px}
        .btn{padding:10px 16px;border:0;border-radius:8px;cursor:pointer}
        .btn-primary{background:#0d6efd;color:#fff}
        .err{background:#ffe5e5;color:#b00020;padding:10px;border-radius:8px;margin:10px 0}
        .ok{background:#e7fff0;color:#0b6b2f;padding:10px;border-radius:8px;margin:10px 0}
        .hint{color:#666;font-size:13px}
    </style>
</head>
<body>
<div class="wrap">
    <h2>ADD NEW USER (Admin)</h2>
    <p class="hint">Chỉ ADMIN mới truy cập được trang này.</p>
<p>DEBUG roles size = ${roles.size()}</p>
    <c:if test="${param.success == '1'}">
        <div class="ok">Tạo user thành công! ID = ${param.id}</div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="err">${error}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/admin/user-add">
        <div class="row">
            <label>Username *</label>
            <input name="username" value="${v_username}" placeholder="vd: staff02"/>
        </div>

        <div class="row">
            <label>Password *</label>
            <input type="password" name="password" placeholder="vd: 123456"/>
        </div>

        <div class="row">
            <label>Full name *</label>
            <input name="full_name" value="${v_full_name}" placeholder="Nguyễn Văn A"/>
        </div>

        <div class="row">
            <label>Email (unique)</label>
            <input name="email" value="${v_email}" placeholder="a@swp.com (hoặc bỏ trống)"/>
        </div>

        <div class="row">
            <label>Phone</label>
            <input name="phone" value="${v_phone}" placeholder="090xxxxxxx"/>
        </div>

        <div class="row">
            <label>Role *</label>
            <select name="role_id">
                <option value="0">-- Choose role --</option>
                <c:forEach var="r" items="${roles}">
                    <option value="${r.roleId}" <c:if test="${v_role_id == r.roleId}">selected</c:if>>
                        ${r.roleName}
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="row">
            <label>Status</label>
            <select name="status">
                <option value="1" <c:if test="${v_status == 1 || empty v_status}">selected</c:if>>Active</option>
                <option value="0" <c:if test="${v_status == 0}">selected</c:if>>Inactive</option>
            </select>
        </div>

        <div class="row">
            <label></label>
            <button class="btn btn-primary" type="submit">Create User</button>
        </div>
    </form>
</div>
</body>
</html>
