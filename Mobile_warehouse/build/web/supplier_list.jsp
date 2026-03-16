<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="isManager" value="${not empty sessionScope.roleName && fn:toUpperCase(sessionScope.roleName) == 'MANAGER'}"/>

<div class="page-wrap">

  <div class="topbar">
    <div style="display:flex; align-items:center; gap:10px;">
      <a class="btn" href="${pageContext.request.contextPath}/home?p=dashboard">← Back</a>
      <div>
        <h1 class="h1" style="margin:0;">Supplier List</h1>
        <div class="small muted" style="margin-top:4px;">Manager can manage suppliers; Staff view-only.</div>
      </div>
    </div>
    <c:if test="${isManager}">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/home?p=add_supplier">+ Add New Supplier</a>
    </c:if>
  </div>

  <c:if test="${not empty param.msg}">
    <p class="msg-ok">${param.msg}</p>
  </c:if>

  <%-- Filters --%>
  <div class="card" style="margin-bottom:14px;">
    <div class="card-body">
      <form method="get" action="${pageContext.request.contextPath}/home">
        <input type="hidden" name="p" value="view_supplier"/>
        <div class="filters" style="grid-template-columns: 2fr 1fr 1fr 1fr auto;">
          <div>
            <label class="label">Search</label>
            <input class="input" name="q" value="${q}" placeholder="name / email / phone"/>
          </div>
          <div>
            <label class="label">Status</label>
            <select class="select" name="status">
              <option value=""       ${empty status          ? 'selected' : ''}>All</option>
              <option value="active" ${status == 'active'   ? 'selected' : ''}>Active</option>
              <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Inactive</option>
            </select>
          </div>
          <div>
            <label class="label">Sort by</label>
            <select class="select" name="sortBy">
              <option value="newest"       ${sortBy == 'newest'       ? 'selected' : ''}>Newest</option>
              <option value="name"         ${sortBy == 'name'         ? 'selected' : ''}>Name</option>
              <option value="transactions" ${sortBy == 'transactions' ? 'selected' : ''}>Most Transactions</option>
            </select>
          </div>
          <div>
            <label class="label">Order</label>
            <select class="select" name="sortOrder">
              <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>DESC</option>
              <option value="ASC"  ${sortOrder == 'ASC'  ? 'selected' : ''}>ASC</option>
            </select>
          </div>
          <div style="display:flex; align-items:flex-end;">
            <button class="btn btn-primary" type="submit">Apply</button>
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
            <th>Supplier</th>
            <th>Contact</th>
            <th style="width:110px;">Status</th>
            <th style="width:120px; text-align:center;">Transactions</th>
            <th style="width:220px;">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty suppliers}">
            <tr><td colspan="5" class="small muted" style="padding:20px;">No suppliers found.</td></tr>
          </c:if>
          <c:forEach var="s" items="${suppliers}">
            <tr>
              <td>
                <b>${s.supplierName}</b>
                <div class="small muted">ID: ${s.supplierId}</div>
              </td>
              <td>
                <div>${s.email}</div>
                <div class="small muted">${s.phone}</div>
              </td>
              <td>
                <c:choose>
                  <c:when test="${s.isActive == 1}"><span class="badge badge-active">Active</span></c:when>
                  <c:otherwise><span class="badge badge-inactive">Inactive</span></c:otherwise>
                </c:choose>
              </td>
              <td style="text-align:center;">${s.totalTransactions}</td>
              <td>
                <div style="display:flex; gap:6px; flex-wrap:wrap;">
                  <a class="btn btn-sm" href="${pageContext.request.contextPath}/home?p=supplier_detail&id=${s.supplierId}">View</a>
                  <c:if test="${isManager}">
                    <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/home?p=update_supplier&id=${s.supplierId}">Update</a>
                    <c:choose>
                      <c:when test="${s.isActive == 1}">
                        <a class="btn btn-sm btn-warning" href="${pageContext.request.contextPath}/home?p=supplier_inactive&id=${s.supplierId}">Inactive</a>
                      </c:when>
                      <c:otherwise>
                        <form method="post" action="${pageContext.request.contextPath}/supplier-toggle" style="margin:0;">
                          <input type="hidden" name="supplierId" value="${s.supplierId}"/>
                          <button type="submit" class="btn btn-sm btn-primary">Active</button>
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
    </div>
  </div>


  <c:set var="safeTotal"      value="${empty totalItems  ? 0 : totalItems}"/>
  <c:set var="safePage"       value="${empty page        ? 1 : page}"/>
  <c:set var="safePageSize"   value="${empty pageSize    ? 5 : pageSize}"/>
  <c:set var="safeTotalPages" value="${empty totalPages  ? 1 : totalPages}"/>
  <c:set var="startRow" value="${safeTotal == 0 ? 0 : (safePage-1)*safePageSize+1}"/>
  <c:set var="endRow"   value="${safeTotal == 0 ? 0 : (safePage*safePageSize > safeTotal ? safeTotal : safePage*safePageSize)}"/>
  <c:set var="base" value="${pageContext.request.contextPath}/home?p=view_supplier&q=${q}&status=${status}&sortBy=${sortBy}&sortOrder=${sortOrder}&page="/>

  <div class="paging-footer">
    <div class="paging-info">Showing <b>${startRow}</b>–<b>${endRow}</b> of <b>${safeTotal}</b> suppliers</div>
    <div class="paging">
      <a class="paging-btn ${safePage==1 ? 'disabled' : ''}" href="${base}${safePage-1}">← Prev</a>
      <c:forEach var="i" begin="1" end="${safeTotalPages}">
        <c:choose>
          <c:when test="${i==safePage}"><span class="paging-btn active">${i}</span></c:when>
          <c:otherwise><a class="paging-btn" href="${base}${i}">${i}</a></c:otherwise>
        </c:choose>
      </c:forEach>
      <a class="paging-btn ${safePage==safeTotalPages ? 'disabled' : ''}" href="${base}${safePage+1}">Next →</a>
    </div>
  </div>

</div>