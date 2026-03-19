<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="page-wrap-sm">

    <div class="topbar">
        <div>
            <div class="title">Add New Product</div>
            <!--<div class="small">Create product information for warehouse operations</div>-->
        </div>

        <div class="actions">
            <button class="btn btn-outline" type="button"
                    onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-list'">
                Back
            </button>
        </div>
    </div>

    <div class="card">
        <div class="card-body">

            <form action="${pageContext.request.contextPath}/manager/product/add" method="post" autocomplete="off">

                <div class="form-grid">

                    <!-- Product Code -->
                    <div class="label">Product Code</div>
                    <div>
                        <input class="input readonly" type="text" value="Auto Generated" readonly>
                    </div>

                    <!-- Product Name -->
                    <div class="label">Product Name <span class="req">*</span></div>
                    <div>
                        <input class="input" type="text" name="productName" value="${productName}" 
                               placeholder="Enter product name" required>
                        <c:if test="${not empty errors.productName}">
                            <div class="err">${errors.productName}</div>
                        </c:if>
                    </div>

                    <!-- Brand -->
                    <div class="label">Brand <span class="req">*</span></div>
                    <div>
                        <select class="select" name="brandId" required>
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

                    <!-- Description -->
                    <div class="label">Description</div>
                    <div>
                        <textarea class="textarea" name="description" 
                                  placeholder="Enter product description">${description}</textarea>
                    </div>

                    <!-- Status -->
                    <div class="label">Status</div>
                    <div>
                        <select class="select" name="status">
                            <option value="ACTIVE" ${status=='ACTIVE' || empty status ? 'selected' : '' }>
                                ACTIVE
                            </option>
                            <option value="INACTIVE" ${status=='INACTIVE' ? 'selected' : '' }>
                                INACTIVE
                            </option>
                        </select>
                    </div>

                </div>

                <div class="form-actions">
                    <button class="btn btn-primary" type="submit">
                        Save
                    </button>
                    <button class="btn btn-outline" type="button"
                            onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-list'">
                        Cancel
                    </button>
                </div>

                <c:if test="${not empty errors.db}">
                    <div class="err text-center mt-16">
                        ${errors.db}
                    </div>
                </c:if>

            </form>

        </div>
    </div>
</div>
>
