<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- Breadcrumb --%>
<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Advanced /</span> Export Center
</h4>

<%-- Alerts --%>
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

<c:if test="${not empty err}">
    <div class="msg-err mb-16">${fn:escapeXml(err)}</div>
</c:if>

<c:if test="${not empty msg}">
    <div class="msg-ok mb-16">${fn:escapeXml(msg)}</div>
</c:if>
<%--summary--%>
<div class="card mb-16">
    <div class="card-body">
        <form method="get" action="${ctx}/export-center">
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label" for="reportType">Report Type</label>
                    <select class="form-select" name="reportType" id="reportType">
                        <option value="inventory" ${reportType == 'inventory' ? 'selected' : ''}>Inventory Report</option>
                        <option value="import" ${reportType == 'import' ? 'selected' : ''}>Import Report</option>
                        <option value="export" ${reportType == 'export' ? 'selected' : ''}>Export Report</option>
                        <option value="brand-statistic" ${reportType == 'brand-statistic' ? 'selected' : ''}>Brand Statistic</option>
                        <option value="low-stock" ${reportType == 'low-stock' ? 'selected' : ''}>Low Stock Report</option>
                    </select>
                </div>

                <div class="col-md-3" id="brandWrap">
                    <label class="form-label">Brand</label>
                    <select class="form-select" name="brandId" id="brandId">
                        <option value="">All Brands</option>
                        <c:forEach items="${allBrands}" var="b">
                            <option value="${b.brandId}" ${brandId == b.brandId || brandId == b.brandId.toString() ? 'selected' : ''}>
                                ${b.brandName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-3" id="fromWrap">
                    <label class="form-label">Date From</label>
                    <input class="form-control" type="date" name="from" value="${from}" />
                </div>

                <div class="col-md-3" id="toWrap">
                    <label class="form-label">Date To</label>
                    <input class="form-control" type="date" name="to" value="${to}" />
                </div>

                <div class="col-md-6" id="keywordWrap">
                    <label class="form-label">Search Product</label>
                    <input class="form-control" type="text" name="keyword" value="${keyword}" placeholder="Product name or code..." />
                </div>

                <div class="col-md-3" id="ropStatusWrap">
                    <label class="form-label">Stock Status Filter</label>
                    <select class="form-select" name="ropStatus" id="ropStatus">
                        <option value="" ${empty ropStatus ? 'selected' : ''}>All</option>
                        <option value="Out Of Stock" ${ropStatus == 'Out Of Stock' ? 'selected' : ''}>Out Of Stock</option>
                        <option value="Reorder Needed" ${ropStatus == 'Reorder Needed' ? 'selected' : ''}>Reorder Needed</option>
                        <option value="At Threshold" ${ropStatus == 'At Threshold' ? 'selected' : ''}>At Threshold</option>
                        <option value="OK" ${ropStatus == 'OK' ? 'selected' : ''}>OK</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Export Format</label>
                    <select class="form-select" name="format" id="format">
                        <option value="xlsx" ${format == 'xlsx' ? 'selected' : ''}>Excel (.xlsx)</option>
                        <option value="pdf" ${format == 'pdf' ? 'selected' : ''}>Adobe PDF (.pdf)</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Detail Level</label>
                    <select class="form-select" name="detailLevel" id="detailLevel">
                        <option value="summary" ${detailLevel == 'summary' ? 'selected' : ''}>Summary</option>
                        <option value="detail" ${detailLevel == 'detail' ? 'selected' : ''}>Detail</option>
                    </select>
                </div>

                <div class="col-md-3" id="pdfOrientationWrap">
                    <label class="form-label">PDF Orientation</label>
                    <select class="form-select" name="pdfOrientation" id="pdfOrientation">
                        <option value="portrait" ${pdfOrientation == 'portrait' ? 'selected' : ''}>Portrait</option>
                        <option value="landscape" ${pdfOrientation == 'landscape' ? 'selected' : ''}>Landscape</option>
                    </select>
                </div>

                <div class="col-12 mt-4 d-flex gap-2">
                    <button class="btn btn-outline-primary" type="submit" name="action" value="preview">
                        <i class="bx bx-show me-1"></i> Preview Data
                    </button>
                    <button class="btn btn-primary" type="submit" name="action" value="export">
                        <i class="bx bx-export me-1"></i> Export File
                    </button>
                    <a class="btn btn-outline-secondary" href="${ctx}/home?p=export-center">
                        <i class="bx bx-refresh me-1"></i> Reset
                    </a>
                </div>
            </div>
        </form>
    </div>
</div>

<c:if test="${not empty previewTitle}">
    <div class="card mt-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">${previewTitle}</h5>
            <span class="badge bg-label-info">Data Preview</span>
        </div>
        <div class="card-body">
            <div class="row g-4 mb-4">
                <div class="col-md-6">
                    <div class="card bg-label-secondary border-0 h-100">
                        <div class="card-body">
                            <h6 class="fw-bold mb-3"><i class="bx bx-filter-alt me-1"></i> Applied Filters</h6>
                            <div class="row g-2">
                                <c:forEach items="${filterLines}" var="entry">
                                    <div class="col-5 text-muted small">${entry.key}</div>
                                    <div class="col-7 fw-semibold small text-end">${entry.value}</div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card bg-label-primary border-0 h-100">
                        <div class="card-body">
                            <h6 class="fw-bold mb-3"><i class="bx bx-stats me-1"></i> Report Summary</h6>
                            <div class="row g-2">
                                <c:forEach items="${summaryLines}" var="entry">
                                    <div class="col-6 text-muted small">${entry.key}</div>
                                    <div class="col-6 fw-bold small text-end text-primary">${entry.value}</div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="table-responsive text-nowrap">
                <table class="table table-hover table-bordered">
                    <thead class="table-light">
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
                                    <td colspan="${fn:length(previewHeaders)}" class="text-center p-5">
                                        <i class="bx bx-search-alt fs-2 mb-2 d-block text-muted"></i>
                                        No data found for these criteria.
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
                pdfOrientationWrap.classList.toggle('d-none', !isPdf);
            }
        }

        function toggleReportSpecificFields() {
            const reportType = reportTypeEl ? reportTypeEl.value : 'inventory';
            const isLowStock = reportType === 'low-stock';
            const isBrandStatistic = reportType === 'brand-statistic';
            const isImportOrExport = reportType === 'import' || reportType === 'export';

            if (brandWrap) {
                brandWrap.classList.toggle('d-none', isImportOrExport);
            }

            if (fromWrap) {
                fromWrap.classList.toggle('d-none', isLowStock);
            }

            if (toWrap) {
                toWrap.classList.toggle('d-none', isLowStock);
            }

            if (keywordWrap) {
                keywordWrap.classList.toggle('d-none', reportType !== 'inventory');
            }

            if (ropStatusWrap) {
                ropStatusWrap.classList.toggle('d-none', !isLowStock);
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
