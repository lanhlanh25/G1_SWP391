<%-- 
    Document   : brand_stats_detail
    Created on : Jan 29, 2026, 12:27:40 AM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
    .wrap{
        padding:16px;
    }
    .top{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:12px;
    }
    .btn{
        display:inline-block;
        padding:6px 14px;
        border:1px solid #333;
        background:#f6f6f6;
        text-decoration:none;
        color:#111;
        border-radius:3px;
    }
    .btn:hover{
        background:#eee;
    }

    .cards{
        display:grid;
        grid-template-columns: repeat(4, 1fr);
        gap:14px;
        margin:10px 0 14px;
    }
    .card{
        border:1px solid #333;
        height:72px;
        display:flex;
        flex-direction:column;
        align-items:center;
        justify-content:center;
    }
    .card .label{
        font-size:12px;
        color:#333;
        margin-bottom:6px;
    }
    .card .value{
        font-size:18px;
        font-weight:700;
    }

    .muted{
        font-size:12px;
        color:#777;
    }

    .filterRow{
        display:flex;
        gap:12px;
        align-items:end;
        margin:10px 0 12px;
    }
    .field label{
        display:block;
        font-size:12px;
        margin-bottom:4px;
        color:#333;
    }
    .field select{
        padding:6px;
        border:1px solid #aaa;
        border-radius:3px;
        min-width:180px;
    }

    table{
        width:100%;
        border-collapse:collapse;
    }
    th, td{
        border:1px solid #333;
        padding:8px;
        text-align:left;
    }
    th{
        background:#f1f1f1;
    }
    .tag{
        padding:2px 8px;
        border:1px solid #999;
        border-radius:12px;
        font-size:12px;
    }
</style>

<%-- Build Back URL with preserved params --%>
<c:url var="backUrl" value="/home">
  <c:param name="p" value="brand-stats"/>
  <c:param name="q" value="${param.listQ}"/>
  <c:param name="status" value="${param.listStatus}"/>
  <c:param name="brandId" value="${param.listBrandId}"/>
  <c:param name="sortBy" value="${param.listSortBy}"/>
  <c:param name="sortOrder" value="${param.listSortOrder}"/>
  <c:param name="range" value="${param.listRange}"/>
  <c:param name="page" value="${empty param.listPage ? 1 : param.listPage}"/>
</c:url>

<div class="wrap">
    <div class="top">
        <h2 style="margin:0;">Brand Detail Statistics: ${brand.brandName}</h2>
        <a class="btn" href="${backUrl}">Back</a>

    </div>

    
    <%-- Summary cards --%>
    <div class="cards">
        <div class="card">
            <div class="label">Total Products</div>
            <div class="value">${detailSummary.totalProducts}</div>
        </div>

        <div class="card">
            <div class="label">Total Stock Units</div>
            <div class="value">${detailSummary.totalStockUnits}</div>
        </div>

        <div class="card">
            <div class="label">Low Stock Products</div>
            <div class="value">${detailSummary.lowStockProducts}</div>
        </div>

        <div class="card">
            <div class="label">Imported Units (Range)</div>
            <div class="value">${detailSummary.importedUnitsInRange}</div>
        </div>

        <div class="card">
            <div class="label">Exported Units (Range)</div>
            <div class="value">${detailSummary.exportedUnitsInRange}</div>
        </div>
    </div>

    <%-- Sort in detail --%>
    <form method="get" action="${ctx}/home">
        <input type="hidden" name="p" value="brand-stats-detail"/>
        <input type="hidden" name="brandId" value="${param.brandId}"/>

        <!-- keep list state (IMPORTANT: use list* param names) -->
<input type="hidden" name="listQ" value="${param.listQ}"/>
<input type="hidden" name="listStatus" value="${param.listStatus}"/>
<input type="hidden" name="listBrandId" value="${param.listBrandId}"/>
<input type="hidden" name="listSortBy" value="${param.listSortBy}"/>
<input type="hidden" name="listSortOrder" value="${param.listSortOrder}"/>
<input type="hidden" name="listRange" value="${param.listRange}"/>
<input type="hidden" name="listPage" value="${empty param.listPage ? 1 : param.listPage}"/>


        <div class="filterRow">
            <div class="field">
                <label>Sort By</label>
                <select name="dSortBy">
                    <option value="stock"  ${dSortBy=='stock' ? 'selected' : ''}>Total Stock</option>
                    <option value="import" ${dSortBy=='import' ? 'selected' : ''}>Imported Units (Range)</option>
                    <option value="export" ${dSortBy=='export' ? 'selected' : ''}>Exported Units (Range)</option>
                    <option value="name"   ${dSortBy=='name' ? 'selected' : ''}>Product Name</option>
                </select>
            </div>

            <div class="field">
                <label>Order</label>
                <select name="dSortOrder">
                    <option value="DESC" ${dSortOrder=='DESC' ? 'selected' : ''}>Descending (Z→A / High→Low)</option>
                    <option value="ASC"  ${dSortOrder=='ASC' ? 'selected' : ''}>Ascending (A→Z / Low→High)</option>
                </select>
            </div>

            <button class="btn" type="submit">Apply</button>
        </div>
    </form>

    <table>
        <tr>
            <th style="width:160px;">Product Code</th>
            <th>Product Name</th>
            <th style="width:140px;">Total Stock Units</th>
            <th style="width:140px;">Imported Units</th>
            <th style="width:140px;">Exported Units</th>
            <th style="width:160px;">Last Import</th>
            <th style="width:160px;">Last Export</th>
            <th style="width:120px;">Status</th>
        </tr>

        <c:forEach items="${products}" var="p">
            <tr>
                <td>${p.productCode}</td>
                <td>${p.productName}</td>
                <td>${p.totalStockUnits}</td>
                <td>${p.importedUnits}</td>
                <td>${p.exportedUnits}</td>
                <td class="muted">${p.lastImportAt}</td>
                <td class="muted">${p.lastExportAt}</td>

                <td><span class="tag">${p.stockStatus}</span></td>
            </tr>

        </c:forEach>

        <c:if test="${empty products}">
            <tr>
                <td colspan="8" style="text-align:center; color:#666;">No products</td>
            </tr>
        </c:if>
    </table>
</div>
