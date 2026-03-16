<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
    .vir-wrap {
        padding: 24px;
    }
    .vir-card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius);
        box-shadow: var(--shadow);
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
        font-weight: 700;
        color: var(--text);
    }
    .vir-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 7px 16px;
        border: 1px solid var(--border);
        border-radius: var(--radius-sm);
        background: var(--surface);
        font-size: 13px;
        font-weight: 600;
        color: var(--text-2);
        cursor: pointer;
        text-decoration: none;
        transition: all .15s;
    }
    .vir-btn:hover {
        background: var(--surface-2);
        color: var(--text);
        text-decoration: none;
    }
    .vir-btn.primary {
        background: var(--primary);
        border-color: var(--primary);
        color: #fff;
    }
    .vir-btn.primary:hover {
        background: var(--primary-2);
    }
    .vir-alert-ok {
        padding: 10px 14px;
        border: 1px solid #b5e8c5;
        background: #e6f9ed;
        border-radius: var(--radius-sm);
        color: #0d6832;
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 14px;
    }
    .vir-alert-err {
        padding: 10px 14px;
        border: 1px solid #f5c6cb;
        background: #fdf0f0;
        border-radius: var(--radius-sm);
        color: #b91c1c;
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 14px;
    }
    .vir-section-title {
        font-size: 12px;
        font-weight: 700;
        color: var(--muted);
        text-transform: uppercase;
        letter-spacing: .08em;
        margin: 0 0 14px;
    }
    .vir-meta {
        display: grid;
        grid-template-columns: 160px 1fr;
        row-gap: 8px;
        column-gap: 16px;
        max-width: 680px;
        margin-bottom: 24px;
        background: var(--surface-2);
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: 16px 20px;
    }
    .vir-meta .mk {
        font-size: 12px;
        font-weight: 700;
        color: var(--muted);
        text-transform: uppercase;
        letter-spacing: .04em;
        padding-top: 2px;
    }
    .vir-meta .mv {
        font-size: 13px;
        font-weight: 600;
        color: var(--text);
    }
    .status-badge {
        display: inline-flex;
        align-items: center;
        padding: 3px 10px;
        border-radius: var(--radius-sm);
        font-size: 12px;
        font-weight: 700;
    }
    .status-completed {
        background: #e6f9ed;
        color: #0d6832;
        border: 1px solid #b5e8c5;
    }
    .status-pending {
        background: #fff8e1;
        color: #7c5e00;
        border: 1px solid #ffe082;
    }
    .status-cancelled {
        background: #fdf0f0;
        color: #b91c1c;
        border: 1px solid #f5c6cb;
    }
    .vir-table {
        border-collapse: separate;
        border-spacing: 0;
        width: 100%;
        font-size: 13px;
        border: 1px solid var(--border);
        border-radius: var(--radius);
        overflow: hidden;
    }
    .vir-table th, .vir-table td {
        border-bottom: 1px solid var(--border);
        padding: 10px 12px;
        vertical-align: top;
    }
    .vir-table th {
        background: var(--surface-2);
        font-weight: 600;
        color: var(--text-2);
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: .03em;
        white-space: nowrap;
    }
    .vir-table tbody tr:hover {
        background: #f3f4f7;
    }
    .vir-table tbody tr:last-child td {
        border-bottom: none;
    }
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
                                <td style="white-space:pre-line;font-size:12px;font-family:monospace;">
                                    <c:choose>
                                        <c:when test="${not empty it.imeiText}">
                                            <c:out value="${it.imeiText}"/>
                                        </c:when>
                                        <c:otherwise><span style="color:var(--muted)">—</span></c:otherwise>
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
