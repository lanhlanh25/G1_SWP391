<%-- 
    Document   : user_add
    Created on : Jan 14, 2026, 12:46:58 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <title>Add User</title>
    <style>
        body { font-family: Arial; background:#f2f2f2; margin:0; }
        .topbar { padding:10px; }
        .btn { display:inline-block; padding:6px 14px; border:2px solid #1f4aa8; background:#4a86d4; color:#000; text-decoration:none; font-weight:600; margin-right:8px; }
        .wrap { padding: 20px 60px; }
        table { border-collapse:collapse; width:900px; background:#fff; }
        td { border:1px solid #000; padding:10px; }
        .label { width:220px; font-weight:700; background:#fafafa; }
        input, select { width:360px; padding:6px; }
        .msg { color:red; margin:10px 0; }
        .preview img { width:90px; height:90px; object-fit:cover; border:1px solid #aaa; border-radius:8px; }
    </style>
</head>
<body>

<div class="topbar">
    <a class="btn" href="${pageContext.request.contextPath}/admin/users">Back</a>
    <a class="btn" href="${pageContext.request.contextPath}/home">Home</a>
</div>

<div class="wrap">
    <h2>Add User</h2>

    <c:if test="${not empty error}">
        <div class="msg"><b>${error}</b></div>
    </c:if>

    <form method="post"
          action="${pageContext.request.contextPath}/admin/user-add"
          enctype="multipart/form-data">

        <input type="hidden" name="status" value="1"/>

        <table>
            <tr>
                <td class="label">Username *</td>
                <td><input name="username" value="${v_username}" placeholder="e.g. staff02"></td>
            </tr>
            <tr>
                <td class="label">Password *</td>
                <td><input type="password" name="password" placeholder="e.g. 123456"></td>
            </tr>
            <tr>
                <td class="label">Full name *</td>
                <td><input name="full_name" value="${v_full_name}" placeholder="Nguyen Van A"></td>
            </tr>
            <tr>
                <td class="label">Email</td>
                <td><input name="email" value="${v_email}" placeholder="a@gmail.com"></td>
            </tr>
            <tr>
                <td class="label">Phone</td>
                <td><input name="phone" value="${v_phone}" placeholder="090xxxxxxx"></td>
            </tr>

            <tr>
                <td class="label">Avatar</td>
                <td>
                    <div class="preview">
                        <img id="addAvatarPreview"
                             src="${pageContext.request.contextPath}/assets/default-avatar.jpg"
                             alt="avatar">
                    </div>
                    <br>
                    <input type="file" name="avatarFile" accept="image/*">
                    <div style="font-size:12px;color:#666;margin-top:6px;">
                        (Optional) If not uploaded, system will use default avatar.
                    </div>
                </td>
            </tr>

            <tr>
                <td class="label">Address</td>
                <td><input name="address" value="${v_address}" placeholder="e.g. Hanoi"></td>
            </tr>

            <tr>
                <td class="label">Role *</td>
                <td>
                    <select name="role_id">
                        <option value="0">-- Choose role --</option>
                        <c:forEach var="r" items="${roles}">
                            <option value="${r.roleId}" <c:if test="${v_role_id == r.roleId}">selected</c:if>>
                                ${r.roleName}
                            </option>
                        </c:forEach>
                    </select>
                </td>
            </tr>

            <tr>
                <td class="label">Status</td>
                <td><b>Active</b></td>
            </tr>
        </table>

        <br>
        <button class="btn" type="submit">Create</button>
    </form>
</div>

<script>
  const input = document.querySelector('input[name="avatarFile"]');
  const img = document.getElementById('addAvatarPreview');
  if (input) {
    input.addEventListener('change', (e) => {
      const f = e.target.files && e.target.files[0];
      if (!f) return;
      img.src = URL.createObjectURL(f);
    });
  }
</script>

</body>
</html>
