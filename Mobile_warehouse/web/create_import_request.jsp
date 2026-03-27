<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="page-wrap">
    <div class="topbar">
        <div class="title">Create Import Request</div>
        <button class="btn btn-primary" type="submit" form="frm" name="action" value="submit">Submit Request</button>
    </div>

    <c:if test="${param.err == '1'}">
        <p class="msg-err">Submit failed. Please check inputs. <c:out value="${param.errMsg}"/></p>
    </c:if>

    <form id="frm" method="post" action="${ctx}/create-import-request">
        <c:if test="${not empty selectedLowStockItem}">
            <input type="hidden" name="sourcePage" value="low-stock-report"/>
            <input type="hidden" name="sourceProductId" value="${selectedLowStockItem.productId}"/>
        </c:if>

        <div class="card" style="margin-bottom:14px;">
            <div class="card-header"><span class="h2">Request Information</span></div>
            <div class="card-body">
                <div class="form-grid">
                    <label class="label">Request Code</label>
                    <input class="input readonly" type="text" value="${irCreateCode}" readonly/>

                    <label class="label">Request Date</label>
                    <input class="input readonly" type="text" value="${irRequestDateDefault}" readonly/>

                    <label class="label">Created By</label>
                    <input class="input readonly" type="text" value="${irCreatedByName}" readonly/>

                    <label class="label">Expected Import Date</label>
                    
                    <input class="input" type="date" name="expected_import_date"
                           min="${today}"
                           value="${not empty param.expected_import_date ? param.expected_import_date : irExpectedImportDateDefault}"/>

                    <label class="label">Note</label>
                    <textarea class="textarea" name="note">${fn:escapeXml(param.note)}</textarea>
                </div>
            </div>
        </div>

        <c:if test="${not empty selectedLowStockItem}">
            <div class="card" style="margin-bottom:14px;">
                <div class="card-header"><span class="h2">Selected Low Stock Product</span></div>
                <div class="card-body">
                    <div class="info-grid">
                        <div class="muted-label">Product</div>
                        <div>
                            <b>${fn:escapeXml(selectedLowStockItem.productName)}</b>
                            <span class="small">(${fn:escapeXml(selectedLowStockItem.productCode)})</span>
                        </div>

                        <div class="muted-label">Supplier</div>
                        <div>${fn:escapeXml(selectedLowStockItem.supplierName)}</div>

                        <div class="muted-label">Current Stock</div>
                        <div>${selectedLowStockItem.currentStock}</div>

                        <div class="muted-label">Threshold</div>
                        <div>${selectedLowStockItem.threshold}</div>

                        <div class="muted-label">Suggested Qty</div>
                        <div><b>${selectedLowStockItem.suggestedReorderQty}</b></div>

                        <div class="muted-label">Status</div>
                        <div>${fn:escapeXml(selectedLowStockItem.stockStatus)}</div>
                    </div>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty selectedProductSkuStocks}">
            <div class="card" style="margin-bottom:14px;">
                <div class="card-header"><span class="h2">SKU Stock Breakdown</span></div>
                <div class="card-body" style="padding:0;">
                    <div class="table-wrap">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>SKU Code</th>
                                    <th>Color</th>
                                    <th>RAM</th>
                                    <th>Storage</th>
                                    <th>Supplier</th>
                                    <th>Current Stock</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${selectedProductSkuStocks}">
                                    <tr>
                                        <td><b>${fn:escapeXml(s.skuCode)}</b></td>
                                        <td>${fn:escapeXml(s.color)}</td>
                                        <td>${s.ramGb} GB</td>
                                        <td>${s.storageGb} GB</td>
                                        <td>${fn:escapeXml(s.supplierName)}</td>
                                        <td>${s.stock}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${s.stockStatus == 'Out Of Stock'}">
                                                    <span class="badge badge-danger">Out Of Stock</span>
                                                </c:when>
                                                <c:when test="${s.stockStatus == 'Low Stock'}">
                                                    <span class="badge badge-warning">Low Stock</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-active">In Stock</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </c:if>

        <div class="card">
            <div class="card-header">
                <span class="h2">Items</span>

                <c:if test="${empty selectedLowStockItem}">
                    <div style="display:flex; gap:8px;">
                        <button class="btn btn-outline" type="button" onclick="addRow()">+ Add Item</button>
                        <button class="btn" type="button" onclick="clearRows()">Clear</button>
                    </div>
                </c:if>
            </div>

            <div class="card-body" style="padding:0;">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="text-align:center; width:60px;">No</th>
                            <th>Product Name</th>
                            <th>SKU</th>
                            <th style="width:140px; text-align:center;">Request Qty</th>
                            <th style="width:100px; text-align:center;">Remove</th>
                        </tr>
                    </thead>
                    <tbody id="tbody"></tbody>
                </table>
                <div style="padding:10px 16px;" class="small">
                    Total quantity: <b id="totalQty">0</b>
                </div>
            </div>
        </div>
    </form>

    <select id="tplProductOptions" style="display:none">
        <option value="">Select Product Name</option>
        <c:forEach var="p" items="${irProducts}">
            <option value="${p.productId}">${fn:escapeXml(p.productName)}</option>
        </c:forEach>
    </select>

    <select id="tplSkuOptions" style="display:none">
        <option value="">Select SKU</option>
        <c:forEach var="s" items="${irSkus}">
            <option value="${s.skuId}" data-product="${s.productId}">${fn:escapeXml(s.skuCode)}</option>
        </c:forEach>
    </select>

    <c:if test="${not empty selectedLowStockItem}">
        <div id="prefillRows" style="display:none;">
            <c:forEach var="s" items="${selectedProductSkuStocks}">
                <c:if test="${s.stockStatus == 'Out Of Stock' || s.stockStatus == 'Low Stock'}">
                    <div class="prefill-row"
                         data-product-id="${selectedLowStockItem.productId}"
                         data-product-name="${fn:escapeXml(selectedLowStockItem.productName)}"
                         data-sku-id="${s.skuId}"
                         data-sku-code="${fn:escapeXml(s.skuCode)}"
                         data-current-stock="${s.stock}"
                         data-threshold="${selectedLowStockItem.threshold}"
                         data-qty="${s.stock < selectedLowStockItem.threshold ? (selectedLowStockItem.threshold - s.stock) : 1}">
                    </div>
                </c:if>
            </c:forEach>
        </div>
    </c:if>
