<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

  <div class="topbar">
    <div class="title">Request Delete Import Receipt</div>
    <div style="display:flex; align-items:center; gap:8px;">
      <span class="badge badge-info"><c:out value="${role}"/></span>
      <a class="btn" href="${ctx}/import-receipt-list">← Cancel</a>
    </div>
  </div>

  <c:if test="${not empty param.err}">
    <p class="msg-err"><c:out value="${param.err}"/></p>
  </c:if>

  <div class="card" style="max-width:700px;">
    <div class="card-header">
      <span class="h2">Receipt Info & Reason</span>
      <span class="small muted">User: <b><c:out value="${currentUser}"/></b></span>
    </div>
    <div class="card-body">
      <form class="form" method="post" action="${ctx}/request-delete-import-receipt">
        <input type="hidden" name="importId"   value="${importInfo.importId}"/>
        <input type="hidden" name="importCode" value="${fn:escapeXml(importInfo.importCode)}"/>

        <div>
          <label class="label">Import Code</label>
          <input class="input readonly" type="text"
                 value="${fn:escapeXml(importInfo.importCode)}" readonly/>
        </div>

        <div>
          <label class="label">Transaction Time</label>
          <input class="input readonly" type="text"
                 value="<fmt:formatDate value="${importInfo.transactionTime}" pattern="MM/dd/yyyy h:mm a"/>"
                 readonly/>
        </div>

        <div>
          <label class="label">Created By</label>
          <input class="input readonly" type="text"
                 value="${fn:escapeXml(currentUser)}" readonly/>
        </div>

        <div>
          <label class="label">Reason <span class="req">*</span></label>
          <textarea class="textarea" name="note"
                    placeholder="Write reason you want to send request delete import receipt."
                    required></textarea>
          <div class="field-hint">Example: Wrong product entered, duplicate entry, incorrect IMEI, etc.</div>
        </div>

        <div class="form-actions">
          <button class="btn btn-primary" type="submit">Send Request</button>
          <a class="btn btn-outline" href="${ctx}/import-receipt-list">Cancel</a>
        </div>

      </form>
    </div>
  </div>

</div>