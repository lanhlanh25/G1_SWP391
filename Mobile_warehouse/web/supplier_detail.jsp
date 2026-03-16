<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="d" value="${supplierDetail}"/>

<div class="page-wrap-md">

    <div class="topbar">
        <div class="title">Supplier Detail</div>
        <div style="display:flex; gap:8px; flex-wrap:wrap;">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=view_supplier">← Back to List</a>
            <c:if test="${sessionScope.roleName != null && sessionScope.roleName.toUpperCase() == 'MANAGER'}">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/home?p=update_supplier&id=${d.supplierId}">Update</a>
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=view_history&supplierId=${d.supplierId}">History</a>
                <c:choose>
                    <c:when test="${d.isActive == 1}">
                        <a class="btn btn-warning" href="${pageContext.request.contextPath}/home?p=supplier_inactive&id=${d.supplierId}">Inactive</a>
                    </c:when>
                    <c:otherwise>
                        <form method="post" action="${pageContext.request.contextPath}/supplier-toggle" style="margin:0;">
                            <input type="hidden" name="supplierId" value="${d.supplierId}"/>
                            <button type="submit" class="btn btn-primary">Active</button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </c:if>
        </div>
    </div>

    <c:if test="${not empty msg}">
        <p class="msg-err">${msg}</p>
    </c:if>

    <div style="display:grid; grid-template-columns: 1.2fr 1fr; gap:14px; margin-top:4px;">

        <%-- Supplier info --%>
        <div class="card">
            <div class="card-header"><span class="h2">Supplier Information</span></div>
            <div class="card-body">
                <div class="info-grid">
                    <span class="label">Supplier Name</span>
                    <input class="input readonly" value="${d.supplierName}" readonly/>

                    <span class="label">Phone</span>
                    <input class="input readonly" value="${d.phone}" readonly/>

                    <span class="label">Email</span>
                    <input class="input readonly" value="${d.email}" readonly/>

                    <span class="label">Address</span>
                    <input class="input readonly" value="${d.address}" readonly/>

                    <span class="label">Status</span>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <c:choose>
                            <c:when test="${d.isActive == 1}">
                                <span class="badge badge-active">Active</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-inactive">Inactive</span>
                            </c:otherwise>
                        </c:choose>
                        <span class="small muted">ID: ${d.supplierId}</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Summary --%>
        <div class="card">
            <div class="card-header"><span class="h2">Summary</span></div>
            <div class="card-body">
                <div class="stat-cards" style="flex-direction:column;">
                    <div class="card stat-card-item" style="flex:none;">
                        <div class="small muted">Total Import Receipts</div>
                        <div class="stat-value">${d.totalImportReceipts}</div>
                    </div>
                    <div class="card stat-card-item" style="flex:none;">
                        <div class="small muted">Last Transaction</div>
                        <div class="stat-value" style="font-size:16px;">
                            <c:choose>
                                <c:when test="${d.lastTransaction != null}">${d.lastTransaction}</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="card stat-card-item" style="flex:none;">
                        <div class="small muted">Total Quantity Imported</div>
                        <div class="stat-value">${d.totalQtyImported}</div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>