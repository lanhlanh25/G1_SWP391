<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
    // ── Đọc flash attributes từ session ──
    HttpSession _s = request.getSession(false);
    if (_s != null) {
        String[] flashKeys = {
            "flash_role_error", "flash_v_role_name", "flash_v_description"
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
            <a class="btn" href="${pageContext.request.contextPath}/home?p=role-list">← Back</a>
            <h1 class="h1">Add Role</h1>
        </div>
    </div>

    <c:if test="${not empty role_error}">
        <div class="msg-err"><b>${role_error}</b></div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="msg-ok"><b>${success}</b></div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <div class="h2" style="margin-bottom:6px;">Create new role</div>
            <div class="muted" style="margin-bottom:16px;">New role will be created as inactive and without permissions by default.</div>

            <form method="post" action="${pageContext.request.contextPath}/role_add" class="form">
                <div class="form-grid">

                    <div class="label">Role Name <span class="req">*</span></div>
                    <div>
                        <input class="input" name="role_name" value="${v_role_name}" placeholder="e.g. AUDITOR">
                    </div>

                    <div class="label">Description</div>
                    <div>
                        <input class="input" name="description" value="${v_description}" placeholder="Role description...">
                    </div>

                    <div class="label">Users</div>
                    <div>
                        <input class="input readonly" value="0 users" readonly>
                    </div>

                    <div class="label">Status</div>
                    <div>
                        <input class="input readonly" value="Inactive" readonly>
                        <input type="hidden" name="is_active" value="0">
                    </div>

                    <div class="label">Permissions</div>
                    <div class="field-hint">
                        New role will have no permissions by default. Add permissions later in Edit Role Permissions.
                    </div>

                </div>

                <div class="form-actions">
                    <a class="btn" href="${pageContext.request.contextPath}/home?p=role-list">Cancel</a>
                    <button type="submit" class="btn btn-primary">Create</button>
                </div>
            </form>
        </div>
    </div>
</div>
