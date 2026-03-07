<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
    :root{
        --line:#2e3f95;
        --bg:#f4f4f4;
        --th:#d9d9d9;
        --blue:#2f6feb;
    }

    .wrap{
        padding:14px;
        background:var(--bg);
    }
    .frame{
        border:2px solid var(--line);
        background:#fff;
        padding:12px;
    }
    .toprow{
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:10px;
        margin-bottom:8px;
    }
    .btn{
        border:1px solid #333;
        background:#f6f6f6;
        padding:6px 12px;
        cursor:pointer;
        display:inline-block;
        text-decoration:none;
        color:#111;
        font-size:13px;
        border-radius:6px;
    }
    .btn.primary{
        background:var(--blue);
        border-color:var(--blue);
        color:#fff;
    }
    .btn.danger{
        background:#fff0f0;
    }
    .btnRow{
        display:flex;
        gap:8px;
        align-items:center;
        flex-wrap:wrap;
    }
    .filters{
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:10px;
        flex-wrap:wrap;
        margin:10px 0;
    }
    .leftFilters, .rightFilters{
        display:flex;
        gap:8px;
        align-items:center;
        flex-wrap:wrap;
    }
    input[type="text"], input[type="date"], select{
        padding:6px 8px;
        border:1px solid #333;
        box-sizing:border-box;
        font-size:13px;
        border-radius:6px;
    }

    .tabs{
        display:flex;
        gap:6px;
        margin:10px 0;
        flex-wrap:wrap;
    }
    .tab{
        display:inline-flex;
        gap:6px;
        align-items:center;
        padding:6px 10px;
        border:1px solid #333;
        background:#f6f6f6;
        text-decoration:none;
        color:#111;
        border-radius:6px;
        font-size:13px;
    }
    .tab.active{
        background:var(--blue);
        color:#fff;
        border-color:var(--blue);
    }

    table{
        border-collapse:collapse;
        width:100%;
    }
    th,td{
        border:1px solid #cfcfcf;
        padding:8px;
        font-size:13px;
        vertical-align:top;
    }
    th{
        background:#efefef;
        text-align:left;
        white-space:nowrap;
    }
    .muted{
        color:#999;
        text-align:center;
    }
    .actions{
        display:flex;
        gap:8px;
        align-items:center;
        flex-wrap:wrap;
    }
    .inline{ display:inline; }
    .pager{
        display:flex;
        justify-content:flex-end;
        gap:6px;
        margin-top:10px;
        align-items:center;
    }
    .pill{
        display:inline-block;
        min-width:28px;
        text-align:center;
        padding:6px 10px;
        border:1px solid #aaa;
        background:#f6f6f6;
        border-radius:6px;
    }
    .pill.active{
        background:var(--blue);
        color:#fff;
        border-color:var(--blue);
    }
</style>

