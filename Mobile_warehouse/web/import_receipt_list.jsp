<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
    :root{
        --blue:#3a7bd5;
        --line:#2e3f95;
        --bg:#f4f4f4;
        --th:#d9d9d9;
    }
    .wrap{
        padding:14px;
        background:var(--bg);
        font-family:Arial, Helvetica, sans-serif;
    }
    .frame{
        border:2px solid var(--line);
        background:#fff;
        padding:12px;
    }
    .topbar{
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:12px;
        margin-bottom:10px;
    }
    .title{
        font-size:22px;
        font-weight:700;
    }
    .btn{
        display:inline-block;
        padding:6px 12px;
        border:1px solid #333;
        background:#f6f6f6;
        text-decoration:none;
        color:#111;
        cursor:pointer;
        font-size:13px;
    }
    .btn.primary{
        background:#1f6feb;
        color:#fff;
        border-color:#1f6feb;
    }
    .btn.danger{
        background:#ff4d4d;
        color:#fff;
        border-color:#ff4d4d;
    }
    .btn.warning{
        background:#ff9800;
        color:#fff;
        border-color:#ff9800;
    }
    .btnRow{
        display:flex;
        gap:8px;
        align-items:center;
    }
    .filters{
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:12px;
        margin:8px 0 10px;
    }
    .leftFilters{
        display:flex;
        gap:8px;
        align-items:center;
    }
    .rightFilters{
        display:flex;
        gap:8px;
        align-items:center;
    }
    input[type="text"], input[type="date"], select{
        padding:6px 8px;
        border:1px solid #333;
        box-sizing:border-box;
        font-size:13px;
    }
    .tabs{
        display:flex;
        gap:6px;
        margin:10px 0;
    }
    .tab{
        padding:6px 10px;
        border:1px solid #999;
        background:#f6f6f6;
        cursor:pointer;
        font-size:13px;
        text-decoration:none;
        color:#111;
    }
    .tab.active{
        background:#1f6feb;
        color:#fff;
        border-color:#1f6feb;
    }
    table{
        width:100%;
        border-collapse:collapse;
    }
    th,td{
        border:1px solid #cfcfcf;
        padding:8px;
        font-size:13px;
        vertical-align:middle;
    }
    th{
        background:#efefef;
        text-align:left;
    }
    .actions{
        display:flex;
        gap:6px;
        flex-wrap:wrap;
        align-items:center;
    }
    .pager{
        display:flex;
        justify-content:flex-end;
        gap:6px;
        margin-top:10px;
        align-items:center;
    }
    .pill{
        display:inline-block;
        min-width:26px;
        text-align:center;
        padding:4px 8px;
        border:1px solid #aaa;
        background:#f6f6f6;
    }
    .pill.active{
        background:#1f6feb;
        color:#fff;
        border-color:#1f6feb;
    }
    .muted{
        color:#666;
        font-size:12px;
    }
    form.inline{
        display:inline;
    }
</style>

