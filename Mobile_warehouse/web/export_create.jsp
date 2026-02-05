<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Stock Out | Create Export Receipt</title>
    <style>
        :root{
            --bg:#f5f7fb;
            --card:#ffffff;
            --text:#111827;
            --muted:#6b7280;
            --line:#e5e7eb;
            --line2:#d1d5db;
            --th:#f3f4f6;
            --primary:#2563eb;
            --primary2:#1d4ed8;
            --danger:#dc2626;
            --radius:10px;
            --shadow:0 10px 20px rgba(0,0,0,.05);
        }
        *{ box-sizing:border-box; }
        body{ margin:0; font-family: Arial, Helvetica, sans-serif; background:var(--bg); color:var(--text); }
        .wrap{ max-width:1200px; margin:0 auto; padding:18px 18px 40px; }

        .pageTitle{ font-size:22px; font-weight:800; margin:0 0 4px; }
        .pageSub{ color:var(--muted); font-size:12px; margin:0 0 14px; }

        .card{
            background:var(--card);
            border:1px solid var(--line);
            border-radius:var(--radius);
            box-shadow:var(--shadow);
            padding:14px;
        }

        .sectionHeader{
            display:flex; align-items:center; justify-content:space-between;
            margin-bottom:12px;
        }
        .crumb{
            display:inline-flex; align-items:center; gap:6px;
            font-size:12px; color:var(--muted); font-weight:800;
        }
        .dot{ width:6px; height:6px; border-radius:999px; background:var(--primary); display:inline-block; }

        .tabs{ display:flex; gap:10px; margin:12px 0; }
        .tab{
            border:1px solid var(--line);
            background:#fff;
            padding:8px 12px;
            border-radius:999px;
            font-weight:900;
            font-size:12px;
            color:#374151;
            cursor:pointer;
            user-select:none;
        }
        .tab.active{
            border-color:#bfdbfe;
            background:#eff6ff;
            color:#1d4ed8;
        }

        .formGrid{
            display:grid;
            grid-template-columns: 1fr 1fr;
            gap:12px;
        }
        .field{ display:flex; flex-direction:column; gap:6px; }
        .field label{ font-size:12px; font-weight:900; color:#374151; }
        .field label .opt{ font-weight:800; color:var(--muted); }
        input, select, textarea{
            border:1px solid var(--line);
            border-radius:8px;
            padding:10px;
            outline:none;
            background:#fff;
        }
        textarea{ min-height:84px; resize:vertical; }
        input:focus, select:focus, textarea:focus{
            border-color:#93c5fd;
            box-shadow:0 0 0 3px rgba(147,197,253,.35);
        }

        .block{ margin-top:14px; }

        .tableWrap{
            border:1px solid var(--line);
            border-radius:10px;
            overflow:hidden;
            background:#fff;
        }
        table{ width:100%; border-collapse:collapse; }
        th{
            background:var(--th);
            font-size:12px;
            color:#374151;
            text-align:left;
            padding:10px;
            border-bottom:1px solid var(--line);
            white-space:nowrap;
        }
        td{
            padding:10px;
            border-bottom:1px solid var(--line);
            vertical-align:top;
            font-size:13px;
        }
        tr:last-child td{ border-bottom:none; }

        .cellSmall{ width:54px; }
        .cellSku{ width:170px; }
        .cellStock{ width:120px; }
        .cellQty{ width:110px; }
        .cellImei{ width:320px; }
        .cellAction{ width:90px; text-align:center; }

        .miniInput, .miniSelect{
            width:100%;
            padding:8px 9px;
            border-radius:8px;
            border:1px solid var(--line2);
        }
        .hint{ font-size:12px; color:var(--muted); margin-top:6px; line-height:1.35; }

        .btnRow{ display:flex; gap:10px; align-items:center; margin-top:12px; }
        .btn{
            display:inline-flex; align-items:center; gap:8px;
            padding:10px 14px;
            border-radius:10px;
            border:1px solid var(--line);
            background:#fff;
            font-weight:900;
            cursor:pointer;
            user-select:none;
        }
        .btn.primary{
            background:var(--primary);
            border-color:var(--primary2);
            color:#fff;
        }
        .btn.primary:hover{ background:var(--primary2); }
        .btn.danger{
            background:#fff;
            color:var(--danger);
            border-color:#fecaca;
        }
        .btn.small{ padding:7px 10px; border-radius:8px; font-weight:900; }
        .icon{
            width:16px; height:16px; display:inline-block;
            border:2px solid currentColor; border-radius:4px;
        }

        .footerBar{
            display:flex;
            justify-content:space-between;
            align-items:flex-start;
            gap:14px;
            margin-top:14px;
            padding-top:14px;
            border-top:1px dashed var(--line);
        }
        .confirm{
            display:flex; align-items:flex-start; gap:10px;
        }
        .confirm small{ color:var(--muted); display:block; margin-top:4px; }
        .summary{
            min-width:320px;
            border:1px solid var(--line);
            border-radius:12px;
            padding:10px 12px;
            background:#fbfbff;
        }
        .sumLine{ display:flex; justify-content:space-between; margin:8px 0; font-weight:900; }
        .sumLine span:first-child{ color:#374151; font-weight:800; }

        .rightActions{ display:flex; gap:10px; }
    </style>
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
