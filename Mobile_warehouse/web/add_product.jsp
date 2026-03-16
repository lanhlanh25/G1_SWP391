<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>

<html>
    <head>
        <meta charset="UTF-8">

        <style>

            *{
                box-sizing:border-box;
            }

            body{
                font-family:Arial,Helvetica,sans-serif;
                background:#f2f2f2;
                margin:0;
            }

            .container{
                width:100%;
                max-width:1000px;
                margin:20px auto;
                padding:16px;
            }

            .card{
                background:white;
                border-radius:14px;
                padding:28px;
                border:1px solid #e6e6e6;
                box-shadow:0 2px 6px rgba(0,0,0,0.05);
            }

            .title{
                font-size:34px;
                font-weight:800;
                margin-bottom:6px;
            }

            .subtitle{
                color:#666;
                margin-bottom:20px;
            }

            .form-grid{
                display:grid;
                grid-template-columns:200px 1fr;
                gap:16px;
                align-items:center;
            }

            .lb{
                font-weight:600;
            }

            .req{
                color:red;
            }

            .ip,select,textarea{
                width:100%;
                border:1px solid #888;
                border-radius:10px;
                font-size:15px;
                padding:10px 12px;
            }

            .ip{
                height:40px;
            }

            textarea{
                height:90px;
                resize:none;
            }

            .err{
                color:#c40000;
                font-size:13px;
                margin-top:5px;
            }

            .btns{
                margin-top:22px;
                display:flex;
                justify-content:center;
                gap:14px;
            }

            .btn-form{
                min-width:120px;
                height:40px;
                border-radius:10px;
                border:1px solid #333;
                background:#f3f3f3;
                cursor:pointer;
                font-size:15px;
            }

            .btn-primary{
                background:#eaf1ff;
                border:1px solid #2b4ea2;
            }

            .btn-primary:hover{
                background:#dbe7ff;
            }

            .auto-code{
                height:40px;
                display:flex;
                align-items:center;
                padding-left:12px;
                border:1px dashed #aaa;
                border-radius:10px;
                background:#fafafa;
                color:#666;
            }

            @media(max-width:900px){

                .form-grid{
                    grid-template-columns:1fr;
                }

            }

        </style>

    </head>

    <body>

        <div class="container">
            <div class="card">

                <div class="title">Add New Product</div>
                <div class="subtitle">Create product information for warehouse operations</div>

                <form action="${pageContext.request.contextPath}/manager/product/add" method="post">

                    <div class="form-grid">

                        <!-- PRODUCT CODE -->
                        <div class="lb">Product Code</div>
                        <div>
                            <div class="auto-code">Auto Generate</div>
                        </div>

                        <!-- PRODUCT NAME -->
                        <div class="lb">Product Name<span class="req">*</span></div>
                        <div>
                            <input class="ip" type="text" name="productName" value="${productName}">
                            <c:if test="${not empty errors.productName}">
                                <div class="err">${errors.productName}</div>
                            </c:if>
                        </div>

                        <!-- BRAND -->
                        <div class="lb">Brand<span class="req">*</span></div>
                        <div>

                            <select name="brandId">

                                <option value="">-- Select Brand --</option>

                                <c:forEach var="b" items="${brands}">
                                    <option value="${b.brandId}" ${brandId == (''+b.brandId) ? 'selected' : ''}>
                                        ${b.brandName}
                                    </option>
                                </c:forEach>

                            </select>

                            <c:if test="${not empty errors.brandId}">
                                <div class="err">${errors.brandId}</div>
                            </c:if>

                        </div>



                        <!-- DESCRIPTION -->
                        <div class="lb">Description</div>
                        <div>
                            <textarea name="description">${description}</textarea>
                        </div>

                        <!-- STATUS -->
                        <div class="lb">Status</div>
                        <div>

                            <select name="status">

                                <option value="ACTIVE" ${status=='ACTIVE' || empty status ? 'selected' : ''}>
                                    Active
                                </option>

                                <option value="INACTIVE" ${status=='INACTIVE' ? 'selected' : ''}>
                                    Inactive
                                </option>

                            </select>

                        </div>

                    </div>

                    <div class="btns">

                        <button class="btn-form btn-primary" type="submit">
                            Create
                        </button>

                        <button class="btn-form" type="button"
                                onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-list'">
                            Cancel
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

    </body>
</html>