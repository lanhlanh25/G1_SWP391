<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="role" value="${sessionScope.roleName}" />

<script>
    let _disableFormId = null;

    function openDisableModalByEl(el) {
        const formId = 'disableForm_' + el.dataset.id;
        const brandName = el.dataset.name;
        const toValue = el.dataset.to;

        _disableFormId = formId;
        document.getElementById('disableBrandName').textContent = brandName || '';

        const isToInactive = (toValue === '0');
        const actionText = isToInactive ? 'DEACTIVATE' : 'ACTIVATE';
        
        document.getElementById('disableActionText').textContent = actionText;
        document.getElementById('disableModalTitle').textContent = actionText + ' BRAND';
        
        const confirmBtn = document.getElementById('disableConfirmBtn');
        confirmBtn.textContent = 'Confirm ' + (isToInactive ? 'Deactivate' : 'Activate');
        confirmBtn.className = 'btn ' + (isToInactive ? 'btn-danger' : 'btn-primary');

        // Use Bootstrap Modal if possible, but keeping current logic for now or converting to Sneat Modal
        document.getElementById('disableModalBackdrop').style.display = 'flex';
    }

    function closeDisableModal() {
        document.getElementById('disableModalBackdrop').style.display = 'none';
        _disableFormId = null;
    }

    function submitDisableForm() {
        if (!_disableFormId) return;
        const f = document.getElementById(_disableFormId);
        if (f) f.submit();
    }

    function openDescModal(title, fullText) {
        document.getElementById('descModalTitle').textContent = title || 'Description';
        document.getElementById('descModalBody').textContent = fullText || '';
        document.getElementById('descModalBackdrop').style.display = 'flex';
    }

    function closeDescModal() {
        document.getElementById('descModalBackdrop').style.display = 'none';
    }
</script>

<h4 class="fw-bold py-3 mb-4">
    <span class="text-muted fw-light">Master Data /</span> Brands
</h4>

