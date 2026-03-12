<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
    long v = System.currentTimeMillis();
%>

<div class="page-wrap">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="<%=request.getContextPath()%>/home?p=user-view&id=${user.userId}">← Back</a>
            <h1 class="h1">Update User Information</h1>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="msg-err"><b>${error}</b></div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <form method="post"
                  action="<%=request.getContextPath()%>/admin/user/update"
                  enctype="multipart/form-data"
                  class="form">

                <input type="hidden" name="current_avatar" value="${user.avatar}"/>

                <div class="form-grid">
                    <div class="label">User ID</div>
                    <div><input class="input readonly" type="text" name="user_id" value="${user.userId}" readonly></div>

                    <div class="label">Username</div>
                    <div><input class="input readonly" type="text" name="username" value="${user.username}" readonly></div>

                    <div class="label">Full Name <span class="req">*</span></div>
                    <div><input class="input" type="text" name="full_name" value="${user.fullName}"></div>

                    <div class="label">Email</div>
                    <div><input class="input" type="text" name="email" value="${user.email}"></div>

                    <div class="label">Phone</div>
                    <div><input class="input" type="text" name="phone" value="${user.phone}"></div>

                    <div class="label">Address</div>
                    <div><input class="input" type="text" name="address" value="${user.address}" placeholder="e.g. Hanoi"></div>

                    <div class="label">Role <span class="req">*</span></div>
                    <div>
                        <select class="select" name="role_id">
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.roleId}" <c:if test="${user.roleId == r.roleId}">selected</c:if>>
                                    ${r.roleName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="label">Status</div>
                    <div>
                        <input class="input readonly" value="Active" readonly>
                        <input type="hidden" name="status" value="1">
                    </div>

                    <div class="label">Avatar</div>
                    <div>
                        <div style="margin-bottom:10px;">
                            <img id="avatarPreview"
                                 src="${pageContext.request.contextPath}/${empty user.avatar ? 'assets/default-avatar.jpg' : user.avatar}?v=<%=v%>"
                                 alt="avatar"
                                 style="width:96px;height:96px;object-fit:cover;border:1px solid var(--border);border-radius:14px;">
                        </div>
                        <input class="input" type="file" name="avatarFile" accept="image/*">
                        <div class="field-hint">(Optional) Upload a new avatar to replace current one.</div>
                    </div>
                </div>

                <div class="form-actions">
                    <a class="btn" href="<%=request.getContextPath()%>/home?p=user-view&id=${user.userId}">Cancel</a>
                    <button class="btn btn-primary" type="submit">Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
  const input = document.querySelector('input[name="avatarFile"]');
  const img = document.getElementById('avatarPreview');
  if (input) {
    input.addEventListener('change', (e) => {
      const f = e.target.files && e.target.files[0];
      if (!f) return;
      img.src = URL.createObjectURL(f);
    });
  }
</script>