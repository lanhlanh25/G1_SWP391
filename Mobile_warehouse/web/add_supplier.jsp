<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="page-wrap-sm">
    <div class="topbar">
        <div>
            <div class="title">Add New Supplier</div>
            <div class="small">Create supplier information for purchasing and import operations</div>
        </div>
        <div class="actions">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=dashboard">Back</a>
        </div>
    </div>

    <c:if test="${param.success == '1'}">
        <div class="msg-ok">Supplier created successfully.</div>
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
        <div class="msg-err">
            <b>Please fix the following:</b>
            <ul style="margin:6px 0 0 18px;">
                <c:forEach var="e" items="${errors}">
                    <li>${e}</li>
                </c:forEach>
            </ul>
        </div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <form class="form" method="post" action="${pageContext.request.contextPath}/supplier-add">
                <div class="form-grid">
                    <div class="label">Supplier Name <span class="req">*</span></div>
                    <div><input class="input" name="supplierName" value="${supplierName}" placeholder="Enter supplier name"/></div>

                    <div class="label">Phone</div>
                    <div><input class="input" name="phone" value="${phone}" placeholder="e.g. 090xxxxxxx"/></div>

                    <div class="label">Email <span class="req">*</span></div>
                    <div><input class="input" name="email" value="${email}" placeholder="supplier@example.com"/></div>

                    <div class="label">Address</div>
                    <div><input class="input" name="address" value="${address}" placeholder="Enter address"/></div>

                    <div class="label">Status</div>
                    <div>
                        <select class="select" name="status">
                            <option value="active"   ${status == 'active' || empty status ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Create</button>
                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/home?p=dashboard">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>