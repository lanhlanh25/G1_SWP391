<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<style>
.wrap {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.title {
    font-size: 22px;
    font-weight: bold;
}

.btn-add {
    padding: 8px 14px;
    background: #28a745;
    color: #fff;
    border-radius: 6px;
    text-decoration: none;
}

.filters {
    display: flex;
    gap: 10px;
    margin-bottom: 15px;
    align-items: center;
}

.searchBox input {
    padding: 8px 10px;
    border-radius: 6px;
    border: 1px solid #ccc;
}

.searchBox button {
    padding: 8px 14px;
    border-radius: 6px;
    border: none;
    background: #007bff;
    color: #fff;
}

.filters select {
    padding: 8px 10px;
    border-radius: 6px;
    border: 1px solid #ccc;
}

.table-wrap table {
    width: 100%;
    border-collapse: collapse;
}

.table-wrap th {
    background: #f8f9fa;
    padding: 10px;
    text-align: left;
    border-bottom: 2px solid #ddd;
}

.table-wrap td {
    padding: 10px;
    border-bottom: 1px solid #eee;
}

.table-wrap tr:hover {
    background: #f5f5f5;
}

.action a {
    margin-right: 6px;
}

.paging {
    margin-top: 15px;
    display: flex;
    justify-content: space-between;
}

.page-btns a {
    padding: 6px 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    text-decoration: none;
    margin-right: 4px;
}

.page-btns a.active {
    background: #007bff;
    color: #fff;
    border-color: #007bff;
}
</style>

<div class="wrap">
    <div class="top">
        <div class="title">View Product List</div>
        <a class="btn-add" href="${pageContext.request.contextPath}/home?p=product-add">Add product</a>
    </div>

    <form method="get" action="${pageContext.request.contextPath}/home">
        <input type="hidden" name="p" value="product-list"/>
        <div class="filters" style="grid-template-columns: 2fr 1fr 1fr auto;">
          <div>
            <label class="label">Search</label>
            <input class="input" type="text" name="q" value="${q != null ? q : ''}" placeholder="Product name, code..."/>
          </div>
          <div>
            <label class="label">Brand</label>
            <select class="select" name="brandId" onchange="this.form.submit()">
              <option value="">All Brands</option>
              <c:forEach var="b" items="${allBrands}">
                <option value="${b.brandId}" ${brandId == (''+b.brandId) ? 'selected' : ''}>${b.brandName}</option>
              </c:forEach>
            </select>
          </div>
          <div>
            <label class="label">Status</label>
            <select class="select" name="status" onchange="this.form.submit()">
              <option value="">All Status</option>
              <option value="ACTIVE"   ${status == 'ACTIVE'   ? 'selected' : ''}>Active</option>
              <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
            </select>
          </div>
          <div style="display:flex; align-items:flex-end;">
            <button class="btn btn-primary" type="submit">Search</button>
          </div>
        </div>
      </form>
    </div>
  </div>

  <%-- Table --%>
  <div class="card">
    <div class="card-body" style="padding:0;">
      <table class="table">
        <thead>
          <tr>
            <th>Product Code</th>
            <th>Product Name</th>
            <th>Brand</th>
            <th style="width:110px;">Status</th>
            <th style="width:160px;">Created At</th>
            <th style="width:140px; text-align:center;">Action</th>
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
              <td style="text-align:center;">
                <div style="display:flex; gap:6px; justify-content:center;">
                  <a class="btn btn-sm"
                     href="${pageContext.request.contextPath}/manager/product/update?id=${x.productId}">Update</a>
                  <a class="btn btn-danger btn-sm"
                     href="${pageContext.request.contextPath}/manager/product/delete?id=${x.productId}">Delete</a>
                </div>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty products}">
            <tr><td colspan="6" class="small muted" style="padding:20px; text-align:center;">No data</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>

  <%-- Pagination --%>
  <c:set var="base" value="${pageContext.request.contextPath}/home?p=product-list&q=${q}&brandId=${brandId}&status=${status}"/>
  <div style="display:flex; align-items:center; justify-content:space-between; margin-top:14px; flex-wrap:wrap; gap:10px;">
    <div class="small">Page ${page} of ${totalPages}</div>
    <div class="paging">
      <c:if test="${page > 1}">
        <a class="paging-btn" href="${base}&page=${page-1}">← Prev</a>
      </c:if>
      <c:if test="${page <= 1}">
        <span class="paging-btn disabled">← Prev</span>
      </c:if>

      <c:forEach var="i" begin="1" end="${totalPages}">
        <c:choose>
          <c:when test="${i == page}"><b>${i}</b></c:when>
          <c:otherwise><a class="paging-btn" href="${base}&page=${i}">${i}</a></c:otherwise>
        </c:choose>
      </c:forEach>

      <c:if test="${page < totalPages}">
        <a class="paging-btn" href="${base}&page=${page+1}">Next →</a>
      </c:if>
      <c:if test="${page >= totalPages}">
        <span class="paging-btn disabled">Next →</span>
      </c:if>
    </div>
  </div>

</div>
