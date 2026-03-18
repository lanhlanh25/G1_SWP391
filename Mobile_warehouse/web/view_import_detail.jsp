<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<link rel="stylesheet" href="${ctx}/assets/css/app.css">
<%-- Internal styles moved to app.css --%>

<div class="vir-wrap">
  <div class="vir-card">

    <div class="vir-header">
      <a class="vir-btn" href="${ctx}/home?p=import-receipt-list">← Back to List</a>
      <div class="vir-title">Import Receipt Detail</div>
    </div>

    <c:if test="${not empty param.msg}">
      <div class="vir-alert-ok">${fn:escapeXml(param.msg)}</div>
    </c:if>
    <c:if test="${not empty err}">
      <div class="vir-alert-err">${fn:escapeXml(err)}</div>
    </c:if>

    <c:if test="${not empty receipt}">

      <div class="vir-section-title">Receipt Information</div>

      <div class="vir-meta">
        <div class="mk">Import Code</div>
        <div class="mv">${fn:escapeXml(receipt.importCode)}</div>

        <div class="mk">Transaction Time</div>
        <div class="mv">
          <c:choose>
            <c:when test="${not empty receipt.receiptDate}">
              <fmt:formatDate value="${receipt.receiptDate}" pattern="dd/MM/yyyy HH:mm"/>
            </c:when>
            <c:otherwise>—</c:otherwise>
          </c:choose>
        </div>

        <div class="mk">Supplier</div>
        <div class="mv">${fn:escapeXml(receipt.supplierName)}</div>

        <div class="mk">Created By</div>
        <div class="mv">${fn:escapeXml(receipt.createdByName)}</div>

        <div class="mk">Note</div>
        <div class="mv">
          <c:choose>
            <c:when test="${not empty receipt.note}">${fn:escapeXml(receipt.note)}</c:when>
            <c:otherwise><span style="color:var(--muted)">—</span></c:otherwise>
          </c:choose>
        </div>

        <div class="mk">Status</div>
        <div class="mv">
          <c:set var="statusUp" value="${fn:toUpperCase(receipt.status)}"/>
          <c:choose>
            <c:when test="${statusUp == 'CONFIRMED'}">
              <span class="status-badge status-completed">Completed</span>
            </c:when>
            <c:when test="${statusUp == 'PENDING' || statusUp == 'DRAFT'}">
              <span class="status-badge status-pending">Pending</span>
            </c:when>
            <c:when test="${statusUp == 'CANCELED' || statusUp == 'CANCELLED'}">
              <span class="status-badge status-cancelled">Cancelled</span>
            </c:when>
            <c:otherwise>
              <span class="status-badge status-pending">${fn:escapeXml(receipt.status)}</span>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <div class="vir-section-title">Import Items</div>

      <div style="overflow-x:auto;">
        <table class="vir-table">
          <thead>
            <tr>
              <th style="width:46px;">#</th>
              <th style="width:160px;">Product Name</th>
              <th style="width:130px;">Product Code</th>
              <th style="width:180px;">SKU</th>
              <th style="width:90px;">Quantity</th>
              <th>IMEI Numbers</th>
              <th style="width:140px;">Item Note</th>
              <th style="width:120px;">Created By</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="it" items="${lines}" varStatus="st">
              <tr>
                <td style="text-align:center;color:var(--muted);">${st.index + 1}</td>
                <td style="font-weight:600;">${fn:escapeXml(it.productName)}</td>
                <td style="font-family:monospace;font-size:12px;">${fn:escapeXml(it.productCode)}</td>
                <td style="font-family:monospace;font-size:12px;">${fn:escapeXml(it.skuCode)}</td>
                <td style="text-align:center;font-weight:700;">${it.qty}</td>
                <td style="font-size:12px;font-family:monospace;">
                  <c:choose>
                    <c:when test="${not empty it.imeis}">
                      <div style="line-height:1.8;">
                        <c:forEach var="im" items="${it.imeis}" varStatus="st2">
                          <div>IMEI <c:out value="${st2.index + 1}"/>: <c:out value="${im}"/></div>
                        </c:forEach>
                      </div>
                    </c:when>
                    <c:otherwise>
                      <span style="color:var(--muted)">—</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty it.itemNote}">${fn:escapeXml(it.itemNote)}</c:when>
                    <c:otherwise><span style="color:var(--muted)">—</span></c:otherwise>
                  </c:choose>
                </td>
                <td style="color:var(--muted);font-size:12px;">${fn:escapeXml(it.createdByName)}</td>
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