</div>

<script>
    function escapeHtml(str) {
        if (str === null || str === undefined)
            return "";
        return String(str)
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#39;");
    }

    function productOptionsHtml(selectedValue) {
        const tpl = document.getElementById("tplProductOptions");
        const clone = tpl.cloneNode(true);
        clone.removeAttribute("id");

        if (selectedValue !== undefined && selectedValue !== null && selectedValue !== "") {
            Array.from(clone.options).forEach(function (opt) {
                if (String(opt.value) === String(selectedValue)) {
                    opt.selected = true;
                }
            });
        }
        return clone.innerHTML;
    }

    function skuOptionsHtml(productId, selectedSkuId) {
        let html = '<option value="">Select SKU</option>';
        document.querySelectorAll("#tplSkuOptions option[data-product]").forEach(function (o) {
            if (String(o.getAttribute("data-product")) === String(productId)) {
                let optionHtml = o.outerHTML;
                if (selectedSkuId && String(o.value) === String(selectedSkuId)) {
                    optionHtml = optionHtml.replace("<option", "<option selected");
                }
                html += optionHtml;
            }
        });
        return html;
    }

    function calcSuggestedQty(prefill) {
        if (prefill && prefill.qty) {
            const v = parseInt(prefill.qty, 10);
            if (!isNaN(v) && v > 0)
                return v;
        }
        return 1;
    }

    function addRow(prefill) {
        const tb = document.getElementById("tbody");
        const tr = document.createElement("tr");

        const selectedProductId = prefill && prefill.productId ? prefill.productId : "";
        const selectedSkuId = prefill && prefill.skuId ? prefill.skuId : "";
        const qtyValue = prefill && prefill.qty ? prefill.qty : calcSuggestedQty(prefill);

        tr.innerHTML =
                '<td class="no" style="text-align:center;"></td>' +
                '<td>' +
                '<select class="select" name="productId" onchange="onProductChange(this)">' +
                productOptionsHtml(selectedProductId) +
                '</select>' +
                '</td>' +
                '<td>' +
                '<select class="select" name="skuId">' +
                skuOptionsHtml(selectedProductId, selectedSkuId) +
                '</select>' +
                '</td>' +
                '<td>' +
                '<input class="input" type="number" min="1" name="qty" value="' + qtyValue + '" style="text-align:center;" oninput="recalcTotal()"/>' +
                '</td>' +
                '<td style="text-align:center;">' +
                '<button type="button" class="btn btn-danger btn-sm" onclick="removeRow(this)">✕</button>' +
                '</td>';

        tb.appendChild(tr);
        renumber();
        recalcTotal();
    }

    function addReadonlyPrefillRow(prefill) {
        const tb = document.getElementById("tbody");
        const tr = document.createElement("tr");

        const qtyValue = calcSuggestedQty(prefill);

        tr.innerHTML =
                '<td class="no" style="text-align:center;"></td>' +
                '<td>' +
                '<input type="hidden" name="productId" value="' + escapeHtml(prefill.productId) + '"/>' +
                '<input class="input readonly" type="text" value="' + escapeHtml(prefill.productName) + '" readonly/>' +
                '</td>' +
                '<td>' +
                '<input type="hidden" name="skuId" value="' + escapeHtml(prefill.skuId) + '"/>' +
                '<input class="input readonly" type="text" value="' + escapeHtml(prefill.skuCode) + '" readonly/>' +
                '</td>' +
                '<td>' +
                '<input class="input" type="number" min="1" name="qty" value="' + qtyValue + '" style="text-align:center;" oninput="recalcTotal()"/>' +
                '</td>' +
                '<td style="text-align:center;">' +
                '<button type="button" class="btn btn-danger btn-sm" onclick="removeRow(this)">✕</button>' +
                '</td>';

        tb.appendChild(tr);
        renumber();
        recalcTotal();
    }

    function onProductChange(sel) {
        const tr = sel.closest("tr");
        const skuSelect = tr.querySelector('select[name="skuId"]');
        skuSelect.innerHTML = skuOptionsHtml(sel.value, "");
    }

    function removeRow(btn) {
        btn.closest("tr").remove();
        renumber();
        recalcTotal();

        if (document.querySelectorAll("#tbody tr").length === 0) {
            addDefaultRowOnEmpty();
        }
    }

    function clearRows() {
        document.getElementById("tbody").innerHTML = "";
        addDefaultRowOnEmpty();
    }

    function renumber() {
        let i = 1;
        document.querySelectorAll("#tbody tr").forEach(function (r) {
            r.querySelector(".no").innerText = i++;
        });
    }

    function recalcTotal() {
        let t = 0;
        document.querySelectorAll('input[name="qty"]').forEach(function (i) {
            const v = parseInt(i.value || "0", 10);
            if (!isNaN(v))
                t += v;
        });
        document.getElementById("totalQty").innerText = t;
    }

    function getPrefillRowsFromLowStock() {
        const nodes = document.querySelectorAll("#prefillRows .prefill-row");
        if (!nodes || nodes.length === 0)
            return [];

        const arr = [];
        nodes.forEach(function (el) {
            arr.push({
                productId: el.dataset.productId || "",
                productName: el.dataset.productName || "",
                skuId: el.dataset.skuId || "",
                skuCode: el.dataset.skuCode || "",
                qty: el.dataset.qty || "1"
            });
        });
        return arr;
    }

    function addDefaultRowOnEmpty() {
        const prefillRows = getPrefillRowsFromLowStock();
        if (prefillRows.length > 0) {
            prefillRows.forEach(function (r) {
                addReadonlyPrefillRow(r);
            });
        } else {
            addRow();
        }
    }

    (function initForm() {
        const prefillRows = getPrefillRowsFromLowStock();
        if (prefillRows.length > 0) {
            prefillRows.forEach(function (r) {
                addReadonlyPrefillRow(r);
            });
        } else {
            addRow();
        }
    })();
</script>