<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
    .wrap{
        padding:10px;
        background:#f4f4f4;
        font-family:Arial, Helvetica, sans-serif;
    }
    .top{
        display:flex;
        justify-content:space-between;
        align-items:flex-start;
        gap:10px;
    }
    .title{
        margin:0;
        font-size:22px;
        font-weight:800;
    }
    .sub{
        margin:4px 0 0;
        color:#666;
        font-size:13px;
    }
    .btn{
        padding:8px 14px;
        border:1px solid #333;
        background:#eee;
        text-decoration:none;
        color:#000;
        border-radius:8px;
        display:inline-block;
    }
    .bar{
        margin-top:12px;
        display:flex;
        gap:14px;
        align-items:flex-end;
        flex-wrap:wrap;
    }
    .field{
        display:flex;
        flex-direction:column;
        gap:6px;
    }
    .field label{
        font-size:12px;
        color:#333;
        font-weight:700;
    }
    input, select{
        padding:8px 10px;
        border:1px solid #888;
        border-radius:6px;
        min-width:220px;
        background:#fff;
    }
    .apply{
        height:34px;
    }

    table{
        width:100%;
        border-collapse:collapse;
        margin-top:12px;
        background:#fff;
    }
    th, td{
        border:1px solid #cfcfcf;
        padding:10px;
        text-align:left;
        vertical-align:middle;
    }
    th{
        background:#f2f2f2;
        font-size:13px;
    }
    .actions{
        display:flex;
        gap:10px;
    }
    .pill{
        display:inline-block;
        padding:2px 8px;
        border:1px solid #bbb;
        border-radius:999px;
        font-size:12px;
    }
    .pill.active{
        background:#e6ffea;
        border-color:#8fd39a;
    }
    .pill.inactive{
        background:#ffecec;
        border-color:#e18a8a;
    }
    .muted{
        color:#777;
        font-size:12px;
    }

    .footer{
        margin-top:12px;
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:10px;
        flex-wrap:wrap;
    }
    .pager{
        display:flex;
        gap:8px;
        align-items:center;
    }
    .pagebtn{
        padding:6px 10px;
        border:1px solid #333;
        background:#eee;
        border-radius:6px;
        text-decoration:none;
        color:#000;
    }
    .pagebtn.current{
        background:#ddd;
        font-weight:700;
    }
</style>

<div class="wrap">
    <div class="top">
        <div>
            <h2 class="title">Supplier List</h2>
            <div class="sub">Search, filter, and view suppliers. Manager can manage suppliers; Staff view-only.</div>
        </div>

        <c:if test="${sessionScope.roleName != null && sessionScope.roleName.toUpperCase() == 'MANAGER'}">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=add_supplier">Add new supplier</a>
        </c:if>
    </div>

    <form method="get" action="${pageContext.request.contextPath}/home" class="bar">
        <input type="hidden" name="p" value="view_supplier"/>

        <div class="field">
            <label>Search</label>
            <input name="q" value="${q}" placeholder="name/email/phone"/>
        </div>

        <div class="field">
            <label>Status</label>
            <select name="status">
                <option value="" ${empty status ? 'selected' : ''}>All</option>
                <option value="active" ${status == 'active' ? 'selected' : ''}>Active</option>
                <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
            </select>
        </div>

        <div class="field">
            <label>Sort by</label>
            <select name="sortBy">
                <option value="newest" ${sortBy == 'newest' ? 'selected' : ''}>Newest</option>
                <option value="name" ${sortBy == 'name' ? 'selected' : ''}>Name</option>
                <option value="rating" ${sortBy == 'rating' ? 'selected' : ''}>Rating</option>
                <option value="transactions" ${sortBy == 'transactions' ? 'selected' : ''}>Most Transaction</option>
            </select>
        </div>

        <div class="field">
            <label>Order</label>
            <select name="sortOrder">
                <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>DESC</option>
                <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>ASC</option>
            </select>
        </div>

        <button class="btn apply" type="submit">Apply</button>
    </form>

    <table>
        <thead>
            <tr>
                <th style="width:28%;">Supplier</th>
                <th style="width:22%;">Contact</th>
                <th style="width:12%;">Status</th>
                <th style="width:12%;">Rating</th>
                <th style="width:12%;">Transactions</th>
                <th style="width:14%;">Action</th>
            </tr>
        </thead>
        <tbody>
            <c:if test="${empty suppliers}">
                <tr><td colspan="6" class="muted">No suppliers found.</td></tr>
            </c:if>

            <c:forEach var="s" items="${suppliers}">
                <tr>
                    <td>
                        <b>${s.supplierName}</b><br/>
                        <span class="muted">ID: ${s.supplierId}</span>
                    </td>
                    <td>
                        <div>${s.email}</div>
                        <div class="muted">${s.phone}</div>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${s.isActive == 1}">
                                <span class="pill active">Active</span>
                            </c:when>
                            <c:otherwise>
                                <span class="pill inactive">Inactive</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${s.avgRating != null}">
                                ${s.avgRating}
                            </c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </td>
                    <td>${s.totalTransactions}</td>
                    <td>
                        <div class="actions">
                            <a class="btn" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${s.supplierId}">View</a>

                            <c:if test="${sessionScope.roleName != null && sessionScope.roleName.toUpperCase() == 'MANAGER'}">
                                <a class="btn" href="${pageContext.request.contextPath}/home?p=update_supplier&id=${s.supplierId}">Update</a>

                                <c:choose>
                                    <c:when test="${s.isActive == 1}">
                                        <a class="btn"
                                           href="${pageContext.request.contextPath}/home?p=supplier_inactive&id=${s.supplierId}">
                                            Inactive
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/supplier-toggle"
                                              style="display:inline;">
                                            <input type="hidden" name="supplierId" value="${s.supplierId}"/>
                                            <button type="submit" class="btn">Active</button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>

                            </c:if>
                        </div>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <div class="footer">
        <div class="muted">
            Showing ${(page-1)*pageSize+1} - ${page*pageSize > totalItems ? totalItems : page*pageSize} of ${totalItems} suppliers
        </div>

        <div class="pager">
            <c:set var="base"
                   value="${pageContext.request.contextPath}/home?p=view_supplier&q=${q}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&page=" />

            <a class="pagebtn" href="${base}${page-1}" style="${page==1?'pointer-events:none;opacity:.5;':''}">Prev</a>

            <c:forEach var="i" begin="1" end="${totalPages}">
                <a class="pagebtn ${i==page?'current':''}" href="${base}${i}">${i}</a>
            </c:forEach>

            <a class="pagebtn" href="${base}${page+1}" style="${page==totalPages?'pointer-events:none;opacity:.5;':''}">Next</a>
        </div>
    </div>
</div>
