<%-- 
    Document   : create_export_receipt
    Created on : Feb 12, 2026, 12:47:26 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Create Export Receipt</title>

        <style>
            :root{
                --line:#2e3f95;
                --bg:#f4f4f4;
                --th:#d9d9d9;
            }
            body{
                font-family: Arial, Helvetica, sans-serif;
                background:#eee;
                margin:0;
            }
            .wrap{
                padding:14px;
                background:var(--bg);
            }
            .frame{
                border:2px solid var(--line);
                background:#fff;
                padding:12px;
            }
            .title{
                font-size:20px;
                font-weight:700;
            }
            .sectionTitle{
                font-weight:700;
                margin:8px 0 6px;
            }
            .row{
                display:flex;
                gap:10px;
                margin-bottom:8px;
                align-items:center;
            }
            .row label{
                min-width:140px;
                font-size:13px;
            }
            input[type="text"], input[type="number"], input[type="datetime-local"], select, textarea{
                width:100%;
                padding:6px 8px;
                border:1px solid #333;
                box-sizing:border-box;
            }
            textarea{
                height:56px;
                resize:vertical;
            }
            .col{
                flex:1;
            }

            .tabs{
                display:flex;
                gap:6px;
                margin-bottom:10px;
            }
            .tabBtn{
                border:1px solid #333;
                background:#f6f6f6;
                padding:6px 10px;
                cursor:pointer;
                font-size:13px;
            }
            .tabBtn.active{
                background:#fff;
                font-weight:700;
            }
            .tabPanel{
                display:none;
            }
            .tabPanel.active{
                display:block;
            }

            table{
                border-collapse:collapse;
                width:100%;
                table-layout:auto;
            }
            th, td{
                border:1px solid #333;
                padding:6px;
                vertical-align:top;
                font-size:12px;
            }
            th{
                background:var(--th);
                text-align:left;
                white-space:nowrap;
            }

            .small{
                font-size:12px;
                color:#333;
            }
            .btn{
                border:1px solid #333;
                background:#f6f6f6;
                padding:6px 12px;
                cursor:pointer;
                display:inline-block;
                text-decoration:none;
                color:#111;
                font-size:13px;
            }
            .btn.danger{
                background:#fff0f0;
            }
            .btnRow{
                display:flex;
                gap:8px;
                margin-top:10px;
            }
            .hint{
                background:#c9f2ff;
                border:1px solid #333;
                padding:8px;
                margin:8px 0;
                font-size:12px;
            }
            .err{
                border:1px solid #b00020;
                background:#ffe9ee;
                padding:8px;
                margin-bottom:10px;
                color:#b00020;
                font-size:13px;
            }
            .ok{
                border:1px solid #0a7f3f;
                background:#e9fff1;
                padding:8px;
                margin-bottom:10px;
                color:#0a7f3f;
                font-size:13px;
            }

            .w60{
                min-width:60px;
            }
            .w90{
                min-width:90px;
            }
            .w120{
                min-width:120px;
            }
            .w160{
                min-width:160px;
            }
            .w200{
                min-width:200px;
            }
            .w260{
                min-width:260px;
            }
            .center{
                text-align:center;
            }

            .imeiBox{
                display:flex;
                flex-direction:column;
                gap:4px;
                min-width:280px;
            }
            .imeiRow{
                display:flex;
                gap:6px;
                align-items:center;
            }
            .imeiRow span{
                min-width:50px;
                font-size:11px;
                white-space:nowrap;
            }
            .imeiRow input{
                flex:1;
                min-width:200px;
                padding:4px 6px;
                font-size:12px;
            }
            .imeiRow input.valid{
                border-color:#0a7f3f;
                background:#f0fff4;
            }
            .imeiRow input.invalid{
                border-color:#b00020;
                background:#fff5f5;
            }
        </style>
    </head>

    <body>
        <div class="wrap">
            <div class="frame">
                <div style="display:flex; gap:10px; align-items:center;">
                    <a class="btn" href="${ctx}/home?p=dashboard">← Back</a>
                    <div class="title">Create Export Receipt</div>
                </div>

                <c:if test="${not empty err}">
                    <div class="err">${fn:escapeXml(err)}</div>
                </c:if>
                <c:if test="${not empty msg}">
                    <div class="ok">${fn:escapeXml(msg)}</div>
                </c:if>

                <div class="sectionTitle">Export Form</div>

                <div class="tabs">
                    <button type="button" class="tabBtn active" data-tab="manual">Manual Entry</button>
                    <button type="button" class="tabBtn" data-tab="excel">Upload Excel With Imei</button>
                </div>

                <!-- ================= Manual ================= -->
                <div id="tab-manual" class="tabPanel active">
                    <form id="manualForm" method="post" action="${ctx}/create-export-receipt">

                        <input type="hidden" name="mode" value="manual"/>

                        <div class="row">
                            <label>Export Code (auto)</label>
                            <div class="col">
                                <input type="text" name="exportCode" value="${fn:escapeXml(exportCode)}" readonly />
                                <div class="small">Generated by system</div>
                            </div>
                        </div>

                        <div class="row">
                            <label>Transaction time</label>
                            <div class="col">
                                <input type="datetime-local" name="receiptDate" value="${fn:escapeXml(receiptDateDefault)}" required />
                            </div>
                        </div>

                        <div class="row">
                            <label>Created by (Sale)</label>
                            <div class="col">
                                <input type="text" value="${fn:escapeXml(createdByName)}" readonly />
                            </div>
                        </div>

                        <div class="row">
                            <label>Note</label>
                            <div class="col">
                                <textarea name="note" placeholder="Optional note for warehouse staff..."></textarea>
                            </div>
                        </div>

                        <div class="sectionTitle">Export Items</div>

                        <table id="itemsTable">
                            <thead>
                                <tr>
                                    <th class="w60 center">#</th>
                                    <th class="w160">Product Code</th>
                                    <th class="w200">SKU</th>
                                    <th class="w90">Quantity</th>
                                    <th class="w260">Imei Numbers</th>
                                    <th class="w160">Item note</th>
                                    <th class="w120 center">Action</th>
                                </tr>
                            </thead>
                            <tbody id="itemsTbody"></tbody>
                        </table>

                        <div style="margin-top:8px;">
                            <button type="button" class="btn" id="btnAddRow">+ Add product Line</button>
                        </div>

                        <div class="btnRow">
                            <button type="submit" class="btn">Create Receipt</button>
                            <a class="btn" href="${ctx}/home">Cancel</a>
                        </div>
                    </form>
                </div>

                <!-- ================= Excel ================= -->
                <div id="tab-excel" class="tabPanel">
                    <form method="post" action="${ctx}/create-export-receipt" enctype="multipart/form-data">
                        <input type="hidden" name="mode" value="excel"/>

                        <div class="hint">
                            <b>Excel Format:</b> 3 columns: <b>product_code</b>, <b>sku_code</b>, <b>imei</b> (IMEI 15 digits)
                        </div>

                        <div class="row">
                            <label>Export Code (auto)</label>
                            <div class="col">
                                <input type="text" name="exportCode" value="${fn:escapeXml(exportCode)}" readonly />
                            </div>
                        </div>

                        <div class="row">
                            <label>Excel File (.xlsx)</label>
                            <div class="col">
                                <input type="file" name="excelFile" accept=".xlsx" required />
                            </div>
                        </div>

                        <div class="row">
                            <label>Transaction time</label>
                            <div class="col">
                                <input type="datetime-local" name="receiptDate" value="${fn:escapeXml(receiptDateDefault)}" required />
                            </div>
                        </div>

                        <div class="row">
                            <label>Created by (Sale)</label>
                            <div class="col">
                                <input type="text" value="${fn:escapeXml(createdByName)}" readonly />
                            </div>
                        </div>

                        <div class="row">
                            <label>Note</label>
                            <div class="col">
                                <textarea name="note" placeholder="Optional note for warehouse staff..."></textarea>
                            </div>
                        </div>

                        <div class="btnRow">
                            <button type="submit" class="btn">Create  with Excel</button>
                            <a class="btn" href="${ctx}/home?p=export-receipt-list">Cancel</a>

                        </div>
                    </form>
                </div>

            </div>
        </div>

        <script>
            (function () {
                // Products: DO NOT use productName (your DAO may return ProductLite only)
                const PRODUCTS = [
            <c:forEach var="p" items="${products}" varStatus="st">
                { id: ${p.productId}, code: "${fn:escapeXml(p.productCode)}" }<c:if test="${!st.last}">,</c:if>
            </c:forEach>
                ];

                // SKUs: must have skuId, skuCode, productId
                const SKUS = [
            <c:forEach var="k" items="${skus}" varStatus="st">
                { id: ${k.skuId}, code: "${fn:escapeXml(k.skuCode)}", productId: ${k.productId} }<c:if test="${!st.last}">,</c:if>
            </c:forEach>
                ];

                const tbody = document.getElementById("itemsTbody");
                const manualForm = document.getElementById("manualForm");
                let rowCounter = 0;

                function buildProductSelect() {
                    const sel = document.createElement("select");
                    sel.name = "productId";
                    sel.required = true;
                    sel.innerHTML = '<option value="">-- Select Product Code --</option>';
                    PRODUCTS.forEach(p => {
                        sel.innerHTML += '<option value="' + p.id + '">' + p.code + '</option>';
                    });
                    return sel;
                }

                function buildSkuSelect() {
                    const sel = document.createElement("select");
                    sel.name = "skuId";
                    sel.required = true;
                    sel.innerHTML = '<option value="">-- Select SKU --</option>';
                    return sel;
                }

                function refreshSkuOptions(skuSelect, productId) {
                    skuSelect.innerHTML = '<option value="">-- Select SKU --</option>';
                    if (!productId)
                        return;
                    SKUS.filter(s => String(s.productId) === String(productId)).forEach(s => {
                        skuSelect.innerHTML += '<option value="' + s.id + '">' + s.code + '</option>';
                    });
                }

                function buildImeiBox(rowIdx, qty) {
                    const box = document.createElement("div");
                    box.className = "imeiBox";

                    for (let i = 1; i <= qty; i++) {
                        const row = document.createElement("div");
                        row.className = "imeiRow";

                        const label = document.createElement("span");
                        label.textContent = "Imei " + i + ":";

                        const input = document.createElement("input");
                        input.type = "text";
                        input.name = "imei_" + rowIdx + "_" + i;   // parse by rowIdx & order
                        input.placeholder = "15 digits";
                        input.required = true;
                        input.maxLength = 15;

                        input.addEventListener("input", function () {
                            this.value = this.value.replace(/\D/g, "").slice(0, 15);
                            if (this.value.length === 15) {
                                this.classList.add("valid");
                                this.classList.remove("invalid");
                            } else if (this.value.length > 0) {
                                this.classList.add("invalid");
                                this.classList.remove("valid");
                            } else {
                                this.classList.remove("valid", "invalid");
                            }
                        });

                        row.appendChild(label);
                        row.appendChild(input);
                        box.appendChild(row);
                    }
                    return box;
                }

                function renumber() {
                    Array.from(tbody.children).forEach((row, idx) => {
                        const noCell = row.querySelector(".cellNo");
                        if (noCell)
                            noCell.textContent = idx + 1;
                    });
                }

                function addRow() {
                    rowCounter++;
                    const rowIdx = rowCounter;

                    const tr = document.createElement("tr");
                    tr.dataset.rowIdx = rowIdx;

                    const tdNo = document.createElement("td");
                    tdNo.className = "center cellNo";
                    tdNo.textContent = tbody.children.length + 1;

                    const tdProd = document.createElement("td");
                    const selProd = buildProductSelect();
                    tdProd.appendChild(selProd);

                    const tdSku = document.createElement("td");
                    const selSku = buildSkuSelect();
                    tdSku.appendChild(selSku);

                    const hidden = document.createElement("input");
                    hidden.type = "hidden";
                    hidden.name = "rowKey";
                    hidden.value = String(rowIdx);
                    tr.appendChild(hidden);


                    selProd.addEventListener("change", function () {
                        refreshSkuOptions(selSku, this.value);
                    });

                    const tdQty = document.createElement("td");
                    const qtyInp = document.createElement("input");
                    qtyInp.type = "number";
                    qtyInp.name = "qty";
                    qtyInp.min = "1";
                    qtyInp.value = "1";
                    qtyInp.required = true;
                    tdQty.appendChild(qtyInp);

                    const tdImei = document.createElement("td");
                    let imeiBox = buildImeiBox(rowIdx, 1);
                    tdImei.appendChild(imeiBox);

                    qtyInp.addEventListener("input", function () {
                        let q = parseInt(this.value) || 1;
                        if (q < 1)
                            q = 1;
                        this.value = q;

                        tdImei.innerHTML = "";
                        imeiBox = buildImeiBox(rowIdx, q);
                        tdImei.appendChild(imeiBox);
                    });

                    const tdNote = document.createElement("td");
                    const noteInp = document.createElement("input");
                    noteInp.type = "text";
                    noteInp.name = "itemNote";
                    noteInp.placeholder = "Notes";
                    tdNote.appendChild(noteInp);

                    const tdAct = document.createElement("td");
                    tdAct.className = "center";
                    const delBtn = document.createElement("button");
                    delBtn.type = "button";
                    delBtn.className = "btn danger";
                    delBtn.textContent = "Delete";
                    delBtn.addEventListener("click", function () {
                        tr.remove();
                        renumber();
                    });

                    selProd.name = "productId_" + rowIdx;
                    selSku.name = "skuId_" + rowIdx;

                    qtyInp.name = "qty_" + rowIdx;
                    noteInp.name = "itemNote_" + rowIdx;


                    tdAct.appendChild(delBtn);

                    tr.appendChild(tdNo);
                    tr.appendChild(tdProd);
                    tr.appendChild(tdSku);
                    tr.appendChild(tdQty);
                    tr.appendChild(tdImei);
                    tr.appendChild(tdNote);
                    tr.appendChild(tdAct);

                    tbody.appendChild(tr);
                }

                document.getElementById("btnAddRow").addEventListener("click", addRow);

                manualForm.addEventListener("submit", function (e) {
                    const rows = tbody.children;
                    if (rows.length === 0) {
                        e.preventDefault();
                        alert("Please add at least 1 product line.");
                        return;
                    }

                    for (let i = 0; i < rows.length; i++) {
                        const row = rows[i];
                        for (let i = 0; i < rows.length; i++) {
                            const row = rows[i];
                            const rowIdx = row.dataset.rowIdx;

                            const productId = row.querySelector('select[name="productId_' + rowIdx + '"]').value;
                            const skuId = row.querySelector('select[name="skuId_' + rowIdx + '"]').value;
                            const qty = parseInt(row.querySelector('input[name="qty_' + rowIdx + '"]').value) || 0;

                            if (!productId || !skuId || qty < 1) {
                                e.preventDefault();
                                alert("Row " + (i + 1) + ": Please fill Product Code, SKU and Quantity");
                                return;
                            }

                            for (let j = 1; j <= qty; j++) {
                                const imeiInput = row.querySelector('input[name="imei_' + rowIdx + '_' + j + '"]');
                                const imei = (imeiInput ? imeiInput.value.trim() : "");

                                if (!imei) {
                                    e.preventDefault();
                                    alert("Row " + (i + 1) + ", IMEI " + j + ": Please enter IMEI");
                                    return;
                                }
                                if (imei.length !== 15) {
                                    e.preventDefault();
                                    alert("Row " + (i + 1) + ", IMEI " + j + ": IMEI must be exactly 15 digits");
                                    return;
                                }
                            }
                        }


                        if (!productId || !skuId || qty < 1) {
                            e.preventDefault();
                            alert("Row " + (i + 1) + ": Please fill Product Code, SKU and Quantity");
                            return;
                        }

                        const imeiInputs = row.querySelectorAll('.imeiRow input');
                        for (let j = 0; j < imeiInputs.length; j++) {
                            const imei = imeiInputs[j].value.trim();
                            if (!imei) {
                                e.preventDefault();
                                alert("Row " + (i + 1) + ", IMEI " + (j + 1) + ": Please enter IMEI");
                                return;
                            }
                            if (imei.length !== 15) {
                                e.preventDefault();
                                alert("Row " + (i + 1) + ", IMEI " + (j + 1) + ": IMEI must be exactly 15 digits");
                                return;
                            }
                        }
                    }
                });

                document.querySelectorAll('.tabBtn').forEach(btn => {
                    btn.addEventListener('click', function () {
                        const tab = this.dataset.tab;

                        document.querySelectorAll('.tabBtn').forEach(b => b.classList.remove('active'));
                        this.classList.add('active');

                        document.querySelectorAll('.tabPanel').forEach(p => p.classList.remove('active'));
                        document.getElementById('tab-' + tab).classList.add('active');
                    });
                });

                // default 1 line
                addRow();
            })();
        </script>

    </body>
</html>
