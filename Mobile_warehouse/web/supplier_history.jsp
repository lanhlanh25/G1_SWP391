<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<style>
    .wrap{
        padding:16px;
        background:#f4f4f4;
        font-family:Arial, Helvetica, sans-serif;
    }
    .card{
        background:#f5f0e8;
        border:1px solid #ddd;
        border-radius:10px;
        padding:16px;
    }
    .top{
        display:flex;
        justify-content:space-between;
        align-items:flex-start;
        gap:10px;
        flex-wrap:wrap;
    }
    .h1{
        font-size:26px;
        font-weight:900;
        margin:0;
    }
    .sub{
        margin-top:4px;
        color:#666;
        font-size:13px;
    }
    .btn{
        padding:8px 14px;
        border:1px solid #333;
        background:#eee;
        border-radius:8px;
        text-decoration:none;
        color:#000;
        display:inline-block;
    }

    .supplierName{
        margin-top:10px;
        font-size:13px;
        color:#444;
    }
    .supplierName b{
        font-size:14px;
    }

    .filter{
        margin-top:12px;
        border:1px solid #d7d0c6;
        border-radius:10px;
        padding:12px;
        background:#efe9df;
    }
    .filterTitle{
        font-size:12px;
        font-weight:800;
        color:#333;
        margin-bottom:10px;
    }
    .row{
        display:flex;
        gap:14px;
        align-items:flex-end;
        flex-wrap:wrap;
    }
    .field{
        display:flex;
        flex-direction:column;
        gap:6px;
    }
    .field label{
        font-size:12px;
        font-weight:700;
        color:#333;
    }
    input, select{
        padding:8px 10px;
        border:1px solid #888;
        border-radius:6px;
        min-width:220px;
        background:#fff;
    }
    .apply{
        height:34px;
    }

    table{
        width:100%;
        border-collapse:collapse;
        margin-top:12px;
        background:#fff;
    }
    th, td{
        border:1px solid #cfcfcf;
        padding:10px;
        text-align:left;
        vertical-align:middle;
    }
    th{
        background:#f2f2f2;
        font-size:13px;
    }
    .muted{
        color:#777;
        font-size:12px;
    }
    .actions{
        display:flex;
        gap:10px;
    }

    .footer{
        margin-top:12px;
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:10px;
        flex-wrap:wrap;
    }
    .pager{
        display:flex;
        gap:8px;
        align-items:center;
    }
    .pagebtn{
        padding:6px 10px;
        border:1px solid #333;
        background:#eee;
        border-radius:6px;
        text-decoration:none;
        color:#000;
    }
    .pagebtn.current{
        background:#ddd;
        font-weight:700;
    }
</style>

<c:set var="sup" value="${supplier}" />

<div class="wrap">
    <div class="card">
        <div class="top">
            <div>
                <h2 class="h1">Transaction History</h2>
                <div class="sub">Import receipts related to this supplier</div>
                <div class="supplierName">
                    Supplier Name: <b><c:out value="${sup.supplierName}"/></b>
                    <span class="muted">(ID: ${sup.supplierId})</span>
                </div>
            </div>

            <a class="btn" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${sup.supplierId}">
                Back to Supplier Detail
            </a>
        </div>

        <c:if test="${not empty msg}">
            <div style="margin-top:10px; padding:10px; background:#ffecec; border:1px solid #e18a8a; border-radius:8px;">
                ${msg}
            </div>
        </c:if>

        <form class="filter" method="get" action="${pageContext.request.contextPath}/home">
            <div class="filterTitle">Filter</div>

            <input type="hidden" name="p" value="view_history"/>
            <input type="hidden" name="supplierId" value="${sup.supplierId}"/>

            <div class="row">
                <div class="field">
                    <label>Search receipt</label>
                    <input name="q" value="${q}" placeholder="receipt code"/>
                </div>

                <div class="field">
                    <label>Date From</label>
                    <input type="date" name="from" value="${from}"/>
                </div>

                <div class="field">
                    <label>Date To</label>
                    <input type="date" name="to" value="${to}"/>
                </div>

                <div class="field">
                    <label>Receipt Status</label>
                    <select name="status">
                        <option value="" ${empty status ? 'selected' : ''}>All</option>
                        <option value="DRAFT" ${status=='DRAFT'?'selected':''}>DRAFT</option>
                        <option value="CONFIRMED" ${status=='CONFIRMED'?'selected':''}>CONFIRMED</option>
                        <option value="CANCELLED" ${status=='CANCELLED'?'selected':''}>CANCELLED</option>
                        <option value="COMPLETED" ${status=='COMPLETED'?'selected':''}>COMPLETED</option>
                    </select>
                </div>

                <button class="btn apply" type="submit">Apply</button>
            </div>
        </form>

        <table>
            <thead>
                <tr>
                    <th style="width:14%;">Receipt Code</th>
                    <th style="width:14%;">Date</th>
                    <th style="width:14%;">Receipt Status</th>
                    <th style="width:12%;">Total Units</th>
                    <th style="width:16%;">Created By</th>
                    <th style="width:20%;">Note</th>
                    <th style="width:10%;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:if test="${empty receipts}">
                    <tr><td colspan="7" class="muted">No receipts found.</td></tr>
                </c:if>

                <c:forEach var="r" items="${receipts}">
                    <tr>
                        <td><b>${r.importCode}</b></td>
                        <td>
                            <c:choose>
                                <c:when test="${r.receiptDate != null}">
                                    <fmt:formatDate value="${r.receiptDate}" pattern="yyyy-MM-dd HH:mm"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td>${r.status}</td>
                        <td>${r.totalUnits}</td>
                        <td><c:out value="${r.createdByName}"/></td>
                        <td><c:out value="${r.note}"/></td>
                        <td>
                            <div class="actions">
                                <!-- nếu bạn đã có trang receipt detail thì link vào đó -->
                                <a class="btn" href="${pageContext.request.contextPath}/home?p=import_receipt_detail&id=${r.importId}">
                                    View Receipt
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div class="footer">
            <div class="muted">
                <c:if test="${totalItems > 0}">
                    Showing ${(page-1)*pageSize+1} -
                    ${page*pageSize > totalItems ? totalItems : page*pageSize}
                    of ${totalItems} receipts
                </c:if>
                <c:if test="${totalItems == 0}">Showing 0 receipts</c:if>
                </div>

                <div class="pager">
                <c:set var="base"
                       value="${pageContext.request.contextPath}/home?p=view_history&supplierId=${sup.supplierId}&q=${q}&from=${from}&to=${to}&status=${status}&page=" />

                <a class="pagebtn"
                   href="${base}${page-1}"
                   style="${page==1?'pointer-events:none;opacity:.5;':''}">
                    Prev
                </a>

                <c:forEach var="i" begin="1" end="${totalPages}">
                    <a class="pagebtn ${i==page?'current':''}" href="${base}${i}">${i}</a>
                </c:forEach>

                <a class="pagebtn"
                   href="${base}${page+1}"
                   style="${page==totalPages?'pointer-events:none;opacity:.5;':''}">
                    Next
                </a>
            </div>
        </div>
    </div>
</div>
