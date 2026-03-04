<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Add User</div>
    <div style="display:flex; gap:8px;">
      <a class="btn" href="${pageContext.request.contextPath}/admin/users">← Back</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/home">Home</a>
    </div>
  </div>

  <c:if test="${not empty error}"><p class="msg-err"><b>${error}</b></p></c:if>

  <div class="card" style="max-width:700px;">
    <div class="card-header"><span class="h2">New User Info</span></div>
    <div class="card-body">
      <form class="form" method="post"
            action="${pageContext.request.contextPath}/admin/user-add"
            enctype="multipart/form-data">
        <input type="hidden" name="status" value="1"/>

        <div class="form-grid" style="grid-template-columns: 200px 1fr;">

          <label class="label">Username <span class="req">*</span></label>
          <div>
            <input class="input" name="username" value="${v_username}" placeholder="e.g. staff02"/>
            <c:if test="${not empty errorU}"><div class="err">${errorU}</div></c:if>
          </div>

          <label class="label">Password <span class="req">*</span></label>
          <input class="input" type="password" name="password" placeholder="e.g. 123456"/>

          <label class="label">Full Name <span class="req">*</span></label>
          <input class="input" name="full_name" value="${v_full_name}" placeholder="Nguyen Van A"/>

          <label class="label">Email <span class="req">*</span></label>
          <div>
            <input class="input" name="email" value="${v_email}" placeholder="a@gmail.com"/>
            <c:if test="${not empty errorE}"><div class="err">${errorE}</div></c:if>
          </div>

          <label class="label">Role <span class="req">*</span></label>
          <select class="select" name="role_id">
            <option value="0">-- Choose role --</option>
            <c:forEach var="r" items="${roles}">
              <option value="${r.roleId}" <c:if test="${v_role_id == r.roleId}">selected</c:if>>${r.roleName}</option>
            </c:forEach>
          </select>

          <label class="label">Phone</label>
          <input class="input" name="phone" value="${v_phone}" placeholder="090xxxxxxx"/>

          <label class="label">Avatar</label>
          <div>
            <img id="addAvatarPreview"
                 src="${pageContext.request.contextPath}/assets/default-avatar.jpg"
                 alt="avatar"
                 style="width:80px; height:80px; object-fit:cover; border-radius:10px; border:1px solid var(--border); margin-bottom:8px; display:block;"/>
            <input type="file" name="avatarFile" accept="image/*"/>
            <div class="field-hint">(Optional) If not uploaded, system will use default avatar.</div>
          </div>

          <label class="label">Address</label>
          <input class="input" name="address" value="${v_address}" placeholder="e.g. Hanoi"/>

          <label class="label">Status</label>
          <span class="badge badge-active">Active</span>

        </div>

        <div class="form-actions">
          <button class="btn btn-primary" type="submit">Create</button>
          <button class="btn btn-outline" type="button"
                  onclick="window.location.href='${pageContext.request.contextPath}/home?p=user-add'">
            Reset
          </button>
        </div>

      </form>
    </div>
  </div>

</div>

<script>
  const input = document.querySelector('input[name="avatarFile"]');
  const img   = document.getElementById('addAvatarPreview');
  if (input) input.addEventListener('change', e => {
    const f = e.target.files && e.target.files[0];
    if (f) img.src = URL.createObjectURL(f);
  });
</script>