<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="s" value="${supplier}"/>

<div class="page-wrap">
  <div class="confirm-page">

    <div class="confirm-icon confirm-icon-warn">
      <svg width="32" height="32" viewBox="0 0 24 24" fill="none"
           stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
        <line x1="12" y1="9" x2="12" y2="13"/>
        <line x1="12" y1="17" x2="12.01" y2="17"/>
      </svg>
    </div>

    <h2 class="confirm-title">Confirm Inactive?</h2>
    <p class="confirm-msg">
      Are you sure you want to inactive supplier
      <b><c:out value="${s.supplierName}"/></b>?
      <br/>
      <span class="small muted">This action can be reversed later.</span>
    </p>

    <div class="confirm-actions">
      <a class="btn btn-outline"
         href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${s.supplierId}">
        Cancel
      </a>
      <form method="post" action="${pageContext.request.contextPath}/supplier-inactive" style="margin:0;">
        <input type="hidden" name="supplierId" value="${s.supplierId}"/>
        <button type="submit" class="btn btn-danger">Confirm Inactive</button>
      </form>
    </div>

  </div>
</div>