<c:if test="${not empty param.msg}">
    <div class="alert alert-success alert-dismissible" role="alert">
        ${fn:escapeXml(param.msg)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty param.err}">
    <div class="alert alert-danger alert-dismissible" role="alert">
        ${fn:escapeXml(param.err)}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<div class="card">
    <div class="card-header d-flex align-items-center justify-content-between">
        <h5 class="mb-0">Brand List</h5>
        <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
            <c:url var="addUrl" value="/home">
                <c:param name="p" value="brand-add"/>
            </c:url>
            <a class="btn btn-primary" href="${addUrl}"><i class="bx bx-plus me-1"></i> Add Brand</a>
        </c:if>
    </div>

    <div class="card-body">
        <form method="get" action="${ctx}/home" class="row g-3 mb-4">
            <input type="hidden" name="p" value="brand-list"/>
            <input type="hidden" name="status" value="${fn:escapeXml(status)}"/>

            <div class="col-md-6 col-lg-4">
                <div class="input-group input-group-merge">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" class="form-control" name="q" value="${fn:escapeXml(q)}" placeholder="Search by brand name..."/>
                </div>
            </div>

            <div class="col-md-3 col-lg-2">
                <select class="form-select" name="sortBy">
                    <option value="name" ${sortBy=='name'?'selected':''}>Sort by Name</option>
                    <option value="createdAt" ${sortBy=='createdAt'?'selected':''}>Sort by Date</option>
                    <option value="status" ${sortBy=='status'?'selected':''}>Sort by Status</option>
                </select>
            </div>

            <div class="col-md-3 col-lg-2">
                <select class="form-select" name="sortOrder">
                    <option value="ASC" ${sortOrder=='ASC'?'selected':''}>Ascending</option>
                    <option value="DESC" ${sortOrder=='DESC'?'selected':''}>Descending</option>
                </select>
            </div>

            <div class="col-md-3 col-lg-2">
                <button class="btn btn-primary w-100" type="submit">Apply</button>
            </div>
            
            <div class="col-md-1">
                <a class="btn btn-outline-secondary w-100" href="${ctx}/home?p=brand-list"><i class="bx bx-refresh"></i></a>
            </div>
        </form>

        <div class="nav-align-top mb-4">
            <ul class="nav nav-tabs" role="tablist">
                <li class="nav-item">
                    <a class="nav-link ${empty status ? 'active' : ''}" href="${ctx}/home?p=brand-list&status=">All Brands</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${status == 'active' ? 'active' : ''}" href="${ctx}/home?p=brand-list&status=active">Active</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${status == 'inactive' ? 'active' : ''}" href="${ctx}/home?p=brand-list&status=inactive">Inactive</a>
                </li>
            </ul>
        </div>

        <div class="table-responsive text-nowrap">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th class="text-center">#</th>
                        <th>Brand Details</th>
                        <th>Description</th>
                        <th class="text-center">Status</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    <c:forEach items="${brands}" var="b" varStatus="st">
                        <tr>
                            <td class="text-center">${(page - 1) * pageSize + st.index + 1}</td>
                            <td>
                                <strong>${fn:escapeXml(b.brandName)}</strong><br/>
                                <small class="text-muted">${b.createdAt}</small>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty b.description && fn:length(b.description) > 60}">
                                        <span class="cursor-pointer" 
                                              data-title="${fn:escapeXml(b.brandName)}" 
                                              data-fulltext="${fn:escapeXml(b.description)}"
                                              onclick="openDescModal(this.getAttribute('data-title'), this.getAttribute('data-fulltext'))">
                                            ${fn:escapeXml(fn:substring(b.description, 0, 60))}...
                                        </span>
                                    </c:when>
                                    <c:otherwise>${fn:escapeXml(b.description)}</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <span class="badge ${b.active ? 'bg-label-success' : 'bg-label-secondary'}">
                                    ${b.active ? 'Active' : 'Inactive'}
                                </span>
                            </td>
                            <td class="text-center">
                                <div class="dropdown">
                                    <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                        <i class="bx bx-dots-vertical-rounded"></i>
                                    </button>
                                    <div class="dropdown-menu">
                                        <c:url var="detailUrl" value="/home">
                                            <c:param name="p" value="brand-detail"/>
                                            <c:param name="id" value="${b.brandId}"/>
                                        </c:url>
                                        <a class="dropdown-item" href="${detailUrl}"><i class="bx bx-show-alt me-1"></i> View</a>
                                        
                                        <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
                                            <c:url var="updateUrl" value="/home">
                                                <c:param name="p" value="brand-update"/>
                                                <c:param name="id" value="${b.brandId}"/>
                                            </c:url>
                                            <a class="dropdown-item" href="${updateUrl}"><i class="bx bx-edit-alt me-1"></i> Edit</a>
                                            
                                            <form id="disableForm_${b.brandId}" method="post" action="${ctx}/manager/brand-disable" style="display:none;">
                                                <input type="hidden" name="id" value="${b.brandId}"/>
                                                <input type="hidden" name="to" value="${b.active ? '0' : '1'}"/>
                                                <input type="hidden" name="page" value="${page}"/>
                                            </form>
                                            <a class="dropdown-item ${b.active ? 'text-danger' : 'text-success'}" href="javascript:void(0);" 
                                               data-id="${b.brandId}"
                                               data-name="${fn:escapeXml(b.brandName)}"
                                               data-to="${b.active ? '0' : '1'}"
                                               onclick="openDisableModalByEl(this)">
                                                <i class="bx ${b.active ? 'bx-trash' : 'bx-check'} me-1"></i> ${b.active ? 'Deactivate' : 'Activate'}
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty brands}">
                        <tr><td colspan="5" class="text-center p-4">No brands found matches your criteria.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <div class="mt-4 d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Page <strong>${page}</strong> of <strong>${totalPages}</strong>
            </div>
            
            <nav aria-label="Page navigation">
                <ul class="pagination pagination-sm mb-0">
                    <%-- Prev Button --%>
                    <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                        <c:url var="prevUrl" value="/home">
                            <c:param name="p" value="brand-list"/><c:param name="page" value="${page-1}"/><c:param name="q" value="${q}"/><c:param name="status" value="${status}"/>
                        </c:url>
                        <a class="page-link" href="${page > 1 ? prevUrl : 'javascript:void(0);'}"><i class="bx bx-chevron-left"></i></a>
                    </li>

                    <%-- Sliding Window logic --%>
                    <c:set var="startPage" value="${page - 1 > 1 ? page - 1 : 1}"/>
                    <c:set var="endPage"   value="${page + 1 < totalPages ? page + 1 : totalPages}"/>

                    <c:if test="${startPage > 1}">
                        <c:url var="p1Url" value="/home">
                            <c:param name="p" value="brand-list"/><c:param name="page" value="1"/><c:param name="q" value="${q}"/><c:param name="status" value="${status}"/>
                        </c:url>
                        <li class="page-item"><a class="page-link" href="${p1Url}">1</a></li>
                        <c:if test="${startPage > 2}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                    </c:if>

                    <c:forEach var="i" begin="${startPage}" end="${endPage}">
                        <c:url var="pageUrl" value="/home">
                            <c:param name="p" value="brand-list"/><c:param name="page" value="${i}"/><c:param name="q" value="${q}"/><c:param name="status" value="${status}"/>
                        </c:url>
                        <li class="page-item ${i == page ? 'active' : ''}"><a class="page-link" href="${pageUrl}">${i}</a></li>
                    </c:forEach>

                    <c:if test="${endPage < totalPages}">
                        <c:if test="${endPage < totalPages - 1}"><li class="page-item disabled"><span class="page-link">...</span></li></c:if>
                        <c:url var="pLastUrl" value="/home">
                            <c:param name="p" value="brand-list"/><c:param name="page" value="${totalPages}"/><c:param name="q" value="${q}"/><c:param name="status" value="${status}"/>
                        </c:url>
                        <li class="page-item"><a class="page-link" href="${pLastUrl}">${totalPages}</a></li>
                    </c:if>

                    <%-- Next Button --%>
                    <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                        <c:url var="nextUrl" value="/home">
                            <c:param name="p" value="brand-list"/><c:param name="page" value="${page+1}"/><c:param name="q" value="${q}"/><c:param name="status" value="${status}"/>
                        </c:url>
                        <a class="page-link" href="${page < totalPages ? nextUrl : 'javascript:void(0);'}"><i class="bx bx-chevron-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>


    </div>
