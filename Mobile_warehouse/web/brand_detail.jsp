<%-- 
    Document   : brand_detail
    Created on : Jan 27, 2026, 11:19:55 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
  String ctx = request.getContextPath();
%>
<c:set var="role" value="${sessionScope.roleName}" />

<div class="page-wrap-md">
  <div class="topbar">
    <div class="d-flex align-center gap-12">
      <h1 class="h1">Brand Details</h1>
    </div>
    <div class="d-flex gap-8 align-center">
      <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
        <a class="btn btn-primary" href="<%=ctx%>/home?p=brand-update&id=${brand.brandId}">Update</a>
      </c:if>
      <a class="btn btn-outline" href="<%=ctx%>/home?p=brand-list">← Back</a>
    </div>
  </div>

  <c:if test="${not empty param.msg}">
    <div class="msg-ok">${param.msg}</div>
  </c:if>

  <div class="card">
    <div class="card-body">
      <table class="table">
        <tbody>
          <tr>
            <th style="width:180px;">Brand Name</th>
            <td class="fw-600">${brand.brandName}</td>
          </tr>
          <tr>
            <th>Description</th>
            <td class="text-muted fs-14">${brand.description}</td>
          </tr>
          <tr>
            <th>Status</th>
            <td>
              <span class="badge ${brand.active ? 'badge-active' : 'badge-inactive'}">
                <c:choose>
                  <c:when test="${brand.active}">Active</c:when>
                  <c:otherwise>Inactive</c:otherwise>
                </c:choose>
              </span>
            </td>
          </tr>
          <tr>
            <th>Creation Date</th>
            <td class="text-muted"><c:out value="${brand.createdAt}"/></td>
          </tr>
          <tr>
            <th>Last Updated</th>
            <td class="text-muted"><c:out value="${brand.updatedAt}"/></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>