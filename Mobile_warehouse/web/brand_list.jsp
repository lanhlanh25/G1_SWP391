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
        padding:2px 8px;
        border:1px solid #999;
        border-radius:10px;
        font-size:12px;
        display:inline-block;
    }
    .badge-active{
        border-color:#2e7d32;
        color:#2e7d32;
        font-weight:600;
    }
    .badge-inactive{
        border-color:#d32f2f;
        color:#d32f2f;
        font-weight:600;
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

    function openDescModal(title, fullText) {
        document.getElementById('descModalTitle').textContent = 'Description - ' + title;
        document.getElementById('descModalBody').textContent = fullText || '';
        document.getElementById('descModalBackdrop').style.display = 'block';
    }
    function closeDescModal() {
        document.getElementById('descModalBackdrop').style.display = 'none';
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

                        <c:if test="${b.active}">
                            |
                            <form method="post"
                                  action="${ctx}/manager/brand-disable"
                                  style="display:inline;"
                                  onsubmit="return confirm('Confirm disable brand: ${fn:escapeXml(b.brandName)}?');">

                                <input type="hidden" name="id" value="${b.brandId}"/>

                                <!-- Keep list state -->
                                <input type="hidden" name="q" value="${q}"/>
                                <input type="hidden" name="status" value="${status}"/>
                                <input type="hidden" name="sortBy" value="${sortBy}"/>
                                <input type="hidden" name="sortOrder" value="${sortOrder}"/>
                                <input type="hidden" name="page" value="${page}"/>

                                <button type="submit"
                                        style="border:none;background:none;color:#06c;cursor:pointer;padding:0;text-decoration:underline;">
                                    Disable
                                </button>
                            </form>
                        </c:if>
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
