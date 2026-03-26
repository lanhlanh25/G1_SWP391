<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="d" value="${supplierDetail}"/>
<c:set var="isManager" value="${not empty sessionScope.roleName && sessionScope.roleName.toUpperCase() == 'MANAGER'}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Supplier Detail
</h4>

<c:if test="${not empty param.msg or not empty msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        ${not empty msg ? msg : param.msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="row g-4">
    <!-- Left: Supplier Info -->
    <div class="col-md-7">
        <div class="card h-100">
            <div class="card-header d-flex align-items-center justify-content-between">
                <h5 class="mb-0">Supplier Information</h5>
                <div class="d-flex gap-2">
                    <a class="btn btn-outline-secondary btn-sm" href="${ctx}/home?p=view_supplier">
                        <i class="bx bx-arrow-back me-1"></i> Back
                    </a>
                    <c:if test="${isManager}">
                        <a class="btn btn-primary btn-sm" href="${ctx}/home?p=update_supplier&id=${d.supplierId}">
                            <i class="bx bx-edit-alt me-1"></i> Update
                        </a>
                    </c:if>
                </div>
            </div>

            <div class="card-body">
                <table class="table table-borderless">
                    <tbody>
                        <tr>
                            <th class="ps-0" style="width: 150px;">Supplier ID</th>
                            <td class="text-muted">#${d.supplierId}</td>
                        </tr>
                        <tr>
                            <th class="ps-0">Supplier Name</th>
                            <td class="fw-bold fs-5">${d.supplierName}</td>
                        </tr>
                        <tr>
                            <th class="ps-0">Phone</th>
                            <td>
                                <span class="badge bg-label-primary">${d.phone}</span>
                            </td>
                        </tr>
                        <tr>
                            <th class="ps-0">Email</th>
                            <td>${d.email}</td>
                        </tr>
                        <tr>
                            <th class="ps-0">Address</th>
                            <td>${d.address}</td>
                        </tr>
                        <tr>
                            <th class="ps-0">Status</th>
                            <td>
                                <span class="badge ${d.isActive == 1 ? 'bg-label-success' : 'bg-label-secondary'}">
                                    ${d.isActive == 1 ? 'Active' : 'Inactive'}
                                </span>
                            </td>
                        </tr>

                        <c:if test="${isManager}">
                            <tr>
                                <th class="ps-0">Action</th>
                                <td class="pt-3">
                                    <c:choose>
                                        <c:when test="${d.isActive == 1}">
                                            <a class="btn btn-outline-danger btn-sm"
                                               href="javascript:void(0);"
                                               data-id="${d.supplierId}"
                                               data-name="${d.supplierName}"
                                               data-action="deactivate"
                                               onclick="openSupplierDetailStatusModal(this)">
                                                <i class="bx bx-block me-1"></i> Deactivate
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="btn btn-outline-success btn-sm"
                                               href="javascript:void(0);"
                                               data-id="${d.supplierId}"
                                               data-name="${d.supplierName}"
                                               data-action="activate"
                                               onclick="openSupplierDetailStatusModal(this)">
                                                <i class="bx bx-check-circle me-1"></i> Re-activate
                                            </a>
                                        </c:otherwise>
                                    </c:choose>

                                    <a class="btn btn-outline-info btn-sm ms-2"
                                       href="${ctx}/home?p=view_history&supplierId=${d.supplierId}">
                                        <i class="bx bx-history me-1"></i> Trade History
                                    </a>

                                    <form id="supplierDetailToggleForm_${d.supplierId}"
                                          method="post"
                                          action="${ctx}/supplier-toggle"
                                          style="display:none;">
                                        <input type="hidden" name="supplierId" value="${d.supplierId}"/>
                                        <input type="hidden" name="action" value="${d.isActive == 1 ? 'deactivate' : 'activate'}"/>
                                    </form>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Right: Activity Summary -->
    <div class="col-md-5">
        <div class="card h-100">
            <div class="card-header border-bottom">
                <h5 class="mb-0">Activity Summary</h5>
            </div>
            <div class="card-body pt-4">
                <div class="row g-4">
                    <div class="col-6">
                        <div class="d-flex align-items-center mb-2">
                            <div class="avatar me-2">
                                <span class="avatar-initial rounded bg-label-primary">
                                    <i class="bx bx-receipt"></i>
                                </span>
                            </div>
                            <h4 class="ms-1 mb-0">${d.totalImportReceipts}</h4>
                        </div>
                        <p class="mb-0 small text-muted">Total Receipts</p>
                    </div>

                    <div class="col-6">
                        <div class="d-flex align-items-center mb-2">
                            <div class="avatar me-2">
                                <span class="avatar-initial rounded bg-label-info">
                                    <i class="bx bx-package"></i>
                                </span>
                            </div>
                            <h4 class="ms-1 mb-0">${d.totalQtyImported}</h4>
                        </div>
                        <p class="mb-0 small text-muted">Total Qty</p>
                    </div>
                </div>

                <hr class="my-4">

                <div>
                    <h6 class="mb-3">Last Transaction</h6>
                    <div class="d-flex align-items-center">
                        <div class="avatar avatar-sm me-3">
                            <span class="avatar-initial rounded bg-label-secondary">
                                <i class="bx bx-time"></i>
                            </span>
                        </div>
                        <div>
                            <p class="mb-0 fw-bold">
                                <c:choose>
                                    <c:when test="${not empty d.lastTransaction}">
                                        ${d.lastTransaction}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">No transactions found</span>
                                    </c:otherwise>
                                </c:choose>
                            </p>
                            <small class="text-muted">Recorded Date</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Supplier Detail Toggle Modal -->
