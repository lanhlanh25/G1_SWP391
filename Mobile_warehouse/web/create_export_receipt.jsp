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
            .imeiRow select{
                flex:1;
                min-width:200px;
                padding:4px 6px;
                font-size:12px;
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

                <c:if test="${not empty param.err}">
                    <div class="err">${fn:escapeXml(param.err)}</div>
                </c:if>
                <c:if test="${not empty param.msg}">
                    <div class="ok">${fn:escapeXml(param.msg)}</div>
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
                            <b>Excel Format:</b> 4 columns:
                            <b>product_code</b>, <b>sku_code</b>, <b>imei</b> (15 digits), <b>item_note</b> (optional)
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
                const PRODUCTS = [
            <c:forEach var="p" items="${products}" varStatus="st">
                { id: ${p.productId}, code: "${fn:escapeXml(p.productCode)}" }<c:if test="${!st.last}">,</c:if>
            </c:forEach>
                ];

                const SKUS = [
            <c:forEach var="k" items="${skus}" varStatus="st">
                { id: ${k.skuId}, code: "${fn:escapeXml(k.skuCode)}", productId: ${k.productId} }<c:if test="${!st.last}">,</c:if>
            </c:forEach>
                ];

                const tbody = document.getElementById("itemsTbody");
                const manualForm = document.getElementById("manualForm");
                let rowCounter = 0;

                async function fetchImeisBySku(skuId) {
                    try {
                        const res = await fetch("${ctx}/api/available-imeis?skuId=" + encodeURIComponent(skuId));
                        if (!res.ok)
                            return [];
                        const data = await res.json();
                        return Array.isArray(data) ? data : [];
                    } catch (e) {
                        return [];
                    }
                }

                function buildProductSelect() {
                    const sel = document.createElement("select");
                    sel.required = true;
                    sel.innerHTML = '<option value="">-- Select Product Code --</option>';
                    PRODUCTS.forEach(p => {
                        sel.innerHTML += '<option value="' + p.id + '">' + p.code + '</option>';
                    });
                    return sel;
                }

                function buildSkuSelect() {
                    const sel = document.createElement("select");
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

                function buildImeiBox(rowIdx, qty, imeiOptions) {
                    const box = document.createElement("div");
                    box.className = "imeiBox";

                    for (let i = 1; i <= qty; i++) {
                        const row = document.createElement("div");
                        row.className = "imeiRow";

                        const label = document.createElement("span");
                        label.textContent = "Imei " + i + ":";

                        const sel = document.createElement("select");
                        sel.name = "imei_" + rowIdx + "_" + i;
                        sel.required = true;

                        sel.innerHTML = '<option value="">-- Select IMEI --</option>';
                        sel.addEventListener("change", syncImeiDisabledOptions);
                        (imeiOptions || []).forEach(v => {
                            const opt = document.createElement("option");
                            opt.value = v;
                            opt.textContent = v;
                            sel.appendChild(opt);
                        });

                        row.appendChild(label);
                        row.appendChild(sel);
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
                    selProd.name = "productId_" + rowIdx;
                    tdProd.appendChild(selProd);

                    const tdSku = document.createElement("td");
                    const selSku = buildSkuSelect();
                    selSku.name = "skuId_" + rowIdx;
                    tdSku.appendChild(selSku);

                    const hidden = document.createElement("input");
                    hidden.type = "hidden";
                    hidden.name = "rowKey";
                    hidden.value = String(rowIdx);
                    tr.appendChild(hidden);

                    const tdQty = document.createElement("td");
                    const qtyInp = document.createElement("input");
                    qtyInp.type = "number";
                    qtyInp.min = "1";
                    qtyInp.value = "1";
                    qtyInp.required = true;
                    qtyInp.name = "qty_" + rowIdx;
                    tdQty.appendChild(qtyInp);

                    const tdImei = document.createElement("td");
                    let currentImeiOptions = [];
                    let imeiBox = buildImeiBox(rowIdx, 1, currentImeiOptions);
                    tdImei.appendChild(imeiBox);
                    syncImeiDisabledOptions();

                    const tdNote = document.createElement("td");
                    const noteInp = document.createElement("input");
                    noteInp.type = "text";
                    noteInp.name = "itemNote_" + rowIdx;
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
                    tdAct.appendChild(delBtn);

                    selProd.addEventListener("change", function () {
                        refreshSkuOptions(selSku, this.value);
                        // reset IMEI when product changes
                        currentImeiOptions = [];
                        tdImei.innerHTML = "";
                        imeiBox = buildImeiBox(rowIdx, parseInt(qtyInp.value) || 1, currentImeiOptions);
                        tdImei.appendChild(imeiBox);
                        syncImeiDisabledOptions();
                    });

                    selSku.addEventListener("change", async function () {
                        const skuId = this.value;
                        currentImeiOptions = skuId ? await fetchImeisBySku(skuId) : [];

                        tdImei.innerHTML = "";
                        imeiBox = buildImeiBox(rowIdx, parseInt(qtyInp.value) || 1, currentImeiOptions);
                        tdImei.appendChild(imeiBox);
                        syncImeiDisabledOptions();

                        if (skuId && currentImeiOptions.length === 0) {
                            alert("No available IMEIs in stock for this SKU.");
                        }
                    });

                    qtyInp.addEventListener("input", function () {
                        let q = parseInt(this.value) || 1;
                        if (q < 1)
                            q = 1;
                        this.value = q;

                        tdImei.innerHTML = "";
                        imeiBox = buildImeiBox(rowIdx, q, currentImeiOptions);
                        tdImei.appendChild(imeiBox);
                        syncImeiDisabledOptions();
                    });

                    tr.appendChild(tdNo);
                    tr.appendChild(tdProd);
                    tr.appendChild(tdSku);
                    tr.appendChild(tdQty);
                    tr.appendChild(tdImei);
                    tr.appendChild(tdNote);
                    tr.appendChild(tdAct);

                    tbody.appendChild(tr);
                }

                function getSelectedImeisBySku() {
                    const map = new Map();

                    Array.from(tbody.children).forEach(tr => {
                        const rowIdx = tr.dataset.rowIdx;
                        const skuSel = tr.querySelector(`select[name="skuId_${rowIdx}"]`);
                        const skuId = skuSel ? skuSel.value : "";
                        if (!skuId)
                            return;

                        const selects = tr.querySelectorAll(`select[name^="imei_${rowIdx}_"]`);
                        selects.forEach(s => {
                            const v = (s.value || "").trim();
                            if (!v)
                                return;
                            if (!map.has(skuId))
                                map.set(skuId, new Set());
                            map.get(skuId).add(v);
                        });
                    });

                    return map;
                }

                function syncImeiDisabledOptions() {
    const selectedMap = getSelectedImeisBySku();

    // helper: đếm IMEI đang được chọn bao nhiêu lần trong cùng SKU
    function countSelectedInSku(skuId, imeiVal) {
        let count = 0;
        Array.from(tbody.children).forEach(tr2 => {
            const rowIdx2 = tr2.dataset.rowIdx;
            const skuSel2 = tr2.querySelector(`select[name="skuId_${rowIdx2}"]`);
            const skuId2 = skuSel2 ? skuSel2.value : "";
            if (skuId2 !== skuId) return;

            const s2 = tr2.querySelectorAll(`select[name^="imei_${rowIdx2}_"]`);
            s2.forEach(x => {
                if ((x.value || "").trim() === imeiVal) count++;
            });
        });
        return count;
    }

    Array.from(tbody.children).forEach(tr => {
        const rowIdx = tr.dataset.rowIdx;
        const skuSel = tr.querySelector(`select[name="skuId_${rowIdx}"]`);
        const skuId = skuSel ? skuSel.value : "";
        if (!skuId) return;

        const chosen = selectedMap.get(skuId) || new Set();
        const selects = tr.querySelectorAll(`select[name^="imei_${rowIdx}_"]`);

        selects.forEach(sel => {
            const myVal = (sel.value || "").trim();

            // 1) Ẩn option đã được chọn ở dropdown khác (cùng SKU)
            Array.from(sel.options).forEach(opt => {
                if (!opt.value) return; // placeholder
                // Ẩn nếu option nằm trong chosen và không phải option đang được chọn của chính select này
                opt.hidden = (chosen.has(opt.value) && opt.value !== myVal);
                opt.disabled = false; // đảm bảo không bị xám (tuỳ bạn)
            });

            // 2) Nếu select hiện tại đang trùng (cùng SKU) -> reset về rỗng
            if (myVal && countSelectedInSku(skuId, myVal) > 1) {
                sel.value = "";
            }

            // 3) Sau khi reset, cần chạy lại hide ngay lập tức để UI sạch
            // (không bắt buộc nhưng giúp nhất quán)
            const newVal = (sel.value || "").trim();
            Array.from(sel.options).forEach(opt => {
                if (!opt.value) return;
                opt.hidden = (chosen.has(opt.value) && opt.value !== newVal);
            });
        });
    });
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
                        const rowIdx = row.dataset.rowIdx;

                        const productSelect = row.querySelector('select[name="productId_' + rowIdx + '"]');
                        const skuSelect = row.querySelector('select[name="skuId_' + rowIdx + '"]');
                        const qtyInput = row.querySelector('input[name="qty_' + rowIdx + '"]');

                        const productId = productSelect ? productSelect.value : "";
                        const skuId = skuSelect ? skuSelect.value : "";
                        const qty = qtyInput ? (parseInt(qtyInput.value) || 0) : 0;

                        if (!productId || !skuId || qty < 1) {
                            e.preventDefault();
                            alert("Row " + (i + 1) + ": Please fill Product Code, SKU and Quantity");
                            return;
                        }

                        // validate IMEI dropdown selected
                        const imeiSet = new Set();
                        for (let j = 1; j <= qty; j++) {
                            const sel = row.querySelector('select[name="imei_' + rowIdx + '_' + j + '"]');
                            const v = sel ? (sel.value || "").trim() : "";
                            if (!v) {
                                e.preventDefault();
                                alert("Row " + (i + 1) + ", IMEI " + j + ": Please select an IMEI");
                                return;
                            }
                            if (imeiSet.has(v)) {
                                e.preventDefault();
                                alert("Row " + (i + 1) + ": Duplicate IMEI selected: " + v);
                                return;
                            }
                            imeiSet.add(v);
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