<div class="wrap">
    <div class="frame">

        <div class="toprow">
            <div class="btnRow">
                <a class="btn" href="${ctx}/home?p=request-delete-import-receipt-list">Request Delete List</a>

                <form method="get" action="${ctx}/home" style="display:inline;">
                    <input type="hidden" name="p" value="import-receipt-list"/>
                    <input type="hidden" name="action" value="export"/>
                    <button type="submit" class="btn primary">EXPORT</button>
                </form>

                <a class="btn" href="${ctx}/home?p=create-import-receipt">CREATE IMPORT RECEIPT</a>
            </div>
        </div>

        <!-- FILTERS -->
        <form method="get" action="${ctx}/home">
            <input type="hidden" name="p" value="import-receipt-list"/>

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

        <!-- TABS (FIX: use c:url with value="/home" => no double context) -->
        <c:url var="tabAllUrl" value="/home">
            <c:param name="p" value="import-receipt-list"/>
            <c:param name="page" value="1"/>
            <c:param name="q" value="${q}"/>
            <c:param name="status" value="all"/>
            <c:param name="from" value="${from}"/>
            <c:param name="to" value="${to}"/>
        </c:url>

        <c:url var="tabPendingUrl" value="/home">
            <c:param name="p" value="import-receipt-list"/>
            <c:param name="page" value="1"/>
            <c:param name="q" value="${q}"/>
            <c:param name="status" value="pending"/>
            <c:param name="from" value="${from}"/>
            <c:param name="to" value="${to}"/>
        </c:url>

        <c:url var="tabCompletedUrl" value="/home">
            <c:param name="p" value="import-receipt-list"/>
            <c:param name="page" value="1"/>
            <c:param name="q" value="${q}"/>
            <c:param name="status" value="completed"/>
            <c:param name="from" value="${from}"/>
            <c:param name="to" value="${to}"/>
        </c:url>

        <c:url var="tabCancelledUrl" value="/home">
            <c:param name="p" value="import-receipt-list"/>
            <c:param name="page" value="1"/>
            <c:param name="q" value="${q}"/>
            <c:param name="status" value="cancelled"/>
            <c:param name="from" value="${from}"/>
            <c:param name="to" value="${to}"/>
        </c:url>

        <div class="tabs">
            <a class="tab ${status=='all' || empty status ? 'active' : ''}" href="${tabAllUrl}">
                ALL <b><c:out value="${tabCounts['all']}"/></b>
            </a>
            <a class="tab ${status=='pending' ? 'active' : ''}" href="${tabPendingUrl}">
                Pending <b><c:out value="${tabCounts['pending']}"/></b>
            </a>
            <a class="tab ${status=='completed' ? 'active' : ''}" href="${tabCompletedUrl}">
                Completed <b><c:out value="${tabCounts['completed']}"/></b>
            </a>
            <a class="tab ${status=='cancelled' ? 'active' : ''}" href="${tabCancelledUrl}">
                Cancelled <b><c:out value="${tabCounts['cancelled']}"/></b>
            </a>
        </div>

        <!-- TABLE -->
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
                        <!-- correct numbering across pages -->
                        <td><c:out value="${(page-1) * pageSize + st.index + 1}"/></td>

                        <td><c:out value="${r.importCode}"/></td>
                        <td><c:out value="${r.supplierName}"/></td>
                        <td><c:out value="${r.createdByName}"/></td>
                        <td><c:out value="${r.receiptDate}"/></td>
                        <td><c:out value="${r.totalQuantity}"/> Phone</td>
                        <td><c:out value="${r.statusUi}"/></td>

                        <td>
                            <div class="actions">
                                <a href="${ctx}/home?p=import-receipt-detail&id=${r.importId}">View</a>

                                <a class="btn primary" href="${ctx}/import-receipt-pdf?id=${r.importId}">
                                    Download PDF
                                </a>

                                <c:if test="${role == 'MANAGER' && r.status == 'PENDING'}">
                                    <!-- keep p in query or hidden input, both ok -->
                                    <form class="inline" method="post" action="${ctx}/home?p=import-receipt-list"
                                          onsubmit="return confirm('Delete this receipt?');">
                                        <input type="hidden" name="action" value="delete"/>
                                        <input type="hidden" name="id" value="${r.importId}"/>
                                        <button type="submit" class="btn danger">Delete</button>
                                    </form>
                                </c:if>

                                <c:if test="${role == 'STAFF' && r.status == 'PENDING'}">
                                    <a class="btn" href="${ctx}/home?p=request-delete-import-receipt&id=${r.importId}">
                                        Send Request Delete
                                    </a>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <!-- PAGINATION (FIX: value="/home" NOT "${ctx}/home") -->
        <c:url var="prevUrl" value="/home">
            <c:param name="p" value="import-receipt-list"/>
            <c:param name="page" value="${page-1}"/>
            <c:param name="q" value="${q}"/>
            <c:param name="status" value="${empty status ? 'all' : status}"/>
            <c:param name="from" value="${from}"/>
            <c:param name="to" value="${to}"/>
        </c:url>

        <c:url var="nextUrl" value="/home">
            <c:param name="p" value="import-receipt-list"/>
            <c:param name="page" value="${page+1}"/>
            <c:param name="q" value="${q}"/>
            <c:param name="status" value="${empty status ? 'all' : status}"/>
            <c:param name="from" value="${from}"/>
            <c:param name="to" value="${to}"/>
        </c:url>

        <c:if test="${totalPages > 1}">
            <div class="pager">
                <c:choose>
                    <c:when test="${page <= 1}">
                        <span class="btn" style="opacity:.5; pointer-events:none;">Prev</span>
                    </c:when>
                    <c:otherwise>
                        <a class="btn" href="${prevUrl}">Prev</a>
                    </c:otherwise>
                </c:choose>

                <span class="pill active"><c:out value="${page}"/></span>

                <c:choose>
                    <c:when test="${page >= totalPages}">
                        <span class="btn" style="opacity:.5; pointer-events:none;">Next</span>
                    </c:when>
                    <c:otherwise>
                        <a class="btn" href="${nextUrl}">Next</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>

    </div>
</div>