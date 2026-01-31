<%-- 
    Document   : add_product
    Created on : Jan 31, 2026, 9:17:08 PM
    Author     : Lanhlanh
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Add New Product</title>
        <style>
            * {
                box-sizing: border-box;
            }

            body {
                font-family: Arial;
                background: #f2f2f2;
                margin: 0;
            }

            .topbar {
                padding: 12px 18px;
            }

            .topbar .btn {
                display: inline-block;
                padding: 6px 12px;
                border: 2px solid #1f4aa8;
                background: #4a86d4;
                color: #000;
                text-decoration: none;
                font-weight: 600;
                margin-right: 8px;
                font-size: 14px;
            }

            .container {
                width: 100%;
                max-width: 1000px;
                margin: 16px auto;
                padding: 14px;
                background: #f1f1f1;
            }

            .card {
                width: 100%;
                max-width: 860px;
                margin: 0 auto;
                background: #fff;
                border-radius: 14px;
                padding: 24px 28px 22px;
                border: 1px solid #e6e6e6;
            }

            .title {
                font-size: 36px;
                font-weight: 800;
                margin: 0 0 6px;
                line-height: 1.1;
            }

            .subtitle {
                margin: 0 0 20px;
                font-size: 16px;
                color: #666;
            }

            .form-grid {
                display: grid;
                grid-template-columns: 200px 1fr;
                column-gap: 18px;
                row-gap: 14px;
                align-items: center;
            }

            .lb {
                font-size: 16px;
                font-weight: 600;
                color: #111;
            }

            .lb .req {
                color: #d20000;
                margin-left: 3px;
            }

            .ip, select, textarea {
                width: 100%;
                border: 1px solid #777;
                border-radius: 10px;
                outline: none;
                background: #fff;
                font-size: 15px;
            }

            .ip, select {
                height: 40px;
                padding: 0 14px;
            }

            textarea {
                height: 90px;
                padding: 10px 14px;
                resize: none;
            }

            .err {
                color: #c40000;
                font-size: 13px;
                margin-top: 6px;
            }

            .btns {
                margin-top: 18px;
                display: flex;
                justify-content: center;
                gap: 14px;
            }

            .btn-form {
                min-width: 120px;
                height: 40px;
                padding: 0 18px;
                border-radius: 12px;
                border: 1px solid #222;
                background: #f2f2f2;
                font-size: 15px;
                cursor: pointer;
            }

            .btn-primary {
                background: #eaf1ff;
                border: 1px solid #2b4ea2;
            }

            .ok {
                margin-top: 12px;
                text-align: center;
                color: #0a7a14;
                font-weight: 600;
                font-size: 14px;
            }

            @media (max-width: 900px) {
                .card {
                    padding: 18px 16px;
                }
                .title {
                    font-size: 28px;
                }
                .subtitle {
                    font-size: 14px;
                    margin-bottom: 16px;
                }
                .form-grid {
                    grid-template-columns: 1fr;
                }
                .lb {
                    font-size: 14px;
                }
                .ip, select {
                    height: 38px;
                }
                textarea {
                    height: 90px;
                }
            }
        </style>

    </head>

    <body>
<!--        <div class="topbar">
            <a class="btn" href="${pageContext.request.contextPath}/home">Home</a>
        </div>-->

        <div class="container">
            <div class="card">
                <div class="title">Add New Product</div>
                <div class="subtitle">Create product information for warehouse operations</div>

                <form action="${pageContext.request.contextPath}/manager/product/add" method="post">
                    <div class="form-grid">

                        <div class="lb">Product Code<span class="req">*</span></div>
                        <div>
                            <input class="ip" type="text" name="productCode"
                                   value="${param.productCode != null ? param.productCode : ''}" required>
                            <c:if test="${not empty errors.productCode}">
                                <div class="err">${errors.productCode}</div>
                            </c:if>
                        </div>

                        <div class="lb">Product Name<span class="req">*</span></div>
                        <div>
                            <input class="ip" type="text" name="productName"
                                   value="${param.productName != null ? param.productName : ''}" required>
                            <c:if test="${not empty errors.productName}">
                                <div class="err">${errors.productName}</div>
                            </c:if>
                        </div>

                        <div class="lb">Brand<span class="req">*</span></div>
                        <div>
                            <select name="brandId" required>
                                <option value="">-- Select Brand --</option>
                                <c:forEach var="b" items="${brands}">
                                    <option value="${b.brandId}" ${param.brandId == (''+b.brandId) ? 'selected' : ''}>
                                        ${b.brandName}
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty errors.brandId}">
                                <div class="err">${errors.brandId}</div>
                            </c:if>
                        </div>

                        <div class="lb">Model</div>
                        <div>
                            <input class="ip" type="text" name="model"
                                   value="${param.model != null ? param.model : ''}">
                        </div>

                        <div class="lb">Description</div>
                        <div>
                            <textarea name="description">${param.description != null ? param.description : ''}</textarea>
                        </div>

                        <div class="lb">Status</div>
                        <div>
                            <select name="status">
                                <option value="ACTIVE" ${param.status == 'ACTIVE' || param.status == null ? 'selected' : ''}>Active</option>
                                <option value="INACTIVE" ${param.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                            </select>
                            <c:if test="${not empty errors.status}">
                                <div class="err">${errors.status}</div>
                            </c:if>
                        </div>

                    </div>

                    <div class="btns">
                        <button class="btn-form btn-primary" type="submit">Create</button>
                        <button class="btn-form" type="button"
                                onclick="window.location.href = '${pageContext.request.contextPath}/home?p=product-add'">
                            Cancel
                        </button>
                    </div>

                    <c:if test="${not empty errors.db}">
                        <div class="err" style="text-align:center; margin-top:12px;">${errors.db}</div>
                    </c:if>

                    <c:if test="${not empty message}">
                        <div class="ok">${message}</div>
                    </c:if>
                </form>
            </div>
        </div>
    </body>
</html>