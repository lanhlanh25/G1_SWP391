<%-- 
    Document   : inventory_report
    Created on : Mar 16, 2026, 7:54:36 AM
    Author     : Lanhlanh
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<style>
    .ir-wrap  {
        padding: 24px;
    }
    .ir-topbar{
        display:flex;
        align-items:center;
        gap:14px;
        margin-bottom:24px;
        flex-wrap:wrap;
    }
    .ir-title {
        font-size:22px;
        font-weight:800;
        color:var(--text);
        letter-spacing:-.02em;
        margin:0;
    }

    .ir-filter-card {
        background:var(--surface);
        border:1px solid var(--border);
        border-radius:var(--radius);
        box-shadow:var(--shadow);
        padding:18px 22px;
        margin-bottom:22px;
    }
    .ir-filter-row  {
        display:flex;
        gap:14px;
        align-items:flex-end;
        flex-wrap:wrap;
    }
    .ir-filter-grp  {
        display:flex;
        flex-direction:column;
        gap:5px;
    }
    .ir-filter-grp label {
        font-size:11.5px;
        font-weight:600;
        color:var(--text-2);
    }
    .ir-filter-grp input,
    .ir-filter-grp select {
        padding:8px 12px;
        border:1px solid var(--border);
        border-radius:var(--radius-xs);
        font-size:13px;
        font-family:inherit;
        background:var(--surface);
        color:var(--text);
        min-width:150px;
        transition:border-color .15s;
    }
    .ir-filter-grp input:focus,
    .ir-filter-grp select:focus {
        outline:none;
        border-color:var(--primary);
        box-shadow:0 0 0 3px rgba(59,130,246,.1);
    }

    .ir-stats {
        display:grid;
        grid-template-columns:repeat(auto-fit,minmax(170px,1fr));
        gap:14px;
        margin-bottom:22px;
    }
    .ir-stat  {
        background:var(--surface);
        border:1px solid var(--border);
        border-radius:var(--radius);
        box-shadow:var(--shadow);
        padding:20px 22px;
    }
    .ir-stat .stat-label {
        font-size:11.5px;
        font-weight:700;
        color:var(--muted);
        text-transform:uppercase;
        letter-spacing:.06em;
        margin-bottom:8px;
    }
    .ir-stat .stat-val   {
        font-size:26px;
        font-weight:800;
        letter-spacing:-.02em;
    }

    .ir-stat-blue  {
        border-left:4px solid #3b82f6;
    }
    .ir-stat-blue  .stat-val {
        color:#2563eb;
    }
    .ir-stat-green {
        border-left:4px solid #22c55e;
    }
    .ir-stat-green .stat-val {
        color:#16a34a;
    }
    .ir-stat-amber {
        border-left:4px solid #f59e0b;
    }
    .ir-stat-amber .stat-val {
        color:#d97706;
    }
    .ir-stat-slate {
        border-left:4px solid #64748b;
    }
    .ir-stat-slate .stat-val {
        color:#475569;
    }

    .ir-card {
        background:var(--surface);
        border:1px solid var(--border);
        border-radius:var(--radius);
        box-shadow:var(--shadow);
        overflow:hidden;
        margin-bottom:8px;
    }
    .ir-tbl  {
        width:100%;
        border-collapse:collapse;
        font-size:13.5px;
    }
    .ir-tbl th {
        padding:11px 14px;
        background:#f8fafd;
        font-weight:700;
        font-size:11.5px;
        color:var(--text-2);
        text-transform:uppercase;
        letter-spacing:.04em;
        border-bottom:1px solid var(--border);
        white-space:nowrap;
    }
    .ir-tbl td {
        padding:12px 14px;
        border-bottom:1px solid var(--border);
        color:var(--text);
        vertical-align:middle;
    }
    .ir-tbl tbody tr:last-child td {
        border-bottom:none;
    }
    .ir-tbl tbody tr:hover td      {
        background:#f7f9ff;
    }
    .ir-tbl tr.group-hdr td {
        background:#f1f5f9;
        color:#64748b;
        font-size:11px;
        font-weight:700;
        text-transform:uppercase;
        letter-spacing:.05em;
        padding:7px 14px;
    }
    .ir-tbl tr.total-row td {
        background:#eff6ff;
        font-weight:700;
        color:#1e40af;
    }
    .ir-tbl .num {
        text-align:right;
    }

    .var-ok     {
        color:#16a34a;
        font-weight:700;
    }
    .var-danger {
        color:#dc2626;
        font-weight:700;
    }
    .var-zero   {
        color:#64748b;
    }

    .badge-ok   {
        display:inline-block;
        padding:3px 10px;
        border-radius:20px;
        background:#dcfce7;
        color:#166534;
        font-size:12px;
        font-weight:600;
    }
    .badge-low  {
        display:inline-block;
        padding:3px 10px;
        border-radius:20px;
        background:#fef9c3;
        color:#854d0e;
        font-size:12px;
        font-weight:600;
    }
    .badge-out  {
        display:inline-block;
        padding:3px 10px;
        border-radius:20px;
        background:#fee2e2;
        color:#991b1b;
        font-size:12px;
        font-weight:600;
    }
    .badge-miss {
        display:inline-block;
        padding:3px 10px;
        border-radius:20px;
        background:#fce7f3;
        color:#9d174d;
        font-size:12px;
        font-weight:600;
    }

    .ir-paging {
        display:flex;
        align-items:center;
        justify-content:center;
        gap:8px;
        padding:16px 20px;
        border-top:1px solid var(--border);
        flex-wrap:wrap;
    }
    .ir-paging a, .ir-paging span {
        display:inline-flex;
        align-items:center;
        padding:7px 14px;
        border:1px solid var(--border);
        border-radius:var(--radius-xs);
        background:var(--surface);
        font-size:13px;
        font-weight:600;
        color:var(--text);
        text-decoration:none;
    }
    .ir-paging a:hover {
        background:var(--surface-2);
    }
    .pg-active   {
        background:var(--primary-light) !important;
        border-color:var(--primary-border) !important;
        color:var(--primary-2) !important;
        pointer-events:none;
    }
    .pg-disabled {
        opacity:.4;
        pointer-events:none;
    }
    .empty-row   {
        text-align:center;
        padding:40px;
        color:var(--muted);
        font-size:14px;
    }
    .formula-hint {
        font-size:12px;
        color:var(--muted);
        margin-top:6px;
    }
