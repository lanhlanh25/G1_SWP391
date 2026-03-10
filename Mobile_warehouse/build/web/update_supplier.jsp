<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="s" value="${requestScope.supplier}"/>
<c:set var="errors"       value="${sessionScope.flashErrors}"/>       <c:remove var="flashErrors"       scope="session"/>
<c:set var="supplierName" value="${sessionScope.flashSupplierName}"/>  <c:remove var="flashSupplierName" scope="session"/>
<c:set var="phone"        value="${sessionScope.flashPhone}"/>         <c:remove var="flashPhone"        scope="session"/>
<c:set var="email"        value="${sessionScope.flashEmail}"/>         <c:remove var="flashEmail"        scope="session"/>
<c:set var="address"      value="${sessionScope.flashAddress}"/>       <c:remove var="flashAddress"      scope="session"/>
<c:if test="${empty supplierName}"><c:set var="supplierName" value="${s.supplierName}"/></c:if>
<c:if test="${empty phone}">       <c:set var="phone"        value="${s.phone}"/></c:if>
<c:if test="${empty email}">       <c:set var="email"        value="${s.email}"/></c:if>
<c:if test="${empty address}">     <c:set var="address"      value="${s.address}"/></c:if>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Update Supplier</div>
    <a class="btn" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${s.supplierId}">← Cancel</a>
  </div>

  <c:if test="${not empty msg}"><p class="msg-err">${msg}</p></c:if>
  <c:if test="${not empty errors}">
    <div class="card" style="border-color:#fecaca; background:#fff1f1; margin-bottom:12px;">
      <div class="card-body">
        <b>Please fix the following:</b>
        <ul style="margin:8px 0 0 18px; padding:0;">
          <c:forEach var="e" items="${errors}"><li class="small">${e}</li></c:forEach>
        </ul>
      </div>
    </div>
  </c:if>

  <div class="card" style="max-width:680px;">
    <div class="card-header"><span class="h2">Supplier Information</span></div>
    <div class="card-body">
      <form class="form" method="post" action="${pageContext.request.contextPath}/supplier-update">
        <input type="hidden" name="supplierId" value="${s.supplierId}"/>

        <div class="form-grid" style="grid-template-columns: 180px 1fr;">
          <label class="label">Supplier Name <span class="req">*</span></label>
          <input class="input" name="supplierName" value="${supplierName}"/>

          <label class="label">Phone</label>
          <input class="input" name="phone" value="${phone}"/>

          <label class="label">Email <span class="req">*</span></label>
          <input class="input" name="email" value="${email}"/>

          <label class="label">Address</label>
          <input class="input" name="address" value="${address}"/>

          <label class="label">Status</label>
          <div style="display:flex; align-items:center; gap:10px;">
            <c:choose>
              <c:when test="${s.isActive == 1}"><span class="badge badge-active">Active</span></c:when>
              <c:otherwise><span class="badge badge-inactive">Inactive</span></c:otherwise>
            </c:choose>
            <span class="small muted">(Change status in Supplier Detail)</span>
          </div>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Save</button>
          <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${s.supplierId}">Cancel</a>
        </div>
      </form>
    </div>
  </div>

</div>