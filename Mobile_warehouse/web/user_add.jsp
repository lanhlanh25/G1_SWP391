<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%

    HttpSession _s = request.getSession(false);
    if (_s != null) {
        String[] flashKeys = {
            "flash_error", "flash_errorU", "flash_errorE",
            "flash_v_username", "flash_v_full_name", "flash_v_email",
            "flash_v_phone", "flash_v_address", "flash_v_role_id"
        };
        for (String key : flashKeys) {
            Object val = _s.getAttribute(key);
            if (val != null) {
        
                String reqKey = key.startsWith("flash_") ? key.substring(6) : key;
                request.setAttribute(reqKey, val);
                _s.removeAttribute(key);
            }
        }
    }
%>

<div class="page-wrap-sm">

  <div class="topbar">
    <div style="display:flex; align-items:center; gap:10px;">
      <h1 class="h1">Add User</h1>
    </div>

    <div style="display:flex; gap:8px;">
      <a class="btn" href="${pageContext.request.contextPath}/home?p=user-list">← Back</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=dashboard">Home</a>
    </div>
  </div>

  <c:if test="${not empty error}">
    <div class="msg-err"><b>${error}</b></div>
  </c:if>

  <div class="card" style="max-width:760px;">
    <div class="card-body">
      <div class="h2" style="margin-bottom:16px;">New User Info</div>

      <form class="form" method="post"
            action="${pageContext.request.contextPath}/admin/user-add"
            enctype="multipart/form-data">

        <input type="hidden" name="status" value="1"/>

        <div class="form-grid" style="grid-template-columns: 180px 1fr;">

          <div class="label">Username <span class="req">*</span></div>
          <div>
            <input class="input" name="username" value="${v_username}" placeholder="e.g. staff02"/>
            <c:if test="${not empty errorU}">
              <div class="err">${errorU}</div>
            </c:if>
          </div>

          <div class="label">Password <span class="req">*</span></div>
          <div>
            <input class="input" type="password" name="password" placeholder="e.g. 123456"/>
          </div>

          <div class="label">Full Name <span class="req">*</span></div>
          <div>
            <input class="input" name="full_name" value="${v_full_name}" placeholder="Nguyen Van A"/>
          </div>

          <div class="label">Email <span class="req">*</span></div>
          <div>
            <input class="input" name="email" value="${v_email}" placeholder="a@gmail.com"/>
            <c:if test="${not empty errorE}">
              <div class="err">${errorE}</div>
            </c:if>
          </div>

          <div class="label">Role <span class="req">*</span></div>
          <div>
            <select class="select" name="role_id">
              <option value="0">-- Choose role --</option>
              <c:forEach var="r" items="${roles}">
                <option value="${r.roleId}" <c:if test="${v_role_id == r.roleId}">selected</c:if>>
                  ${r.roleName}
                </option>
              </c:forEach>
            </select>
          </div>

          <div class="label">Phone</div>
          <div>
            <input class="input" name="phone" value="${v_phone}" placeholder="090xxxxxxx"/>
          </div>

          <div class="label">Avatar</div>
          <div>
            <img id="addAvatarPreview"
                 src="${pageContext.request.contextPath}/assets/default-avatar.jpg"
                 alt="avatar"
                 style="width:90px; height:90px; object-fit:cover; border-radius:12px; border:1px solid var(--border); margin-bottom:10px; display:block;"/>
            <input type="file" name="avatarFile" accept="image/*"/>
            <div class="field-hint">(Optional) If not uploaded, system will use default avatar.</div>
          </div>

          <div class="label">Address</div>
          <div>
            <input class="input" name="address" value="${v_address}" placeholder="e.g. Hanoi"/>
          </div>

          <div class="label">Status</div>
          <div>
            <span class="badge badge-active">Active</span>
          </div>

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
  const img = document.getElementById('addAvatarPreview');
  if (input) {
    input.addEventListener('change', e => {
      const f = e.target.files && e.target.files[0];
      if (f) img.src = URL.createObjectURL(f);
    });
  }
</script>
