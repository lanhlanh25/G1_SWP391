<%-- 
    Document   : delete_product
    Created on : Feb 5, 2026, 3:13:32 PM
    Author     : Lanhlanh
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Delete Product</title>
        <style>
            body{
                font-family:Arial;
                background:#f2f2f2;
                margin:0;
            }
            .wrap{
                width:100%;
                max-width:880px;
                margin:18px auto;
                background:#fff;
                border-radius:14px;
                border:1px solid #e6e6e6;
                padding:18px 22px;
                box-sizing:border-box;
            }
            .head{
                margin:0 0 12px;
            }
            .head h1{
                margin:0;
                font-size:34px;
                letter-spacing:.3px;
            }
            .sub{
                margin:8px 0 0;
                color:#666;
            }
            .card{
                margin-top:14px;
                border:1px solid #ddd;
                border-radius:12px;
                background:#fafafa;
                padding:14px;
            }
            .grid{
                display:grid;
                grid-template-columns:220px 1fr;
                gap:10px 16px;
                align-items:center;
            }
            .lb{
                font-weight:800;
                color:#111;
            }
            .val{
                background:#fff;
                border:1px solid #cfcfcf;
                border-radius:10px;
                padding:9px 12px;
            }
            .warn{
                margin-top:14px;
                border:1px solid #f2c200;
                background:#fff7d6;
                border-radius:12px;
                padding:12px;
                color:#6a4a00;
                font-weight:700;
            }
            .err{
                margin-top:14px;
                border:1px solid #f0b3b3;
                background:#ffe8e8;
                border-radius:12px;
                padding:12px;
                color:#8a0000;
                font-weight:800;
            }
            .ok{
                margin-top:14px;
                color:#0a7a14;
                font-weight:800;
                text-align:center;
            }
            .btns{
                margin-top:18px;
                display:flex;
                justify-content:flex-end;
                gap:14px;
                flex-wrap:wrap;
            }
            .btn{
                min-width:160px;
                height:44px;
                border-radius:12px;
                border:1.6px solid #6f6f6f;
                font-size:16px;
                cursor:pointer;
                background:#efefef;
            }
            .btn-danger{
                background:#ffdede;
                border-color:#d26b6b;
                font-weight:800;
            }
            .btn-danger:hover{
                background:#ffcfcf;
            }
            .btn-secondary:hover{
                background:#e6e6e6;
            }
            @media (max-width: 900px){
                .wrap{
                    max-width:96%;
                }
                .grid{
                    grid-template-columns:1fr;
                }
                .btns{
                    justify-content:center;
                }
            }
        </style>
    </head>
    <body>
        <div class="wrap">
            <div class="head">
                <h1>Delete Product</h1>
                <div class="sub">(soft delete).</div>
            </div>

            <c:if test="${empty product}">
                <div class="err">Product not found.</div>
                <div class="btns">
                    <button class="btn btn-secondary" type="button"
                            onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-list'">
                        Back
                    </button>
                </div>
            </c:if>

            <c:if test="${not empty product}">

                <c:if test="${not empty blockReason}">
                    <div class="warn">
                        Cannot delete this product because: ${blockReason}
                    </div>
                </c:if>
                <div class="card">
                    <div class="grid">
                        <div class="lb">Product Code</div>
                        <div class="val">${product.productCode}</div>

                        <div class="lb">Brand</div>
                        <div class="val">${product.brandName}</div>

                        <div class="lb">Model</div>
                        <div class="val">${product.model}</div>

                        <div class="lb">Status</div>
                        <div class="val">${product.status}</div>

                        <div class="lb">SKU Count</div>
                        <div class="val">${skuCount}</div>
                    </div>

                    <div style="margin-top:12px; display:flex; gap:12px; align-items:center;">
                        <div class="lb" style="min-width:220px;">Created At</div>
                        <div class="val" style="flex:1;">${createdAt}</div>
                    </div>

                </div>

                <c:if test="${not empty errors}">
                    <div class="err">${errors}</div>
                </c:if>

                <c:if test="${not empty message}">
                    <div class="ok">${message}</div>
                </c:if>

                <div class="btns">
                    <c:choose>
                        <c:when test="${empty blockReason}">
                            <form action="${pageContext.request.contextPath}/manager/product/delete" method="post" style="margin:0;">
                                <input type="hidden" name="id" value="${product.productId}">
                                <button class="btn btn-danger" type="submit"
                                        onclick="return confirm('Set this product to INACTIVE?');">
                                    Inactivate
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <button class="btn btn-danger" type="button" disabled>Inactivate</button>
                        </c:otherwise>
                    </c:choose>

                    <button class="btn btn-secondary" type="button"
                            onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-list'">
                        Cancel
                    </button>
                </div>
            </c:if>
        </div>
    </body>
</html>