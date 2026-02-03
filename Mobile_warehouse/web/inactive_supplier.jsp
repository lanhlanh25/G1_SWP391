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
        margin:0 auto;
        background:#f5f0e8;
        border:1px solid #ddd;
        border-radius:10px;
        padding:22px;
    }
    .h1{
        font-size:28px;
        font-weight:900;
        margin:0;
    }
    .msg{
        margin-top:80px;
        text-align:center;
        font-size:22px;
        color:#777;
    }
    .btns{
        margin-top:120px;
        display:flex;
        justify-content:flex-end;
        gap:14px;
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
</style>

<c:set var="s" value="${supplier}" />
<div class="wrap">
    <div class="card">
        <div class="h1">Confirm Inactive?</div>

        <div class="msg">
            Are you sure you want to inactive Supplier "<b><c:out value='${s.supplierName}'/></b>"
        </div>

        <div class="btns">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${s.supplierId}">Cancel</a>


            <form method="post" action="${pageContext.request.contextPath}/supplier-inactive" style="margin:0;">
                <input type="hidden" name="supplierId" value="${s.supplierId}" />
                <button type="submit" class="btn">Confirm Inactive</button>
            </form>
        </div>
    </div>
</div>
