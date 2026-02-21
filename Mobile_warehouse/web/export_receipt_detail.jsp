<%-- 
    Document   : export_receipt_detail
    Created on : Feb 19, 2026, 1:56:11 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="role" value="${sessionScope.roleName}" />

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>View Export Receipt Detail</title>

  <style>
    :root{
      --line:#2e3f95;
      --bg:#f4f4f4;
      --th:#d9d9d9;
    }
    body{font-family: Arial, Helvetica, sans-serif; background:#eee; margin:0;}
    .wrap{padding:14px; background:var(--bg);}
    .frame{border:2px solid var(--line); background:#fff; padding:12px;}
    .topbar{display:flex; gap:10px; align-items:center; margin-bottom:10px;}
    .btn{display:inline-block; padding:6px 12px; border:1px solid #333; background:#f6f6f6; text-decoration:none; color:#111; cursor:pointer; font-size:13px;}
    .title{font-size:20px; font-weight:700;}
    .badge{display:inline-block; padding:6px 12px; border:1px solid #333; background:#f6f6f6; font-weight:700;}
    .badge.role{margin-left:10px;}
    .sectionTitle{font-weight:700; margin:12px 0 6px;}
    .infoGrid{display:grid; grid-template-columns: 180px 1fr; gap:6px 12px; max-width:720px;}
    .infoGrid .lbl{color:#111;}
    .infoGrid .val{color:#111;}
    table{width:100%; border-collapse:collapse; table-layout:fixed;}
    th,td{border:1px solid #999; padding:8px; font-size:13px; vertical-align:top;}
    th{background:#efefef; text-align:center; font-weight:700;}
    .colNo{width:60px; text-align:center;}
    .colProd{width:140px;}
    .colSku{width:210px;}
    .colQty{width:130px;}
    .colImei{width:520px;}
    .colNote{width:140px;}
    .colBy{width:140px;}
    .muted{color:#666; font-size:12px;}
    .imeiLine{white-space:pre-line; line-height:1.35;}
  </style>
</head>

<body>
<div class="wrap">
  <div class="frame">

    <div class="topbar">
      <a class="btn" href="${ctx}/export-receipt-list">← Back</a>
      <div class="title">View Export Receipt Detail</div>
    </div>

    <div style="display:flex; gap:10px; align-items:center; margin:4px 0 10px;">
      <div class="badge">Export Form</div>
      <div class="badge role">Role: <c:out value="${role}"/></div>
    </div>

    <c:if test="${empty header}">
      <div class="muted">No data (receipt not found).</div>
    </c:if>

    <c:if test="${not empty header}">
      <div class="infoGrid">
        <div class="lbl">Export Code</div>
        <div class="val"><c:out value="${header.exportCode}"/></div>

        <div class="lbl">Transaction time</div>
        <div class="val"><c:out value="${header.exportDateUi}"/></div>

        <div class="lbl">Request Code</div>
        <div class="val">
          <c:choose>
            <c:when test="${empty header.requestCode}">
              <span class="muted">N/A</span>
            </c:when>
            <c:otherwise>
              <c:out value="${header.requestCode}"/>
            </c:otherwise>
          </c:choose>
        </div>

        <div class="lbl">Note</div>
        <div class="val">
          <c:choose>
            <c:when test="${empty header.note}">
              <span class="muted">-</span>
            </c:when>
            <c:otherwise>
              <c:out value="${header.note}"/>
            </c:otherwise>
          </c:choose>
        </div>

        <div class="lbl">Status</div>
        <div class="val"><c:out value="${header.status}"/></div>
      </div>

      <div class="sectionTitle">Export Items</div>

      <table>
        <thead>
          <tr>
            <th class="colNo">#</th>
            <th class="colProd">Product Code</th>
            <th class="colSku">SKU</th>
            <th class="colQty">Quantity</th>
            <th class="colImei">Imei Numbers</th>
            <th class="colNote">Item note</th>
            <th class="colBy">Create By</th>
          </tr>
        </thead>
        <tbody>
          <c:if test="${empty lines}">
            <tr>
              <td colspan="7" class="muted">No items</td>
            </tr>
          </c:if>

          <c:forEach var="it" items="${lines}" varStatus="st">
            <tr>
              <td class="colNo"><c:out value="${st.index + 1}"/></td>
              <td class="colProd"><c:out value="${it.productCode}"/></td>
              <td class="colSku"><c:out value="${it.skuCode}"/></td>
              <td class="colQty">Products: <c:out value="${it.qty}"/></td>
              <td class="colImei">
                <div class="imeiLine">
                  <c:forEach var="im" items="${it.imeis}" varStatus="st2">
                    Imei <c:out value="${st2.index + 1}"/> : <c:out value="${im}"/><c:if test="${!st2.last}">&#10;</c:if>
                  </c:forEach>
                </div>
              </td>

              <!-- item_note: schema export_receipt_lines chưa có => để trống/hoặc nếu bạn add sau thì mapping sẽ tự có -->
              <td class="colNote">
                <c:choose>
                  <c:when test="${empty it.itemNote}">
                    <span class="muted"></span>
                  </c:when>
                  <c:otherwise>
                    <c:out value="${it.itemNote}"/>
                  </c:otherwise>
                </c:choose>
              </td>

              <td class="colBy"><c:out value="${it.createdByName}"/></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:if>

  </div>
</div>
</body>
</html>
