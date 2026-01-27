<%-- 
    Document   : conduct_inventory_count
    Created on : Jan 27, 2026
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Conduct Inventory Count</title>

    <style>
        :root{
            --border:#1d4f8b;
            --gray:#d9d9d9;
        }
        body{
            margin:0;
            font-family: Arial, Helvetica, sans-serif;
            background:#ffffff;
            color:#111;
        }
        .page{
            padding:14px 18px 22px;
        }

        
        .topbar{
            display:flex;
            align-items:center;
            gap:14px;
            margin-bottom:10px;
        }
        .btn-back{
            border:1px solid #333;
            background:#d9d9d9;
            padding:6px 14px;
            border-radius:2px;
            cursor:pointer;
            font-weight:600;
            text-decoration:none;
            color:#000;
            display:inline-block;
        }
        .title{
            font-size:18px;
            font-weight:700;
        }

       
        .panel{
            border:2px solid var(--border);
            padding:12px;
            margin:12px 0 16px;
        }
        .panel-title{
            font-weight:700;
            margin-bottom:10px;
        }
        .search-row{
            display:grid;
            grid-template-columns: 320px 180px 160px 90px 90px 90px;
            gap:12px;
            align-items:center;
        }
        .search-row input[type="text"], .search-row select{
            height:34px;
            border:1px solid #999;
            padding:0 10px;
            outline:none;
            background:#fff;
        }
        .btn{
            height:34px;
            border:1px solid #333;
            background:#d9d9d9;
            cursor:pointer;
            font-weight:700;
        }

        
        .table-wrap{
            border:2px solid var(--border);
        }
        table{
            width:100%;
            border-collapse:collapse;
            table-layout:fixed;
        }
        thead th{
            background:var(--gray);
            border-bottom:2px solid var(--border);
            border-right:2px solid var(--border);
            padding:10px 8px;
            text-align:center;
            font-weight:800;
        }
        thead th:last-child{ border-right:none; }

        tbody td{
            border-top:2px solid var(--border);
            border-right:2px solid var(--border);
            padding:10px 8px;
            height:42px;
            vertical-align:middle;
            background:#fff;
            overflow:hidden;
            text-overflow:ellipsis;
            white-space:nowrap;
        }
        tbody td:last-child{ border-right:none; }

        .c-sku{ width:120px; text-align:center; }
        .c-name{ width:240px; }
        .c-color{ width:110px; text-align:center; }
        .c-ram{ width:90px; text-align:center; }
        .c-storage{ width:110px; text-align:center; }
        .c-sys{ width:120px; text-align:center; }
        .c-counted{ width:120px; text-align:center; }
        .c-diff{ width:120px; text-align:center; }
        .c-status{ width:120px; text-align:center; }
        .c-action{ width:130px; text-align:center; }

        .counted-input{
            width:70px;
            height:28px;
            border:1px solid #999;
            padding:0 8px;
            text-align:center;
            outline:none;
            background:#fff;
        }

        .imei-link{
            color:#0b55d6;
            text-decoration:underline;
            font-weight:700;
        }

        
        .pager{
            display:flex;
            align-items:center;
            justify-content:space-between;
            padding:12px;
            border-top:2px solid var(--border);
            background:#fff;
        }
        .pager-left{ font-weight:700; }
        .pager-mid{
            display:flex;
            align-items:center;
            gap:10px;
        }
        .pager-mid .nav{
            width:34px;
            height:30px;
            border:2px solid var(--border);
            background:#d9d9d9;
            cursor:pointer;
            font-weight:900;
        }
        .pager-mid .page{
            padding:6px 12px;
            border:1px solid #bbb;
            background:#fff;
        }
        .pager-right{
            display:flex;
            align-items:center;
            gap:10px;
            font-weight:700;
        }
        .rows-select{
            height:30px;
            border:1px solid #999;
            background:#fff;
        }
    </style>
</head>

<body>
<div class="page">

    <div class="topbar">
        <a class="btn-back" href="${pageContext.request.contextPath}/home?p=dashboard">Back</a>
        <div class="title">Conduct Inventory Count</div>
    </div>

    <div class="panel">
        <div class="panel-title">Search Criteria</div>

        <!-- UI only (chưa có DB/Servlet thì để #) -->
        <form method="get" action="#">
            <div class="search-row">
                <input type="text" name="q" placeholder="Product name, SKU,..." />

                <select name="categoryId">
                    <option value="">All Categories</option>
                </select>

                <select name="brandId">
                    <option value="">All Brands</option>
                </select>

                <button type="button" class="btn">Search</button>
                <button type="reset" class="btn">Reset</button>
                <button type="button" class="btn">Save</button>
            </div>
        </form>
    </div>

    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th class="c-sku">SKU</th>
                <th class="c-name">Product Name</th>
                <th class="c-color">Color</th>
                <th class="c-ram">RAM</th>
                <th class="c-storage">Storage</th>
                <th class="c-sys">System Qty</th>
                <th class="c-counted">Counted Qty</th>
                <th class="c-diff">Difference</th>
                <th class="c-status">Status</th>
                <th class="c-action">Action</th>
            </tr>
            </thead>

            
            <tbody>
                <tr>
                    <td>&nbsp;</td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td>
                    <td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
                <tr>
                    <td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td>
                    <td style="text-align:center;"><input class="counted-input" disabled /></td>
                    <td></td><td></td>
                    <td style="text-align:center;"><span class="imei-link" style="visibility:hidden;">View List Imei</span></td>
                </tr>
            </tbody>
        </table>

        <div class="pager">
            <div class="pager-left">Page 1</div>

            <div class="pager-mid">
                <button class="nav" type="button">&lt;</button>
                <span class="page">1</span>
                <button class="nav" type="button">&gt;</button>
            </div>

            <div class="pager-right">
                Show
                <select class="rows-select">
                    <option selected>10 Row</option>
                    <option>20 Row</option>
                    <option>50 Row</option>
                </select>
            </div>
        </div>
    </div>

</div>
</body>
</html>
