<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
    body{
        font-family:Arial,Helvetica,sans-serif;
        background:#f4f4f4;
        margin:0;
    }
    .wrap{
        padding:16px;
    }
    .card{
        background:#fff;
        border:1px solid #333;
        padding:14px;
    }
    .topbar{
        display:flex;
        justify-content:space-between;
        align-items:center;
    }
    .title{
        font-size:34px;
        font-weight:800;
    }
    .btn{
        padding:8px 16px;
        border:1px solid #333;
        background:#f6f6f6;
        cursor:pointer;
    }
    .section{
        border:1px solid #999;
        padding:12px;
        margin-top:12px;
        background:#f1ede7;
    }
    .sectionTitle{
        font-weight:700;
        margin-bottom:10px;
    }
    .grid{
        display:grid;
        grid-template-columns:160px 320px 1fr;
        gap:14px 16px;
        align-items:center;
    }
    input, textarea, select{
        width:100%;
        padding:8px;
        border:1px solid #333;
        background:#fff;
    }
    textarea{
        height:60px;
    }
    table{
        width:100%;
        border-collapse:collapse;
        background:#f1ede7;
    }
    th,td{
        border:1px solid #333;
        padding:10px;
        text-align:center;
        vertical-align:top;
    }
    th{
        background:#eee;
    }
    .rightTools{
        display:flex;
        justify-content:flex-end;
        gap:10px;
        margin:10px 0;
    }
    .xbtn{
        width:44px;
        height:44px;
        border:1px solid #333;
        background:#fff;
        cursor:pointer;
    }
    .msg{
        margin-top:10px;
        padding:10px;
        border:1px solid #999;
        background:#fff;
    }
</style>

<div class="wrap">
    <div class="card">

        <div class="topbar">
            <div class="title">Create Export Request</div>
            <div style="display:flex;gap:10px;">
                <button class="btn" type="submit" form="frm" name="action" value="submit">Submit Request</button>
            </div>
        </div>

        <c:if test="${param.err == '1'}">
            <div class="msg" style="border-color:#b00020;color:#b00020;">
                Submit failed. Please check inputs.
                <c:out value="${param.errMsg}" />
            </div>
        </c:if>

        <form id="frm" method="post" action="${ctx}/create-export-request">
            <div class="section">
                <div class="sectionTitle">Request Information</div>

                <div class="grid">
                    <div>Request Code</div>
                    <input type="text" value="${erCreateCode}" readonly />
                    <div>auto</div>

                    <div>Request Date</div>
                    <input type="text" value="${erRequestDateDefault}" readonly />
                    <div>auto now</div>

                    <div>Created By</div>
                    <input type="text" value="${erCreatedByName}" readonly />
                    <div>auto sale name</div>

                    <div>Expected Export Date</div>
                    <input type="date" name="expected_export_date" value="${param.expected_export_date}" />
                    <div></div>

                    <div>Note</div>
                    <textarea name="note">${fn:escapeXml(param.note)}</textarea>
                    <div></div>
                </div>
            </div>

            <div class="rightTools">
                <button class="btn" type="button" onclick="addRow()">Add Item</button>
                <button class="btn" type="button" onclick="clearRows()">Clear</button>
            </div>

            <div class="section">
                <div class="sectionTitle">Items</div>

                <table>
                    <thead>
                        <tr>
                            <th style="width:70px;">No</th>
                            <th>Product Code</th>
                            <th>SKU (option)</th>
                            <th style="width:140px;">Request Qty</th>
                            <th style="width:120px;">Remove</th>
                        </tr>
                    </thead>
                    <tbody id="tbody"></tbody>
                </table>

                <div style="margin-top:8px;font-size:13px;">
                    Total quantity: <b id="totalQty">0</b>
                </div>
            </div>
        </form>
        <select id="tplProductOptions" style="display:none">
            <option value="">Select Product Code</option>
            <c:forEach var="p" items="${erProducts}">
                <option value="${p.productId}">${fn:escapeXml(p.productCode)}</option>
            </c:forEach>
        </select>
        <!-- SKU template: mỗi option có data-product -->
        <select id="tplSkuOptions" style="display:none">
            <option value="">Select SKU</option>
            <c:forEach var="s" items="${erSkus}">
                <option value="${s.skuId}" data-product="${s.productId}">
                    ${fn:escapeXml(s.skuCode)}
                </option>
            </c:forEach>
        </select>
    </div>
</div>
<script>
    function productOptionsHtml() {
        return document.getElementById("tplProductOptions").innerHTML;
    }

    function skuOptionsHtml(productId) {
        let html = '<option value="">Select SKU</option>';
        if (!productId)
            return html;

        const tpl = document.getElementById("tplSkuOptions");
        const opts = tpl.querySelectorAll("option[data-product]");

        opts.forEach(o => {
            if (o.getAttribute("data-product") === String(productId)) {
                html += o.outerHTML;
            }
        });
        return html;
    }

    function addRow() {
        const tb = document.getElementById("tbody");
        const tr = document.createElement("tr");

        tr.innerHTML =
                '<td class="no"></td>' +
                '<td>' +
                '<select name="productId" onchange="onProductChange(this)">' +
                productOptionsHtml() +
                '</select>' +
                '</td>' +
                '<td>' +
                '<select name="skuId">' +
                '<option value="">Select SKU</option>' +
                '</select>' +
                '</td>' +
                '<td><input name="qty" value="1" oninput="recalcTotal()" /></td>' +
                '<td><button type="button" class="xbtn" onclick="removeRow(this)">X</button></td>';

        tb.appendChild(tr);
        renumber();
        recalcTotal();
        // auto fill sku options based on current product selection
        const prodSel = tr.querySelector('select[name="productId"]');
        onProductChange(prodSel);
    }

    function onProductChange(sel) {
        const tr = sel.closest("tr");
        const skuSel = tr.querySelector('select[name="skuId"]');
        skuSel.innerHTML = skuOptionsHtml(sel.value);
    }

    function removeRow(btn) {
        btn.closest("tr").remove();
        renumber();
        recalcTotal();
    }

    function clearRows() {
        document.getElementById("tbody").innerHTML = "";
        addRow();
    }

    function renumber() {
        const rows = document.querySelectorAll("#tbody tr");
        let i = 1;
        rows.forEach(r => r.querySelector(".no").innerText = i++);
    }

    function recalcTotal() {
        let total = 0;
        document.querySelectorAll('input[name="qty"]').forEach(inp => {
            const v = parseInt(inp.value || "0", 10);
            if (!isNaN(v))
                total += v;
        });
        document.getElementById("totalQty").innerText = total;
    }

    addRow();
</script>