<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<link rel="stylesheet" href="${ctx}/assets/css/app.css">
<%-- Internal styles moved to app.css --%>

<div class="container page-wrap ec-page">

  <div class="topbar">
    <div>
      <div class="title">Export Center</div>
      <div class="small">Preview and export reports to Excel or PDF from one shared screen.</div>
    </div>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err">${fn:escapeXml(err)}</div>
  </c:if>

  <c:if test="${not empty msg}">
    <div class="msg-ok">${fn:escapeXml(msg)}</div>
  </c:if>

  <div class="card card-body">
    <form method="get" action="${ctx}/export-center">
      <div class="ec-grid">

        <div class="field">
          <label>Report Type</label>
          <select class="select" name="reportType" id="reportType">
            <option value="inventory" ${reportType == 'inventory' ? 'selected' : ''}>Inventory Report</option>
            <option value="import" ${reportType == 'import' ? 'selected' : ''}>Import Report</option>
            <option value="export" ${reportType == 'export' ? 'selected' : ''}>Export Report</option>
            <option value="brand-statistic" ${reportType == 'brand-statistic' ? 'selected' : ''}>Brand Statistic</option>
            <option value="low-stock" ${reportType == 'low-stock' ? 'selected' : ''}>Low Stock Report</option>
          </select>
        </div>

        <div class="field" id="brandWrap">
          <label>Brand</label>
          <select class="select" name="brandId" id="brandId">
            <option value="">All Brands</option>
            <c:forEach items="${allBrands}" var="b">
              <option value="${b.brandId}" ${brandId == b.brandId || brandId == b.brandId.toString() ? 'selected' : ''}>
                ${b.brandName}
              </option>
            </c:forEach>
          </select>
          <div class="ec-note">Used for Inventory Report, Brand Statistic, and Low Stock Report.</div>
        </div>

        <div class="field" id="fromWrap">
          <label>Date From</label>
          <input class="input" type="date" name="from" value="${from}" />
        </div>

        <div class="field" id="toWrap">
          <label>Date To</label>
          <input class="input" type="date" name="to" value="${to}" />
        </div>

        <div class="field span-2" id="keywordWrap">
          <label>Search Product</label>
          <input class="input" type="text" name="keyword" value="${keyword}" placeholder="Enter product name or code" />
          <div class="ec-note">Used mainly for Inventory Report.</div>
        </div>

        <div class="field" id="ropStatusWrap">
          <label>ROP Status</label>
          <select class="select" name="ropStatus" id="ropStatus">
            <option value="" ${empty ropStatus ? 'selected' : ''}>All Below ROP</option>
            <option value="Out Of Stock" ${ropStatus == 'Out Of Stock' ? 'selected' : ''}>Out Of Stock</option>
            <option value="Reorder Needed" ${ropStatus == 'Reorder Needed' ? 'selected' : ''}>Reorder Needed</option>
            <option value="At ROP Level" ${ropStatus == 'At ROP Level' ? 'selected' : ''}>At ROP Level</option>
            <option value="OK" ${ropStatus == 'OK' ? 'selected' : ''}>OK</option>
          </select>
        </div>

        <div class="field">
          <label>Format</label>
          <select class="select" name="format" id="format">
            <option value="xlsx" ${format == 'xlsx' ? 'selected' : ''}>Excel (.xlsx)</option>
            <option value="pdf" ${format == 'pdf' ? 'selected' : ''}>PDF</option>
          </select>
        </div>

        <div class="field">
          <label>Detail Level</label>
          <select class="select" name="detailLevel" id="detailLevel">
            <option value="summary" ${detailLevel == 'summary' ? 'selected' : ''}>Summary</option>
            <option value="detail" ${detailLevel == 'detail' ? 'selected' : ''}>Detail</option>
          </select>
        </div>

        <div class="field" id="pdfOrientationWrap">
          <label>PDF Orientation</label>
          <select class="select" name="pdfOrientation" id="pdfOrientation">
            <option value="portrait" ${pdfOrientation == 'portrait' ? 'selected' : ''}>Portrait</option>
            <option value="landscape" ${pdfOrientation == 'landscape' ? 'selected' : ''}>Landscape</option>
          </select>
          <div class="ec-note">Only applies when Format = PDF. Preview is data-only.</div>
        </div>
      </div>

      <div class="ec-actions">
        <a class="btn btn-outline" href="${ctx}/home?p=export-center">Reset</a>
        <button class="btn" type="submit" name="action" value="preview">Preview Data</button>
        <button class="btn btn-primary" type="submit" name="action" value="export">Export Now</button>
      </div>
    </form>
  </div>

  <c:if test="${not empty previewTitle}">
    <div class="card card-body">
      <div class="h2">${previewTitle}</div>
      <div class="card-subtitle">Preview shows report data only. Final PDF layout may differ.</div>

      <div style="height:12px;"></div>

      <div class="ec-box">
        <div class="h2" style="font-size:15px; margin-bottom:10px;">Applied Filters</div>
        <div class="ec-kv">
          <c:forEach items="${filterLines}" var="entry">
            <div>${entry.key}</div>
            <div>${entry.value}</div>
          </c:forEach>
        </div>
      </div>

      <div style="height:14px;"></div>

      <div class="ec-box">
        <div class="h2" style="font-size:15px; margin-bottom:10px;">Summary</div>
        <div class="ec-kv">
          <c:forEach items="${summaryLines}" var="entry">
            <div>${entry.key}</div>
            <div>${entry.value}</div>
          </c:forEach>
        </div>
      </div>

      <div style="height:14px;"></div>

      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <c:forEach items="${previewHeaders}" var="h">
                <th>${h}</th>
              </c:forEach>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty previewRows}">
                <tr>
                  <td colspan="${fn:length(previewHeaders)}" class="empty-row">No data</td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach items="${previewRows}" var="row">
                  <tr>
                    <c:forEach items="${row}" var="cell">
                      <td>${cell}</td>
                    </c:forEach>
                  </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>
  </c:if>