<div class="wrap">
    <div class="frame">

        <div class="topbar">
            <div class="btnRow">
                <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
                <div class="title">View import receipt list</div>
            </div>

            <div class="btnRow">
                <!-- ✅ Manager: Request Delete Import Receipt List button -->
                <c:if test="${role == 'MANAGER'}">
                    <a class="btn warning" href="${ctx}/home?p=request-delete-import-receipt-list">Request Delete List</a>
                </c:if>

                <!-- ✅ Export button -->
                <a class="btn primary"
                   href="${ctx}/import-receipt-list?action=export&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
                    EXPORT
                </a>
                <a class="btn" href="${ctx}/home?p=create-import-receipt">CREATE IMPORT RECEIPT</a>
            </div>
        </div>

        <form method="get" action="${ctx}/import-receipt-list">
            <div class="filters">
                <div class="leftFilters">
                    <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search by Import Code" />
                    <button class="btn" type="submit">SEARCH</button>
                </div>

                <div class="rightFilters">
                    <select name="status">
                        <option value="all" ${status=='all' || empty status ? 'selected' : ''}>ALL</option>
                        <option value="pending" ${status=='pending' ? 'selected' : ''}>Pending</option>
                        <option value="completed" ${status=='completed' ? 'selected' : ''}>Completed</option>
                        <option value="cancelled" ${status=='cancelled' ? 'selected' : ''}>Cancelled</option>
                    </select>

                    <input type="date" name="from" value="${fn:escapeXml(from)}"/>
                    <input type="date" name="to" value="${fn:escapeXml(to)}"/>
                    <button class="btn" type="submit">Apply</button>
                </div>
            </div>
        </form>

        <div class="tabs">
            <a class="tab ${status=='all' || empty status ? 'active' : ''}"
               href="${ctx}/import-receipt-list?status=all&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
                ALL <b><c:out value="${tabCounts['all']}"/></b>
            </a>
            <a class="tab ${status=='pending' ? 'active' : ''}"
               href="${ctx}/import-receipt-list?status=pending&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
                Pending <b><c:out value="${tabCounts['pending']}"/></b>
            </a>
            <a class="tab ${status=='completed' ? 'active' : ''}"
               href="${ctx}/import-receipt-list?status=completed&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
                Completed <b><c:out value="${tabCounts['completed']}"/></b>
            </a>
            <a class="tab ${status=='cancelled' ? 'active' : ''}"
               href="${ctx}/import-receipt-list?status=cancelled&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">
                Cancelled <b><c:out value="${tabCounts['cancelled']}"/></b>
            </a>
        </div>

        <table>
            <thead>
                <tr>
                    <th style="width:60px;">No</th>
                    <th style="width:140px;">Receipt Code</th>
                    <th>Supplier</th>
                    <th style="width:140px;">Created By</th>
                    <th style="width:160px;">Created Date</th>
                    <th style="width:120px;">Total Quantity</th>
                    <th style="width:120px;">Status</th>
                    <th style="width:260px;">Action</th>
                </tr>
            </thead>
            <tbody>
                <c:if test="${empty rows}">
                    <tr>
                        <td colspan="8" class="muted">No data</td>
                    </tr>
                </c:if>

                <c:forEach var="r" items="${rows}" varStatus="st">
                    <tr>
                        <td><c:out value="${st.index + 1}"/></td>
                        <td><c:out value="${r.importCode}"/></td>
                        <td><c:out value="${r.supplierName}"/></td>
                        <td><c:out value="${r.createdByName}"/></td>
                        <td><c:out value="${r.receiptDate}"/></td>
                        <td><c:out value="${r.totalQuantity}"/></td>
                        <td><c:out value="${r.statusUi}"/></td>

                        <td>
                            <div class="actions">
                                <a class="btn" href="${ctx}/import-receipt-detail?id=${r.importId}">View Detail</a>
                                <a class="btn primary"
                                   href="${ctx}/import-receipt-pdf?id=${r.importId}">
                                    Download PDF
                                </a>

                                
                                <c:if test="${role == 'MANAGER' && r.status == 'PENDING'}">
                                    <form class="inline" method="post" action="${ctx}/import-receipt-list"
                                          onsubmit="return confirm('Delete this receipt?');">
                                        <input type="hidden" name="action" value="delete"/>
                                        <input type="hidden" name="id" value="${r.importId}"/>
                                        <button type="submit" class="btn danger">Delete</button>
                                    </form>
                                </c:if>

                              
                                <c:if test="${role == 'STAFF' && r.status == 'PENDING'}">
                                    <a class="btn warning" href="${ctx}/home?p=request-delete-import-receipt&id=${r.importId}">Send Request Delete</a>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div class="pager">
            <c:set var="cur" value="${page}" />
            <c:set var="tp" value="${totalPages}" />

            <c:choose>
                <c:when test="${cur <= 1}">
                    <span class="btn" style="opacity:.5; pointer-events:none;">Prev</span>
                </c:when>
                <c:otherwise>
                    <a class="btn" href="${ctx}/import-receipt-list?page=${cur-1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">Prev</a>
                </c:otherwise>
            </c:choose>

            <span class="pill active"><c:out value="${cur}"/></span>

            <c:choose>
                <c:when test="${cur >= tp}">
                    <span class="btn" style="opacity:.5; pointer-events:none;">Next</span>
                </c:when>
                <c:otherwise>
                    <a class="btn" href="${ctx}/import-receipt-list?page=${cur+1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">Next</a>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>
