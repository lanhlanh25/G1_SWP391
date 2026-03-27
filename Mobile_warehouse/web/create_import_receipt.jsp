<%-- Document : create_import_receipt --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- Internal styles moved to app.css --%>

<div class="container-xxl flex-grow-1">
    <div class="row">
        <div class="col-12">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${ctx}/home?p=dashboard">Home</a></li>
                    <li class="breadcrumb-item"><a href="${ctx}/home?p=import-receipt-list">Import Receipts</a></li>
                    <li class="breadcrumb-item active">Create Receipt</li>
                </ol>
            </nav>

            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bx bx-plus-circle me-1"></i> Create Import Receipt</h5>
                    <c:choose>
                        <c:when test="${not empty requestId}">
                            <a class="btn btn-outline-secondary btn-sm" href="${ctx}/home?p=import-request-list">
                                <i class="bx bx-arrow-back me-1"></i> Back to List
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-outline-secondary btn-sm" href="${ctx}/home?p=dashboard">
                                <i class="bx bx-arrow-back me-1"></i> Back to Dashboard
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="card-body">
                    <%-- Source request banner --%>
                    <c:if test="${not empty irHeader}">
                        <div class="alert alert-primary d-flex align-items-center mb-4" role="alert">
                            <i class="bx bx-info-circle me-2"></i>
                            <div>
                                <strong>Source Request:</strong> <c:out value="${irHeader.requestCode}" /> 
                                <span class="mx-2">|</span> 
                                <strong>Status:</strong> <span class="badge bg-label-primary">${irHeader.status}</span>
                                <span class="mx-2">|</span>
                                <strong>Expected:</strong> <c:out value="${irHeader.expectedImportDate}" />
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${not empty err}">
                        <div class="alert alert-danger alert-dismissible" role="alert">
                            ${fn:escapeXml(err)}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty msg}">
                        <div class="alert alert-success alert-dismissible" role="alert">
                            ${fn:escapeXml(msg)}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:set var="isExcel" value="${mode == 'excel'}" />

                    <div class="nav-align-top mb-4">
                        <ul class="nav nav-tabs" role="tablist">
                            <li class="nav-item">
                                <button type="button" class="nav-link ${isExcel ? '' : 'active'}" role="tab" data-bs-toggle="tab" data-bs-target="#tab-manual" aria-controls="tab-manual" aria-selected="${!isExcel}">
                                    <i class="tf-icons bx bx-edit-alt me-1"></i> Manual Entry
                                </button>
                            </li>
                            <c:if test="${empty requestId}">
                                <li class="nav-item">
                                    <button type="button" class="nav-link ${isExcel ? 'active' : ''}" role="tab" data-bs-toggle="tab" data-bs-target="#tab-excel" aria-controls="tab-excel" aria-selected="${isExcel}">
                                        <i class="tf-icons bx bx-file-blank me-1"></i> Upload Excel
                                    </button>
                                </li>
                            </c:if>
                        </ul>

                        <div class="tab-content px-0 pb-0 shadow-none border-0">
                            <!-- ===================== TAB: MANUAL ===================== -->
                            <div class="tab-pane fade ${isExcel ? '' : 'show active'}" id="tab-manual" role="tabpanel">
                                <form id="manualForm" method="post" action="${ctx}/create-import-receipt">
                                    <input type="hidden" name="mode" value="manual" />
                                    <c:if test="${not empty requestId}">
                                        <input type="hidden" name="requestId" value="${requestId}" />
                                    </c:if>

                                    <div class="row g-3 mb-4">
                                        <div class="col-md-3">
                                            <label class="form-label" for="importCode">Import Code</label>
                                            <input type="text" class="form-control" id="importCode" name="importCode" value="${fn:escapeXml(importCode)}" readonly />
                                            <div class="form-text">System generated</div>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label" for="receiptDate">Transaction Time <span class="text-danger">*</span></label>
                                            <input type="datetime-local" class="form-control" id="receiptDate" name="receiptDate" value="${fn:escapeXml(receiptDateDefault)}" required />
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label" for="supplierId">Supplier <span class="text-danger">*</span></label>
                                            <select class="form-select" id="supplierId" name="supplierId" required>
                                                <option value="" selected disabled>-- Select Supplier --</option>
                                                <c:forEach var="s" items="${suppliers}">
                                                    <option value="${s.id}">${fn:escapeXml(s.name)}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label">Created By</label>
                                            <input type="text" class="form-control" value="${fn:escapeXml(createdByName)}" readonly />
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label" for="note">Note</label>
                                            <textarea class="form-control" id="note" name="note" rows="2" placeholder="Optional notes..."></textarea>
                                        </div>
                                    </div>

                                    <div class="divider text-start">
                                        <div class="divider-text fw-bold text-primary">IMPORT ITEMS</div>
                                    </div>

                                    <div class="table-responsive text-nowrap mb-3 border rounded">
                                        <table class="table table-sm table-hover" id="itemsTable">
                                            <thead class="table-light">
                                                <tr>
                                                    <th style="width:20px" class="text-center">#</th>
                                                    <th style="width:180px">Product</th>
                                                    <th style="width:120px">Code</th>
                                                    <th style="width:250px">SKU</th>
                                                    <th style="width:120px" class="text-center">Qty</th>
                                                    <th style="width:300px">IMEI Details</th>
                                                    <th style="width:250px">Note</th>
                                                    <th style="width:20px" class="text-center">Delete</th>
                                                </tr>
                                            </thead>
                                            <tbody id="itemsTbody"></tbody>
                                        </table>
                                    </div>

                                    <div class="mb-4">
                                        <button type="button" class="btn btn-outline-primary btn-sm" id="btnAddRow">
                                            <i class="bx bx-plus me-1"></i> Add Product
                                        </button>
                                    </div>

                                    <div class="pt-2">
                                        <button type="submit" class="btn btn-primary">Save Receipt</button>
                                        <c:choose>
                                            <c:when test="${not empty requestId}">
                                                <a class="btn btn-outline-secondary ms-2" href="${ctx}/home?p=import-request-list">Cancel</a>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="btn btn-outline-secondary ms-2" href="${ctx}/home?p=import-receipt-list">Cancel</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </form>
                            </div>

                            <!-- ===================== TAB: EXCEL ===================== -->
                            <c:if test="${empty requestId}">
                                <div class="tab-pane fade ${isExcel ? 'show active' : ''}" id="tab-excel" role="tabpanel">
                                    <form method="post" action="${ctx}/create-import-receipt" enctype="multipart/form-data">
                                        <input type="hidden" name="mode" value="excel" />
                                        <input type="hidden" name="importCode" value="${fn:escapeXml(importCode)}" />

                                        <div class="alert alert-info border-info mb-4" role="alert">
                                            <h6 class="alert-heading fw-bold mb-1">Excel Format</h6>
                                            <p class="mb-0 small">
                                                Please upload a <strong>.xlsx</strong> file with columns:
                                                <code>product_code</code>, <code>sku_code</code>, <code>imei</code> (15 digits).
                                            </p>
                                        </div>

                                        <div class="row g-3 mb-4">
                                            <div class="col-md-3">
                                                <label class="form-label" for="importCodeExcel">Import Code</label>
                                                <input type="text"
                                                       class="form-control"
                                                       id="importCodeExcel"
                                                       name="importCode"
                                                       value="${fn:escapeXml(importCode)}"
                                                       readonly />
                                                <div class="form-text">System generated</div>
                                            </div>

                                            <div class="col-md-3">
                                                <label class="form-label" for="excelFile">Excel File (.xlsx) <span class="text-danger">*</span></label>
                                                <input type="file" class="form-control" id="excelFile" name="excelFile" accept=".xlsx" required />
                                            </div>

                                            <div class="col-md-3">
                                                <label class="form-label" for="receiptDateExcel">Transaction Time <span class="text-danger">*</span></label>
                                                <input type="datetime-local"
                                                       class="form-control"
                                                       id="receiptDateExcel"
                                                       name="receiptDate"
                                                       value="${fn:escapeXml(receiptDateDefault)}"
                                                       required />
                                            </div>

                                            <div class="col-md-3">
                                                <label class="form-label" for="supplierIdExcel">Supplier <span class="text-danger">*</span></label>
                                                <select class="form-select" id="supplierIdExcel" name="supplierId" required>
                                                    <option value="" selected disabled>-- Select Supplier --</option>
                                                    <c:forEach var="s" items="${suppliers}">
                                                        <option value="${s.id}">${fn:escapeXml(s.name)}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>

                                            <div class="col-12">
                                                <label class="form-label" for="noteExcel">Note</label>
                                                <textarea class="form-control" id="noteExcel" name="note" rows="2" placeholder="Notes..."></textarea>
                                            </div>
                                        </div>

                                        <div class="pt-2">
                                            <button type="submit" class="btn btn-primary">Import with Excel</button>
                                            <a class="btn btn-outline-secondary ms-2" href="${ctx}/home?p=import-receipt-list">Cancel</a>
                                        </div>
                                    </form>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    (function () {
    // PRODUCTS: id, code, name
    const PRODUCTS = [
    <c:forEach var="p" items="${products}" varStatus="st">
    { id: "${p.productId}", code: "${fn:escapeXml(p.productCode)}", name: "${fn:escapeXml(p.productName)}" }${!st.last ? ',' : ''}
    </c:forEach>
    ];
            const SKUS = [
    <c:forEach var="k" items="${skus}" varStatus="st">
            { id: "${k.skuId}", code: "${fn:escapeXml(k.skuCode)}", productId: "${k.productId}" }${!st.last ? ',' : ''}
    </c:forEach>
            ];
            // Pre-filled rows from import request (empty array = manual mode)
            const REQUEST_ITEMS = [
    <c:forEach var="it" items="${requestItems}" varStatus="st">
            {
            productId: "${it.productId}",
                    productCode: "${fn:escapeXml(it.productCode)}",
                    productName: "${fn:escapeXml(it.productName)}",
                    skuId: "${it.skuId}",
                    skuCode: "${fn:escapeXml(it.skuCode)}",
                    qty: ${it.requestQty}
            }${!st.last ? ',' : ''}
    </c:forEach>
            ];
            const IS_REQUEST_MODE = REQUEST_ITEMS.length > 0;
                    const CREATED_BY = "${fn:escapeXml(createdByName)}";
            const tbody = document.getElementById("itemsTbody");
            const manualForm = document.getElementById("manualForm");
            let rowCounter = 0;
            function buildProductNameCell(prefill) {
            if (IS_REQUEST_MODE && prefill) {
            // Readonly display
            const inp = document.createElement("input");
                    inp.type = "text";
                    inp.className = "form-control bg-light";
                    inp.value = prefill.productName;
                    inp.readOnly = true;
                    return inp;
            }
            const sel = document.createElement("select");
                    sel.className = "form-select form-select-sm";
                    sel.required = true;
                    sel.style.width = "100%";
                    const defOpt = document.createElement("option");
                    defOpt.value = "";
                    defOpt.textContent = "-- Select Product --";
                    defOpt.disabled = true;
                    defOpt.selected = true;
                    sel.appendChild(defOpt);
                    PRODUCTS.forEach(p => {
                    const opt = document.createElement("option");
                            opt.value = p.id;
                            opt.textContent = p.name;
                            opt.dataset.code = p.code;
                            sel.appendChild(opt);
                    });
                    return sel;
            }

    function buildProductIdInput(prefillId) {
    const inp = document.createElement("input");
            inp.type = "hidden";
            inp.name = "productId";
            if (prefillId) inp.value = prefillId;
            return inp;
    }

    function buildCodeDisplay(prefillCode) {
    const div = document.createElement("div");
            div.className = "form-control form-control-sm bg-light text-muted fw-bold";
            div.style.minHeight = "31px";
            div.textContent = prefillCode || "—";
            return div;
    }

    function buildSkuCell(prefill) {
    if (IS_REQUEST_MODE && prefill) {
    // Readonly + hidden skuId
    const wrap = document.createElement("div");
            const hidSku = document.createElement("input");
            hidSku.type = "hidden";
            hidSku.name = "skuId";
            hidSku.value = prefill.skuId;
            const inp = document.createElement("input");
            inp.type = "text";
            inp.className = "form-control form-control-sm bg-light";
            inp.value = prefill.skuCode;
            inp.readOnly = true;
            wrap.appendChild(hidSku);
            wrap.appendChild(inp);
            return wrap;
    }
    const sel = document.createElement("select");
            sel.className = "form-select form-select-sm";
            sel.name = "skuId";
            sel.required = true;
            sel.style.width = "100%";
            const defOpt = document.createElement("option");
            defOpt.value = "";
            defOpt.textContent = "-- SKU --";
            sel.appendChild(defOpt);
            return sel;
    }

    function refreshSkuOptions(skuSelect, productId) {
    skuSelect.innerHTML = "";
            const defOpt = document.createElement("option");
            defOpt.value = "";
            defOpt.textContent = "-- Select SKU --";
            skuSelect.appendChild(defOpt);
            if (!productId) return;
            SKUS.filter(s => String(s.productId) === String(productId))
            .forEach(s => {
            const opt = document.createElement("option");
                    opt.value = s.id;
                    opt.textContent = s.code;
                    skuSelect.appendChild(opt);
            });
    }

    function buildImeiBox(rowIdx, qty) {
    const box = document.createElement("div");
            box.className = "d-flex flex-column gap-1 py-1";
            for (let i = 1; i <= qty; i++) {
    const row = document.createElement("div");
            row.className = "input-group input-group-sm";
            const label = document.createElement("span");
            label.className = "input-group-text py-0 px-2 small";
            label.textContent = "IMEI " + i;
            const input = document.createElement("input");
            input.type = "text";
            input.name = "imei_" + rowIdx + "_" + i;
            input.placeholder = "15 digits";
            input.required = true;
            input.maxLength = 15;
            input.className = "form-control form-control-sm";
            input.addEventListener("input", function () {
            this.value = this.value.replace(/\D/g, "").slice(0, 15);
                    if (this.value.length === 15) {
            this.classList.add("is-valid"); this.classList.remove("is-invalid");
            } else if (this.value.length > 0) {
            this.classList.add("is-invalid"); this.classList.remove("is-valid");
            } else {
            this.classList.remove("is-valid", "is-invalid");
            }
            });
            row.appendChild(label);
            row.appendChild(input);
            box.appendChild(row);
    }
    return box;
    }

    function addRow(prefill) {
    rowCounter++;
            const rowIdx = rowCounter;
            const isLocked = !!prefill && IS_FROM_REQUEST;
            const tr = document.createElement("tr");
            tr.dataset.rowIdx = rowIdx;
            const hiddenRowKey = document.createElement("input");
            hiddenRowKey.type = "hidden";
            hiddenRowKey.name = "rowKey";
            hiddenRowKey.value = String(rowIdx);
            tr.appendChild(hiddenRowKey);
            // ===== No =====
            const tdNo = document.createElement("td");
            tdNo.className = "center cellNo";
            tdNo.textContent = tbody.children.length + 1;
            // ===== Product Name =====
            const tdProdName = document.createElement("td");
            const selProd = buildProductNameSelect();
            selProd.name = "productId_" + rowIdx;
            // ===== Product Code =====
            const tdProdCode = document.createElement("td");
            const productCodeBox = buildProductCodeDisplay("");
            // ===== SKU =====
            const tdSku = document.createElement("td");
            const selSku = buildSkuSelect();
            selSku.name = "skuId_" + rowIdx;
            selSku.disabled = true;
            // ===== Qty - rewritten same style as import =====
            const tdQty = document.createElement("td");
            tdQty.className = "text-center align-middle";
            const qtyInp = document.createElement("input");
            qtyInp.type = "number";
            qtyInp.name = "qty_" + rowIdx;
            qtyInp.min = "1";
            qtyInp.step = "1";
            qtyInp.required = true;
            qtyInp.value = prefill ? prefill.qty : "1";
            qtyInp.className = "form-control form-control-sm text-center";
            qtyInp.style.width = "80px";
            qtyInp.style.margin = "0 auto";
            // ===== IMEI =====
            const tdImei = document.createElement("td");
            let currentImeiOptions = [];
            let imeiBox = buildImeiBox(rowIdx, parseInt(qtyInp.value, 10) || 1, currentImeiOptions);
            tdImei.appendChild(imeiBox);
            // ===== Note =====
            const tdNote = document.createElement("td");
            const noteInp = document.createElement("input");
            noteInp.type = "text";
            noteInp.name = "itemNote_" + rowIdx;
            noteInp.placeholder = "Notes";
            noteInp.className = "form-control form-control-sm";
            tdNote.appendChild(noteInp);
            // ===== Action =====
            const tdAct = document.createElement("td");
            tdAct.className = "center";
            const delBtn = document.createElement("button");
            delBtn.type = "button";
            delBtn.className = "btn btn-danger btn-sm";
            delBtn.textContent = "Delete";
            delBtn.addEventListener("click", function () {
            tr.remove();
                    renumber();
                    syncImeiDisabledOptions();
            });
            // ===== Prefill request/manual =====
            if (prefill) {
    let matchedProduct = null;
            if (prefill.productId) {
    matchedProduct = PRODUCTS.find(p => String(p.id) === String(prefill.productId));
    }
    if (!matchedProduct && prefill.productCode) {
    matchedProduct = PRODUCTS.find(p => p.code === prefill.productCode);
    }

    if (matchedProduct) {
    selProd.value = String(matchedProduct.id);
            productCodeBox.textContent = matchedProduct.code || "—";
            refreshSkuOptions(selSku, matchedProduct.id);
            selSku.disabled = false;
            let matchedSku = null;
            if (prefill.skuId) {
    matchedSku = SKUS.find(s => String(s.id) === String(prefill.skuId));
    }
    if (!matchedSku && prefill.skuCode) {
    matchedSku = SKUS.find(s =>
            String(s.productId) === String(matchedProduct.id) &&
            s.code === prefill.skuCode
            );
    }

    if (matchedSku) {
    selSku.value = String(matchedSku.id);
    }
    }

    qtyInp.value = prefill.qty || 1;
            if (prefill.itemNote) {
    noteInp.value = prefill.itemNote;
    }
    }

    // ===== Locked mode from request =====
    if (isLocked) {
    const hiddenProd = document.createElement("input");
            hiddenProd.type = "hidden";
            hiddenProd.name = "productId_" + rowIdx;
            hiddenProd.value = selProd.value;
            const hiddenSku = document.createElement("input");
            hiddenSku.type = "hidden";
            hiddenSku.name = "skuId_" + rowIdx;
            hiddenSku.value = selSku.value;
            const hiddenQty = document.createElement("input");
            hiddenQty.type = "hidden";
            hiddenQty.name = "qty_" + rowIdx;
            hiddenQty.value = qtyInp.value;
            selProd.disabled = true;
            selSku.disabled = true;
            qtyInp.readOnly = true;
            qtyInp.classList.add("bg-light");
            tdProdName.appendChild(selProd);
            tdProdName.appendChild(hiddenProd);
            tdProdCode.appendChild(productCodeBox);
            tdSku.appendChild(selSku);
            tdSku.appendChild(hiddenSku);
            tdQty.appendChild(qtyInp);
            tdQty.appendChild(hiddenQty);
            tdAct.textContent = "-";
    } else {
    tdProdName.appendChild(selProd);
            tdProdCode.appendChild(productCodeBox);
            tdSku.appendChild(selSku);
            tdQty.appendChild(qtyInp);
            tdAct.appendChild(delBtn);
            // Product change -> refresh code + sku + imei box
            selProd.addEventListener("change", function () {
            const selectedOpt = this.options[this.selectedIndex];
                    const productId = this.value;
                    productCodeBox.textContent =
                    selectedOpt && selectedOpt.dataset.code
                    ? selectedOpt.dataset.code
                    : "—";
                    refreshSkuOptions(selSku, productId);
                    selSku.disabled = !productId;
                    selSku.value = "";
                    currentImeiOptions = [];
                    tdImei.innerHTML = "";
                    imeiBox = buildImeiBox(rowIdx, parseInt(qtyInp.value, 10) || 1, currentImeiOptions);
                    tdImei.appendChild(imeiBox);
                    syncImeiDisabledOptions();
            });
            // SKU change -> load available imeis
            selSku.addEventListener("change", async function () {
            const skuId = this.value;
                    currentImeiOptions = skuId ? await fetchImeisBySku(skuId) : [];
                    tdImei.innerHTML = "";
                    imeiBox = buildImeiBox(rowIdx, parseInt(qtyInp.value, 10) || 1, currentImeiOptions);
                    tdImei.appendChild(imeiBox);
                    syncImeiDisabledOptions();
                    if (skuId && currentImeiOptions.length === 0) {
            alert("No available IMEIs in stock for this SKU.");
            }
            });
            // Qty change -> same behavior as import: rebuild imei inputs
            qtyInp.addEventListener("change", function () {
            let q = parseInt(this.value, 10);
                    if (isNaN(q) || q < 1) {
            q = 1;
                    this.value = "1";
            }

            tdImei.innerHTML = "";
                    imeiBox = buildImeiBox(rowIdx, q, currentImeiOptions);
                    tdImei.appendChild(imeiBox);
                    syncImeiDisabledOptions();
            });
            qtyInp.addEventListener("input", function () {
            let q = parseInt(this.value, 10);
                    if (isNaN(q) || q < 1) {
            this.value = "1";
            }
            });
    }

    if (prefill && selSku.value) {
    loadImeisForLockedOrPrefillRow(selSku.value, rowIdx, qtyInp, tdImei);
    } else {
    syncImeiDisabledOptions();
    }

    tr.appendChild(tdNo);
            tr.appendChild(tdProdName);
            tr.appendChild(tdProdCode);
            tr.appendChild(tdSku);
            tr.appendChild(tdQty);
            tr.appendChild(tdImei);
            tr.appendChild(tdNote);
            tr.appendChild(tdAct);
            tbody.appendChild(tr);
            }

    // "+ Add Product Line" button — only visible in manual mode
    const btnAddRow = document.getElementById("btnAddRow");
            if (IS_REQUEST_MODE) {
    btnAddRow.style.display = "none";
    } else {
    btnAddRow.addEventListener("click", () => addRow(null));
    }

    manualForm.addEventListener("submit", function (e) {
    if (tbody.children.length === 0) {
    e.preventDefault();
            alert("Please add at least 1 product line.");
    }
    });
            // Tabs handled by Bootstrap data-bs-toggle

            // Initialize rows
            if (IS_REQUEST_MODE) {
    REQUEST_ITEMS.forEach(item => addRow(item));
    } else {
    addRow(null);
    }
    })();
</script>