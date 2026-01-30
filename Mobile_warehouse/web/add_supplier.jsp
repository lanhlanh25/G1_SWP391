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
    input, select{
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
    .msg-success{
        margin:10px 0;
        padding:10px;
        background:#e6ffea;
        border:1px solid #7bd389;
        border-radius:8px;
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

<div class="wrap">
    <div class="card">
        <div class="h1">Add New Supplier</div>
        <div class="sub">Create supplier information for purchasing and import operations</div>

        <c:if test="${param.success == '1'}">
            <div class="msg-success">Supplier created successfully.</div>
        </c:if>

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

        <c:set var="status" value="${sessionScope.flashStatus}" />
        <c:remove var="flashStatus" scope="session"/>    

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

        <form class="form" method="post" action="${pageContext.request.contextPath}/supplier-add">
            <label>Supplier Name<span class="req">*</span></label>
            <input name="supplierName" value="${supplierName}" placeholder="Enter supplier name"/>

            <label>Phone</label>
            <input name="phone" value="${phone}" placeholder="e.g. 090xxxxxxx"/>

            <label>Email<span class="req">*</span></label>
            <input name="email" value="${email}" placeholder="supplier@example.com"/>

            <label>Address</label>
            <input name="address" value="${address}" placeholder="Enter address"/>

            <label>Status</label>
            <select name="status">
                <option value="active"   ${status == 'active' || empty status ? 'selected' : ''}>Active</option>
                <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
            </select>

            <div></div>
            <div class="actions">
                <button type="submit" class="btn btn-primary">Create</button>
                <a class="btn" href="${pageContext.request.contextPath}/home?p=dashboard">Cancel</a>
            </div>
        </form>
    </div>
</div>
