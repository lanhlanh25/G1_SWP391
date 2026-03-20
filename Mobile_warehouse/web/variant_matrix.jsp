<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
    Integer pageObj = (Integer) request.getAttribute("page");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    Integer totalItemsObj = (Integer) request.getAttribute("totalItems");
    int curPage = (pageObj == null) ? 1 : pageObj;
    int totalPages = (totalPagesObj == null) ? 1 : totalPagesObj;
    int totalItems = (totalItemsObj == null) ? 0 : totalItemsObj;
%>

<div class="page-wrap">

    <div class="topbar">
        <div style="display:flex; align-items:center; gap:10px;">
            <a class="btn" href="${pageContext.request.contextPath}/home?p=product-list">← Back</a>
            <h1 class="h1">View Variants</h1>
        </div>
    </div>

    <div class="card">
        <div class="card-body">

            <form method="get" action="${pageContext.request.contextPath}/home" class="filters" style="grid-template-columns: 1fr 1fr 1fr 1fr 1fr auto;">
                <input type="hidden" name="p" value="variant-matrix">
                <input type="hidden" name="productId" value="${param.productId}">

                <div>
                    <label>Color</label>
                    <select class="select" name="color">
                        <option value="">- All Colors -</option>
                        <c:forEach items="${colors}" var="c">
                            <option value="${c}" ${param.color==c?"selected":""}>${c}</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label>Storage</label>
                    <select class="select" name="storage">
                        <option value="">- All Storage -</option>
                        <c:forEach items="${storages}" var="s">
                            <option value="${s}" ${param.storage==s?"selected":""}>${s}GB</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label>RAM</label>
                    <select class="select" name="ram">
                        <option value="">- All RAM -</option>
                        <c:forEach items="${rams}" var="r">
                            <option value="${r}" ${param.ram==r?"selected":""}>${r}GB</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label>Status</label>
                    <select class="select" name="status">
                        <option value="">- All Status -</option>
                        <option value="ACTIVE" ${param.status=="ACTIVE"?"selected":""}>ACTIVE</option>
                        <option value="INACTIVE" ${param.status=="INACTIVE"?"selected":""}>INACTIVE</option>
                    </select>
                </div>

                <div>
                    <label>Search SKU</label>
                    <input class="input" type="text" name="sku" value="${param.sku}" placeholder="Search SKU">
                </div>

                <div style="display:flex; align-items:end;">
                    <button class="btn btn-primary" type="submit">Filter</button>
                </div>
            </form>

            <table class="table">
                <thead>
                    <tr>
                        <th>SKU</th>
                        <th>Color</th>
                        <th>Storage</th>
                        <th>RAM</th>
                        <th style="width:120px;">Status</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${skus}" var="s">
                        <tr>
                            <td>${s.skuCode}</td>
                            <td>${s.color}</td>
                            <td>${s.storageGb}GB</td>
                            <td>${s.ramGb}GB</td>
                            <td>
                                <c:choose>
                                    <c:when test="${s.status=='ACTIVE'}">
                                        <span class="badge badge-active">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-inactive">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty skus}">
                        <tr><td colspan="5" style="text-align:center;">No variants found.</td></tr>
                    </c:if>
                </tbody>
            </table>

            <%-- Pagination --%>
            <div class="paging-footer">
                <div class="paging-info">
                    Showing <b><%= totalItems == 0 ? 0 : (curPage - 1) * 10 + 1 %></b>–<b><%= Math.min(curPage * 10, totalItems) %></b> 
                </div>
                <div class="paging">
                    <% if (curPage > 1) { %>
                        <a class="paging-btn" href="${pageContext.request.contextPath}/home?p=variant-matrix&productId=${param.productId}&color=${param.color}&storage=${param.storage}&ram=${param.ram}&status=${param.status}&sku=${param.sku}&page=<%= (curPage - 1) %>">Prev</a>
                    <% } else { %>
                        <span class="paging-btn disabled">Prev</span>
                    <% } %>

                    <% 
                        int start = Math.max(1, curPage - 1);
                        int end = Math.min(totalPages, start + 2);
                        if (end == totalPages) {
                            start = Math.max(1, end - 2);
                        }
                        for (int i = start; i <= end; i++) { 
                    %>
                        <% if (i == curPage) { %>
                            <span class="paging-btn active"><%= i %></span>
                        <% } else { %>
                            <a class="paging-btn" href="${pageContext.request.contextPath}/home?p=variant-matrix&productId=${param.productId}&color=${param.color}&storage=${param.storage}&ram=${param.ram}&status=${param.status}&sku=${param.sku}&page=<%= i %>"><%= i %></a>
                        <% } %>
                    <% } %>

                    <% if (curPage < totalPages) { %>
                        <a class="paging-btn" href="${pageContext.request.contextPath}/home?p=variant-matrix&productId=${param.productId}&color=${param.color}&storage=${param.storage}&ram=${param.ram}&status=${param.status}&sku=${param.sku}&page=<%= (curPage + 1) %>">Next</a>
                    <% } else { %>
                        <span class="paging-btn disabled">Next</span>
                    <% } %>
                </div>
            </div>

        </div>
    </div>

</div>