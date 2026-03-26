<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="isManager" value="${not empty sessionScope.roleName && fn:toUpperCase(sessionScope.roleName) == 'MANAGER'}"/>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Warehouse /</span> Supplier Management
</h4>

<c:if test="${not empty param.msg or not empty msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        ${not empty msg ? msg : param.msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="card mb-4">
    <div class="card-body">
        <form method="get" action="${ctx}/home" class="row g-3">
            <input type="hidden" name="p" value="view_supplier"/>
            <input type="hidden" name="page" value="1"/>

            <div class="col-md-4">
                <label class="form-label">Search Supplier</label>
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control" name="q" value="${q}" placeholder="Name, email, phone..."/>
                </div>
            </div>

            <div class="col-md-2">
                <label class="form-label">Status</label>
                <select class="form-select" name="status">
                    <option value="" ${empty status ? 'selected' : ''}>All Status</option>
                    <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>

            <div class="col-md-3">
                <label class="form-label">Sort By</label>
                <div class="input-group">
                    <select class="form-select" name="sortBy">
                        <option value="newest" ${sortBy == 'newest' ? 'selected' : ''}>Newest</option>
                        <option value="name" ${sortBy == 'name' ? 'selected' : ''}>Name</option>
                        <option value="transactions" ${sortBy == 'transactions' ? 'selected' : ''}>Transactions</option>
                    </select>
                    <select class="form-select" name="sortOrder" style="max-width: 100px;">
                        <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>DESC</option>
                        <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>ASC</option>
                    </select>
                </div>
            </div>

            <div class="col-md-3 d-flex align-items-end gap-2">
                <button class="btn btn-primary w-100" type="submit">Apply Filters</button>
                <a class="btn btn-outline-secondary" href="${ctx}/home?p=view_supplier">
                    <i class="bx bx-refresh"></i>
                </a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Supplier List</h5>
        <c:if test="${isManager}">
            <a class="btn btn-primary" href="${ctx}/home?p=add_supplier">
                <i class="bx bx-plus me-1"></i> Add Supplier
            </a>
        </c:if>
    </div>

    <div class="table-responsive text-nowrap">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Supplier</th>
                    <th>Contact</th>
                    <th class="text-center">Status</th>
                    <th class="text-center">Transactions</th>
                    <th class="text-center">Action</th>
                </tr>
            </thead>

            <tbody class="table-border-bottom-0">
                <c:if test="${empty suppliers}">
                    <tr>
                        <td colspan="5" class="text-center p-4">No suppliers found matching your criteria.</td>
                    </tr>
                </c:if>

                <c:forEach var="s" items="${suppliers}">
                    <tr>
                        <td>
                            <div class="d-flex align-items-center">
                                <div class="avatar avatar-xs me-2">
                                    <span class="avatar-initial rounded bg-label-primary">
                                        <i class="bx bx-buildings"></i>
                                    </span>
                                </div>
                                <div>
                                    <h6 class="mb-0 text-truncate" style="max-width: 200px;">${s.supplierName}</h6>
                                    <small class="text-muted">ID: ${s.supplierId}</small>
                                </div>
                            </div>
                        </td>

                        <td>
                            <div class="d-flex flex-column">
                                <small class="fw-semibold">${s.email}</small>
                                <small class="text-muted">${s.phone}</small>
                            </div>
                        </td>

                        <td class="text-center">
                            <span class="badge ${s.isActive == 1 ? 'bg-label-success' : 'bg-label-secondary'}">
                                ${s.isActive == 1 ? 'Active' : 'Inactive'}
                            </span>
                        </td>

                        <td class="text-center">
                            <span class="fw-bold">${s.totalTransactions}</span>
                        </td>

                        <td class="text-center">
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>

                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="${ctx}/home?p=supplier_detail&id=${s.supplierId}">
                                        <i class="bx bx-show-alt me-1"></i> View Detail
                                    </a>

                                    <c:if test="${isManager}">
                                        <a class="dropdown-item" href="${ctx}/home?p=update_supplier&id=${s.supplierId}">
                                            <i class="bx bx-edit-alt me-1"></i> Edit Supplier
                                        </a>

                                        <c:choose>
                                            <c:when test="${s.isActive == 1}">
                                                <a class="dropdown-item text-danger"
                                                   href="javascript:void(0);"
                                                   data-id="${s.supplierId}"
                                                   data-name="${s.supplierName}"
                                                   data-action="deactivate"
                                                   onclick="openSupplierStatusModal(this)">
                                                    <i class="bx bx-block me-1"></i> Deactivate
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="dropdown-item text-success"
                                                   href="javascript:void(0);"
                                                   data-id="${s.supplierId}"
                                                   data-name="${s.supplierName}"
                                                   data-action="activate"
                                                   onclick="openSupplierStatusModal(this)">
                                                    <i class="bx bx-check-circle me-1"></i> Activate
                                                </a>
                                            </c:otherwise>
                                        </c:choose>

                                        <form id="supplierToggleForm_${s.supplierId}"
                                              method="post"
                                              action="${ctx}/supplier-toggle"
                                              style="display:none;">
                                            <input type="hidden" name="supplierId" value="${s.supplierId}"/>
                                            <input type="hidden" name="action" value="${s.isActive == 1 ? 'deactivate' : 'activate'}"/>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <c:set var="safeTotal" value="${empty totalItems ? 0 : totalItems}"/>
    <c:set var="safePage" value="${empty page ? 1 : page}"/>
    <c:set var="safeTotalPages" value="${empty totalPages ? 1 : totalPages}"/>
    <c:set var="safePageSize" value="${empty pageSize ? 5 : pageSize}"/>
    <c:set var="base" value="${ctx}/home?p=view_supplier&q=${q}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&page="/>

    <div class="card-footer d-flex justify-content-between align-items-center">
        <div class="text-muted small">
            Page <strong>${safePage}</strong> of <strong>${safeTotalPages}</strong>
        </div>

        <nav aria-label="Page navigation">
            <ul class="pagination pagination-sm mb-0">
                <li class="page-item ${safePage <= 1 ? 'disabled' : ''}">
                    <a class="page-link" href="${safePage > 1 ? base.concat(safePage-1) : 'javascript:void(0);'}">
                        <i class="bx bx-chevron-left"></i>
                    </a>
                </li>

                <c:set var="startPage" value="${safePage - 1 > 1 ? safePage - 1 : 1}"/>
                <c:set var="endPage" value="${safePage + 1 < safeTotalPages ? safePage + 1 : safeTotalPages}"/>

                <c:if test="${startPage > 1}">
                    <li class="page-item"><a class="page-link" href="${base}1">1</a></li>
                        <c:if test="${startPage > 2}">
                        <li class="page-item disabled"><span class="page-link">...</span></li>
                        </c:if>
                    </c:if>

                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                    <li class="page-item ${i == safePage ? 'active' : ''}">
                        <a class="page-link" href="${base}${i}">${i}</a>
                    </li>
                </c:forEach>

                <c:if test="${endPage < safeTotalPages}">
                    <c:if test="${endPage < safeTotalPages - 1}">
                        <li class="page-item disabled"><span class="page-link">...</span></li>
                        </c:if>
                    <li class="page-item"><a class="page-link" href="${base}${safeTotalPages}">${safeTotalPages}</a></li>
                    </c:if>

                <li class="page-item ${safePage >= safeTotalPages ? 'disabled' : ''}">
                    <a class="page-link" href="${safePage < safeTotalPages ? base.concat(safePage+1) : 'javascript:void(0);'}">
                        <i class="bx bx-chevron-right"></i>
                    </a>
                </li>
            </ul>
        </nav>
    </div>
