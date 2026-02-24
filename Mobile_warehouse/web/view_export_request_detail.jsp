<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setTimeZone value="Asia/Ho_Chi_Minh"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
    .wrap{
        padding:16px;
        font-family:Arial, Helvetica, sans-serif;
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
        line-height:1.6;
    }
    table{
        width:100%;
        border-collapse:collapse;
        background:#fff;
    }
    th, td{
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
            <div class="title">View Request Detail</div>
            <a class="btn" href="${ctx}/home?p=export-request-list">Back to list</a>
        </div>


        <div class="meta">
            <div><b>Request Code:</b> <span style="color:#111">${erHeader.requestCode}</span></div>
            <div><b>Created By:</b> <span style="color:#111">${erHeader.createdByName}</span></div>
            <div>
                <b>Request Date:</b>
                <span style="color:#111">
                    <fmt:formatDate value="${erHeader.requestDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                </span>
            </div>
            <div>
                <b>Expected Export Date:</b>
                <span style="color:#111">
                    <fmt:formatDate value="${erHeader.expectedExportDate}" pattern="yyyy-MM-dd"/>
                </span>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th>No</th>
                    <th>Product Code</th>
                    <th>SKU (option)</th>
                    <th>Request Qty</th>
                </tr>
            </thead>
            <tbody>
                <c:if test="${empty erItems}">
                    <tr><td colspan="4">No items.</td></tr>
                </c:if>

                <c:forEach var="it" items="${erItems}">
                    <tr>
                        <td>${it.no}</td>
                        <td>${fn:escapeXml(it.productCode)}</td>
                        <td>
                            <c:choose>
                                <c:when test="${empty it.skuCode}">-</c:when>
                                <c:otherwise>${fn:escapeXml(it.skuCode)}</c:otherwise>
                            </c:choose>
                        </td>
                        <td>${it.requestQty}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>