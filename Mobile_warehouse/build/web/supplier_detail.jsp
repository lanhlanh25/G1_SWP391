<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
    .wrap{
        padding:16px;
        background:#f4f4f4;
        font-family:Arial, Helvetica, sans-serif;
    }
    .topbar{
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:10px;
        flex-wrap:wrap;
    }
    .title{
        font-size:24px;
        font-weight:800;
        margin:0;
    }
    .sub{
        margin-top:4px;
        color:#666;
        font-size:13px;
    }
    .btn{
        padding:8px 12px;
        border:1px solid #333;
        background:#eee;
        border-radius:8px;
        text-decoration:none;
        color:#000;
        display:inline-block;
    }
    .btn-group{
        display:flex;
        gap:8px;
        flex-wrap:wrap;
    }
    .grid{
        margin-top:12px;
        display:grid;
        grid-template-columns: 1.2fr 1fr;
        gap:14px;
    }
    .card{
        background:#fff;
        border:1px solid #ddd;
        border-radius:10px;
        padding:14px;
    }
    .card h3{
        margin:0 0 10px;
        font-size:14px;
        color:#333;
    }
    .form{
        display:grid;
        grid-template-columns: 160px 1fr;
        gap:12px 14px;
        align-items:center;
    }
    label{
        font-weight:700;
        font-size:13px;
        color:#333;
    }
    input{
        width:100%;
        padding:10px 12px;
        border:1px solid #888;
        border-radius:6px;
        background:#f7f7f7;
    }
    .summary{
        display:grid;
        grid-template-columns: 1fr 1fr;
        gap:12px;
    }
    .box{
        border:1px solid #ddd;
        border-radius:10px;
        padding:12px;
        min-height:90px;
    }
    .k{
        font-size:12px;
        color:#666;
        margin-bottom:8px;
        font-weight:700;
    }
    .v{
        font-size:18px;
        font-weight:800;
    }
    .muted{
        color:#777;
        font-size:12px;
    }
    .pill{
        display:inline-block;
        padding:2px 8px;
        border:1px solid #bbb;
        border-radius:999px;
        font-size:12px;
    }
    .pill.active{
        background:#e6ffea;
        border-color:#8fd39a;
    }
    .pill.inactive{
        background:#ffecec;
        border-color:#e18a8a;
    }
</style>

<c:set var="d" value="${supplierDetail}" />

<div class="wrap">
    <div class="topbar">
        <div>
            <div class="title">View Supplier Detail</div>
            <div class="sub">Create supplier information for purchasing and import operations</div>
        </div>

        <div class="btn-group">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=view_supplier">Back to list</a>
            <a class="btn" href="${pageContext.request.contextPath}/home?p=view_history&supplierId=${d.supplierId}">History</a>
            <a class="btn" href="${pageContext.request.contextPath}/home?p=rate_supplier&supplierId=${d.supplierId}">Rate</a>

            <c:if test="${sessionScope.roleName != null && sessionScope.roleName.toUpperCase() == 'MANAGER'}">
                <a class="btn" href="${pageContext.request.contextPath}/home?p=update_supplier&id=${d.supplierId}">Update</a>

                <c:choose>
                    
                    <c:when test="${d.isActive == 1}">
                        <a class="btn"
                           href="${pageContext.request.contextPath}/home?p=supplier_inactive&id=${d.supplierId}">
                            Inactive
                        </a>
                    </c:when>

                    
                    <c:otherwise>
                        <form method="post"
                              action="${pageContext.request.contextPath}/supplier-toggle"
                              style="display:inline;">
                            <input type="hidden" name="supplierId" value="${d.supplierId}"/>
                            <button type="submit" class="btn">Active</button>
                        </form>
                    </c:otherwise>
                </c:choose>

            </c:if>
        </div>
    </div>

    <c:if test="${not empty msg}">
        <div class="card" style="margin-top:10px; border-color:#e18a8a; background:#ffecec;">
            ${msg}
        </div>
    </c:if>

    <div class="grid">
        <!-- Left: Supplier Information -->
        <div class="card">
            <h3>Supplier Information</h3>
            <div class="form">
                <label>Supplier Name</label>
                <input value="${d.supplierName}" readonly/>

                <label>Phone</label>
                <input value="${d.phone}" readonly/>

                <label>Email</label>
                <input value="${d.email}" readonly/>

                <label>Address</label>
                <input value="${d.address}" readonly/>

                <label>Status</label>
                <div>
                    <c:choose>
                        <c:when test="${d.isActive == 1}">
                            <span class="pill active">Active</span>
                        </c:when>
                        <c:otherwise>
                            <span class="pill inactive">Inactive</span>
                        </c:otherwise>
                    </c:choose>
                    <span class="muted" style="margin-left:8px;">Supplier ID: ${d.supplierId}</span>
                </div>
            </div>
        </div>

        <!-- Right: Summary -->
        <div class="card">
            <h3>Summary</h3>
            <div class="summary">
                <div class="box">
                    <div class="k">Avg rating</div>
                    <div class="v">
                        <c:choose>
                            <c:when test="${d.avgRating != null}">${d.avgRating}</c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="box">
                    <div class="k">Total import receipts</div>
                    <div class="v">${d.totalImportReceipts}</div>
                </div>

                <div class="box">
                    <div class="k">Last transaction</div>
                    <div class="v" style="font-size:14px;">
                        <c:choose>
                            <c:when test="${d.lastTransaction != null}">${d.lastTransaction}</c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="box">
                    <div class="k">Total Quantity imported</div>
                    <div class="v">${d.totalQtyImported}</div>
                </div>
            </div>
        </div>
    </div>
</div>
