<%-- 
    Document   : brand_list
    Created on : Jan 27, 2026, 11:19:16 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="role" value="${sessionScope.roleName}" />

<style>
    .page-wrap{
        padding:16px;
    }
    .topbar{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin-bottom:12px;
    }
    .title{
        font-size:22px;
        font-weight:700;
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
    .msg-ok{
        color:green;
        margin:8px 0;
    }
    .msg-err{
        color:red;
        margin:8px 0;
    }

    .filters{
        display:grid;
        grid-template-columns: 2fr 1fr 1fr 1fr auto auto;
        gap:10px;
        align-items:end;
        margin:10px 0 14px;
    }
    .filters label{
        display:block;
        font-size:12px;
        margin-bottom:4px;
        color:#333;
    }
    .filters input, .filters select{
        width:100%;
        padding:6px;
        border:1px solid #aaa;
        border-radius:3px;
    }

    table{
        width:100%;
        border-collapse:collapse;
    }
    th, td{
        border:1px solid #333;
        padding:8px;
        text-align:left;
        vertical-align:top;
    }
    th{
        background:#f1f1f1;
    }

    .badge{
        display:inline-flex;
        align-items:center;
        gap:6px;
        padding:4px 10px;
        border-radius:999px;     /* pill */
        font-size:12px;
        font-weight:700;
        border:1px solid transparent;
        line-height:1;
    }

    /* pill ACTIVE */
    .badge-active{
        color:#1b5e20;
        background:#e8f5e9;
        border-color:#c8e6c9;
    }

    /* pill INACTIVE */
    .badge-inactive{
        color:#8e0000;
        background:#ffebee;
        border-color:#ffcdd2;
    }



    /* Description cell */
    .desc-cell{
        max-width: 380px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .desc-link{
        color:#06c;
        cursor:pointer;
        text-decoration:underline;
        background:none;
        border:none;
        padding:0;
        font:inherit;
    }

    /* Small button like "View" */
    .mini-btn{
        display:inline-block;
        padding:2px 8px;
        border:1px solid #888;
        background:#e9e9e9;
        color:#111;
        border-radius:4px;
        cursor:pointer;
        font:inherit;
        line-height:1.2;
    }
    .mini-btn:hover{
        background:#dcdcdc;
    }

    /* Modal */
    .modal-backdrop{
        display:none;
        position:fixed;
        inset:0;
        background:rgba(0,0,0,0.35);
        z-index:999;
    }
    .modal{
        width:min(760px, 92vw);
        max-height:70vh;
        overflow:auto;
        background:#fff;
        border:1px solid #ccc;
        border-radius:10px;
        padding:14px;
        position:absolute;
        top:10vh;
        left:50%;
        transform:translateX(-50%);
    }
    .modal h3{
        margin:0 0 8px;
    }
    .modal pre{
        white-space:pre-wrap;
        word-break:break-word;
        margin:0;
        font-family:inherit;
    }
    .modal .close{
        float:right;
        border:1px solid #aaa;
        background:#f3f3f3;
        padding:4px 10px;
        cursor:pointer;
        border-radius:6px;
    }

    .paging{
        margin-top:12px;
        display:flex;
        gap:10px;
        justify-content:center;
        align-items:center;
    }
    .paging a{
        padding:4px 10px;
        border:1px solid #ccc;
        text-decoration:none;
        color:#111;
    }
    .paging b{
        padding:4px 10px;
        border:1px solid #333;
    }
</style>

<script>
    let _disableFormId = null;

    function openDisableModal(formId, brandName, brandDesc, toValue) {
        _disableFormId = formId;

        document.getElementById('disableBrandName').textContent = brandName || '';
        document.getElementById('disableBrandDesc').textContent = brandDesc || '';


        // NEW: đổi tiêu đề + text nút theo hành động
        const isToInactive = (toValue === '0'); // to=0 nghĩa là set Inactive
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
        if (!_disableFormId)
            return;
        const f = document.getElementById(_disableFormId);
        if (f)
            f.submit();
    }
</script>


<div class="page-wrap">
    <div class="topbar">
        <div class="title">Brand List</div>

        <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
            <c:url var="addUrl" value="/home">
                <c:param name="p" value="brand-add"/>
                <c:param name="q" value="${q}"/>
                <c:param name="status" value="${status}"/>
                <c:param name="sortBy" value="${sortBy}"/>
                <c:param name="sortOrder" value="${sortOrder}"/>
                <c:param name="page" value="${page}"/>
            </c:url>
            <a class="btn" href="${addUrl}">+ Add New Brand</a>
        </c:if>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="msg-ok">${fn:escapeXml(param.msg)}</div>
    </c:if>
    <c:if test="${not empty param.err}">
        <div class="msg-err">${fn:escapeXml(param.err)}</div>
    </c:if>

    <!-- Modal -->
    <div id="descModalBackdrop" class="modal-backdrop" onclick="closeDescModal()">
        <div class="modal" onclick="event.stopPropagation()">
            <button class="close" type="button" onclick="closeDescModal()">Close</button>
            <h3 id="descModalTitle">Description</h3>
            <pre id="descModalBody"></pre>
        </div>
    </div>

    <!-- Disable Confirm Modal (NEW) -->
    <div id="disableModalBackdrop" class="modal-backdrop" onclick="closeDisableModal()">
        <div class="modal" onclick="event.stopPropagation()">
            <h3 id="disableModalTitle">Disable Brand</h3>

            <div style="margin:8px 0; color:#333;">
                Are you sure you want to set this brand to <b><span id="disableActionText">Inactive</span></b>?

            </div>

            <div style="margin:8px 0;">
                <b>Name:</b> <span id="disableBrandName"></span>
            </div>

            <div style="margin:8px 0;">
                <b>Description:</b>
                <pre id="disableBrandDesc" style="margin-top:6px;"></pre>
            </div>

            <div style="display:flex; gap:10px; justify-content:flex-end; margin-top:12px;">
                <button id="disableConfirmBtn" type="button" class="btn"
                        style="border-color:#d32f2f;background:#ffecec;"
                        onclick="submitDisableForm()">
                    Confirm Disable
                </button>

                <button type="button" class="btn" onclick="closeDisableModal()">Cancel</button>

            </div>
        </div>
    </div>

    <!-- Filter form -->
    <form method="get" action="${ctx}/home">
        <input type="hidden" name="p" value="brand-list"/>

        <div class="filters">
            <div>
                <label>Search</label>
                <input name="q" value="${fn:escapeXml(q)}" placeholder="brand name"/>
            </div>

            <div>
                <label>Status</label>
                <select name="status">
                    <option value="" ${empty status ? 'selected' : ''}>All</option>
                    <option value="active" ${status=='active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${status=='inactive' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>

            <div>
                <label>Sort By</label>
                <select name="sortBy">
                    <option value="name" ${sortBy=='name'?'selected':''}>Name</option>
                    <option value="createdAt" ${sortBy=='createdAt'?'selected':''}>Created At</option>
                    <option value="status" ${sortBy=='status'?'selected':''}>Status</option>
                </select>
            </div>

            <div>
                <label>Order</label>
                <select name="sortOrder">
                    <option value="ASC" ${sortOrder=='ASC'?'selected':''}>Ascending (A→Z / Low→High)</option>
                    <option value="DESC" ${sortOrder=='DESC'?'selected':''}>Descending (Z→A / High→Low)</option>

                </select>
            </div>

            <button class="btn" type="submit">Apply</button>
            <a class="btn" href="${ctx}/home?p=brand-list">Reset</a>
        </div>
    </form>
    <%-- Show current filters so users know what they are viewing --%>
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



    <table>
        <tr>
            <th style="width:60px;">#</th>
            <th style="width:220px;">Brand Name</th>
            <th>Description</th>
            <th style="width:120px;">Status</th>
            <th style="width:180px;">Created At</th>
            <th style="width:220px;">Action</th>
        </tr>

        <c:forEach items="${brands}" var="b" varStatus="st">
            <tr>
                <td>${(page - 1) * pageSize + st.index + 1}</td>

                <td>
                    ${fn:escapeXml(b.brandName)}
                </td>

                <td class="desc-cell" title="${fn:escapeXml(b.description)}">
                    <c:choose>
                        <c:when test="${not empty b.description && fn:length(b.description) > 60}">
                            ${fn:escapeXml(fn:substring(b.description, 0, 60))}...
                            <%-- Use data-* to avoid breaking JS when text contains quotes --%>
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

                <td>${b.createdAt}</td>

                <td>
                    <c:url var="detailUrl" value="/home">
                        <c:param name="p" value="brand-detail"/>
                        <c:param name="id" value="${b.brandId}"/>
                    </c:url>
                    <a href="${detailUrl}">Detail</a>

                    <c:if test="${role != null && role.toUpperCase() == 'MANAGER'}">
                        |
                        <c:url var="updateUrl" value="/home">
                            <c:param name="p" value="brand-update"/>
                            <c:param name="id" value="${b.brandId}"/>
                            <c:param name="q" value="${q}"/>
                            <c:param name="status" value="${status}"/>
                            <c:param name="sortBy" value="${sortBy}"/>
                            <c:param name="sortOrder" value="${sortOrder}"/>
                            <c:param name="page" value="${page}"/>
                        </c:url>
                        <a href="${updateUrl}">Update</a>

                        |
                        <form id="disableForm_${b.brandId}" method="post"
                              action="${ctx}/manager/brand-disable"
                              style="display:inline;">

                            <input type="hidden" name="id" value="${b.brandId}"/>

                            <!-- NEW: to = 0 nếu đang Active (disable), to = 1 nếu đang Inactive (enable) -->
                            <input type="hidden" name="to" value="${b.active ? '0' : '1'}"/>

                            <!-- Keep list state -->
                            <input type="hidden" name="q" value="${q}"/>
                            <input type="hidden" name="status" value="${status}"/>
                            <input type="hidden" name="sortBy" value="${sortBy}"/>
                            <input type="hidden" name="sortOrder" value="${sortOrder}"/>
                            <input type="hidden" name="page" value="${page}"/>

                            <button type="button" class="mini-btn"
                                    data-name="${fn:escapeXml(b.brandName)}"
                                    data-desc="${fn:escapeXml(b.description)}"
                                    data-to="${b.active ? '0' : '1'}"
                                    onclick="openDisableModal('disableForm_${b.brandId}', this.dataset.name, this.dataset.desc, this.dataset.to)">
                                ${b.active ? 'Inactive' : 'Active'}

                            </button>
                        </form>



                    </c:if>
                </td>
            </tr>
        </c:forEach>

        <c:if test="${empty brands}">
            <tr>
                <td colspan="6" style="text-align:center;color:#666;">No data</td>
            </tr>
        </c:if>
    </table>

    <!-- Paging -->
    <div class="paging">
        <c:choose>
            <c:when test="${page <= 1}">
                <span style="color:#999;">&laquo; Prev</span>
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
                <a href="${prevUrl}">&laquo; Prev</a>
            </c:otherwise>
        </c:choose>

        <c:forEach begin="1" end="${totalPages}" var="i">
            <c:choose>
                <c:when test="${i == page}">
                    <b>${i}</b>
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
                    <a href="${pUrl}">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <c:choose>
            <c:when test="${page >= totalPages}">
                <span style="color:#999;">Next &raquo;</span>
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
                <a href="${nextUrl}">Next &raquo;</a>
            </c:otherwise>
        </c:choose>
    </div>
</div>
