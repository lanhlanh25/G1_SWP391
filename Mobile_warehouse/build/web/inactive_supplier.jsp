<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
    .wrap{
        padding:16px;
        background:#f4f4f4;
        font-family:Arial, Helvetica, sans-serif;
    }
    .card{
        max-width:900px;
        background:#fff;
        border:1px solid #ddd;
        padding:18px;
        border-radius:10px;
    }
    .h1{
        font-size:28px;
        font-weight:800;
        margin:0;
    }
    .sub{
        margin:6px 0 10px;
        color:#666;
    }
    .warn{
        margin:10px 0 14px;
        padding:10px;
        border:1px solid #f1c27d;
        background:#fff6e6;
        border-radius:8px;
        color:#8a5a00;
    }
    .grid{
        display:grid;
        grid-template-columns: 160px 1fr;
        gap:12px 18px;
        align-items:start;
        margin-top:12px;
    }
    label{
        font-weight:700;
        color:#333;
    }
    .val{
        padding-top:2px;
    }
    textarea, input{
        width:100%;
        padding:10px 12px;
        border:1px solid #888;
        border-radius:6px;
        font-size:14px;
    }
    textarea{
        min-height:120px;
        resize:vertical;
    }
    .pill{
        display:inline-block;
        padding:2px 10px;
        border-radius:999px;
        font-size:12px;
        font-weight:700;
        border:1px solid #ccc;
        background:#f7f7f7;
    }
    .pill-active{
        border-color:#8fd39a;
        background:#e6ffea;
    }
    .pill-inactive{
        border-color:#e18a8a;
        background:#ffecec;
    }
    .actions{
        margin-top:16px;
        display:flex;
        gap:12px;
        justify-content:flex-end;
    }
    .btn{
        padding:10px 18px;
        border:1px solid #333;
        background:#eee;
        border-radius:8px;
        text-decoration:none;
        color:#000;
        cursor:pointer;
    }
    .btn-danger{
        background:#ffecec;
        border-color:#e18a8a;
    }
    .msg-error{
        margin:10px 0;
        padding:10px;
        background:#ffecec;
        border:1px solid #e18a8a;
        border-radius:8px;
    }
    ul{
        margin:6px 0 0 18px;
    }
</style>

<c:set var="s" value="${requestScope.supplier}" />

<!-- flash -->
<c:set var="errors" value="${sessionScope.flashErrors}" />
<c:remove var="flashErrors" scope="session"/>

<c:set var="reason" value="${sessionScope.flashReason}" />
<c:remove var="flashReason" scope="session"/>

<div class="wrap">
    <div class="card">
        <div class="h1">Inactive supplier?</div>
        <div class="sub">This will set supplier status to <b>Inactive</b> (soft delete).</div>

        <div class="warn">
            <b>Effect:</b> Supplier cannot be selected for new import receipts. Transaction history remains available.
        </div>

        <c:if test="${not empty msg}">
            <div class="msg-error">${msg}</div>
        </c:if>

        <c:if test="${not empty errors}">
            <div class="msg-error">
                <b>Please fix the following:</b>
                <ul>
                    <c:forEach var="e" items="${errors}">
                        <li>${e}</li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>

        <div class="grid">
            <label>Supplier</label>
            <div class="val">
                <b>${s.supplierName}</b> <span style="color:#777;">(#${s.supplierId})</span>
            </div>

            <label>Current status</label>
            <div class="val">
                <c:choose>
                    <c:when test="${s.isActive == 1}">
                        <span class="pill pill-active">Active</span>
                    </c:when>
                    <c:otherwise>
                        <span class="pill pill-inactive">Inactive</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <label>Transactions</label>
            <div class="val">
                Import receipts: <b>${requestScope.importTx}</b>
            </div>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/supplier-inactive" style="margin-top:16px;">
            <input type="hidden" name="supplierId" value="${s.supplierId}"/>

            <div class="grid">
                <label>Reasons</label>
                <div class="val">
                    <textarea name="reason" placeholder="Explain why this supplier is being set to inactive...">${reason}</textarea>
                </div>

                <label>Type Inactive to confirm</label>
                <div class="val">
                    <input name="confirmText" placeholder="Inactive"/>
                </div>
            </div>

            <div class="actions">
                <a class="btn" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${s.supplierId}">Cancel</a>
                <button type="submit" class="btn btn-danger">Confirm Inactive</button>
            </div>
        </form>

    </div>
</div>
