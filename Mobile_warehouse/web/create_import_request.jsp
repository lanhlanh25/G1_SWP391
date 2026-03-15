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
                    <input class="input" type="date" name="expected_import_date" min="${today}" value="${param.expected_import_date}"/>

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

                        <div class="muted-label">ROP</div>
                        <div>${selectedLowStockItem.rop}</div>

                        <div class="muted-label">Suggested Qty</div>
                        <div><b>${selectedLowStockItem.suggestedReorderQty}</b></div>

                        <div class="muted-label">Status</div>
                        <div>${fn:escapeXml(selectedLowStockItem.ropStatus)}</div>
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
                                        <td><b>${s.skuCode}</b></td>
                                        <td>${s.color}</td>
                                        <td>${s.ramGb} GB</td>
                                        <td>${s.storageGb} GB</td>
                                        <td>${s.supplierName}</td>
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
                <div style="display:flex; gap:8px;">
                    <button class="btn btn-outline" type="button" onclick="addRow()">+ Add Item</button>
                    <button class="btn" type="button" onclick="clearRows()">Clear</button>
                </div>
            </div>

            <div class="card-body" style="padding:0;">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="text-align:center; width:60px;">No</th>
                            <th>Product Code</th>
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
        <option value="">Select Product Code</option>
        <c:forEach var="p" items="${irProducts}">
            <option value="${p.productId}">${fn:escapeXml(p.productCode)}</option>
        </c:forEach>
    </select>

    <select id="tplSkuOptions" style="display:none">
        <option value="">Select SKU</option>
        <c:forEach var="s" items="${irSkus}">
            <option value="${s.skuId}" data-product="${s.productId}">${fn:escapeXml(s.skuCode)}</option>
        </c:forEach>
    </select>

    <c:if test="${not empty selectedLowStockItem}">
        <div id="prefillData"
             data-product-id="${selectedLowStockItem.productId}"
             data-current-stock="${selectedLowStockItem.currentStock}"
             data-rop="${selectedLowStockItem.rop}"
             data-suggested-qty="${selectedLowStockItem.suggestedReorderQty}"
             style="display:none;"></div>
    </c:if>
</div>

<script>
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
                '<input class="input" name="qty" value="' + qtyValue + '" style="text-align:center;" oninput="recalcTotal()"/>' +
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

    function getPrefillFromLowStock() {
        const el = document.getElementById("prefillData");
        if (!el)
            return null;

        return {
            productId: el.dataset.productId || "",
            currentStock: el.dataset.currentStock || "0",
            rop: el.dataset.rop || "0",
            qty: el.dataset.suggestedQty || "1"
        };
    }

    function addDefaultRowOnEmpty() {
        const prefill = getPrefillFromLowStock();
        if (prefill) {
            addRow(prefill);
        } else {
            addRow();
        }
    }

    (function initForm() {
        const prefill = getPrefillFromLowStock();
        if (prefill) {
            addRow(prefill);
        } else {
            addRow();
        }
    })();
</script>