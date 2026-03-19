<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="page-wrap ec-page">

  <div class="topbar">
    <div class="d-flex align-center gap-12">
      <div>
        <h1 class="h1">Export Center</h1>
        <div class="text-muted fs-13">Preview and export consolidated reports to Excel or PDF</div>
      </div>
    </div>
    <div class="d-flex gap-8 align-center">
      <a class="btn btn-outline" href="${ctx}/home?p=dashboard">← Dashboard</a>
    </div>
  </div>

  <c:if test="${not empty err}">
    <div class="msg-err mb-16">${fn:escapeXml(err)}</div>
  </c:if>

  <c:if test="${not empty msg}">
    <div class="msg-ok mb-16">${fn:escapeXml(msg)}</div>
  </c:if>

  <div class="card mb-16">
    <div class="card-body">
      <form method="get" action="${ctx}/export-center">
        <div class="grid-12 gap-16 align-end">

          <div class="col-3">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Report Type</label>
            <select class="select" name="reportType" id="reportType">
              <option value="inventory" ${reportType == 'inventory' ? 'selected' : ''}>Inventory Report</option>
              <option value="import" ${reportType == 'import' ? 'selected' : ''}>Import Report</option>
              <option value="export" ${reportType == 'export' ? 'selected' : ''}>Export Report</option>
              <option value="brand-statistic" ${reportType == 'brand-statistic' ? 'selected' : ''}>Brand Statistic</option>
              <option value="low-stock" ${reportType == 'low-stock' ? 'selected' : ''}>Low Stock Report</option>
            </select>
          </div>

          <div class="col-3" id="brandWrap">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Brand</label>
            <select class="select" name="brandId" id="brandId">
              <option value="">All Brands</option>
              <c:forEach items="${allBrands}" var="b">
                <option value="${b.brandId}" ${brandId == b.brandId || brandId == b.brandId.toString() ? 'selected' : ''}>
                  ${b.brandName}
                </option>
              </c:forEach>
            </select>
          </div>

          <div class="col-3" id="fromWrap">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Date From</label>
            <input class="input" type="date" name="from" value="${from}" />
          </div>

          <div class="col-3" id="toWrap">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Date To</label>
            <input class="input" type="date" name="to" value="${to}" />
          </div>

          <div class="col-6" id="keywordWrap">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Search Product</label>
            <input class="input" type="text" name="keyword" value="${keyword}" placeholder="Product name or code..." />
          </div>

          <div class="col-3" id="ropStatusWrap">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">ROP Status Filter</label>
            <select class="select" name="ropStatus" id="ropStatus">
              <option value="" ${empty ropStatus ? 'selected' : ''}>All Below ROP</option>
              <option value="Out Of Stock" ${ropStatus == 'Out Of Stock' ? 'selected' : ''}>Out Of Stock</option>
              <option value="Reorder Needed" ${ropStatus == 'Reorder Needed' ? 'selected' : ''}>Reorder Needed</option>
              <option value="At ROP Level" ${ropStatus == 'At ROP Level' ? 'selected' : ''}>At ROP Level</option>
              <option value="OK" ${ropStatus == 'OK' ? 'selected' : ''}>OK</option>
            </select>
          </div>

          <div class="col-2">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Export Format</label>
            <select class="select" name="format" id="format">
              <option value="xlsx" ${format == 'xlsx' ? 'selected' : ''}>Excel (.xlsx)</option>
              <option value="pdf" ${format == 'pdf' ? 'selected' : ''}>Adobe PDF (.pdf)</option>
            </select>
          </div>

          <div class="col-2">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">Detail Level</label>
            <select class="select" name="detailLevel" id="detailLevel">
              <option value="summary" ${detailLevel == 'summary' ? 'selected' : ''}>Summary</option>
              <option value="detail" ${detailLevel == 'detail' ? 'selected' : ''}>Detail</option>
            </select>
          </div>

          <div class="col-2" id="pdfOrientationWrap">
            <label class="d-block mb-4 fw-600 fs-12 text-muted uppercase">PDF Orientation</label>
            <select class="select" name="pdfOrientation" id="pdfOrientation">
              <option value="portrait" ${pdfOrientation == 'portrait' ? 'selected' : ''}>Portrait</option>
              <option value="landscape" ${pdfOrientation == 'landscape' ? 'selected' : ''}>Landscape</option>
            </select>
          </div>

          <div class="col-6 d-flex gap-8">
            <button class="btn btn-outline" type="submit" name="action" value="preview">Preview Data</button>
            <button class="btn btn-primary" type="submit" name="action" value="export">Export File</button>
            <a class="btn btn-outline" href="${ctx}/home?p=export-center">Reset</a>
          </div>
        </div>
      </form>
    </div>
  </div>

  <c:if test="${not empty previewTitle}">
    <div class="card">
      <div class="card-body">
        <div class="d-flex justify-between align-center mb-16">
            <div>
                <div class="h2">${previewTitle}</div>
                <div class="text-muted fs-13">Data-only preview. Final document styling may differ.</div>
            </div>
        </div>

        <div class="grid-12 gap-16 mb-20">
            <div class="col-6">
                <div class="p-16 bg-surface-2 border-radius" style="border: 1px solid var(--border);">
                    <div class="fw-700 fs-12 uppercase mb-8 text-primary">Applied Filters</div>
                    <div class="grid-12 gap-8">
                        <c:forEach items="${filterLines}" var="entry">
                            <div class="col-4 fs-12 text-muted">${entry.key}</div>
                            <div class="col-8 fs-12 fw-600 text-right">${entry.value}</div>
                        </c:forEach>
                    </div>
                </div>
            </div>
            <div class="col-6">
                <div class="p-16 bg-surface-2 border-radius" style="border: 1px solid var(--border);">
                    <div class="fw-700 fs-12 uppercase mb-8 text-primary">Report Summary</div>
                    <div class="grid-12 gap-8">
                        <c:forEach items="${summaryLines}" var="entry">
                            <div class="col-6 fs-12 text-muted">${entry.key}</div>
                            <div class="col-6 fs-12 fw-700 text-right text-primary">${entry.value}</div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>

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
                    <td colspan="${fn:length(previewHeaders)}">
                        <div class="p-40 text-center text-muted">No data found for these criteria.</div>
                    </td>
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