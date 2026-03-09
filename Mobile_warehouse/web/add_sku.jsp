<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="container">

```
<div class="topbar">
    <div>
        <div class="title">Add SKU</div>
        <div class="small">Create SKU information for warehouse operations</div>
    </div>

    <div class="actions">
        <button class="btn btn-outline" type="button"
                onclick="window.location.href='${pageContext.request.contextPath}/home?p=product-list'">
            Back
        </button>
    </div>
</div>


<div class="card">
    <div class="card-body">

        <form action="${pageContext.request.contextPath}/manager/sku/add" method="post" autocomplete="off">

            <div class="form-grid">

                <div class="label">Product <span class="req">*</span></div>
                <div>

                    <select class="select" id="productId" name="productId" required>
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



                <div class="label">Product Code</div>
                <div>

                    <input id="productCode"
                           class="input readonly"
                           type="text"
                           name="productCodeView"
                           readonly>

                </div>



                <div class="label">Color <span class="req">*</span></div>
                <div>

                    <input id="color"
                           class="input"
                           type="text"
                           name="color"
                           value="${param.color != null ? param.color : ''}"
                           required>

                    <c:if test="${not empty errors.color}">
                        <div class="err">${errors.color}</div>
                    </c:if>

                </div>



                <div class="label">Storage <span class="req">*</span></div>
                <div>

                    <select class="select"
                            id="storageSelect"
                            name="storageGb"
                            onchange="toggleStorage();generateSku();"
                            required>

                        <option value="">-- Select Storage --</option>

                        <option value="16">16GB</option>
                        <option value="32">32GB</option>
                        <option value="64">64GB</option>
                        <option value="128">128GB</option>
                        <option value="256">256GB</option>
                        <option value="512">512GB</option>
                        <option value="1024">1TB</option>

                        <option value="custom">Other...</option>

                    </select>

                    <input id="storageCustom"
                           class="input"
                           type="number"
                           placeholder="Enter new storage (GB)"
                           style="display:none;margin-top:6px;">

                    <c:if test="${not empty errors.storageGb}">
                        <div class="err">${errors.storageGb}</div>
                    </c:if>

                </div>



                <div class="label">RAM <span class="req">*</span></div>
                <div>

                    <select class="select"
                            id="ramSelect"
                            name="ramGb"
                            onchange="toggleRam();generateSku();"
                            required>

                        <option value="">-- Select RAM --</option>

                        <option value="4">4GB</option>
                        <option value="6">6GB</option>
                        <option value="8">8GB</option>
                        <option value="12">12GB</option>
                        <option value="16">16GB</option>

                        <option value="custom">Other...</option>

                    </select>

                    <input id="ramCustom"
                           class="input"
                           type="number"
                           placeholder="Enter new RAM (GB)"
                           style="display:none;margin-top:6px;">

                    <c:if test="${not empty errors.ramGb}">
                        <div class="err">${errors.ramGb}</div>
                    </c:if>

                </div>



                <div class="label">SKU Code <span class="req">*</span></div>
                <div>

                    <input id="skuCode"
                           class="input readonly"
                           type="text"
                           name="skuCode"
                           value="${param.skuCode != null ? param.skuCode : ''}"
                           readonly
                           required>

                    <c:if test="${not empty errors.skuCode}">
                        <div class="err">${errors.skuCode}</div>
                    </c:if>

                </div>



                <div class="label">Status</div>
                <div>

                    <select class="select" name="status">

                        <option value="ACTIVE"
                                ${param.status == 'ACTIVE' || param.status == null ? 'selected' : ''}>
                            ACTIVE
                        </option>

                        <option value="INACTIVE"
                                ${param.status == 'INACTIVE' ? 'selected' : ''}>
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
                        onclick="window.location.href='${pageContext.request.contextPath}/home?p=product-list'">
                    Cancel
                </button>

                <button class="btn btn-outline" type="button"
                        onclick="window.location.href='${pageContext.request.contextPath}/manager/sku/add'">
                    Reset
                </button>

            </div>



            <c:if test="${not empty message}">
                <div class="ok" style="text-align:center;">
                    ${message}
                </div>
            </c:if>

        </form>

    </div>
</div>
```

</div>

<script>

const productSelect = document.getElementById('productId');
const productCodeInput = document.getElementById('productCode');

function syncProductCode(){

    const opt = productSelect.options[productSelect.selectedIndex];
    const code = opt ? (opt.getAttribute('data-code') || '') : '';

    productCodeInput.value = code;

}

productSelect.addEventListener('change', function(){
    syncProductCode();
    generateSku();
});

syncProductCode();



function toggleStorage(){

    const select = document.getElementById("storageSelect");
    const input = document.getElementById("storageCustom");

    if(select.value === "custom"){

        input.style.display = "block";
        select.removeAttribute("name");
        input.setAttribute("name","storageGb");

    }else{

        input.style.display = "none";
        input.removeAttribute("name");
        select.setAttribute("name","storageGb");

    }

}



function toggleRam(){

    const select = document.getElementById("ramSelect");
    const input = document.getElementById("ramCustom");

    if(select.value === "custom"){

        input.style.display = "block";
        select.removeAttribute("name");
        input.setAttribute("name","ramGb");

    }else{

        input.style.display = "none";
        input.removeAttribute("name");
        select.setAttribute("name","ramGb");

    }

}



function generateSku(){

    const productCode = document.getElementById("productCode").value;
    const color = document.getElementById("color").value;
    const storage = document.getElementById("storageSelect").value;
    const ram = document.getElementById("ramSelect").value;

    if(productCode && color && storage && ram && storage !== "custom" && ram !== "custom"){

        const sku =
            productCode.trim() + "-" +
            color.trim().toUpperCase() + "-" +
            storage + "-" +
            ram;

        document.getElementById("skuCode").value = sku;

    }

}

document.getElementById("color").addEventListener("keyup", generateSku);
document.getElementById("storageSelect").addEventListener("change", generateSku);
document.getElementById("ramSelect").addEventListener("change", generateSku);

</script>
