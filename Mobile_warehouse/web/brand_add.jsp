<%-- 
    Document   : brand_add
    Created on : Jan 27, 2026, 11:19:38 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();

  
  String qParam = request.getParameter("q");
  String statusParam = request.getParameter("status");
  String sortByParam = request.getParameter("sortBy");
  String sortOrderParam = request.getParameter("sortOrder");
  String pageParam = request.getParameter("page");
%>

<div class="page-wrap-sm">
  <div class="topbar">
    <div>
      <div class="title">Add New Brand</div>
      <!--<div class="small">Create a new brand</div>-->
    </div>
    <div class="actions">
      <a class="btn btn-outline"
         href="<%=ctx%>/home?p=brand-list&q=<%= (qParam==null?"":qParam) %>&status=<%= (statusParam==null?"":statusParam) %>&sortBy=<%= (sortByParam==null?"":sortByParam) %>&sortOrder=<%= (sortOrderParam==null?"":sortOrderParam) %>&page=<%= (pageParam==null?"":pageParam) %>">
        Back
      </a>
    </div>
  </div>

  <% if (request.getParameter("err") != null) { %>
    <div class="msg-err"><%=request.getParameter("err")%></div>
  <% } %>

  <div class="card">
    <div class="card-body">
      <form class="form" method="post" action="<%=ctx%>/manager/brand-create" onsubmit="return validateDesc255();">

      
        <input type="hidden" name="q" value="<%= (qParam==null?"":qParam) %>"/>
        <input type="hidden" name="status" value="<%= (statusParam==null?"":statusParam) %>"/>
        <input type="hidden" name="sortBy" value="<%= (sortByParam==null?"":sortByParam) %>"/>
        <input type="hidden" name="sortOrder" value="<%= (sortOrderParam==null?"":sortOrderParam) %>"/>
        <input type="hidden" name="page" value="<%= (pageParam==null?"":pageParam) %>"/>

        <div class="form-grid">
          <div class="label">Brand Name <span class="req">*</span></div>
          <div>
            <input class="input" name="brandName" maxlength="100" required value="${param.brandName}"/>
          </div>

          <div class="label">Description <span class="req">*</span></div>
          <div>
            <textarea class="textarea" id="desc" name="description" maxlength="255" rows="4" required
                      oninput="updateCounter()">${param.description}</textarea>
            <div class="muted" style="margin-top:6px;">
              <span id="counter">0</span>/255 characters
            </div>
          </div>

          <div class="label">Status</div>
          <div>
            <select class="select" name="isActive">
              <option value="1" ${param.isActive=='0' ? '' : 'selected'}>Active</option>
              <option value="0" ${param.isActive=='0' ? 'selected' : ''}>Inactive</option>
            </select>
          </div>
        </div>

        <div class="form-actions">
          <button class="btn btn-primary" type="submit">Save</button>

          <a class="btn btn-outline"
             href="<%=ctx%>/home?p=brand-list&q=<%= (qParam==null?"":qParam) %>&status=<%= (statusParam==null?"":statusParam) %>&sortBy=<%= (sortByParam==null?"":sortByParam) %>&sortOrder=<%= (sortOrderParam==null?"":sortOrderParam) %>&page=<%= (pageParam==null?"":pageParam) %>">
            Cancel
          </a>
        </div>
      </form>
    </div>
  </div>
</div>

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