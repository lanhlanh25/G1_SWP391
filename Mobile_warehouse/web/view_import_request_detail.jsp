<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

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
    .top{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:10px;
    }
    .title{
        font-size:20px;
        font-weight:700;
    }
    .btn{
        padding:6px 14px;
        border:1px solid #333;
        background:#f6f6f6;
        text-decoration:none;
        color:#111;
    }
    .meta{
        font-size:13px;
        color:#333;
        margin-bottom:10px;
        line-height:1.7;
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
</style>

<div class="wrap">
    <div class="card">
        <div class="top">
            <div class="title">View Import Request Detail</div>
            <a class="btn" href="${ctx}/home?p=import-request-list">Back to list</a>
        </div>

        <div class="meta">
            <b>Request Code:</b> <c:out value="${irHeader.requestCode}"/><br/>
            <b>Created By:</b> <c:out value="${irHeader.createdByName}"/><br/>
            <b>Request Date:</b>
            <fmt:formatDate value="${irHeader.requestDate}" pattern="yyyy-MM-dd HH:mm:ss"/><br/>
            <b>Expected Import Date:</b>
            <fmt:formatDate value="${irHeader.expectedImportDate}" pattern="yyyy-MM-dd"/><br/>
            <b>Status:</b> <c:out value="${irHeader.status}"/><br/>
        </div>

        <table>
            <thead>
                <tr>
                    <th style="width:70px;">No</th>
                    <th>Product Code</th>
                    <th>SKU</th>
                    <th style="width:140px;">Request Qty</th>
                </tr>
            </thead>
            <tbody>
            <c:if test="${empty irItems}">
                <tr><td colspan="4">No items.</td></tr>
            </c:if>

            <c:forEach var="it" items="${irItems}">
                <tr>
                    <td>${it.no}</td>
                    <td>${fn:escapeXml(it.productCode)}</td>
                    <td>${fn:escapeXml(it.skuCode)}</td>
                    <td>${it.requestQty}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>

    </div>
</div>