<div id="supplierDetailStatusModalBackdrop"
     class="modal-backdrop-custom"
     style="display:none;"
     onclick="if (event.target === this)
                 closeSupplierDetailStatusModal()">

    <div class="modal-content-custom card border-0 shadow"
         style="max-width:420px; width:100%; margin:auto; border-radius:16px;">
        <div class="card-body text-center p-4">
            <div class="mb-3">
                <span id="supplierDetailStatusIconWrap"
                      class="d-inline-flex align-items-center justify-content-center rounded-circle"
                      style="width:56px;height:56px;background:#fff3cd;color:#f59e0b;">
                    <i id="supplierDetailStatusIcon" class="bx bx-error fs-3"></i>
                </span>
            </div>

            <h5 id="supplierDetailStatusTitle" class="card-title mb-2 fw-semibold">Confirm Inactive?</h5>

            <p class="mb-1 text-muted" id="supplierDetailStatusText">
                Are you sure you want to inactive supplier?
            </p>

            <small class="text-muted d-block mb-4" id="supplierDetailStatusSubtext">
                This action can be reversed later.
            </small>

            <div class="d-flex justify-content-center gap-2">
                <button type="button" class="btn btn-outline-secondary btn-sm px-3" onclick="closeSupplierDetailStatusModal()">
                    Cancel
                </button>
                <button type="button" id="supplierDetailStatusConfirmBtn" class="btn btn-danger btn-sm px-3" onclick="submitSupplierDetailToggleForm()">
                    Confirm Inactive
                </button>
            </div>
        </div>
    </div>
</div>

<style>
    .modal-backdrop-custom {
        position: fixed;
        inset: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.45);
        z-index: 1090;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 24px;
    }

    .modal-content-custom {
        animation: supplierDetailModalFadeIn 0.18s ease-out;
    }

    @keyframes supplierDetailModalFadeIn {
        from {
            opacity: 0;
            transform: translateY(-8px) scale(0.98);
        }
        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }
</style>

<script>
    let _supplierDetailToggleFormId = null;

    function openSupplierDetailStatusModal(el) {
        const supplierId = el.dataset.id;
        const supplierName = el.dataset.name || '';
        const action = el.dataset.action || 'deactivate';

        _supplierDetailToggleFormId = 'supplierDetailToggleForm_' + supplierId;

        const isDeactivate = action === 'deactivate';

        document.getElementById('supplierDetailStatusTitle').textContent =
                isDeactivate ? 'Confirm Inactive?' : 'Confirm Activate?';

        document.getElementById('supplierDetailStatusText').textContent =
                isDeactivate
                ? ('Are you sure you want to inactive supplier ' + supplierName + '?')
                : ('Are you sure you want to activate supplier ' + supplierName + '?');

        document.getElementById('supplierDetailStatusSubtext').textContent =
                isDeactivate
                ? 'This action can be reversed later.'
                : 'This supplier will become available again.';

        const confirmBtn = document.getElementById('supplierDetailStatusConfirmBtn');
        const iconWrap = document.getElementById('supplierDetailStatusIconWrap');
        const icon = document.getElementById('supplierDetailStatusIcon');

        confirmBtn.textContent = isDeactivate ? 'Confirm Inactive' : 'Confirm Activate';
        confirmBtn.className = isDeactivate
                ? 'btn btn-danger btn-sm px-3'
                : 'btn btn-success btn-sm px-3';

        iconWrap.style.background = isDeactivate ? '#fff3cd' : '#d1fae5';
        iconWrap.style.color = isDeactivate ? '#f59e0b' : '#10b981';
        icon.className = isDeactivate ? 'bx bx-error fs-3' : 'bx bx-check-circle fs-3';

        document.getElementById('supplierDetailStatusModalBackdrop').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeSupplierDetailStatusModal() {
        document.getElementById('supplierDetailStatusModalBackdrop').style.display = 'none';
        document.body.style.overflow = '';
        _supplierDetailToggleFormId = null;
    }

    function submitSupplierDetailToggleForm() {
        if (!_supplierDetailToggleFormId)
            return;
        const form = document.getElementById(_supplierDetailToggleFormId);
        if (form)
            form.submit();
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeSupplierDetailStatusModal();
        }
    });
</script>