<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
    .wrap{
        padding:16px;
        font-family:Arial,Helvetica,sans-serif;
        background:#f4f4f4;
    }
    .card{
        background:#fff;
        border:1px solid #333;
        padding:14px;
    }
    .title{
        font-size:22px;
        font-weight:700;
        margin-bottom:12px;
    }
    .filters{
        display:flex;
        gap:16px;
        align-items:flex-end;
        flex-wrap:wrap;
        margin-bottom:12px;
    }
    .field label{
        display:block;
        font-size:12px;
        margin-bottom:4px;
    }
    .field input{
        padding:6px 8px;
        border:1px solid #333;
        min-width:180px;
    }
    .btn{
        padding:6px 14px;
        border:1px solid #333;
        background:#f6f6f6;
        cursor:pointer;
        text-decoration:none;
        color:#111;
        display:inline-block;
    }
    table{
        width:100%;
        border-collapse:collapse;
        background:#fff;
    }
    th,td{
        border:1px solid #333;
        padding:8px;
        font-size:13px;
        text-align:center;
    }
    th{
        background:#eee;
    }
    .pager{
        display:flex;
        justify-content:flex-end;
        gap:6px;
        margin-top:10px;
        align-items:center;
    }
    .pagebtn{
        padding:6px 10px;
        border:1px solid #333;
        text-decoration:none;
        color:#111;
        background:#fff;
    }
    .pagebtn.active{
        background:#ddd;
        font-weight:700;
    }
    .hint{
        font-size:12px;
        color:#666;
        margin-top:6px;
    }
</style>

<div class="wrap">
    <div class="card">
        <div class="title">Import Request List</div>

        <form class="filters" method="get" action="${ctx}/home">
            <input type="hidden" name="p" value="import-request-list"/>
            <div class="field">
                <label>Search</label>
                <input type="text" name="q" placeholder="request code" value="${fn:escapeXml(q)}"/>
            </div>

            <div class="field">
                <label>Request Date</label>
                <input type="date" name="reqDate" value="${reqDate}"/>
            </div>

            <div class="field">
                <label>Expected Import Date</label>
                <input type="date" name="expDate" value="${expDate}"/>
            </div>

            <div class="field">
                <button class="btn" type="submit">Apply</button>
                <a class="btn" href="${ctx}/home?p=import-request-list">Reset</a>
            </div>
        </form>

        <table>
            <thead>
                <tr>
                    <th>Request Code</th>
                    <th>Created By</th>
                    <th>Request Date</th>
                    <th>Expected Import Date</th>
                    <th>Total Items</th>
                    <th>Total Qty</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <c:if test="${empty irList}">
                <tr><td colspan="7">No requests found.</td></tr>
            </c:if>

            <c:forEach var="r" items="${irList}">
                <tr>
                    <td>${fn:escapeXml(r.requestCode)}</td>
                    <td>${fn:escapeXml(r.createdByName)}</td>
                    <td><c:out value="${r.requestDate}"/></td>
                <td><c:out value="${r.expectedImportDate}"/></td>
                <td>${r.totalItems}</td>
                <td>${r.totalQty}</td>
                <td>
                    <a class="btn" href="${ctx}/home?p=import-request-detail&id=${r.requestId}">View</a>
                </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>

        <c:url var="baseUrl" value="/home">
            <c:param name="p" value="import-request-list"/>
            <c:param name="q" value="${q}"/>
            <c:param name="reqDate" value="${reqDate}"/>
            <c:param name="expDate" value="${expDate}"/>
        </c:url>

        <div class="pager">
            <c:if test="${page > 1}">
                <a class="pagebtn" href="${baseUrl}&page=${page-1}">Prev</a>
            </c:if>

            <c:forEach var="i" begin="1" end="${totalPages}">
                <a class="pagebtn ${i==page?'active':''}" href="${baseUrl}&page=${i}">${i}</a>
            </c:forEach>

            <c:if test="${page < totalPages}">
                <a class="pagebtn" href="${baseUrl}&page=${page+1}">Next</a>
            </c:if>
        </div>

        <div class="hint">
            Total: ${totalItems} item(s) • Page ${page}/${totalPages}
        </div>

    </div>
</div>