<%-- 
    Document   : brand_list
    Created on : Jan 27, 2026, 11:19:16 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="role" value="${sessionScope.roleName}" />

<script>
    let _disableFormId = null;

    function openDisableModal(formId, brandName, brandDesc, toValue) {
        _disableFormId = formId;

        document.getElementById('disableBrandName').textContent = brandName || '';
        document.getElementById('disableBrandDesc').textContent = brandDesc || '';

        const isToInactive = (toValue === '0');
        document.getElementById('disableActionText').textContent = isToInactive ? 'Inactive' : 'Active';
        document.getElementById('disableModalTitle').textContent = isToInactive ? 'Set Inactive' : 'Set Active';
        document.getElementById('disableConfirmBtn').textContent = isToInactive ? 'Confirm Inactive' : 'Confirm Active';

        document.getElementById('disableModalBackdrop').style.display = 'block';
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
        document.getElementById('descModalBackdrop').style.display = 'block';
    }

    function closeDescModal() {
        document.getElementById('descModalBackdrop').style.display = 'none';
    }
</script>

<div class="page-wrap">
    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=dashboard">← Back</a>
            <h1 class="h1">View Brand List</h1>
        </div>

        <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
            <c:url var="addUrl" value="/home">
                <c:param name="p" value="brand-add"/>
                <c:param name="q" value="${q}"/>
                <c:param name="status" value="${status}"/>
                <c:param name="sortBy" value="${sortBy}"/>
                <c:param name="sortOrder" value="${sortOrder}"/>
                <c:param name="page" value="${page}"/>
            </c:url>
            <a class="btn btn-primary" href="${addUrl}">+ Add Brand</a>
        </c:if>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="msg-ok">${fn:escapeXml(param.msg)}</div>
    </c:if>
    <c:if test="${not empty param.err}">
        <div class="msg-err">${fn:escapeXml(param.err)}</div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <div class="h2" style="margin-bottom:6px;">Manage Brands</div>
            <div class="muted" style="margin-bottom:14px;">Define and manage product brands in your catalog.</div>

            <form method="get" action="${ctx}/home" class="filters" style="grid-template-columns: 1.5fr 1fr 1fr 1.5fr auto auto; gap: 12px; align-items: end;">
                <input type="hidden" name="p" value="brand-list"/>

                <div class="filter-group">
                    <label>Search Brand</label>
                    <input class="input" name="q" value="${fn:escapeXml(q)}" placeholder="Brand name..."/>
                </div>

                <div class="filter-group">
                    <label>Status</label>
                    <select class="select" name="status">
                        <option value="" ${empty status ? 'selected' : ''}>All Status</option>
                        <option value="active" ${status=='active' ? 'selected' : ''}>Active</option>
                        <option value="inactive" ${status=='inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label>Sort By</label>
                    <select class="select" name="sortBy">
                        <option value="name" ${sortBy=='name'?'selected':''}>Name</option>
                        <option value="createdAt" ${sortBy=='createdAt'?'selected':''}>Created At</option>
                        <option value="status" ${sortBy=='status'?'selected':''}>Status</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label>Order</label>
                    <select class="select" name="sortOrder">
                        <option value="ASC" ${sortOrder=='ASC'?'selected':''}>Ascending (A-Z)</option>
                        <option value="DESC" ${sortOrder=='DESC'?'selected':''}>Descending (Z-A)</option>
                    </select>
                </div>

                <div class="filter-actions" style="display:contents;">
                    <button class="btn btn-primary" type="submit" style="height: 38px;">Apply</button>
                    <a class="btn" href="${ctx}/home?p=brand-list" style="height: 38px;">Reset</a>
                </div>
            </form>

   
    <c:set var="statusLabel"
           value="${status=='active' ? 'Active'
                    : status=='inactive' ? 'Inactive'
                    : 'All'}" />

    <c:set var="sortLabel"
           value="${sortBy=='createdAt' ? 'Created At'
                    : sortBy=='status' ? 'Status'
                    : 'Name'}" />

    <c:set var="orderLabel" value="${empty sortOrder ? 'DESC' : sortOrder}" />

    <div style="color:#666; font-size:12px; margin:6px 0 10px;">
        Applied:
        Status = <b>${statusLabel}</b> •
        Search = <b>${empty q ? '-' : q}</b> •
        Sort = <b>${sortLabel}</b> <b>${orderLabel}</b>
    </div>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width:60px;">#</th>
                        <th style="width:220px;">Brand Name</th>
                        <th>Description</th>
                        <th style="width:120px;">Status</th>
                        <th style="width:180px;">Created At</th>
                        <th style="width:240px;">Action</th>
                    </tr>
                </thead>

                <tbody>
                    <c:forEach items="${brands}" var="b" varStatus="st">
                        <tr>
                            <td>${(page - 1) * pageSize + st.index + 1}</td>

                            <td style="font-weight:600;">${fn:escapeXml(b.brandName)}</td>

                            <td class="desc-cell" title="${fn:escapeXml(b.description)}">
                                <c:choose>
                                    <c:when test="${not empty b.description && fn:length(b.description) > 60}">
                                        ${fn:escapeXml(fn:substring(b.description, 0, 60))}...
                                        <button type="button" class="desc-link"
                                                data-title="${fn:escapeXml(b.brandName)}"
                                                data-full="${fn:escapeXml(b.description)}"
                                                onclick="openDescModal(this.dataset.title, this.dataset.full)">
                                            View
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        ${fn:escapeXml(b.description)}
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <td>
                                <span class="badge ${b.active ? 'badge-active' : 'badge-inactive'}">
                                    ${b.active ? 'Active' : 'Inactive'}
                                </span>
                            </td>

                            <td style="color:var(--muted);">${b.createdAt}</td>

                            <td>
                                <div style="display:flex; gap:6px; flex-wrap:nowrap; align-items:center;">
                                    <c:url var="detailUrl" value="/home">
                                        <c:param name="p" value="brand-detail"/>
                                        <c:param name="id" value="${b.brandId}"/>
                                    </c:url>
                                    <a class="btn btn-sm btn-info" href="${detailUrl}">View</a>

                                    <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
                                        <c:url var="updateUrl" value="/home">
                                            <c:param name="p" value="brand-update"/>
                                            <c:param name="id" value="${b.brandId}"/>
                                            <c:param name="q" value="${q}"/>
                                            <c:param name="status" value="${status}"/>
                                            <c:param name="sortBy" value="${sortBy}"/>
                                            <c:param name="sortOrder" value="${sortOrder}"/>
                                            <c:param name="page" value="${page}"/>
                                        </c:url>
                                        <a class="btn btn-sm btn-warning" href="${updateUrl}">Update</a>

                                        <form id="disableForm_${b.brandId}" method="post"
                                              action="${ctx}/manager/brand-disable"
                                              style="margin:0;">
                                            <input type="hidden" name="id" value="${b.brandId}"/>
                                            <input type="hidden" name="to" value="${b.active ? '0' : '1'}"/>
                                            <input type="hidden" name="q" value="${q}"/>
                                            <input type="hidden" name="status" value="${status}"/>
                                            <input type="hidden" name="sortBy" value="${sortBy}"/>
                                            <input type="hidden" name="sortOrder" value="${sortOrder}"/>
                                            <input type="hidden" name="page" value="${page}"/>

                                            <button type="button" class="btn btn-sm ${b.active ? 'btn-danger' : 'btn-primary'}"
                                                    data-name="${fn:escapeXml(b.brandName)}"
                                                    data-desc="${fn:escapeXml(b.description)}"
                                                    data-to="${b.active ? '0' : '1'}"
                                                    onclick="openDisableModal('disableForm_${b.brandId}', this.dataset.name, this.dataset.desc, this.dataset.to)">
                                                ${b.active ? 'Inactive' : 'Active'}
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty brands}">
                        <tr>
                            <td colspan="6" style="text-align:center;color:var(--muted);padding:24px;">No data found</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>


    <div class="paging-footer">
        <div class="paging-info">Page <b>${page}</b> of <b>${totalPages}</b></div>
        <div class="paging">
            <c:choose>
                <c:when test="${page <= 1}">
                    <span class="paging-btn disabled">&laquo; Prev</span>
                </c:when>
                <c:otherwise>
                    <c:url var="prevUrl" value="/home">
                        <c:param name="p" value="brand-list"/>
                        <c:param name="page" value="${page-1}"/>
                        <c:param name="q" value="${q}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="sortBy" value="${sortBy}"/>
                        <c:param name="sortOrder" value="${sortOrder}"/>
                    </c:url>
                    <a class="paging-btn" href="${prevUrl}">&laquo; Prev</a>
                </c:otherwise>
            </c:choose>

            <c:forEach begin="1" end="${totalPages}" var="i">
                <c:choose>
                    <c:when test="${i == page}">
                        <span class="paging-btn active">${i}</span>
                    </c:when>
                    <c:otherwise>
                        <c:url var="pUrl" value="/home">
                            <c:param name="p" value="brand-list"/>
                            <c:param name="page" value="${i}"/>
                            <c:param name="q" value="${q}"/>
                            <c:param name="status" value="${status}"/>
                            <c:param name="sortBy" value="${sortBy}"/>
                            <c:param name="sortOrder" value="${sortOrder}"/>
                        </c:url>
                        <a class="paging-btn" href="${pUrl}">${i}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>

            <c:choose>
                <c:when test="${page >= totalPages}">
                    <span class="paging-btn disabled">Next &raquo;</span>
                </c:when>
                <c:otherwise>
                    <c:url var="nextUrl" value="/home">
                        <c:param name="p" value="brand-list"/>
                        <c:param name="page" value="${page+1}"/>
                        <c:param name="q" value="${q}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="sortBy" value="${sortBy}"/>
                        <c:param name="sortOrder" value="${sortOrder}"/>
                    </c:url>
                    <a class="paging-btn" href="${nextUrl}">Next &raquo;</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>