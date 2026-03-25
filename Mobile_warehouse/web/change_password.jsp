<%-- 
    Document   : change_password
    Created on : Jan 11, 2026, 3:51:54 PM
    Author     : Admin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Read flash messages from session (set by ChangePassword servlet after redirect)
    String cpError = null;
    String cpSuccess = null;
    if (session != null) {
        cpError = (String) session.getAttribute("cp_error");
        cpSuccess = (String) session.getAttribute("cp_success");
        session.removeAttribute("cp_error");
        session.removeAttribute("cp_success");
    }
    // Also support request attributes (fallback)
    if (cpError == null && request.getAttribute("error") != null) {
        cpError = (String) request.getAttribute("error");
    }
    if (cpSuccess == null && request.getAttribute("success") != null) {
        cpSuccess = (String) request.getAttribute("success");
    }
%>
<div class="page-wrap-sm">
  <div class="auth-card-inline">
    <div class="auth-icon">
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none"
           stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
        <circle cx="12" cy="11" r="1.5" fill="currentColor" stroke="none"/>
      </svg>
    </div>
    <h1 class="auth-title">Change Password</h1>
    <p class="auth-subtitle">Update your password to keep your account secure</p>

    <% if (cpError != null) { %>
      <p class="msg-err"><%= cpError %></p>
    <% } %>
    <% if (cpSuccess != null) { %>
      <p class="msg-ok"><%= cpSuccess %></p>
    <% } %>

    <form class="form" action="<%=request.getContextPath()%>/change_password" method="post">
      <div>
        <label class="label">Current Password</label>
        <div class="input-wrap">
          <input class="input" type="password" name="current_password"
                 placeholder="Enter current password" id="inp-cur"/>
          <button type="button" class="eye-btn" onclick="togglePw('inp-cur')">👁</button>
        </div>
      </div>
      <div>
        <label class="label">New Password</label>
        <div class="input-wrap">
          <input class="input" type="password" name="new_password"
                 placeholder="Enter new password" id="inp-new"/>
          <button type="button" class="eye-btn" onclick="togglePw('inp-new')">👁</button>
        </div>
        <div class="field-hint">Must be at least 8 characters with letters and numbers.</div>
      </div>
      <div>
        <label class="label">Confirm New Password</label>
        <div class="input-wrap">
          <input class="input" type="password" name="confirm_new_password"
                 placeholder="Confirm new password" id="inp-confirm"/>
          <button type="button" class="eye-btn" onclick="togglePw('inp-confirm')">👁</button>
        </div>
      </div>
      <button class="btn btn-primary btn-block" type="submit">Reset password</button>
    </form>
    <div style="text-align:center; margin-top:14px;">
      <a href="<%=request.getContextPath()%>/home">← Back to home</a>
    </div>
  </div>
</div>
<script>
  function togglePw(id) {
    const inp = document.getElementById(id);
    inp.type = inp.type === "password" ? "text" : "password";
  }
</script>
