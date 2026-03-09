<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<style>
    .page-wrap{
        padding:25px;
        font-family:Segoe UI, Arial;
    }

    .page-wrap h2{
        font-size:22px;
        font-weight:600;
    }

    .card{
        background:white;
        border-radius:10px;
        padding:20px;
        box-shadow:0 2px 8px rgba(0,0,0,0.06);
    }

    form select,
    form input{
        padding:8px 10px;
        border:1px solid #d1d5db;
        border-radius:6px;
        font-size:14px;
    }

    form input{
        width:150px;
    }

    form button{
        background:#2563eb;
        color:white;
        border:none;
        padding:8px 16px;
        border-radius:6px;
        cursor:pointer;
        font-weight:500;
    }

    form button:hover{
        background:#1d4ed8;
    }

    .table{
        width:100%;
        border-collapse:collapse;
        margin-top:10px;
    }

    .table thead{
        background:#f3f4f6;
    }

    .table th{
        text-align:left;
        padding:12px;
        font-size:14px;
        color:#374151;
    }

    .table td{
        padding:12px;
        border-top:1px solid #e5e7eb;
        font-size:14px;
    }

    .table tbody tr:hover{
        background:#f9fafb;
    }

    .badge-active{
        background:#d1fae5;
        color:#065f46;
        padding:4px 12px;
        border-radius:12px;
        font-size:13px;
    }

    .badge-inactive{
        background:#fee2e2;
        color:#991b1b;
        padding:4px 12px;
        border-radius:12px;
        font-size:13px;
    }

    .btn-back{
        background:#e5e7eb;
        padding:8px 14px;
        border-radius:6px;
        text-decoration:none;
        color:#111;
        font-size:14px;
    }

    .btn-back:hover{
        background:#d1d5db;
    }
</style>

<div class="page-wrap">

    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
        <h2>View Variants</h2>

        <a href="${pageContext.request.contextPath}/home?p=product-list" class="btn-back">
            ← Back
        </a>
    </div>

    <div class="card">

        <form method="get" action="${pageContext.request.contextPath}/home">

            <input type="hidden" name="p" value="variant-matrix">
            <input type="hidden" name="productId" value="${param.productId}">

            <div style="display:flex;gap:10px;margin-bottom:15px;flex-wrap:wrap;">

                <select name="color">
                    <option value="">- All Colors -</option>
                    <c:forEach items="${colors}" var="c">
                        <option value="${c}" ${param.color==c?"selected":""}>
                            ${c}
                        </option>
                    </c:forEach>
                </select>

                <select name="storage">
                    <option value="">- All Storage -</option>
                    <c:forEach items="${storages}" var="s">
                        <option value="${s}" ${param.storage==s?"selected":""}>
                            ${s}GB
                        </option>
                    </c:forEach>
                </select>

                <select name="ram">
                    <option value="">- All RAM -</option>
                    <c:forEach items="${rams}" var="r">
                        <option value="${r}" ${param.ram==r?"selected":""}>
                            ${r}GB
                        </option>
                    </c:forEach>
                </select>

                <select name="status">
                    <option value="">- All Status -</option>
                    <option value="ACTIVE" ${param.status=="ACTIVE"?"selected":""}>
                        ACTIVE
                    </option>
                    <option value="INACTIVE" ${param.status=="INACTIVE"?"selected":""}>
                        INACTIVE
                    </option>
                </select>

                <input type="text" name="sku" value="${param.sku}" placeholder="Search SKU">

                <button type="submit">Filter</button>

            </div>

        </form>

        <table class="table">

            <thead>
                <tr>
                    <th>SKU</th>
                    <th>Color</th>
                    <th>Storage</th>
                    <th>RAM</th>
                    <th>Status</th>
                </tr>
            </thead>

            <tbody>

                <c:forEach items="${skus}" var="s">

                    <tr>

                        <td>${s.skuCode}</td>
                        <td>${s.color}</td>
                        <td>${s.storageGb}GB</td>
                        <td>${s.ramGb}GB</td>

                        <td>

                            <c:choose>

                                <c:when test="${s.status=='ACTIVE'}">
                                    <span class="badge-active">
                                        Active
                                    </span>
                                </c:when>

                                <c:otherwise>
                                    <span class="badge-inactive">
                                        Inactive
                                    </span>
                                </c:otherwise>

                            </c:choose>

                        </td>

                    </tr>

                </c:forEach>

            </tbody>

        </table>

    </div>

</div>