</div>

<script>
  (function () {
    const formatEl = document.getElementById('format');
    const reportTypeEl = document.getElementById('reportType');

    const pdfOrientationWrap = document.getElementById('pdfOrientationWrap');
    const brandWrap = document.getElementById('brandWrap');
    const fromWrap = document.getElementById('fromWrap');
    const toWrap = document.getElementById('toWrap');
    const keywordWrap = document.getElementById('keywordWrap');
    const ropStatusWrap = document.getElementById('ropStatusWrap');

    function togglePdfOrientation() {
      const isPdf = formatEl && formatEl.value === 'pdf';
      if (pdfOrientationWrap) {
        pdfOrientationWrap.style.display = isPdf ? '' : 'none';
      }
    }

    function toggleReportSpecificFields() {
      const reportType = reportTypeEl ? reportTypeEl.value : 'inventory';
      const isLowStock = reportType === 'low-stock';
      const isBrandStatistic = reportType === 'brand-statistic';
      const isImportOrExport = reportType === 'import' || reportType === 'export';

      if (brandWrap) {
        brandWrap.style.display = (isImportOrExport) ? 'none' : '';
      }

      if (fromWrap) {
        fromWrap.style.display = isLowStock ? 'none' : '';
      }

      if (toWrap) {
        toWrap.style.display = isLowStock ? 'none' : '';
      }

      if (keywordWrap) {
        keywordWrap.style.display = (reportType === 'inventory') ? '' : 'none';
      }

      if (ropStatusWrap) {
        ropStatusWrap.style.display = isLowStock ? '' : 'none';
      }
    }

    if (formatEl) {
      formatEl.addEventListener('change', togglePdfOrientation);
      togglePdfOrientation();
    }

    if (reportTypeEl) {
      reportTypeEl.addEventListener('change', toggleReportSpecificFields);
      toggleReportSpecificFields();
    }
  })();
</script>