<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
    .wrap{
        padding:16px;
        background:#f4f4f4;
        font-family:Arial, Helvetica, sans-serif;
    }
    .card{
        max-width:760px;
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
        margin:6px 0 18px;
        color:#666;
    }
    .form{
        display:grid;
        grid-template-columns: 200px 1fr;
        gap:14px 18px;
        align-items:center;
    }
    label{
        color:#333;
        font-weight:600;
    }
    input{
        width:100%;
        padding:10px 12px;
        border:1px solid #888;
        border-radius:6px;
        font-size:14px;
        background:#fff;
    }
    .req{
        color:#c00;
    }
    .actions{
        margin-top:18px;
        display:flex;
        gap:12px;
    }
    .btn{
        display:inline-block;
        padding:10px 18px;
        border:1px solid #333;
        background:#eee;
        border-radius:8px;
        text-decoration:none;
        color:#000;
        cursor:pointer;
    }
    .btn-primary{
        background:#e8f0ff;
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


<c:set var="errors" value="${sessionScope.flashErrors}" />
<c:remove var="flashErrors" scope="session"/>

<c:set var="supplierName" value="${sessionScope.flashSupplierName}" />
<c:remove var="flashSupplierName" scope="session"/>

<c:set var="phone" value="${sessionScope.flashPhone}" />
<c:remove var="flashPhone" scope="session"/>

<c:set var="email" value="${sessionScope.flashEmail}" />
<c:remove var="flashEmail" scope="session"/>

<c:set var="address" value="${sessionScope.flashAddress}" />
<c:remove var="flashAddress" scope="session"/>


<c:if test="${empty supplierName}">
    <c:set var="supplierName" value="${s.supplierName}" />
</c:if>
<c:if test="${empty phone}">
    <c:set var="phone" value="${s.phone}" />
</c:if>
<c:if test="${empty email}">
    <c:set var="email" value="${s.email}" />
</c:if>
<c:if test="${empty address}">
    <c:set var="address" value="${s.address}" />
</c:if>

<div class="wrap">
    <div class="card">
        <div class="h1">Update supplier information</div>
        <div class="sub">Update supplier information for purchasing and import operations</div>

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

        <form class="form" method="post" action="${pageContext.request.contextPath}/supplier-update">
            <input type="hidden" name="supplierId" value="${s.supplierId}" />

            <label>Supplier Name<span class="req">*</span></label>
            <input name="supplierName" value="${supplierName}" />

            <label>Phone</label>
            <input name="phone" value="${phone}" />

            <label>Email<span class="req">*</span></label>
            <input name="email" value="${email}" />

            <label>Address</label>
            <input name="address" value="${address}" />

            <!-- Status readonly -->
            <label>Status</label>
            <div>
                <c:choose>
                    <c:when test="${s.isActive == 1}">
                        <span style="display:inline-block;padding:2px 10px;border:1px solid #8fd39a;background:#e6ffea;border-radius:999px;font-size:12px;font-weight:700;">
                            Active
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span style="display:inline-block;padding:2px 10px;border:1px solid #e18a8a;background:#ffecec;border-radius:999px;font-size:12px;font-weight:700;">
                            Inactive
                        </span>
                    </c:otherwise>
                </c:choose>

                <span style="margin-left:10px;color:#777;font-size:12px;">
                    (Change status in Supplier Detail)
                </span>
            </div>

            <div></div>
            <div class="actions">
                <a class="btn" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${s.supplierId}">Cancel</a>
                <button type="submit" class="btn btn-primary">Save</button>
            </div>
        </form>
    </div>
</div>
