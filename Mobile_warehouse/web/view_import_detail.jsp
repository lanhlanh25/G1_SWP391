<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  .vir-wrap { padding: 24px; }
  .vir-card {
    background: var(--surface, #fff);
    border: 1px solid var(--border, #e2e8f2);
    border-radius: var(--radius, 16px);
    box-shadow: var(--shadow, 0 4px 16px rgba(16,24,40,.06));
    padding: 24px;
  }

  .vir-header {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 20px;
  }
  .vir-title {
    font-size: 20px;
    font-weight: 800;
    color: var(--text, #0d1829);
  }

  .vir-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border: 1px solid var(--border, #e2e8f2);
    border-radius: var(--radius-xs, 8px);
    background: var(--surface, #fff);
    font-size: 13px;
    font-weight: 600;
    color: var(--text, #0d1829);
    cursor: pointer;
    text-decoration: none;
    transition: background .15s;
  }
  .vir-btn:hover { background: var(--surface-2, #f8fafc); color: var(--text,#0d1829); }
  .vir-btn.primary {
    background: var(--primary, #3b82f6);
    border-color: var(--primary, #3b82f6);
    color: #fff;
  }
  .vir-btn.primary:hover { background: var(--primary-2, #2563eb); }

  .vir-alert-ok {
    padding: 10px 14px;
    border: 1px solid #86efac;
    background: #f0fdf4;
    border-radius: 10px;
    color: #166534;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 14px;
  }
  .vir-alert-err {
    padding: 10px 14px;
    border: 1px solid #fca5a5;
    background: #fef2f2;
    border-radius: 10px;
    color: #b91c1c;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 14px;
  }

  .vir-section-title {
    font-size: 12px;
    font-weight: 700;
    color: var(--muted, #64748b);
    text-transform: uppercase;
    letter-spacing: .08em;
    margin: 0 0 14px;
  }

  /* Meta grid */
  .vir-meta {
    display: grid;
    grid-template-columns: 160px 1fr;
    row-gap: 8px;
    column-gap: 16px;
    max-width: 680px;
    margin-bottom: 24px;
    background: var(--surface-2, #f8fafc);
    border: 1px solid var(--border, #e2e8f2);
    border-radius: 12px;
    padding: 16px 20px;
  }
  .vir-meta .mk { font-size: 12px; font-weight: 700; color: var(--muted, #64748b); text-transform: uppercase; letter-spacing: .04em; padding-top: 2px; }
  .vir-meta .mv { font-size: 13.5px; font-weight: 600; color: var(--text, #0d1829); }

  /* Status badges */
  .status-badge {
    display: inline-flex;
    align-items: center;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 700;
  }
  .status-completed { background: #f0fdf4; color: #166534; border: 1px solid #86efac; }
  .status-pending   { background: #fffbeb; color: #92400e; border: 1px solid #fcd34d; }
  .status-cancelled { background: #fef2f2; color: #b91c1c; border: 1px solid #fca5a5; }

  /* Table */
  .vir-table {
    border-collapse: collapse;
    width: 100%;
    font-size: 13px;
  }
  .vir-table th, .vir-table td {
    border: 1px solid var(--border, #e2e8f2);
    padding: 10px 12px;
    vertical-align: top;
  }
  .vir-table th {
    background: var(--surface-2, #f8fafc);
    font-weight: 700;
    color: var(--text-2, #334155);
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: .04em;
    white-space: nowrap;
  }
  .vir-table tbody tr:hover { background: #fafbff; }
</style>

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
