<%-- 
    Document   : request_delete_import_receipt
    Created on : Feb 15, 2026, 5:15:39 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!-- NOTE:
  File này được include vào homepage.jsp (layout chung).
  Không dùng <html><head><body> để tránh lệch margin/padding.
-->

<div class="container">
  <div class="card">
    <div class="card-header">
      <div>
        <div class="h2">Request Delete Import Receipt</div>
        <div class="small" style="margin-top:4px;">
          Role: <b>${fn:escapeXml(role)}</b>
          
        </div>
      </div>

      <a class="btn btn-outline" href="${ctx}/home?p=request-delete-import-receipt-list">Back</a>
    </div>

    <div class="card-body">

      <c:if test="${not empty param.err}">
        <div class="msg-err">${fn:escapeXml(param.err)}</div>
      </c:if>

      <form method="post" action="${ctx}/request-delete-import-receipt" class="form">

        <input type="hidden" name="importId" value="${importInfo.importId}"/>
        <input type="hidden" name="importCode" value="${fn:escapeXml(importInfo.importCode)}"/>

        <div class="form-grid">
          <div class="label">Import Code</div>
          <input class="input readonly" type="text" value="${fn:escapeXml(importInfo.importCode)}" readonly />

          <div class="label">Transaction time</div>
          <input class="input readonly" type="text"
                 value="<fmt:formatDate value='${importInfo.transactionTime}' pattern='MM/dd/yyyy h:mm a'/>"
                 readonly />

          <div class="label">Create By</div>
          <input class="input readonly" type="text" value="${fn:escapeXml(currentUser)}" readonly />

          <div class="label">Note <span class="req">*</span></div>
          <div>
            <textarea class="textarea" name="note" required
              placeholder="Write reason you want to send request delete import receipt."></textarea>
            <div class="field-hint">
              Example: Wrong product entered, duplicate entry, incorrect IMEI, etc.
            </div>
          </div>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Send Request</button>
          <a href="${ctx}/home?p=import-receipt-list" class="btn">Cancel</a>
        </div>

      </form>
    </div>
  </div>
</div>