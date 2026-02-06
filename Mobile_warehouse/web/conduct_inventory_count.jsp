<%-- 
    Document   : conduct_inventory_count
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<style>
  .wrap{ padding:10px; background:#f4f4f4; font-family:Arial, Helvetica, sans-serif; }
  .topbar{ display:flex; gap:10px; align-items:center; }
  .btn{ padding:6px 14px; border:1px solid #333; background:#eee; text-decoration:none; color:#000; display:inline-block; cursor:pointer; }
  .title{ margin:0 0 0 10px; font-weight:800; }
  .box{ margin-top:10px; border:2px solid #3b5db7; background:#fff; padding:10px; }
  table{ width:100%; border-collapse:collapse; margin-top:10px; }
  th,td{ border:1px solid #333; padding:6px; font-size:12px; }
  th{ background:#ddd; }
  .st-enough{ color:#0a8a0a; font-weight:800; }
  .st-missing{ color:#d00000; font-weight:800; }
  .diff-input{ width:90px; padding:3px 6px; }
  .pagerbar{ display:flex; align-items:center; justify-content:space-between; margin-top:12px; gap:10px; flex-wrap:wrap; }
  .paging{ display:flex; justify-content:center; align-items:center; gap:8px; flex-wrap:wrap; }
  .pg{ display:inline-block; padding:6px 16px; border:2px solid #1d4f91; background:#eee; color:#000; text-decoration:none; font-weight:600; }
  .pg.active{ background:#3a7bd5; color:#000; }
  .pg.disabled{ pointer-events:none; opacity:0.5; }
</style>

<div class="wrap">
  <div class="topbar">
    <a class="btn" href="${pageContext.request.contextPath}/home">Back</a>
    <h3 class="title">Conduct Inventory Count</h3>
  </div>

  <div class="box">
    <b>Search Criteria</b>

    <form method="get" action="${pageContext.request.contextPath}/inventory-count" style="margin-top:8px;">
      <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Product name, SKU,..."
             style="width:240px; height:28px; padding:0 8px;"/>

      <select name="brandId" style="height:30px; margin-left:12px; width:160px;">
        <option value="">All Brands</option>
        <c:forEach var="b" items="${brands}">
          <option value="${b.id}" <c:if test="${b.id == brandId}">selected</c:if>>
            ${fn:escapeXml(b.name)}
          </option>
        </c:forEach>
      </select>

      <button class="btn" type="submit" style="margin-left:12px;">Search</button>
      <a class="btn" href="${pageContext.request.contextPath}/inventory-count">Reset</a>

      <input type="hidden" name="page" value="1"/>
      <input type="hidden" name="pageSize" value="${pageSize}"/>
    </form>

    <form method="post" action="${pageContext.request.contextPath}/inventory-count" style="margin-top:8px;">
      <input type="hidden" name="q" value="${fn:escapeXml(q)}"/>
      <input type="hidden" name="brandId" value="${fn:escapeXml(brandId)}"/>
      <input type="hidden" name="page" value="${pageNumber}"/>
      <input type="hidden" name="pageSize" value="${pageSize}"/>

      <div style="display:flex; justify-content:flex-end;">
        <button class="btn" type="submit">Save</button>
      </div>

      <table>
        <thead>
          <tr>
            <th style="width:160px;">SKU</th>
            <th>Product Name</th>
            <th style="width:120px;">Color</th>
            <th style="width:80px;">RAM</th>
            <th style="width:95px;">Storage</th>
            <th style="width:95px;">System Qty</th>
            <th style="width:110px;">Counted Qty</th>
            <th style="width:90px;">Status</th>
            <th style="width:120px;">Action</th>
          </tr>
        </thead>

        <tbody>
          <c:forEach var="r" items="${rows}">
            <tr>
              <td>${fn:escapeXml(r.skuCode)}</td>
              <td>${fn:escapeXml(r.productName)}</td>
              <td>${fn:escapeXml(r.color)}</td>
              <td style="text-align:center;">${r.ramGb} GB</td>
              <td style="text-align:center;">${r.storageGb} GB</td>

              <td style="text-align:center;">${r.systemQty}</td>

              <td style="text-align:center;">
                <input type="hidden" name="skuId" value="${r.skuId}"/>
                <input class="diff-input js-counted" type="number" name="countedQty"
                       min="0" value="${r.countedQty}" data-system="${r.systemQty}" />
              </td>

              <td style="text-align:center;" class="js-status">
                <c:choose>
                  <c:when test="${r.countedQty == r.systemQty}">
                    <span class="st-enough">enough</span>
                  </c:when>
                  <c:otherwise>
                    <span class="st-missing">missing</span>
                  </c:otherwise>
                </c:choose>
              </td>

              <td style="text-align:center;">
                <c:url var="imeiUrl" value="/imei-list">
                  <c:param name="skuId" value="${r.skuId}"/>
                  <c:param name="page" value="1"/>
                  <c:param name="pageSize" value="10"/>
                </c:url>
                <a href="${imeiUrl}" style="color:#0b39b8; text-decoration:underline;">View List IMEI</a>
              </td>
            </tr>
          </c:forEach>

          <c:if test="${empty rows}">
            <tr><td colspan="9" style="text-align:center;">No data</td></tr>
          </c:if>
        </tbody>
      </table>
    </form>

    <script>
      function updateStatusForInput(inputEl) {
        const systemQty = parseInt(inputEl.dataset.system || "0", 10);
        const countedQty = parseInt(inputEl.value || "0", 10);
        const tr = inputEl.closest("tr");
        const statusCell = tr ? tr.querySelector(".js-status") : null;
        if (!statusCell) return;
        statusCell.innerHTML = (countedQty === systemQty)
          ? '<span class="st-enough">enough</span>'
          : '<span class="st-missing">missing</span>';
      }
      document.querySelectorAll(".js-counted").forEach(inp => {
        inp.addEventListener("input", () => updateStatusForInput(inp));
        updateStatusForInput(inp);
      });
    </script>

  </div>
</div>
