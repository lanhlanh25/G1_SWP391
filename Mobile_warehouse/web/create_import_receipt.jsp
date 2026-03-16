<%-- Document : create_import_receipt --%>
  <%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
      <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <style>
          .ir-wrap {
            padding: 24px;
            background: transparent;
          }

          .ir-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 24px;
          }

          .ir-header {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 20px;
          }

          .ir-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text);
          }

          .ir-err {
            border: 1px solid #f5c6cb;
            background: #fdf0f0;
            border-radius: var(--radius-sm);
            padding: 10px 14px;
            margin: 0 0 16px;
            color: #b91c1c;
            font-size: 13px;
            font-weight: 600;
          }

          .ir-ok {
            border: 1px solid #b5e8c5;
            background: #e6f9ed;
            border-radius: var(--radius-sm);
            padding: 10px 14px;
            margin: 0 0 16px;
            color: #0d6832;
            font-size: 13px;
            font-weight: 600;
          }

          .ir-section-title {
            font-size: 13px;
            font-weight: 700;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: .08em;
            margin: 20px 0 10px;
          }

          .ir-row {
            display: flex;
            gap: 12px;
            margin-bottom: 12px;
            align-items: flex-start;
          }

          .ir-row label {
            min-width: 150px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-2);
            padding-top: 8px;
          }

          .ir-col {
            flex: 1;
          }

          .ir-hint {
            font-size: 11.5px;
            color: var(--muted);
            margin-top: 4px;
          }

          .ir-wrap input[type="text"],
          .ir-wrap input[type="number"],
          .ir-wrap input[type="datetime-local"],
          .ir-wrap select,
          .ir-wrap textarea {
            width: 100%;
            padding: 7px 12px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 13px;
            font-family: inherit;
            color: var(--text);
            background: var(--surface);
            box-sizing: border-box;
            transition: border-color .15s;
          }

          .ir-wrap input:focus,
          .ir-wrap select:focus,
          .ir-wrap textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(50, 31, 219, .12);
          }

          .ir-wrap input[readonly] {
            background: var(--surface-2);
            color: var(--muted);
          }

          .ir-wrap textarea {
            height: 72px;
            resize: vertical;
          }

          .ir-tabs {
            display: flex;
            gap: 8px;
            margin-bottom: 20px;
            border-bottom: 2px solid var(--border);
            padding-bottom: 0;
          }

          .ir-tab-btn {
            padding: 8px 18px;
            border: none;
            background: none;
            font-size: 13px;
            font-weight: 600;
            color: var(--muted);
            cursor: pointer;
            border-bottom: 2px solid transparent;
            margin-bottom: -2px;
            border-radius: 0;
            transition: color .15s, border-color .15s;
          }

          .ir-tab-btn.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
          }

          .ir-tab-panel {
            display: none;
          }

          .ir-tab-panel.active {
            display: block;
          }

          .ir-table {
            border-collapse: separate;
            border-spacing: 0;
            width: 100%;
            table-layout: fixed;
            font-size: 13px;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
          }

          .ir-table th,
          .ir-table td {
            border-bottom: 1px solid var(--border);
            padding: 8px 10px;
            vertical-align: top;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          .ir-table th {
            background: var(--surface-2);
            font-weight: 600;
            color: var(--text-2);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .03em;
            white-space: nowrap;
          }

          .ir-table tbody tr:last-child td {
            border-bottom: none;
          }

          .ir-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 16px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            background: var(--surface);
            font-size: 13px;
            font-weight: 600;
            color: var(--text-2);
            cursor: pointer;
            text-decoration: none;
            transition: all .15s;
          }

          .ir-btn:hover {
            background: var(--surface-2);
            text-decoration: none;
          }

          .ir-btn.primary {
            background: var(--primary);
            border-color: var(--primary);
            color: #fff;
          }

          .ir-btn.primary:hover {
            background: var(--primary-2);
          }

          .ir-btn.danger {
            background: #fdf0f0;
            border-color: #f5c6cb;
            color: #b91c1c;
          }

          .ir-btn.danger:hover {
            background: #f8d7da;
          }

          .ir-btn-row {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            align-items: center;
            flex-wrap: wrap;
          }

          .ir-hint-box {
            background: var(--primary-light);
            border: 1px solid var(--primary-border);
            border-radius: var(--radius-sm);
            padding: 10px 14px;
            font-size: 12.5px;
            color: var(--text-2);
            margin-bottom: 16px;
          }

          td.ir-imei-cell {
            overflow: auto;
          }

          .ir-imei-box {
            display: flex;
            flex-direction: column;
            gap: 5px;
            min-width: 200px;
          }

          .ir-imei-row {
            display: flex;
            gap: 6px;
            align-items: center;
          }

          .ir-imei-row span {
            min-width: 52px;
            font-size: 11.5px;
            color: var(--muted);
            white-space: nowrap;
            font-weight: 600;
          }

          .ir-imei-row input {
            flex: 1;
            min-width: 140px;
            padding: 5px 8px !important;
            font-size: 12px !important;
          }

          .ir-imei-row input.valid {
            border-color: #2eb85c !important;
            background: #e6f9ed !important;
          }

          .ir-imei-row input.invalid {
            border-color: #e55353 !important;
            background: #fdf0f0 !important;
          }

          .center {
            text-align: center;
          }

          .ir-code-display {
            padding: 7px 12px;
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 13px;
            color: var(--muted);
            min-height: 36px;
            display: flex;
            align-items: center;
            font-weight: 600;
          }
        </style>

        <div class="ir-wrap">
          <div class="ir-card">

            <div class="ir-header">
              <c:choose>
                <c:when test="${not empty requestId}">
                  <a class="ir-btn" href="${ctx}/home?p=import-request-list">← Back</a>
                </c:when>
                <c:otherwise>
                  <a class="ir-btn" href="${ctx}/home?p=dashboard">← Back</a>
                </c:otherwise>
              </c:choose>
              <div class="ir-title">Create Import Receipt</div>
            </div>

            <%-- Source request banner --%>
              <c:if test="${not empty irHeader}">
                <div style="background:#eff6ff; border:1px solid #bfdbfe; border-radius:10px;
                  padding:10px 16px; margin-bottom:16px; font-size:13px; color:#1e40af;">
                  <b>Source Request:</b>
                  <c:out value="${irHeader.requestCode}" />
                  &nbsp;|&nbsp;
                  <b>Status:</b>
                  <c:out value="${irHeader.status}" />
                  &nbsp;|&nbsp;
                  <b>Expected Import Date:</b>
                  <c:out value="${irHeader.expectedImportDate}" />
                </div>
              </c:if>

              <c:if test="${not empty err}">
                <div class="ir-err">${fn:escapeXml(err)}</div>
              </c:if>
              <c:if test="${not empty msg}">
                <div class="ir-ok">${fn:escapeXml(msg)}</div>
              </c:if>

              <c:set var="isExcel" value="${mode == 'excel'}" />

              <%-- Hide mode tabs when coming from a request --%>
                <c:if test="${empty requestId}">
                  <div class="ir-tabs">
                    <button type="button" class="ir-tab-btn ${isExcel ? '' : 'active'}" data-tab="manual">Manual
                      Entry</button>
                    <button type="button" class="ir-tab-btn ${isExcel ? 'active' : ''}" data-tab="excel">Upload Excel
                      With IMEI</button>
                  </div>
                </c:if>

                <!-- ===================== TAB: MANUAL ===================== -->
                <div id="tab-manual" class="ir-tab-panel ${isExcel ? '' : 'active'}">
                  <form id="manualForm" method="post" action="${ctx}/create-import-receipt">
                    <input type="hidden" name="mode" value="manual" />
                    <c:if test="${not empty requestId}">
                      <input type="hidden" name="requestId" value="${requestId}" />
                    </c:if>

                    <div class="ir-section-title">Import Form</div>

                    <div class="ir-row">
                      <label>Import Code (auto)</label>
                      <div class="ir-col">
                        <input type="text" name="importCode" value="${fn:escapeXml(importCode)}" readonly />
                        <div class="ir-hint">Generated by system</div>
                      </div>
                    </div>

                    <div class="ir-row">
                      <label>Transaction time</label>
                      <div class="ir-col">
                        <input type="datetime-local" name="receiptDate" value="${fn:escapeXml(receiptDateDefault)}"
                          required />
                      </div>
                    </div>

                    <div class="ir-row">
                      <label>Supplier <span style="color:#ef4444">*</span></label>
                      <div class="ir-col">
                        <select name="supplierId" required>
                          <option value="" selected disabled>-- Select Supplier --</option>
                          <c:forEach var="s" items="${suppliers}">
                            <option value="${s.id}">${fn:escapeXml(s.name)}</option>
                          </c:forEach>
                        </select>
                      </div>
                    </div>

                    <div class="ir-row">
                      <label>Note</label>
                      <div class="ir-col">
                        <textarea name="note" placeholder="Notes..."></textarea>
                      </div>
                    </div>

                    <div class="ir-section-title">Import Items</div>

                    <div style="overflow-x:auto;">
                      <table class="ir-table" id="itemsTable">
                        <thead>
                          <tr>
                            <th style="width:46px" class="center">#</th>
                            <th style="width:160px">Product Name</th>
                            <th style="width:140px">Product Code</th>
                            <th style="width:160px">SKU</th>
                            <th style="width:80px">Quantity</th>
                            <th style="width:240px">IMEI Numbers</th>
                            <th style="width:130px">Item Note</th>
                            <th style="width:100px">Created By</th>
                            <th style="width:80px" class="center">Action</th>
                          </tr>
                        </thead>
                        <tbody id="itemsTbody"></tbody>
                      </table>
                    </div>

                    <div style="margin-top:12px;">
                      <button type="button" class="ir-btn" id="btnAddRow">+ Add Product Line</button>
                    </div>

                    <div class="ir-btn-row">
                      <button type="submit" class="ir-btn primary">Save</button>
                      <c:choose>
                        <c:when test="${not empty requestId}">
                          <a class="ir-btn" href="${ctx}/home?p=import-request-list">Cancel</a>
                        </c:when>
                        <c:otherwise>
                          <a class="ir-btn" href="${ctx}/home?p=import-receipt-list">Cancel</a>
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </form>
                </div>

                <!-- ===================== TAB: EXCEL (hidden in request mode) ===================== -->
                <c:if test="${empty requestId}">
                  <div id="tab-excel" class="ir-tab-panel ${isExcel ? 'active' : ''}">
                    <form method="post" action="${ctx}/create-import-receipt" enctype="multipart/form-data">
                      <input type="hidden" name="mode" value="excel" />

                      <div class="ir-section-title">Import Form</div>

                      <div class="ir-hint-box">
                        <b>Excel Format:</b> 3 columns: <b>product_code</b>, <b>sku_code</b>, <b>imei</b> (IMEI 15
                        digits)
                      </div>

                      <div class="ir-row">
                        <label>Import Code (auto)</label>
                        <div class="ir-col">
                          <input type="text" name="importCode" value="${fn:escapeXml(importCode)}" readonly />
                        </div>
                      </div>

                      <div class="ir-row">
                        <label>Excel File (.xlsx)</label>
                        <div class="ir-col">
                          <input type="file" name="excelFile" accept=".xlsx" required />
                        </div>
                      </div>

                      <div class="ir-row">
                        <label>Transaction time</label>
                        <div class="ir-col">
                          <input type="datetime-local" name="receiptDate" value="${fn:escapeXml(receiptDateDefault)}"
                            required />
                        </div>
                      </div>

                      <div class="ir-row">
                        <label>Supplier <span style="color:#ef4444">*</span></label>
                        <div class="ir-col">
                          <select name="supplierId" required>
                            <option value="" selected disabled>-- Select Supplier --</option>
                            <c:forEach var="s" items="${suppliers}">
                              <option value="${s.id}">${fn:escapeXml(s.name)}</option>
                            </c:forEach>
                          </select>
                        </div>
                      </div>

                      <div class="ir-row">
                        <label>Note</label>
                        <div class="ir-col">
                          <textarea name="note" placeholder="Notes..."></textarea>
                        </div>
                      </div>

                      <div class="ir-btn-row">
                        <button type="submit" class="ir-btn primary">Import with Excel</button>
                        <a class="ir-btn" href="${ctx}/home?p=import-receipt-list">Cancel</a>
                      </div>
                    </form>
                  </div>
                </c:if><%-- end c:if empty requestId (excel tab) --%>

          </div>
        </div>

        <script>
          (function () {
            // PRODUCTS: id, code, name
            const PRODUCTS = [
              <c:forEach var="p" items="${products}" varStatus="st">
                {id: ${p.productId}, code: "${fn:escapeXml(p.productCode)}", name: "${fn:escapeXml(p.productName)}" }<c:if test="${!st.last}">,</c:if>
              </c:forEach>
            ];

            const SKUS = [
              <c:forEach var="k" items="${skus}" varStatus="st">
                {id: ${k.skuId}, code: "${fn:escapeXml(k.skuCode)}", productId: ${k.productId} }<c:if test="${!st.last}">,</c:if>
              </c:forEach>
            ];

            // Pre-filled rows from import request (empty array = manual mode)
            const REQUEST_ITEMS = [
              <c:forEach var="it" items="${requestItems}" varStatus="st">
                {
                  productId:   ${it.productId},
                productCode: "${fn:escapeXml(it.productCode)}",
                productName: "${fn:escapeXml(it.productName)}",
                skuId:       ${it.skuId},
                skuCode:     "${fn:escapeXml(it.skuCode)}",
                qty:         ${it.requestQty}
      }<c:if test="${!st.last}">,</c:if>
              </c:forEach>
            ];

            const IS_REQUEST_MODE = REQUEST_ITEMS.length > 0;

            const CREATED_BY = "${fn:escapeXml(createdByName)}";
            const tbody = document.getElementById("itemsTbody");
            const manualForm = document.getElementById("manualForm");
            let rowCounter = 0;

            // Build Product Name dropdown (or readonly display in request mode)
            function buildProductNameCell(prefill) {
              if (IS_REQUEST_MODE && prefill) {
                // Readonly display
                const inp = document.createElement("input");
                inp.type = "text";
                inp.value = prefill.productName;
                inp.readOnly = true;
                inp.style.background = "var(--surface-2,#f8fafc)";
                inp.style.color = "var(--muted,#64748b)";
                return inp;
              }
              const sel = document.createElement("select");
              sel.required = true;
              sel.style.width = "100%";
              const defOpt = document.createElement("option");
              defOpt.value = "";
              defOpt.textContent = "-- Select Product Name --";
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
              div.className = "ir-code-display";
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
                inp.value = prefill.skuCode;
                inp.readOnly = true;
                inp.style.background = "var(--surface-2,#f8fafc)";
                inp.style.color = "var(--muted,#64748b)";
                wrap.appendChild(hidSku);
                wrap.appendChild(inp);
                return wrap;
              }
              const sel = document.createElement("select");
              sel.name = "skuId";
              sel.required = true;
              sel.style.width = "100%";
              const defOpt = document.createElement("option");
              defOpt.value = "";
              defOpt.textContent = "-- Select SKU --";
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
              box.className = "ir-imei-box";
              for (let i = 1; i <= qty; i++) {
                const row = document.createElement("div");
                row.className = "ir-imei-row";
                const label = document.createElement("span");
                label.textContent = "IMEI " + i + ":";
                const input = document.createElement("input");
                input.type = "text";
                input.name = "imei_" + rowIdx + "_" + i;
                input.placeholder = "15 digits";
                input.required = true;
                input.maxLength = 15;
                input.addEventListener("input", function () {
                  this.value = this.value.replace(/\D/g, "").slice(0, 15);
                  if (this.value.length === 15) {
                    this.classList.add("valid"); this.classList.remove("invalid");
                  } else if (this.value.length > 0) {
                    this.classList.add("invalid"); this.classList.remove("valid");
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

            function addRow(prefill) {
              rowCounter++;
              const rowIdx = rowCounter;
              const tr = document.createElement("tr");
              tr.dataset.rowIdx = rowIdx;

              // #
              const tdNo = document.createElement("td");
              tdNo.className = "center cellNo";
              tdNo.textContent = tbody.children.length + 1;

              // Product Name
              const tdName = document.createElement("td");
              const nameEl = buildProductNameCell(prefill);
              tdName.appendChild(nameEl);

              // Product Code (display + hidden productId)
              const tdCode = document.createElement("td");
              const hidProductId = buildProductIdInput(prefill ? prefill.productId : null);
              const codeDisplay = buildCodeDisplay(prefill ? prefill.productCode : null);
              tdCode.appendChild(hidProductId);
              tdCode.appendChild(codeDisplay);

              // SKU
              const tdSku = document.createElement("td");
              const skuEl = buildSkuCell(prefill);
              tdSku.appendChild(skuEl);

              // Wire up name→code+sku only in manual mode
              if (!IS_REQUEST_MODE) {
                const selName = nameEl; // it's a select in manual mode
                const selSku = skuEl;   // it's a select in manual mode
                selName.addEventListener("change", function () {
                  const pid = this.value;
                  const selectedOpt = this.options[this.selectedIndex];
                  hidProductId.value = pid;
                  codeDisplay.textContent = selectedOpt ? (selectedOpt.dataset.code || "—") : "—";
                  refreshSkuOptions(selSku, pid);
                });
              }

              // Quantity
              const tdQty = document.createElement("td");
              const qtyInp = document.createElement("input");
              qtyInp.type = "number";
              qtyInp.name = "qty";
              qtyInp.min = "1";
              qtyInp.value = prefill ? prefill.qty : "1";
              qtyInp.required = true;
              if (IS_REQUEST_MODE && prefill) {
                // Lock quantity in request mode
                qtyInp.readOnly = true;
                qtyInp.style.background = "var(--surface-2,#f8fafc)";
                qtyInp.style.color = "var(--muted,#64748b)";
              }
              tdQty.appendChild(qtyInp);

              // IMEI
              const tdImei = document.createElement("td");
              tdImei.className = "ir-imei-cell";
              const initQty = prefill ? prefill.qty : 1;
              let imeiBox = buildImeiBox(rowIdx, initQty);
              tdImei.appendChild(imeiBox);

              // Only allow qty change (and IMEI refresh) in manual mode
              if (!IS_REQUEST_MODE) {
                qtyInp.addEventListener("change", function () {
                  let q = parseInt(this.value);
                  if (isNaN(q) || q < 1) { q = 1; this.value = 1; }
                  tdImei.innerHTML = "";
                  imeiBox = buildImeiBox(rowIdx, q);
                  tdImei.appendChild(imeiBox);
                });
              }

              // Item Note
              const tdNote = document.createElement("td");
              const noteInp = document.createElement("input");
              noteInp.type = "text";
              noteInp.name = "itemNote";
              noteInp.placeholder = "Notes";
              tdNote.appendChild(noteInp);

              // Created By
              const tdBy = document.createElement("td");
              tdBy.textContent = CREATED_BY || "Staff";
              tdBy.style.color = "var(--muted,#64748b)";
              tdBy.style.fontSize = "12px";

              // Action — hide delete in request mode
              const tdAct = document.createElement("td");
              tdAct.className = "center";
              if (!IS_REQUEST_MODE) {
                const delBtn = document.createElement("button");
                delBtn.type = "button";
                delBtn.className = "ir-btn danger";
                delBtn.textContent = "Delete";
                delBtn.style.fontSize = "12px";
                delBtn.style.padding = "5px 10px";
                delBtn.addEventListener("click", function () {
                  tr.remove();
                  Array.from(tbody.children).forEach((row, idx) => {
                    const noCell = row.querySelector(".cellNo");
                    if (noCell) noCell.textContent = idx + 1;
                  });
                });
                tdAct.appendChild(delBtn);
              } else {
                tdAct.textContent = "-";
              }

              tr.append(tdNo, tdName, tdCode, tdSku, tdQty, tdImei, tdNote, tdBy, tdAct);
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

            // Tabs (only in manual mode — tabs are hidden in request mode)
            document.querySelectorAll('.ir-tab-btn').forEach(btn => {
              btn.addEventListener('click', function () {
                const tab = this.dataset.tab;
                document.querySelectorAll('.ir-tab-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                document.querySelectorAll('.ir-tab-panel').forEach(p => p.classList.remove('active'));
                document.getElementById('tab-' + tab).classList.add('active');
              });
            });

            // Initialize rows
            if (IS_REQUEST_MODE) {
              REQUEST_ITEMS.forEach(item => addRow(item));
            } else {
              addRow(null);
            }
          })();
        </script>