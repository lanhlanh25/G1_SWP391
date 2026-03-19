<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="page-wrap">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
            <h1 class="h1">Import Receipt List</h1>
        </div>
        <c:if test="${role eq 'STAFF'}">
            <a class="btn btn-primary" href="${ctx}/home?p=create-import-receipt">+ Create Receipt</a>
        </c:if>
    </div>

    <div class="card">
        <div class="card-body">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:14px;">
                <div>
                    <div class="h2">Manage Import Receipts</div>
                    <!--<div class="muted">Review and export confirmed material arrival documents.</div>-->
                </div>
                <form method="get" action="${ctx}/home">
                    <input type="hidden" name="p" value="import-receipt-list"/>
                    <input type="hidden" name="action" value="export"/>
                    <button type="submit" class="btn btn-outline" style="color: #10b981; border-color: #10b981;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
                        Export Excel
                    </button>
                </form>
            </div>

            <c:if test="${not empty param.msg}">
                <div class="msg-ok">${fn:escapeXml(param.msg)}</div>
            </c:if>
            <c:if test="${not empty param.err}">
                <div class="msg-err">${fn:escapeXml(param.err)}</div>
            </c:if>

            <form method="get" action="${ctx}/home" class="filters" style="grid-template-columns: 2fr 1fr 1fr auto; gap: 12px; align-items: end; margin-bottom: 20px;">
                <input type="hidden" name="p" value="import-receipt-list"/>
                
                <div class="filter-group">
                    <label>Search by Code</label>
                    <input class="input" type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Receipt code (e.g. IR-2026...)"/>
                </div>
                
                <div class="filter-group">
                    <label>From Date</label>
                    <input class="input" type="date" name="from" value="${fn:escapeXml(from)}"/>
                </div>
                
                <div class="filter-group">
                    <label>To Date</label>
                    <input class="input" type="date" name="to" value="${fn:escapeXml(to)}"/>
                </div>
                
                <div class="filter-actions">
                    <button class="btn btn-primary" type="submit" style="height: 38px;">Apply Filter</button>
                </div>
            </form>

            <div class="ir-tabs" style="display:flex; gap:10px; margin-bottom:16px;">
                <c:url var="tabAllUrl" value="/home">
                    <c:param name="p" value="import-receipt-list"/><c:param name="page" value="1"/>
                    <c:param name="q" value="${q}"/><c:param name="status" value="all"/>
                    <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
                </c:url>
                <c:url var="tabCompletedUrl" value="/home">
                    <c:param name="p" value="import-receipt-list"/><c:param name="page" value="1"/>
                    <c:param name="q" value="${q}"/><c:param name="status" value="completed"/>
                    <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
                </c:url>

                <a class="btn btn-sm ${status=='all' || empty status ? 'btn-primary' : 'btn-outline'}" href="${tabAllUrl}" style="border-radius:20px;">
                    All Receipts <span style="margin-left:5px; opacity:0.8;">(${tabCounts['all']})</span>
                </a>
           
                <a class="btn btn-sm ${status=='completed' ? 'btn-primary' : 'btn-outline'}" href="${tabCompletedUrl}" style="border-radius:20px;">
                    Completed <span style="margin-left:5px; opacity:0.8;">(${tabCounts['completed']})</span>
                </a>
            </div>


            <table class="table">
                <thead>
                    <tr>
                        <th style="width:50px;" class="text-center">No</th>
                        <th style="width:160px;">Receipt Code</th>
                        <th>Supplier</th>
                        <th>Created By</th>
                        <th style="width:160px;">Date</th>
                        <th style="width:80px;" class="text-center">Qty</th>
                        <th>Category</th>
                        <th style="width:120px;" class="text-center">Status</th>
                        <th style="width:180px;" class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty rows}">
                        <tr>
                            <td colspan="9" style="text-align:center; padding:24px; color:var(--muted);">No receipts found.</td>
                        </tr>
                    </c:if>
                    <c:forEach var="r" items="${rows}" varStatus="st">
                        <tr>
                            <td style="text-align:center; color:var(--muted);">
                                <c:out value="${(page-1)*pageSize + st.index + 1}"/>
                            </td>
                            <td class="fw-600"><c:out value="${r.importCode}"/></td>
                            <td><c:out value="${r.supplierName}"/></td>
                            <td><c:out value="${r.createdByName}"/></td>
                            <td class="text-muted"><c:out value="${r.receiptDate}"/></td>
                            <td class="text-center fw-700"><c:out value="${r.totalQuantity}"/></td>
                            <td class="text-center"><span class="badge badge-outline">Phone</span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.statusUi == 'CONFIRMED' || r.statusUi == 'completed' || r.statusUi == 'COMPLETED'}">
                                        <span class="badge badge-active">Completed</span>
                                    </c:when>
                                    <c:when test="${r.statusUi == 'pending' || r.statusUi == 'PENDING'}">
                                        <span class="badge badge-warning">Pending</span>
                                    </c:when>
                                    <c:when test="${r.statusUi == 'cancelled' || r.statusUi == 'CANCELLED' || r.statusUi == 'CANCELED'}">
                                        <span class="badge badge-inactive">Cancelled</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-active">Completed</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="d-flex gap-8 align-center justify-center flex-nowrap">
                                    <a class="btn btn-sm btn-info" href="${ctx}/home?p=import-receipt-detail&id=${r.importId}">View</a>
                                    <a class="btn btn-sm btn-warning" href="${ctx}/import-receipt-pdf?id=${r.importId}">PDF</a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        <c:url var="prevUrl" value="/home">
            <c:param name="p" value="import-receipt-list"/><c:param name="page" value="${page-1}"/>
            <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
            <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
        </c:url>
        <c:url var="nextUrl" value="/home">
            <c:param name="p" value="import-receipt-list"/><c:param name="page" value="${page+1}"/>
            <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
            <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
        </c:url>

        <div class="paging-footer">
            <div class="paging-info">Page <b>${page}</b> of <b>${totalPages}</b></div>
            <div class="paging">
                <c:choose>
                    <c:when test="${page <= 1}">
                        <span class="paging-btn disabled">← Prev</span>
                    </c:when>
                    <c:otherwise>
                        <a class="paging-btn" href="${prevUrl}">← Prev</a>
                    </c:otherwise>
                </c:choose>

                <c:forEach begin="1" end="${totalPages}" var="i">
                    <c:choose>
                        <c:when test="${i == page}">
                            <span class="paging-btn active">${i}</span>
                        </c:when>
                        <c:otherwise>
                            <c:url var="pageUrl" value="/home">
                                <c:param name="p" value="import-receipt-list"/><c:param name="page" value="${i}"/>
                                <c:param name="q" value="${q}"/><c:param name="status" value="${empty status ? 'all' : status}"/>
                                <c:param name="from" value="${from}"/><c:param name="to" value="${to}"/>
                            </c:url>
                            <a class="paging-btn" href="${pageUrl}">${i}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:choose>
                    <c:when test="${page >= totalPages}">
                        <span class="paging-btn disabled">Next →</span>
                    </c:when>
                    <c:otherwise>
                        <a class="paging-btn" href="${nextUrl}">Next →</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
</div>
