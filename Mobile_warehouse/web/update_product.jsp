<%-- 
    Document   : update_product
    Created on : Feb 5, 2026, 2:50:20 PM
    Author     : Lanhlanh
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Update Product</title>
        <style>
            body{
                font-family: Arial;
                background:#f2f2f2;
                margin:0;
            }

            .wrap{
                width:100%;
                max-width:900px;
                margin:18px auto;
                background:#fff;
                border-radius:14px;
                border:1px solid #e6e6e6;
                padding:18px 22px;
                box-sizing:border-box;
            }

            .head{
                margin:0 0 14px;
                text-align:center;
            }

            .head h1{
                margin:0;
                font-size:34px;
                letter-spacing:.3px;
            }

            .grid{
                display:grid;
                grid-template-columns: 220px 1fr 1fr;
                gap:14px 18px;
                align-items:center;
                margin-top:18px;
            }

            .lb{
                font-size:16px;
                font-weight:700;
                color:#111;
            }

            .req{
                color:#c40000;
                font-weight:800;
            }

            .ip, select, textarea{
                width:100%;
                box-sizing:border-box;
                border:1.6px solid #8a8a8a;
                border-radius:12px;
                padding:10px 14px;
                font-size:15px;
                outline:none;
                background:#fff;
            }

            .ip:focus, select:focus, textarea:focus{
                border-color:#2f6fb9;
                box-shadow:0 0 0 3px rgba(47,111,185,.12);
            }

            .readonly{
                background:#e9e9e9;
            }

            textarea{
                min-height:140px;
                resize:none;
                grid-column: 2 / 4;
            }

            .row-span{
                grid-column: 2 / 4;
            }

            .err{
                margin-top:6px;
                color:#c40000;
                font-size:13px;
            }

            .ok{
                margin-top:14px;
                color:#0a7a14;
                font-weight:700;
                text-align:center;
            }

            .btns{
                margin-top:18px;
                display:flex;
                justify-content:center;
                gap:20px;
            }

            .btn{
                min-width:140px;
                height:42px;
                border-radius:12px;
                border:1.6px solid #1f4aa8;
                font-size:16px;
                cursor:pointer;
                background:#efefef;
            }

            .btn-primary{
                background:#4a86d4;
                color:#000;
                font-weight:700;
            }

            .btn-primary:hover{
                background:#3f79c7;
            }

            .btn-secondary{
                border-color:#6f6f6f;
            }

            @media (max-width: 900px){
                .wrap{ max-width:96%; }
                .grid{ grid-template-columns: 1fr; }
                textarea{ grid-column:auto; }
                .row-span{ grid-column:auto; }
            }
        </style>
    </head>
    <body>
        <div class="wrap">
            <div class="head">
                <h1>Update Product</h1>
            </div>

            <c:if test="${empty product}">
                <div class="err" style="text-align:center;">Product not found.</div>
            </c:if>

            <c:if test="${not empty product}">
                <form action="${pageContext.request.contextPath}/manager/product/update" method="post" autocomplete="off">
                    <input type="hidden" name="id" value="${product.productId}"/>

                    <div class="grid">
                        <div class="lb">Product Code</div>
                        <div class="row-span">
                            <input class="ip readonly" type="text" value="${product.productCode}" readonly>
                        </div>

                        <div class="lb">Product Name <span class="req">*</span></div>
                        <div class="row-span">
                            <input class="ip" type="text" name="productName"
                                   value="${param.productName != null ? param.productName : product.productName}" required>
                            <c:if test="${not empty errors.productName}">
                                <div class="err">${errors.productName}</div>
                            </c:if>
                        </div>

                        <div class="lb">Brand</div>
                        <div class="row-span">
                            <input class="ip readonly" type="text" value="${product.brandName}" readonly>
                        </div>

                        <div class="lb">Model</div>
                        <div class="row-span">
                            <input class="ip" type="text" name="model"
                                   value="${param.model != null ? param.model : product.model}">
                            <c:if test="${not empty errors.model}">
                                <div class="err">${errors.model}</div>
                            </c:if>
                        </div>

                        <div class="lb">Description</div>
                        <textarea name="description">${param.description != null ? param.description : product.description}</textarea>

                        <div class="lb">Status</div>
                        <div class="row-span">
                            <select name="status">
                                <option value="ACTIVE" ${(param.status != null ? param.status : product.status) == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                <option value="INACTIVE" ${(param.status != null ? param.status : product.status) == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                            </select>
                        </div>
                    </div>

                    <div class="btns">
                        <button class="btn btn-primary" type="submit">Update</button>
                        <button class="btn btn-secondary" type="button"
                                onclick="window.location.href='${pageContext.request.contextPath}/home?p=product-list'">
                            Cancel
                        </button>
                    </div>

                    <c:if test="${not empty message}">
                        <div class="ok">${message}</div>
                    </c:if>
                </form>
            </c:if>
        </div>
    </body>
</html>