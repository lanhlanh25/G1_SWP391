<%-- Document : delete_product Created on : Feb 5, 2026, 3:13:32 PM Author : Lanhlanh --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <title>Delete Product</title>
                <style>
                    body {
                        font-family: 'Inter', sans-serif;
                        background: var(--bg, #ebedef);
                        margin: 0;
                    }

                    .wrap {
                        width: 100%;
                        max-width: 880px;
                        margin: 18px auto;
                        background: var(--surface);
                        border-radius: var(--radius);
                        border: 1px solid var(--border);
                        padding: 18px 22px;
                        box-sizing: border-box;
                        box-shadow: var(--shadow);
                    }

                    .head {
                        margin: 0 0 12px;
                    }

                    .head h1 {
                        margin: 0;
                        font-size: 22px;
                        font-weight: 700;
                        color: var(--text);
                    }

                    .sub {
                        margin: 8px 0 0;
                        color: var(--muted);
                        font-size: 14px;
                    }

                    .card {
                        margin-top: 14px;
                        border: 1px solid var(--border);
                        border-radius: var(--radius);
                        background: var(--surface-2);
                        padding: 14px;
                    }

                    .grid {
                        display: grid;
                        grid-template-columns: 220px 1fr;
                        gap: 10px 16px;
                        align-items: center;
                    }

                    .lb {
                        font-weight: 700;
                        color: var(--text);
                        font-size: 13px;
                    }

                    .val {
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: var(--radius-sm);
                        padding: 7px 12px;
                        font-size: 14px;
                        color: var(--text-2);
                    }

                    .warn {
                        margin-top: 14px;
                        border: 1px solid #ffe082;
                        background: #fff8e1;
                        border-radius: var(--radius-sm);
                        padding: 12px;
                        color: #7c5e00;
                        font-weight: 700;
                        font-size: 13px;
                    }

                    .err {
                        margin-top: 14px;
                        border: 1px solid #f5c6cb;
                        background: #fdf0f0;
                        border-radius: var(--radius-sm);
                        padding: 12px;
                        color: #b91c1c;
                        font-weight: 700;
                        font-size: 13px;
                    }

                    .ok {
                        margin-top: 14px;
                        color: var(--success);
                        font-weight: 700;
                        text-align: center;
                    }

                    .btns {
                        margin-top: 18px;
                        display: flex;
                        justify-content: flex-end;
                        gap: 14px;
                        flex-wrap: wrap;
                    }

                    .wrap .btn {
                        min-width: 160px;
                        height: 40px;
                        border-radius: var(--radius-sm);
                        border: 1px solid var(--border);
                        font-size: 14px;
                        cursor: pointer;
                        background: var(--surface-2);
                        font-weight: 600;
                        font-family: inherit;
                        transition: all .15s;
                    }

                    .wrap .btn:hover {
                        background: #e9ecef;
                    }

                    .wrap .btn-danger {
                        background: #fdf0f0;
                        border-color: var(--danger);
                        font-weight: 700;
                        color: var(--danger);
                    }

                    .wrap .btn-danger:hover {
                        background: #f8d7da;
                    }

                    .btn-secondary:hover {
                        background: #e9ecef;
                    }

                    @media(max-width:900px) {
                        .wrap {
                            max-width: 96%;
                        }

                        .grid {
                            grid-template-columns: 1fr;
                        }

                        .btns {
                            justify-content: center;
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
                                    <form action="${pageContext.request.contextPath}/manager/product/delete"
                                        method="post" style="margin:0;">
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