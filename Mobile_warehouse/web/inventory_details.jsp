<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
      <c:set var="ctx" value="${pageContext.request.contextPath}" />

      <link rel="stylesheet" href="${ctx}/assets/css/app.css">
      <%-- Internal styles moved to app.css --%>

        <div class="p-24">

          <div class="topbar mb-22">
            <a href="${ctx}/inventory" class="btn btn-sm btn-outline">← Back</a>

            <h1 class="h1">Inventory Details</h1>
          </div>

          <div class="id-chips">
            <div class="id-chip">
              <div class="chip-label">Quantity</div>
              <div class="chip-val">${totalQty} Phone</div>
            </div>
            <div class="id-chip">
              <div class="chip-label">Product Code</div>
              <div class="chip-val">${fn:escapeXml(productCode)}</div>
            </div>
            <div class="id-chip">
              <div class="chip-label">Product Model</div>
              <div class="chip-val">${fn:escapeXml(productModel)}</div>
            </div>
          </div>

          <c:url var="backToDetails" value="/inventory-details">
            <c:param name="productCode" value="${productCode}" />
            <c:param name="page" value="${pageNumber}" />
            <c:param name="pageSize" value="${pageSize}" />
          </c:url>

          <div class="card overflow-hidden">
            <div class="table-wrap">
              <table class="table">
                <thead>
                  <tr>
                    <th class="text-left">SKU</th>
                    <th class="text-center">Color</th>
                    <th class="text-center">RAM</th>
                    <th class="text-center">Storage</th>
                    <th class="text-center">Inventory Status</th>
                    <th class="text-right">Quantity</th>
                    <th class="text-center">Action</th>
                  </tr>
                </thead>
                <tbody>
                  <c:if test="${empty skuRows}">
                    <tr>
                      <td colspan="7" class="empty-row">No SKU variants found.</td>
                    </tr>
                  </c:if>
                  <c:forEach var="s" items="${skuRows}">
                    <tr>
                      <td class="text-left font-bold">${fn:escapeXml(s.skuCode)}</td>
                      <td class="text-center">${fn:escapeXml(s.color)}</td>
                      <td class="text-center">${s.ramGb} GB</td>
                      <td class="text-center">${s.storageGb} GB</td>
                      <td class="text-center">
                        <c:choose>
                          <c:when test="${s.stockStatus == 'OK'}">
                            <span class="badge badge-success">In Stock</span>
                          </c:when>
                          <c:when test="${s.stockStatus == 'LOW'}">
                            <span class="badge badge-warning">Low Stock</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-danger">Out of Stock</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-right font-bold">
                        ${s.qty}
                        <span style="font-size:11px;color:var(--muted);margin-left:2px;">Phone</span>
                      </td>
                      <td class="tc">
                        <c:url var="imeiUrl" value="/imei-list">
                          <c:param name="skuId" value="${s.skuId}" />
                          <c:param name="page" value="1" />
                          <c:param name="pageSize" value="10" />
                          <c:param name="back" value="${backToDetails}" />
                        </c:url>
                        <a class="btn btn-sm btn-outline" href="${imeiUrl}">View List IMEI</a>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>

            <div class="paging-footer">
              <div class="paging-info">Page <b>${pageNumber}</b> of <b>${totalPages}</b></div>

              <div class="paging">
                <c:url var="prevUrl" value="/inventory-details">
                  <c:param name="productCode" value="${productCode}" />
                  <c:param name="page" value="${pageNumber - 1}" />
                  <c:param name="pageSize" value="${pageSize}" />
                </c:url>
                <a class="paging-btn ${pageNumber <= 1 ? 'disabled' : ''}" href="${prevUrl}">← Prev</a>

                <c:forEach begin="${pgStart}" end="${pgEnd}" var="pg">
                  <c:url var="pgUrl" value="/inventory-details">
                    <c:param name="productCode" value="${productCode}" />
                    <c:param name="page" value="${pg}" />
                    <c:param name="pageSize" value="${pageSize}" />
                  </c:url>
                  <c:choose>
                    <c:when test="${pg == pageNumber}"><span class="paging-btn active">${pg}</span></c:when>
                    <c:otherwise><a class="paging-btn" href="${pgUrl}">${pg}</a></c:otherwise>
                  </c:choose>
                </c:forEach>

                <c:url var="nextUrl" value="/inventory-details">
                  <c:param name="productCode" value="${productCode}" />
                  <c:param name="page" value="${pageNumber + 1}" />
                  <c:param name="pageSize" value="${pageSize}" />
                </c:url>
                <a class="paging-btn ${pageNumber >= totalPages ? 'disabled' : ''}" href="${nextUrl}">Next →</a>
              </div>

              <div class="paging-size">
                <span>Rows:</span>
                <select class="select w-70"
                  onchange="location.href='${ctx}/inventory-details?productCode=${fn:escapeXml(productCode)}&page=1&pageSize='+this.value">
                  <option value="5" ${pageSize==5 ? 'selected' : '' }>5</option>
                  <option value="10" ${pageSize==10 ? 'selected' : '' }>10</option>
                  <option value="20" ${pageSize==20 ? 'selected' : '' }>20</option>
                </select>
              </div>
            </div>
          </div>

        </div>