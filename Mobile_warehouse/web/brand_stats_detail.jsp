<%-- 
    Document   : brand_stats_detail
    Created on : Jan 29, 2026, 12:27:40 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  .wrap{ padding:16px; }
  .top{ display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; }
  .btn{ display:inline-block; padding:6px 14px; border:1px solid #333; background:#f6f6f6; text-decoration:none; color:#111; border-radius:3px; }
  table{ width:100%; border-collapse:collapse; }
  th, td{ border:1px solid #333; padding:8px; text-align:left; }
  th{ background:#f1f1f1; }
  .tag{ padding:2px 8px; border:1px solid #999; border-radius:12px; font-size:12px; }
</style>

<div class="wrap">
  <div class="top">
    <h2 style="margin:0;">Brand Detail Statistics: ${brand.brandName}</h2>
    <a class="btn" href="${ctx}/home?p=brand-stats">← Back</a>
  </div>

  <table>
    <tr>
      <th style="width:160px;">Product Code</th>
      <th>Product Name</th>
      <th style="width:140px;">Total Stock Units</th>
      <th style="width:120px;">Status</th>
    </tr>

    <c:forEach items="${products}" var="p">
      <tr>
        <td>${p.productCode}</td>
        <td>${p.productName}</td>
        <td>${p.totalStockUnits}</td>
        <td>
          <span class="tag">${p.stockStatus}</span>
        </td>
      </tr>
    </c:forEach>

    <c:if test="${empty products}">
      <tr>
        <td colspan="4" style="text-align:center; color:#666;">No products</td>
      </tr>
    </c:if>
  </table>
</div>
