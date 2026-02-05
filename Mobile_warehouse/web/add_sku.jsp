<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Add SKU</title>
        <style>
            body{
                font-family: Arial;
                background:#f2f2f2;
                margin:0;
            }

            .wrap{
                width:100%;
                max-width:860px;
                margin:18px auto;
                background:#fff;
                border-radius:14px;
                border:1px solid #e6e6e6;
                padding:18px 22px;
                box-sizing:border-box;
            }

            .head{
                margin:0 0 14px;
            }

            .head h1{
                margin:0;
                font-size:44px;
                letter-spacing:0.5px;
            }

            .head p{
                margin:8px 0 0;
                color:#666;
                font-size:16px;
            }

            .grid{
                display:grid;
                grid-template-columns: 260px 1fr;
                gap:14px 18px;
                align-items:center;
                margin-top:18px;
            }

            .lb{
                font-size:18px;
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
                border-radius:14px;
                padding:10px 14px;
                font-size:16px;
                outline:none;
                background:#fff;
            }

            .ip:focus, select:focus, textarea:focus{
                border-color:#2f6fb9;
                box-shadow:0 0 0 3px rgba(47,111,185,.12);
            }

            textarea{
                min-height:96px;
                resize:none;
            }

            .readonly{
                background:#f7f7f7;
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
                justify-content:flex-end;
                gap:16px;
            }

            .btn{
                min-width:160px;
                height:44px;
                border-radius:14px;
                border:1.6px solid #6f6f6f;
                font-size:18px;
                cursor:pointer;
                background:#efefef;
            }

            .btn-primary{
                background:#e7f0ff;
                border-color:#6a8fe6;
            }

            .btn-primary:hover{
                background:#dbe9ff;
            }

            .btn-secondary:hover{
                background:#e6e6e6;
            }

            @media (max-width: 900px){
                .wrap{ max-width:96%; }
                .head h1{ font-size:38px; }
                .grid{ grid-template-columns: 1fr; }
                .btns{ justify-content:center; }
            }
        </style>
    </head>
    <body>
        <div class="wrap">
            <div class="head">
                <h1>Add SKU</h1>
                <p>Create SKU information for warehouse operations</p>
            </div>

            <form action="${pageContext.request.contextPath}/manager/sku/add" method="post" autocomplete="off">
                <div class="grid">
                    <div class="lb">Product <span class="req">*</span></div>
                    <div>
                        <select id="productId" name="productId" required>
                            <option value="">-- Select Product --</option>
                            <c:forEach var="p" items="${products}">
                                <option value="${p.productId}"
                                        data-code="${p.productCode}"
                                        ${param.productId == (''+p.productId) ? 'selected' : ''}>
                                    ${p.productName}
                                </option>
                            </c:forEach>
                        </select>
                        <c:if test="${not empty errors.productId}">
                            <div class="err">${errors.productId}</div>
                        </c:if>
                    </div>

                    <div class="lb">Product Code</div>
                    <div>
                        <input id="productCode" class="ip readonly" type="text" name="productCodeView"
                               value="${param.productCodeView != null ? param.productCodeView : ''}"
                               readonly>
                    </div>

                    <div class="lb">Color <span class="req">*</span></div>
                    <div>
                        <input class="ip" type="text" name="color"
                               value="${param.color != null ? param.color : ''}" required>
                        <c:if test="${not empty errors.color}">
                            <div class="err">${errors.color}</div>
                        </c:if>
                    </div>

                    <div class="lb">Storage <span class="req">*</span></div>
                    <div>
                        <select name="storageGb" required>
                            <option value="">-- Select Storage --</option>
                            <option value="16" ${param.storageGb == '16' ? 'selected' : ''}>16GB</option>
                            <option value="32" ${param.storageGb == '32' ? 'selected' : ''}>32GB</option>
                            <option value="64" ${param.storageGb == '64' ? 'selected' : ''}>64GB</option>
                            <option value="128" ${param.storageGb == '128' ? 'selected' : ''}>128GB</option>
                            <option value="256" ${param.storageGb == '256' ? 'selected' : ''}>256GB</option>
                            <option value="512" ${param.storageGb == '512' ? 'selected' : ''}>512GB</option>
                            <option value="1024" ${param.storageGb == '1024' ? 'selected' : ''}>1TB</option>
                        </select>
                        <c:if test="${not empty errors.storageGb}">
                            <div class="err">${errors.storageGb}</div>
                        </c:if>
                    </div>

                    <div class="lb">RAM <span class="req">*</span></div>
                    <div>
                        <select name="ramGb" required>
                            <option value="">-- Select RAM --</option>
                            <option value="4" ${param.ramGb == '4' ? 'selected' : ''}>4GB</option>
                            <option value="6" ${param.ramGb == '6' ? 'selected' : ''}>6GB</option>
                            <option value="8" ${param.ramGb == '8' ? 'selected' : ''}>8GB</option>
                            <option value="12" ${param.ramGb == '12' ? 'selected' : ''}>12GB</option>
                            <option value="16" ${param.ramGb == '16' ? 'selected' : ''}>16GB</option>
                        </select>
                        <c:if test="${not empty errors.ramGb}">
                            <div class="err">${errors.ramGb}</div>
                        </c:if>
                    </div>

                    <div class="lb">SKU Code <span class="req">*</span></div>
                    <div>
                        <input class="ip" type="text" name="skuCode"
                               value="${param.skuCode != null ? param.skuCode : ''}" required>
                        <c:if test="${not empty errors.skuCode}">
                            <div class="err">${errors.skuCode}</div>
                        </c:if>
                    </div>

                    <div class="lb">Status</div>
                    <div>
                        <select name="status">
                            <option value="ACTIVE" ${param.status == 'ACTIVE' || param.status == null ? 'selected' : ''}>ACTIVE</option>
                            <option value="INACTIVE" ${param.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                        </select>
                    </div>
                </div>

                <div class="btns">
                    <button class="btn btn-primary" type="submit">Save</button>
                    <button class="btn btn-secondary" type="button"
                            onclick="window.location.href='${pageContext.request.contextPath}/home?p=product-list'">
                        Cancel
                    </button>
                    <button class="btn btn-secondary" type="button"
                            onclick="window.location.href='${pageContext.request.contextPath}/manager/sku/add'">
                        Reset
                    </button>
                </div>

                <c:if test="${not empty message}">
                    <div class="ok">${message}</div>
                </c:if>
            </form>
        </div>

        <script>
            const sel = document.getElementById('productId');
            const code = document.getElementById('productCode');

            function syncCode(){
                const opt = sel.options[sel.selectedIndex];
                const v = opt ? (opt.getAttribute('data-code') || '') : '';
                code.value = v;
            }

            sel.addEventListener('change', syncCode);
            syncCode();
        </script>
    </body>
</html>
