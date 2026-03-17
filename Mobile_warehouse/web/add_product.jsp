<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="page-wrap-sm">

    <div class="form-topbar">
        <a class="btn" href="${pageContext.request.contextPath}/home?p=product-list">← Back</a>
        <h1 class="h1">Add New Product</h1>
    </div>

    <div class="form-card">
        <div class="title">Add New Product</div>
        <div class="subtitle">Create product information for warehouse operations</div>

        <form action="${pageContext.request.contextPath}/manager/product/add" method="post">

            <div class="form-grid">

                <!-- PRODUCT CODE -->
                <div class="label">Product Code</div>
                <div>
                    <div class="auto-code">Auto Generate</div>
                </div>

                <div class="label">Product Name<span class="req">*</span></div>
                <div>
                    <input class="input" type="text" name="productName" value="${productName}">
                    <c:if test="${not empty errors.productName}">
                        <div class="err">${errors.productName}</div>
                    </c:if>
                </div>

               
                <div class="label">Brand<span class="req">*</span></div>
                <div>
                    <select class="select" name="brandId">
                        <option value="">-- Select Brand --</option>
                        <c:forEach var="b" items="${brands}">
                            <option value="${b.brandId}" ${brandId==(''+b.brandId) ? 'selected' : '' }>
                                ${b.brandName}
                            </option>
                        </c:forEach>
                    </select>
                    <c:if test="${not empty errors.brandId}">
                        <div class="err">${errors.brandId}</div>
                    </c:if>
                </div>

              
                <div class="label">Description</div>
                <div>
                    <textarea class="textarea" name="description">${description}</textarea>
                </div>

              
                <div class="label">Status</div>
                <div>
                    <select class="select" name="status">
                        <option value="ACTIVE" ${status=='ACTIVE' || empty status ? 'selected' : '' }>
                            Active
                        </option>
                        <option value="INACTIVE" ${status=='INACTIVE' ? 'selected' : '' }>
                            Inactive
                        </option>
                    </select>
                </div>

            </div>

            <div class="form-btns">
                <button class="btn" type="button"
                    onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-list'">
                    Cancel
                </button>
                <button class="btn btn-primary" type="submit">
                    Create
                </button>
            </div>

            <c:if test="${not empty errors.db}">
                <div class="err" style="text-align:center;margin-top:12px">
                    ${errors.db}
                </div>
            </c:if>

        </form>

    </div>
</div>