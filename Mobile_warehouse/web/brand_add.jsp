<%-- 
    Document   : brand_add
    Created on : Jan 27, 2026, 11:19:38 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();

  // keep list state (NOTE: đừng đặt tên biến là "page" vì trùng implicit object)
  String qParam = request.getParameter("q");
  String statusParam = request.getParameter("status");
  String sortByParam = request.getParameter("sortBy");
  String sortOrderParam = request.getParameter("sortOrder");
  String pageParam = request.getParameter("page");
%>

<h2>Create New Brand</h2>

<% if (request.getParameter("err") != null) { %>
  <p style="color:red;"><%=request.getParameter("err")%></p>
<% } %>

<style>
  .hint{ color:#666; font-size:12px; margin-top:4px; }
  textarea{ width:420px; max-width:90%; }
</style>

<form method="post" action="<%=ctx%>/manager/brand-create" onsubmit="return validateDesc255();">

  <!-- keep list state -->
  <input type="hidden" name="q" value="<%= (qParam==null?"":qParam) %>"/>
  <input type="hidden" name="status" value="<%= (statusParam==null?"":statusParam) %>"/>
  <input type="hidden" name="sortBy" value="<%= (sortByParam==null?"":sortByParam) %>"/>
  <input type="hidden" name="sortOrder" value="<%= (sortOrderParam==null?"":sortOrderParam) %>"/>
  <input type="hidden" name="page" value="<%= (pageParam==null?"":pageParam) %>"/>

  Brand Name (*): <br/>
  <input name="brandName" maxlength="100" required value="${param.brandName}"/><br/><br/>

  Description: <br/>
  <textarea id="desc" name="description" maxlength="255" rows="4" required
            oninput="updateCounter()">${param.description}</textarea>
  <div class="hint">
    <span id="counter">0</span>/255 characters
  </div>
  <br/>

  Status:
  <select name="isActive">
    <option value="1" ${param.isActive=='0' ? '' : 'selected'}>Active</option>
    <option value="0" ${param.isActive=='0' ? 'selected' : ''}>Inactive</option>
  </select>
  <br/><br/>

  <button type="submit">Save</button>

  <a href="<%=ctx%>/home?p=brand-list&q=<%= (qParam==null?"":qParam) %>&status=<%= (statusParam==null?"":statusParam) %>&sortBy=<%= (sortByParam==null?"":sortByParam) %>&sortOrder=<%= (sortOrderParam==null?"":sortOrderParam) %>&page=<%= (pageParam==null?"":pageParam) %>">
    Cancel
  </a>
</form>

<script>
  function updateCounter(){
    var el = document.getElementById('desc');
    var c = (el && el.value) ? el.value.length : 0;
    document.getElementById('counter').textContent = c;
  }
  function validateDesc255(){
    var el = document.getElementById('desc');
    if (!el) return true;
    if (el.value.length > 255){
      alert('Description must be <= 255 characters.');
      return false;
    }
    return true;
  }
  updateCounter();
</script>
