<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="role" value="${sessionScope.roleName}"/>

<div class="page-wrap">

    <div class="topbar">
        <div class="title">View Import Receipt List</div>
        <div style="display:flex; gap:8px;">
            <c:if test="${role == 'MANAGER'}">
                <a class="btn" style="color:#d97706; border-color:#d97706;" href="${ctx}/home?p=request-delete-import-receipt-list">Request Delete List</a>
            </c:if>
            <a class="btn btn-primary" href="${ctx}/home?p=import-receipt-list&action=export&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">Export</a>
            <a class="btn btn-primary" href="${ctx}/home?p=create-import-receipt">+ Create Import Receipt</a>
        </div>
    </div>

    <c:if test="${not empty msg}"><p class="msg-ok"><c:out value="${msg}"/></p></c:if>
    <c:if test="${not empty err}"><p class="msg-err"><c:out value="${err}"/></p></c:if>

        <div class="card" style="margin-bottom:14px;">
            <div class="card-body">
                <form method="get" action="${ctx}/home">
                <input type="hidden" name="p" value="import-receipt-list"/>

                <div class="filters" style="grid-template-columns: 2fr 1fr 1fr 1fr auto auto;">
                    <div>
                        <label class="label">Search</label>
                        <input class="input" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Import code..."/>
                    </div>
                    <div>
                        <label class="label">Status</label>
                        <select class="input" name="status" style="width: 100%;">
                            <option value="all" ${status=='all' || empty status ? 'selected' : ''}>ALL</option>
                            <option value="pending" ${status=='pending' ? 'selected' : ''}>Pending</option>
                            <option value="completed" ${status=='completed' ? 'selected' : ''}>Completed</option>
                            <option value="cancelled" ${status=='cancelled' ? 'selected' : ''}>Cancelled</option>
                        </select>
                    </div>
                    <div>
                        <label class="label">From</label>
                        <input class="input" type="date" name="from" value="${fn:escapeXml(from)}"/>
                    </div>
                    <div>
                        <label class="label">To</label>
                        <input class="input" type="date" name="to" value="${fn:escapeXml(to)}"/>
                    </div>
                    <div style="display:flex; align-items:flex-end;">
                        <button class="btn btn-primary" type="submit">Search</button>
                    </div>
                    <div style="display:flex; align-items:flex-end;">
                        <a class="btn" style="background:#f6f6f6;" href="${ctx}/home?p=import-receipt-list">Reset</a>
                    </div>
                </div>
            </form>

            <div style="display:flex; gap:8px; margin-top: 16px; padding-top: 16px; border-top: 1px solid #eaeaea;">
                <c:set var="base" value="${ctx}/home?p=import-receipt-list&q=${fn:escapeXml(q)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}" />

                <a class="btn ${status=='all' || empty status ? 'btn-primary' : ''}" style="${status=='all' || empty status ? '' : 'background:#f6f6f6;'}" href="${base}&status=all">
                    ALL <b><c:out value="${tabCounts['all']}"/></b>
                </a>
                <a class="btn ${status=='pending' ? 'btn-primary' : ''}" style="${status=='pending' ? '' : 'background:#f6f6f6;'}" href="${base}&status=pending">
                    Pending <b><c:out value="${tabCounts['pending']}"/></b>
                </a>
                <a class="btn ${status=='completed' ? 'btn-primary' : ''}" style="${status=='completed' ? '' : 'background:#f6f6f6;'}" href="${base}&status=completed">
                    Completed <b><c:out value="${tabCounts['completed']}"/></b>
                </a>
                <a class="btn ${status=='cancelled' ? 'btn-primary' : ''}" style="${status=='cancelled' ? '' : 'background:#f6f6f6;'}" href="${base}&status=cancelled">
                    Cancelled <b><c:out value="${tabCounts['cancelled']}"/></b>
                </a>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-body" style="padding:0;">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width:50px;">No</th>
                        <th>Receipt Code</th>
                        <th>Supplier</th>
                        <th>Created By</th>
                        <th>Created Date</th>
                        <th style="text-align:center;">Total Qty</th>
                        <th>Status</th>
                        <th style="width:250px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty rows}">
                        <tr><td colspan="8" class="small muted" style="padding:20px;">No data</td></tr>
                    </c:if>

                    <c:forEach var="r" items="${rows}" varStatus="st">
                        <tr>
                            <td><c:out value="${st.index + 1}"/></td>
                            <td><c:out value="${r.importCode}"/></td>
                            <td><c:out value="${r.supplierName}"/></td>
                            <td><c:out value="${r.createdByName}"/></td>
                            <td><c:out value="${r.receiptDate}"/></td>
                            <td style="text-align:center;"><c:out value="${r.totalQuantity}"/> Phone</td>
                            <td><c:out value="${r.statusUi}"/></td>

                            <td>
                                <div style="display:flex; gap:6px; flex-wrap: wrap;">
                                    <a class="btn btn-sm" href="${ctx}/home?p=import-receipt-detail&id=${r.importId}">View</a>
                                    <a class="btn btn-primary btn-sm" href="${ctx}/import-receipt-pdf?id=${r.importId}" target="_blank">Download PDF</a>

                                    <c:if test="${role == 'MANAGER' && r.status == 'PENDING'}">
                                        <form method="post" action="${ctx}/home?p=import-receipt-list" style="margin:0;" onsubmit="return confirm('Delete this receipt?');">
                                            <input type="hidden" name="action" value="delete"/>
                                            <input type="hidden" name="id" value="${r.importId}"/>
                                            <button type="submit" class="btn btn-sm" style="background:#ef4444; color:white; border-color:#ef4444;">Delete</button>
                                        </form>
                                    </c:if>

                                    <c:if test="${role == 'STAFF' && r.status == 'PENDING'}">
                                        <a class="btn btn-sm" style="background:#f59e0b; color:white; border-color:#f59e0b;" href="${ctx}/home?p=request-delete-import-receipt&id=${r.importId}">Req Delete</a>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="paging" style="margin-top:14px; justify-content:flex-end;">
        <c:set var="cur" value="${page}" />
        <c:set var="tp" value="${totalPages}" />

        <c:choose>
            <c:when test="${cur <= 1}">
                <span class="paging-btn disabled">← Prev</span>
            </c:when>
            <c:otherwise>
                <a class="paging-btn" href="${ctx}/home?p=import-receipt-list&page=${cur-1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">← Prev</a>
            </c:otherwise>
        </c:choose>

        <b>${cur}</b>

        <c:choose>
            <c:when test="${cur >= tp}">
                <span class="paging-btn disabled">Next →</span>
            </c:when>
            <c:otherwise>
                <a class="paging-btn" href="${ctx}/home?p=import-receipt-list&page=${cur+1}&q=${fn:escapeXml(q)}&status=${fn:escapeXml(status)}&from=${fn:escapeXml(from)}&to=${fn:escapeXml(to)}">Next →</a>
            </c:otherwise>
        </c:choose>
    </div>

</div>