</div>

<!-- Modal Confirm Toggle Action -->
<div id="disableModalBackdrop" class="modal-backdrop-custom" style="display:none;" onclick="if(event.target==this) closeDisableModal()">
    <div class="modal-content-custom card p-4" style="max-width: 400px; margin: auto; margin-top: 100px;">
        <h5 id="disableModalTitle" class="card-title text-center mb-3">Confirm Action</h5>
        <p class="text-center mb-4">
            Are you sure you want to <span id="disableActionText" class="fw-bold">action</span> brand 
            <span id="disableBrandName" class="text-primary fw-bold"></span>?
        </p>
        <div class="d-flex justify-content-center gap-2">
            <button class="btn btn-outline-secondary" onclick="closeDisableModal()">Cancel</button>
            <button id="disableConfirmBtn" class="btn btn-primary" onclick="submitDisableForm()">Confirm</button>
        </div>
    </div>
</div>

<!-- Modal Description View -->
<div id="descModalBackdrop" class="modal-backdrop-custom" style="display:none;" onclick="if(event.target==this) closeDescModal()">
    <div class="modal-content-custom card p-4" style="max-width: 600px; margin: auto; margin-top: 50px;">
        <h5 id="descModalTitle" class="card-title mb-3">Description</h5>
        <div id="descModalBody" class="mb-4" style="white-space: pre-wrap; max-height: 300px; overflow-y: auto; background: #f8f9fa; padding: 15px; border-radius: 5px;"></div>
        <div class="d-flex justify-content-end">
            <button class="btn btn-primary" onclick="closeDescModal()">Close</button>
        </div>
    </div>
</div>

<style>
    .modal-backdrop-custom {
        position: fixed;
        top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.5);
        z-index: 1090;
        display: flex;
        align-items: flex-start;
        justify-content: center;
    }
    .cursor-pointer { cursor: pointer; color: #696cff; text-decoration: underline; }
</style>