</div>

<!-- Supplier Toggle Modal -->
<div id="supplierStatusModalBackdrop"
     class="modal-backdrop-custom"
     style="display:none;"
     onclick="if (event.target === this)
                 closeSupplierStatusModal()">

    <div class="modal-content-custom card border-0 shadow"
         style="max-width:420px; width:100%; margin:auto; border-radius:16px;">
        <div class="card-body text-center p-4">
            <div class="mb-3">
                <span id="supplierStatusIconWrap"
                      class="d-inline-flex align-items-center justify-content-center rounded-circle"
                      style="width:56px;height:56px;background:#fff3cd;color:#f59e0b;">
                    <i id="supplierStatusIcon" class="bx bx-error fs-3"></i>
                </span>
            </div>

            <h5 id="supplierStatusTitle" class="card-title mb-2 fw-semibold">Confirm Inactive?</h5>

            <p class="mb-1 text-muted" id="supplierStatusText">
                Are you sure you want to inactive supplier?
            </p>

            <small class="text-muted d-block mb-4" id="supplierStatusSubtext">
                This action can be reversed later.
            </small>

            <div class="d-flex justify-content-center gap-2">
                <button type="button" class="btn btn-outline-secondary btn-sm px-3" onclick="closeSupplierStatusModal()">
                    Cancel
                </button>
                <button type="button" id="supplierStatusConfirmBtn" class="btn btn-danger btn-sm px-3" onclick="submitSupplierToggleForm()">
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
        animation: supplierModalFadeIn 0.18s ease-out;
    }

    @keyframes supplierModalFadeIn {
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
    let _supplierToggleFormId = null;

    function openSupplierStatusModal(el) {
        const supplierId = el.dataset.id;
        const supplierName = el.dataset.name || '';
        const action = el.dataset.action || 'deactivate';

        _supplierToggleFormId = 'supplierToggleForm_' + supplierId;

        const isDeactivate = action === 'deactivate';

        document.getElementById('supplierStatusTitle').textContent =
                isDeactivate ? 'Confirm Inactive?' : 'Confirm Activate?';

        document.getElementById('supplierStatusText').textContent =
                isDeactivate
                ? ('Are you sure you want to inactive supplier ' + supplierName + '?')
                : ('Are you sure you want to activate supplier ' + supplierName + '?');

        document.getElementById('supplierStatusSubtext').textContent =
                isDeactivate
                ? 'This action can be reversed later.'
                : 'This supplier will become available again.';

        const confirmBtn = document.getElementById('supplierStatusConfirmBtn');
        const iconWrap = document.getElementById('supplierStatusIconWrap');
        const icon = document.getElementById('supplierStatusIcon');

        confirmBtn.textContent = isDeactivate ? 'Confirm Inactive' : 'Confirm Activate';
        confirmBtn.className = isDeactivate
                ? 'btn btn-danger btn-sm px-3'
                : 'btn btn-success btn-sm px-3';

        iconWrap.style.background = isDeactivate ? '#fff3cd' : '#d1fae5';
        iconWrap.style.color = isDeactivate ? '#f59e0b' : '#10b981';
        icon.className = isDeactivate ? 'bx bx-error fs-3' : 'bx bx-check-circle fs-3';

        document.getElementById('supplierStatusModalBackdrop').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeSupplierStatusModal() {
        document.getElementById('supplierStatusModalBackdrop').style.display = 'none';
        document.body.style.overflow = '';
        _supplierToggleFormId = null;
    }

    function submitSupplierToggleForm() {
        if (!_supplierToggleFormId)
            return;
        const form = document.getElementById(_supplierToggleFormId);
        if (form)
            form.submit();
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeSupplierStatusModal();
        }
    });
</script>