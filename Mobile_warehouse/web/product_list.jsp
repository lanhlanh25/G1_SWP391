<%-- 
    Document   : product_list
    Created on : Jan 31, 2026, 10:16:26 PM
    Author     : Lanhlanh
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%
    Integer pageObj = (Integer) request.getAttribute("page");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    int curPage = (pageObj == null) ? 1 : pageObj;
    int totalPages = (totalPagesObj == null) ? 1 : totalPagesObj;
%>

<div class="page-wrap">

    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=dashboard">← Back</a>
            <h1 class="h1">View Product List</h1>
        </div>
        <c:if test="${sessionScope.roleName == 'MANAGER' || sessionScope.roleName == 'ADMIN'}">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/home?p=product-add">+ Add Product</a>
        </c:if>
    </div>

    <c:if test="${not empty param.msg}">
        <div class="msg-ok">${param.msg}</div>
    </c:if>
    <c:if test="${sessionScope.msg != null}">
        <div class="msg-ok">${sessionScope.msg}</div>
        <c:remove var="msg" scope="session"/>
    </c:if>

    <div class="card">
        <div class="card-body">
            <div class="h2" style="margin-bottom:6px;">Manage Products</div>
            <div class="muted" style="margin-bottom:14px;">Search and filter products in the warehouse.</div>

            <form method="get" action="${pageContext.request.contextPath}/home" class="filters" style="grid-template-columns: 2fr 1fr 1fr auto auto;">
                <input type="hidden" name="p" value="product-list"/>
                <input type="hidden" name="page" value="1"/>

                <div>
                    <label>Search Product</label>
                    <input class="input" type="text" name="q" value="${q != null ? q : ''}" placeholder="e.g. product name, code...">
                </div>

                <div>
                    <label>Brand</label>
                    <select class="select" name="brandId">
                        <option value="">All Brand</option>
                        <c:forEach var="b" items="${allBrands}">
                            <option value="${b.brandId}" ${brandId == (''+b.brandId) ? 'selected' : ''}>${b.brandName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label>Status</label>
                    <select class="select" name="status">
                        <option value="">All</option>
                        <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                        <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>

                <div style="display:flex; align-items:end;">
                    <button class="btn btn-primary" type="submit">Search</button>
                </div>

                <div style="display:flex; align-items:end;">
                    <a class="btn" href="${pageContext.request.contextPath}/home?p=product-list">Reset</a>
                </div>
            </form>

            <table class="table">
                <thead>
                    <tr>
                        <th>Product Code</th>
                        <th>Product Name</th>
                        <th>Brand</th>
                        <th style="width:120px;">Status</th>
                        <th style="width:160px;">Created At</th>
                        <th style="width:220px;">Action</th>
                    </tr>
                </thead>

                <tbody>
                    <c:forEach var="x" items="${products}">
                        <tr>
                            <td>${x.productCode}</td>
                            <td>${x.productName}</td>
                            <td>${x.brandName}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${x.status == 'ACTIVE'}">
                                        <span class="badge badge-active">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-inactive">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><fmt:formatDate value="${x.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                            <td>
                                <div style="display:flex; gap:6px; flex-wrap:wrap;">
                                    <a class="btn btn-sm" href="${pageContext.request.contextPath}/home?p=product-detail&id=${x.productId}">View</a>
                                    <c:if test="${sessionScope.roleName == 'MANAGER' || sessionScope.roleName == 'ADMIN'}">
                                        <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/manager/product/update?id=${x.productId}">Update</a>
                                        <a class="btn btn-sm btn-danger" href="${pageContext.request.contextPath}/manager/product/delete?id=${x.productId}">Delete</a>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty products}">
                        <tr><td colspan="6" style="text-align:center;">No data</td></tr>
                    </c:if>
                </tbody>
            </table>

            <c:if test="${totalPages > 1}">
                <div class="paging-footer">
                    <div class="paging-info">Page <b>${page}</b> of <b>${totalPages}</b></div>
                    <div class="paging">
                        <c:set var="base" value="${pageContext.request.contextPath}/home?p=product-list&q=${q}&brandId=${brandId}&status=${status}"/>

                        <% if (curPage > 1) { %>
                            <a class="paging-btn" href="<%= request.getContextPath() %>/home?p=product-list&q=${q}&brandId=${brandId}&status=${status}&page=<%= (curPage - 1) %>">Prev</a>
                        <% } else { %>
                            <span class="paging-btn disabled">Prev</span>
                        <% } %>

                        <% for (int i = 1; i <= totalPages; i++) { %>
                            <% if (i == curPage) { %>
                                <span class="paging-btn active"><%= i %></span>
                            <% } else { %>
                                <a class="paging-btn" href="<%= request.getContextPath() %>/home?p=product-list&q=${q}&brandId=${brandId}&status=${status}&page=<%= i %>"><%= i %></a>
                            <% } %>
                        <% } %>

                        <% if (curPage < totalPages) { %>
                            <a class="paging-btn" href="<%= request.getContextPath() %>/home?p=product-list&q=${q}&brandId=${brandId}&status=${status}&page=<%= (curPage + 1) %>">Next</a>
                        <% } else { %>
                            <span class="paging-btn disabled">Next</span>
                        <% } %>
                    </div>
                </div>
            </c:if>

        </div>
    </div>
</div>
