<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="d" value="${supplierDetail}"/>

<div class="page-wrap-md">

    <div class="topbar">
        <div class="d-flex align-center gap-12">
            <h1 class="h1">Supplier Overview</h1>
        </div>
        <div class="d-flex gap-8 align-center">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=view_supplier">← Back</a>
            <c:if test="${sessionScope.roleName != null && sessionScope.roleName.toUpperCase() == 'MANAGER'}">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/home?p=update_supplier&id=${d.supplierId}">Update Profile</a>
                <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=view_history&supplierId=${d.supplierId}">Trade History</a>
                <c:choose>
                    <c:when test="${d.isActive == 1}">
                        <a class="btn btn-warning" href="${pageContext.request.contextPath}/home?p=supplier_inactive&id=${d.supplierId}">Mark Inactive</a>
                    </c:when>
                    <c:otherwise>
                        <form method="post" action="${pageContext.request.contextPath}/supplier-toggle" style="margin:0;">
                            <input type="hidden" name="supplierId" value="${d.supplierId}"/>
                            <button type="submit" class="btn btn-primary">Re-activate</button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </c:if>
        </div>
    </div>

    <c:if test="${not empty msg}">
        <p class="msg-err">${msg}</p>
    </c:if>

    <div class="grid-12 gap-16">
        <div class="col-7">

        <%-- Supplier info --%>
        <div class="card">
            <div class="card-body">
                <div class="h2 mb-16">Supplier Information</div>
                <table class="table no-border-first">
                    <tbody>
                        <tr>
                            <th style="width:160px;">ID</th>
                            <td><span class="mono-text text-muted fs-12">${d.supplierId}</span></td>
                        </tr>
                        <tr>
                            <th>Supplier Name</th>
                            <td class="fw-700">${d.supplierName}</td>
                        </tr>
                        <tr>
                            <th>Phone</th>
                            <td class="text-primary fw-600">${d.phone}</td>
                        </tr>
                        <tr>
                            <th>Email</th>
                            <td class="fw-600">${d.email}</td>
                        </tr>
                        <tr>
                            <th>Address</th>
                            <td class="text-muted fs-14">${d.address}</td>
                        </tr>
                        <tr>
                            <th>Status</th>
                            <td>
                                <c:choose>
                                    <c:when test="${d.isActive == 1}">
                                        <span class="badge badge-active">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-inactive">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        </div>

        <div class="col-5">

        <%-- Summary --%>
        <div class="card h-full">
            <div class="card-body">
                <div class="h2 mb-16">Activity Summary</div>
                <div class="d-flex flex-column gap-12">
                    <div class="card p-16 bg-light d-flex justify-between align-center">
                        <div class="muted fs-12 uppercase">Total Receipts</div>
                        <div class="h3 m-0">${d.totalImportReceipts}</div>
                    </div>
                    <div class="card p-16 bg-light d-flex justify-between align-center">
                        <div class="muted fs-12 uppercase">Total Qty</div>
                        <div class="h3 m-0">${d.totalQtyImported}</div>
                    </div>
                    <div class="card p-16 bg-light">
                        <div class="muted fs-12 uppercase mb-4">Last Transaction</div>
                        <div class="fs-14 fw-600">
                            <c:choose>
                                <c:when test="${d.lastTransaction != null}">${d.lastTransaction}</c:when>
                                <c:otherwise><span class="text-muted">No transactions</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </div>
</div>