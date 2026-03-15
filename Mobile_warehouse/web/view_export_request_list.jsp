<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<div class="page-wrap">

    <div class="topbar">
        <div class="title">Export Request List</div>
    </div>

    <div class="card" style="margin-bottom:14px;">
        <div class="card-body">
            <form method="get" action="${ctx}/home">
                <input type="hidden" name="p" value="export-request-list"/>
                <div class="filters" style="grid-template-columns: 2fr 1fr 1fr 1fr auto auto;">
                    <div>
                        <label class="label">Search</label>
                        <input class="input" type="text" name="q" placeholder="request code" value="${fn:escapeXml(q)}"/>
                    </div>
                    <div>
                        <label class="label">Status</label>
                        <select class="input" name="status">
                            <option value="">All</option>
                            <option value="NEW" ${status eq 'NEW' ? 'selected' : ''}>New</option>
                            <option value="COMPLETE" ${status eq 'COMPLETE' ? 'selected' : ''}>Complete</option>
                        </select>
                    </div>
                    <div>
                        <label class="label">Request Date</label>
                        <input class="input" type="date" name="reqDate" value="${reqDate}"/>
                    </div>
                    <div>
                        <label class="label">Expected Export Date</label>
                        <input class="input" type="date" name="expDate" value="${expDate}"/>
                    </div>
                    <div style="display:flex; align-items:flex-end;">
                        <button class="btn btn-primary" type="submit">Apply</button>
                    </div>
                    <div style="display:flex; align-items:flex-end;">
                        <a class="btn btn-outline" href="${ctx}/home?p=export-request-list">Reset</a>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-body" style="padding:0;">
            <table class="table">
                <thead>
                    <tr>
                        <th>Request Code</th>
                        <th>Created By</th>
                        <th>Request Date</th>
                        <th>Expected Export Date</th>
                        <th style="width:100px; text-align:center;">Total Items</th>
                        <th style="width:100px; text-align:center;">Total Qty</th>
                        <th style="width:120px; text-align:center;">Status</th>
                        <th style="width:160px; text-align:center;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty erList}">
                        <tr>
                            <td colspan="8" class="small muted" style="padding:20px; text-align:center;">No requests found.</td>
                        </tr>
                    </c:if>

                    <c:forEach var="r" items="${erList}">
                        <tr>
                            <td>${fn:escapeXml(r.requestCode)}</td>
                            <td>${fn:escapeXml(r.createdByName)}</td>
                            <td><c:out value="${r.requestDate}"/></td>
                            <td><c:out value="${r.expectedExportDate}"/></td>
                            <td style="text-align:center;">${r.totalItems}</td>
                            <td style="text-align:center;">${r.totalQty}</td>
                            <td style="text-align:center;">
                                <c:choose>
                                    <c:when test="${r.status eq 'COMPLETE'}">
                                        <span>Complete</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span>New</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align:center;">
                                <c:if test="${role eq 'STAFF'}">
                                    <c:choose>
                                        <c:when test="${r.status eq 'COMPLETE'}">
                                            <span class="btn btn-sm" style="pointer-events:none; opacity:.6;">Created</span>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="btn btn-sm" href="${ctx}/home?p=create-export-receipt&requestId=${r.requestId}">Create</a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>

                                <a class="btn btn-sm" href="${ctx}/home?p=export-request-detail&id=${r.requestId}">View</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <c:url var="baseUrl" value="/home">
        <c:param name="p" value="export-request-list"/>
        <c:param name="q" value="${q}"/>
        <c:param name="status" value="${status}"/>
        <c:param name="reqDate" value="${reqDate}"/>
        <c:param name="expDate" value="${expDate}"/>
    </c:url>

    <div style="display:flex; align-items:center; justify-content:space-between; margin-top:14px; flex-wrap:wrap; gap:10px;">
        <div class="small muted">Total: ${totalItems} item(s) • Page ${page}/${totalPages}</div>
        <div class="paging">
            <c:choose>
                <c:when test="${page > 1}">
                    <a class="paging-btn" href="${baseUrl}&page=${page-1}">← Prev</a>
                </c:when>
                <c:otherwise>
                    <span class="paging-btn disabled">← Prev</span>
                </c:otherwise>
            </c:choose>

            <c:forEach var="i" begin="1" end="${totalPages}">
                <c:choose>
                    <c:when test="${i==page}">
                        <b>${i}</b>
                    </c:when>
                    <c:otherwise>
                        <a class="paging-btn" href="${baseUrl}&page=${i}">${i}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>

            <c:choose>
                <c:when test="${page < totalPages}">
                    <a class="paging-btn" href="${baseUrl}&page=${page+1}">Next →</a>
                </c:when>
                <c:otherwise>
                    <span class="paging-btn disabled">Next →</span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</div>