</style>

<div class="ir-wrap">

    <div class="ir-topbar">
        <h1 class="ir-title">Inventory Report</h1>
        <span style="font-size:13px;color:var(--muted);">Import / Export / Stock summary by period</span>
    </div>

    <c:if test="${not empty err}">
        <div style="background:#fee2e2;color:#b91c1c;border:1px solid #fecaca;padding:10px 16px;
             border-radius:var(--radius-xs);font-weight:600;margin-bottom:14px;">
            ${fn:escapeXml(err)}
        </div>
    </c:if>

    <div class="ir-filter-card">
        <form method="get" action="${ctx}/inventory-report">
            <input type="hidden" name="page" value="1"/>
            <div class="ir-filter-row">

                <div class="ir-filter-grp">
                    <label>From Date</label>
                    <input type="date" name="from" value="${fn:escapeXml(from)}"/>
                </div>

                <div class="ir-filter-grp">
                    <label>To Date</label>
                    <input type="date" name="to" value="${fn:escapeXml(to)}"/>
                </div>

                <div class="ir-filter-grp">
                    <label>Brand</label>
                    <select name="brandId">
                        <option value="">All Brands</option>
                        <c:forEach var="b" items="${brands}">
                            <option value="${b.id}" ${brandId == b.id ? 'selected' : ''}>
                                ${fn:escapeXml(b.name)}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="ir-filter-grp">
                    <label>Keyword</label>
                    <input type="text" name="keyword" value="${fn:escapeXml(keyword)}"
                           placeholder="Product name or code..."/>
                </div>

                <div style="display:flex;align-items:flex-end;gap:8px;">
                    <button type="submit" class="btn btn-primary">Apply</button>
                    <a href="${ctx}/inventory-report" class="btn btn-outline">Reset</a>
                </div>

            </div>
            <p class="formula-hint">
                Opening Stock = Current Stock - Import + Export &nbsp;|&nbsp;
                Closing Stock = Opening + Import - Export &nbsp;|&nbsp;
                Variance = 0 when data is consistent
            </p>
        </form>
    </div>

    <div class="ir-stats">

        <div class="ir-stat ir-stat-slate">
            <div class="stat-label">Opening Stock</div>
            <div class="stat-val">${summary.totalOpening}</div>
            <div style="font-size:12px;color:var(--muted);margin-top:4px;">Beginning of period</div>
        </div>

        <div class="ir-stat ir-stat-green">
            <div class="stat-label">Total Import</div>
            <div class="stat-val">+${summary.totalImport}</div>
            <div style="font-size:12px;color:var(--muted);margin-top:4px;">Confirmed receipts</div>
        </div>

        <div class="ir-stat ir-stat-amber">
            <div class="stat-label">Total Export</div>
            <div class="stat-val">-${summary.totalExport}</div>
            <div style="font-size:12px;color:var(--muted);margin-top:4px;">Issued in period</div>
        </div>

        <div class="ir-stat ir-stat-blue">
            <div class="stat-label">Closing Stock</div>
            <div class="stat-val">${summary.totalClosing}</div>
            <div style="font-size:12px;color:var(--muted);margin-top:4px;">Current on-hand</div>
        </div>

    </div>

    <div style="font-size:16px;font-weight:700;color:var(--text);margin:0 0 12px;
         display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;">
        <span>Inventory Details</span>
        <span style="font-size:13px;font-weight:400;color:var(--muted);">
            Showing ${totalItems} product(s)
        </span>
    </div>

    <div class="ir-card">
        <div style="overflow-x:auto;">
            <table class="ir-tbl">
                <thead>
                    <tr>
                        <th>Product Code</th>
                        <th>Product Name</th>
                        <th>Brand</th>
                        <th>Unit</th>
                        <th class="num" style="background:#f0fdf4;color:#166534;">Opening Stock</th>
                        <th class="num" style="background:#f0fdf4;color:#166534;">Import</th>
                        <th class="num" style="background:#fff7ed;color:#9a3412;">Export</th>
                        <th class="num" style="background:#eff6ff;color:#1e40af;">Closing Stock</th>
                        <th class="num">Variance</th>
                        <th style="text-align:center;">Status</th>
                    </tr>
                </thead>
                <tbody>

                <c:if test="${empty rows}">
                    <tr><td colspan="10" class="empty-row">
                            No data found for the selected period. Please adjust the filters and try again.
                        </td></tr>
                </c:if>

                <c:set var="lastBrand" value=""/>
                <c:set var="sumOpen"   value="${0}"/>
                <c:set var="sumImp"    value="${0}"/>
                <c:set var="sumExp"    value="${0}"/>
                <c:set var="sumClose"  value="${0}"/>
                <c:set var="sumVar"    value="${0}"/>

                <c:forEach var="r" items="${rows}">

                    <c:if test="${r.brandName != lastBrand}">
                        <tr class="group-hdr">
                            <td colspan="10">${fn:escapeXml(r.brandName)}</td>
                        </tr>
                        <c:set var="lastBrand" value="${r.brandName}"/>
                    </c:if>

                    <c:set var="sumOpen"  value="${sumOpen  + r.openingQty}"/>
                    <c:set var="sumImp"   value="${sumImp   + r.importQty}"/>
                    <c:set var="sumExp"   value="${sumExp   + r.exportQty}"/>
                    <c:set var="sumClose" value="${sumClose + r.closingQty}"/>
                    <c:set var="sumVar"   value="${sumVar   + r.variance}"/>

                    <c:set var="rowStatus">
                        <c:choose>
                            <c:when test="${r.variance lt 0}">MISSING</c:when>
                            <c:when test="${r.closingQty eq 0}">OUT</c:when>
                            <c:when test="${r.closingQty le 10}">LOW</c:when>
                            <c:otherwise>OK</c:otherwise>
                        </c:choose>
                    </c:set>

                    <tr>
                        <td style="font-weight:700;">${fn:escapeXml(r.productCode)}</td>
                        <td>
                            <a href="${ctx}/inventory-details?productCode=${fn:escapeXml(r.productCode)}"
                               style="color:var(--primary);text-decoration:underline;">
                                ${fn:escapeXml(r.productName)}
                            </a>
                        </td>
                        <td>${fn:escapeXml(r.brandName)}</td>
                        <td style="color:var(--muted);">${r.unit}</td>

                        <td class="num" style="background:#f0fdf4;">${r.openingQty}</td>

                        <td class="num" style="background:#f0fdf4;color:#16a34a;font-weight:600;">
                            +${r.importQty}
                        </td>

                        <td class="num" style="background:#fff7ed;color:#ea580c;font-weight:600;">
                            -${r.exportQty}
                        </td>

                        <td class="num" style="background:#eff6ff;font-weight:700;">${r.closingQty}</td>

                        <td class="num">
                    <c:choose>
                        <c:when test="${r.variance lt 0}">
                            <span class="var-danger">${r.variance}</span>
                        </c:when>
                        <c:when test="${r.variance gt 0}">
                            <span class="var-ok">+${r.variance}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="var-zero">0</span>
                        </c:otherwise>
                    </c:choose>
                    </td>

                    <td style="text-align:center;">
                    <c:choose>
                        <c:when test="${fn:trim(rowStatus) eq 'MISSING'}">
                            <span class="badge-miss">Shortage</span>
                        </c:when>
                        <c:when test="${fn:trim(rowStatus) eq 'OUT'}">
                            <span class="badge-out">Out of Stock</span>
                        </c:when>
                        <c:when test="${fn:trim(rowStatus) eq 'LOW'}">
                            <span class="badge-low">Low Stock</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge-ok">In Stock</span>
                        </c:otherwise>
                    </c:choose>
                    </td>
                    </tr>
                </c:forEach>

                <c:if test="${not empty rows}">
                    <tr class="total-row">
                        <td colspan="4" style="font-weight:800;">Total</td>
                        <td class="num">${sumOpen}</td>
                        <td class="num">+${sumImp}</td>
                        <td class="num">-${sumExp}</td>
                        <td class="num">${sumClose}</td>
                        <td class="num">
                    <c:choose>
                        <c:when test="${sumVar lt 0}"><span class="var-danger">${sumVar}</span></c:when>
                        <c:when test="${sumVar gt 0}"><span class="var-ok">+${sumVar}</span></c:when>
                        <c:otherwise><span class="var-zero">0</span></c:otherwise>
                    </c:choose>
                    </td>
                    <td></td>
                    </tr>
                </c:if>

                </tbody>
            </table>
        </div>

        <c:if test="${totalPages > 1}">
            <c:set var="qsBase" value="from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}&brandId=${brandId}&keyword=${fn:escapeXml(keyword)}"/>
            <div class="ir-paging">

                <c:choose>
                    <c:when test="${page > 1}">
                        <a href="${ctx}/inventory-report?${qsBase}&page=${page - 1}">Prev</a>
                    </c:when>
                    <c:otherwise>
                        <span class="pg-disabled">Prev</span>
                    </c:otherwise>
                </c:choose>

                <c:forEach begin="1" end="${totalPages}" var="pg">
                    <c:choose>
                        <c:when test="${pg == page}">
                            <span class="pg-active">${pg}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="${ctx}/inventory-report?${qsBase}&page=${pg}">${pg}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:choose>
                    <c:when test="${page < totalPages}">
                        <a href="${ctx}/inventory-report?${qsBase}&page=${page + 1}">Next</a>
                    </c:when>
                    <c:otherwise>
                        <span class="pg-disabled">Next</span>
                    </c:otherwise>
                </c:choose>

            </div>
        </c:if>

    </div>

    <div style="font-size:12px;color:var(--muted);margin-top:10px;line-height:1.8;">
        <strong>Legend:</strong>
        <span class="badge-ok"  style="font-size:11px;">In Stock</span> Qty &gt; 10 &nbsp;|&nbsp;
        <span class="badge-low" style="font-size:11px;">Low Stock</span> Qty 1-10 &nbsp;|&nbsp;
        <span class="badge-out" style="font-size:11px;">Out of Stock</span> Qty = 0 &nbsp;|&nbsp;
        <span class="badge-miss" style="font-size:11px;">Shortage</span> Negative variance (needs review)
        &nbsp;&nbsp;
        Opening Stock formula: <code>Current Stock - Import + Export</code>
    </div>

</div>
