<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Stock Out | Create Export Receipt</title>

</head>

<body>
<div class="wrap">

    <h1 class="pageTitle">Stock Out</h1>
    <p class="pageSub">Create an export receipt to request warehouse staff to export items</p>

    <div class="card">
        <div class="sectionHeader">
            <div class="crumb"><span class="dot"></span> Stock Out Form</div>
            <div class="rightActions">
                <button class="btn" type="button">Back</button>
                <button class="btn primary" type="button">Create &amp; Confirm</button>
            </div>
        </div>

        <div class="tabs">
            <div class="tab active">Manual Entry</div>
            <div class="tab">Upload Excel with IMEIs</div>
        </div>

        <!-- Top form giống demo nhưng chỉnh "Customer" => Created by (Sale) -->
        <div class="formGrid">
            <div class="field">
                <label>Transaction time</label>
                <input type="text" value="02/04/2026 12:34 PM" readonly>
            </div>

            <div class="field">
                <label>Export code <span class="opt">(auto)</span></label>
                <input type="text" value="EXP-0001" readonly>
            </div>

            <div class="field">
                <label>Created by (Sale)</label>
                <input type="text" value="sale01 - Duc Dang" readonly>
            </div>
            
            <div class="field">
                <label>Export type</label>
                <input type="text" value="Delivery to Customer" readonly>
            </div>

            <div class="field" style="grid-column: 1 / span 2;">
                <label>General note <span class="opt">(optional)</span></label>
                <textarea placeholder="Additional notes"></textarea>
            </div>
        </div>

        <!-- Export items -->
        <div class="block">
            <div style="font-weight:900; margin-bottom:8px;">Export items*</div>

            <div class="tableWrap">
                <table>
                    <thead>
                    <tr>
                        <th class="cellSmall">#</th>
                        <th>Product*</th>
                        <th class="cellSku">SKU <span style="font-weight:800; color:var(--muted)">(optional)</span></th>
                        <th class="cellStock">In Stock</th>
                        <th class="cellQty">Quantity*</th>
                        <th class="cellImei">IMEI List <span style="font-weight:800; color:var(--muted)">(optional)</span></th>
                        <th class="cellAction">Action</th>
                    </tr>
                    </thead>

                    <tbody>
                    <tr>
                        <td>1</td>

                        <td>
                            <select class="miniSelect">
                                <option>-- Choose product --</option>
                                <option>iPhone 15 Pro Max 256GB</option>
                                <option>Samsung S24 Ultra 512GB</option>
                            </select>
                            <div class="hint">
                                Gợi ý: product -> load list SKU tương ứng (nếu có).
                            </div>
                        </td>

                        <td>
                            <select class="miniSelect">
                                <option>-- Choose SKU (optional) --</option>
                                <option>IP15PM-256-BLK</option>
                                <option>IP15PM-256-WHT</option>
                            </select>
                            <div class="hint">
                                Nếu không chọn SKU: có thể export theo “model chung” (tuỳ nghiệp vụ bạn).
                            </div>
                        </td>

                        <td>
                            <input class="miniInput" value="12" readonly>
                            <div class="hint">units available</div>
                        </td>

                        <td>
                            <input class="miniInput" type="number" min="1" placeholder="e.g. 2">
                            <div class="hint">Không vượt quá In Stock.</div>
                        </td>

                        <td>
                            <textarea class="miniInput" style="min-height:54px;" placeholder="Paste IMEIs (one per line) or pick from modal..."></textarea>
                            <div class="btnRow" style="margin-top:8px;">
                                <button class="btn small" type="button">Pick IMEI</button>
                            </div>
                            <div class="hint">
                                IMEI là optional: nếu bạn export theo số lượng thì có thể bỏ trống.
                            </div>
                        </td>

                        <td class="cellAction">
                            <button class="btn danger small" type="button">Delete</button>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="7" style="color:var(--muted); font-size:12px;">
                            Tip: Có thể validate: nếu user nhập IMEI thì count(IMEI) phải = Quantity.
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div class="btnRow">
                <button class="btn" type="button">
                    <span class="icon"></span>
                    Add product line
                </button>
            </div>
        </div>

        <!-- Footer -->
        <div class="footerBar">
            <div class="confirm">
                <input type="checkbox" id="confirm" style="margin-top:4px;">
                <div>
                    <label for="confirm" style="font-weight:900; cursor:pointer;">I confirm items are correct</label>
                    <small>Bạn có thể chặn “Create &amp; Confirm” nếu chưa tick.</small>
                </div>
            </div>

            <div class="summary">
                <div class="sumLine"><span>Total Qty</span><span>2</span></div>
                <div class="sumLine"><span>Total Lines</span><span>1</span></div>
            </div>
        </div>

        <div class="btnRow" style="justify-content:flex-start; margin-top:14px;">
            <button class="btn primary" type="button">Save</button>
            <button class="btn" type="button">Cancel</button>
        </div>

    </div>
</div>
</body>
</html>
