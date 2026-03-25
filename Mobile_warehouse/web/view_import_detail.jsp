<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<link rel="stylesheet" href="${ctx}/assets/css/app.css">
<%-- Internal styles moved to app.css --%>

<div class="page-wrap">
  <div class="topbar">
    <div class="d-flex align-center gap-12">
      <h1 class="h1">Import Receipt Details</h1>
    </div>
    <div class="d-flex gap-8 align-center">
      <a class="btn btn-outline" href="${ctx}/home?p=import-receipt-list">← Back to List</a>
    </div>
  </div>

    <c:if test="${not empty param.msg}">
      <div class="vir-alert-ok">${fn:escapeXml(param.msg)}</div>
    </c:if>
    <c:if test="${not empty err}">
      <div class="vir-alert-err">${fn:escapeXml(err)}</div>
    </c:if>

    <c:if test="${not empty receipt}">

    <div class="card mb-16">
      <div class="card-body">
        <div class="h2 mb-16">Receipt Information</div>
        <table class="table no-border-first">
          <tbody>
            <tr>
              <th style="width:180px;">Import Code</th>
              <td class="fw-600">${fn:escapeXml(receipt.importCode)}</td>
            </tr>
            <tr>
              <th>Transaction Time</th>
              <td class="text-muted">
                <c:choose>
                  <c:when test="${not empty receipt.receiptDate}">
                    <fmt:formatDate value="${receipt.receiptDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:when>
                  <c:otherwise>—</c:otherwise>
                </c:choose>
              </td>
            </tr>
            <tr>
              <th>Supplier</th>
              <td class="text-primary fw-600">${fn:escapeXml(receipt.supplierName)}</td>
            </tr>
            <tr>
              <th>Created By</th>
              <td class="text-muted fs-14">${fn:escapeXml(receipt.createdByName)}</td>
            </tr>
            <tr>
              <th>Note</th>
              <td class="text-muted fs-14">
                <c:choose>
                  <c:when test="${not empty receipt.note}">${fn:escapeXml(receipt.note)}</c:when>
                  <c:otherwise>—</c:otherwise>
                </c:choose>
              </td>
            </tr>
            <tr>
              <th>Status</th>
              <td>
                <c:set var="statusUp" value="${fn:toUpperCase(receipt.status)}"/>
                <c:choose>
                  <c:when test="${statusUp == 'CONFIRMED'}">
                    <span class="badge badge-active">Completed</span>
                  </c:when>
                  <c:when test="${statusUp == 'PENDING' || statusUp == 'DRAFT'}">
                    <span class="badge badge-warning">Pending</span>
                  </c:when>
                  <c:when test="${statusUp == 'CANCELED' || statusUp == 'CANCELLED'}">
                    <span class="badge badge-inactive">Cancelled</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-info">${fn:escapeXml(receipt.status)}</span>
                  </c:otherwise>
                </c:choose>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="h2 mb-16">Import Items</div>
        <table class="table">
          <thead>
            <tr>
              <th style="width:46px;" class="text-center">#</th>
              <th>Product Name</th>
              <th style="width:130px;">Code</th>
              <th style="width:150px;">SKU</th>
              <th style="width:80px;" class="text-center">Qty</th>
              <th>IMEI Numbers</th>
              <th style="width:140px;">Note</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="it" items="${lines}" varStatus="st">
              <tr>
                <td class="text-center text-muted fs-12">${st.index + 1}</td>
                <td class="fw-600">${fn:escapeXml(it.productName)}</td>
                <td class="mono-text fs-12">${fn:escapeXml(it.productCode)}</td>
                <td class="mono-text fs-12">${fn:escapeXml(it.skuCode)}</td>
                <td class="text-center fw-700">${it.qty}</td>
                <td class="fs-12">
                  <c:choose>
                    <c:when test="${not empty it.imeis}">
                      <div class="d-flex flex-column gap-2">
                        <c:forEach var="im" items="${it.imeis}" varStatus="st2">
                          <span class="mono-text text-muted">#${st2.index + 1}: ${im}</span>
                        </c:forEach>
                      </div>
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">—</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="text-muted fs-12">
                  <c:choose>
                    <c:when test="${not empty it.itemNote}">${fn:escapeXml(it.itemNote)}</c:when>
                    <c:otherwise>—</c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty lines}">
              <tr>
                <td colspan="8" style="text-align:center;color:var(--muted);padding:20px;">No items</td>
              </tr>
            </c:if>
          </tbody>
        </table>
      </div>

    </c:if>

  </div>
</div>
