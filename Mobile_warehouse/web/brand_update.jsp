<%-- 
    Document   : brand_update
    Created on : Jan 27, 2026, 11:20:19 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  String ctx = request.getContextPath();

  String qParam = request.getParameter("q");
  String statusParam = request.getParameter("status");
  String sortByParam = request.getParameter("sortBy");
  String sortOrderParam = request.getParameter("sortOrder");
  String pageParam = request.getParameter("page");
%>

<h2>Update Brand</h2>

<% if (request.getParameter("err") != null) { %>
<p style="color:red;"><%=request.getParameter("err")%></p>
<% } %>

<style>
    .hint{
        color:#666;
        font-size:12px;
        margin-top:4px;
    }
    textarea{
        width:420px;
        max-width:90%;
    }
</style>

<form method="post" action="<%=ctx%>/manager/brand-update" onsubmit="return validateDesc255();">
    <input type="hidden" name="id" value="${brand.brandId}"/>

    <!-- keep list state -->
    <input type="hidden" name="q" value="<%= (qParam==null?"":qParam) %>"/>
    <input type="hidden" name="status" value="<%= (statusParam==null?"":statusParam) %>"/>
    <input type="hidden" name="sortBy" value="<%= (sortByParam==null?"":sortByParam) %>"/>
    <input type="hidden" name="sortOrder" value="<%= (sortOrderParam==null?"":sortOrderParam) %>"/>
    <input type="hidden" name="page" value="<%= (pageParam==null?"":pageParam) %>"/>

    Brand Name (*): <br/>
    <input name="brandName" maxlength="100" required
           value="${not empty param.brandName ? param.brandName : brand.brandName}"/><br/><br/>

    Description: <br/>
    <textarea id="desc" name="description" maxlength="255" rows="4"
              oninput="updateCounter()">${not empty param.description ? param.description : brand.description}</textarea>
    <div class="hint">
        <span id="counter">0</span>/255 characters
    </div>
    <br/>

    
    <c:set var="currentActive"
           value="${not empty param.isActive ? param.isActive : (brand.active ? '1' : '0')}" />

    Status:
    <select name="isActive">
        <option value="1" ${currentActive == '1' ? 'selected' : ''}>Active</option>
        <option value="0" ${currentActive == '0' ? 'selected' : ''}>Inactive</option>
    </select>


    <br/><br/>

    <button type="submit">Update</button>

    <a href="<%=ctx%>/home?p=brand-list&q=<%= (qParam==null?"":qParam) %>&status=<%= (statusParam==null?"":statusParam) %>&sortBy=<%= (sortByParam==null?"":sortByParam) %>&sortOrder=<%= (sortOrderParam==null?"":sortOrderParam) %>&page=<%= (pageParam==null?"":pageParam) %>">
        Cancel
    </a>
</form>

<script>
    function updateCounter() {
        var el = document.getElementById('desc');
        var c = (el && el.value) ? el.value.length : 0;
        document.getElementById('counter').textContent = c;
    }
    function validateDesc255() {
        var el = document.getElementById('desc');
        if (!el)
            return true;
        if (el.value.length > 255) {
            alert('Description must be <= 255 characters.');
            return false;
        }
        return true;
    }
    updateCounter();
</script>
