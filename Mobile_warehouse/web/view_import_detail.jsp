<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<style>
  .detail-container {
    background-color: #f2f2f2;
    padding: 30px;
    font-family: sans-serif;
  }
  .header-actions {
    display: flex;
    justify-content: flex-end;
    gap: 15px;
    margin-bottom: 20px;
  }
  .btn-action {
    padding: 8px 16px;
    border: none;
    color: white;
    font-weight: bold;
    cursor: pointer;
  }
  .btn-draft { background-color: #4A86E8; }
  .btn-approve { background-color: #00AA00; }
  .btn-reject { background-color: #CC0000; }
  
  .info-block {
    margin-bottom: 20px;
    font-size: 15px;
    line-height: 1.6;
  }
  .table-custom {
    width: 100%;
    border-collapse: collapse;
    background-color: #d9d9d9;
  }
  .table-custom th {
    text-align: left;
    padding: 12px;
    color: #333;
  }
  .table-custom td {
    background-color: white;
    padding: 12px;
    border-bottom: 1px solid #ccc;
  }
  .btn-view-imei {
    background-color: #4A86E8;
    color: white;
    text-decoration: none;
    padding: 6px 12px;
    font-size: 13px;
    border: 1px solid #333;
    cursor: pointer; 
  }
  .footer-total {
    text-align: right;
    margin-top: 10px;
    font-weight: bold;
    padding-right: 20px;
  }
  .note-box {
    margin-top: 30px;
    padding: 10px;
    background-color: white;
    border: 1px solid #333;
    min-height: 50px;
  }

  .modal {
    display: none; 
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5); 
  }
  .modal-content {
    background-color: #fefefe;
    margin: 10% auto; 
    padding: 20px;
    border: 1px solid #888;
    width: 40%;
    min-width: 300px;
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
  }
  .close {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
  }
  .close:hover, .close:focus {
    color: black;
    text-decoration: none;
  }
</style>

<div class="detail-container">
  <c:if test="${not empty receipt}">
    
    <div class="header-actions">
      <c:set var="statusUpper" value="${fn:toUpperCase(receipt.status)}" />
      <c:if test="${statusUpper eq 'DRAFT'}">
          <button class="btn-action btn-draft">Draft</button>
      </c:if>
      
      <c:if test="${role eq 'MANAGER' && (statusUpper eq 'DRAFT' || statusUpper eq 'PENDING')}">
          <form method="post" action="${pageContext.request.contextPath}/import-receipt-detail" style="display:inline;">
              <input type="hidden" name="id" value="${receipt.importId}"/>
              <input type="hidden" name="action" value="approve"/>
              <button type="submit" class="btn-action btn-approve" onclick="return confirm('Approve this receipt?');">Approve</button>
          </form>
          
          <form method="post" action="${pageContext.request.contextPath}/import-receipt-detail" style="display:inline;">
              <input type="hidden" name="id" value="${receipt.importId}"/>
              <input type="hidden" name="action" value="cancel"/>
              <button type="submit" class="btn-action btn-reject" onclick="return confirm('Reject this receipt?');">Reject</button>
          </form>
      </c:if>
    </div>

    <div class="info-block">
      <div>Receipt Code: ${receipt.importCode}</div>
      <div>Supplier: ${receipt.supplierName}</div>
      <div>Created By: ${receipt.createdByName}</div>
      <div>Created Date: <fmt:formatDate value="${receipt.receiptDate}" pattern="dd/MM/yyyy"/></div>
    </div>

    <table class="table-custom">
      <thead>
        <tr>
          <th>Product</th>
          <th>Color</th>
          <th>Storage</th>
          <th>RAM</th>
          <th style="text-align:center;">Quantity</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <c:set var="totalItems" value="0"/>
        <c:forEach var="it" items="${lines}">
          <tr>
            <td>${it.productName}</td>
            <td>${it.color}</td>
            <td>${it.storageGb}G</td>
            <td>${it.ramGb}GB</td>
            <td style="text-align:center;">${it.qty}</td>
            
            <td style="text-align:right;">
                <div id="imei-data-${it.lineId}" style="display:none;">
                    <c:choose>
                        <c:when test="${not empty it.imeiText}">
                            <c:out value="${it.imeiText}" />
                        </c:when>
                        <c:otherwise>Không có dữ liệu IMEI</c:otherwise>
                    </c:choose>
                </div>
                <button type="button" class="btn-view-imei" onclick="openImeiModal(${it.lineId})">
                    View IMEI
                </button>
            </td>

          </tr>
          <c:set var="totalItems" value="${totalItems + it.qty}"/>
        </c:forEach>
        <c:if test="${empty lines}">
          <tr><td colspan="6" style="text-align:center;">No items found</td></tr>
        </c:if>
      </tbody>
    </table>

    <%-- Tổng số lượng --%>
    <div class="footer-total">
        Total: ${totalItems}
    </div>

    <%-- Hộp Ghi chú --%>
    <div class="note-box">
        Note: ${receipt.note}
    </div>

  </c:if>
</div>

<div id="imeiModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeModal()">&times;</span>
    <h3 style="margin-top:0;">Danh sách IMEI</h3>
    <hr>
    <div id="imeiListContent" style="white-space: pre-line; line-height: 1.5; max-height: 300px; overflow-y: auto;">
    </div>
  </div>
</div>

<script>
    function openImeiModal(lineId) {
        var imeiData = document.getElementById('imei-data-' + lineId).innerHTML;
        document.getElementById('imeiListContent').innerHTML = imeiData;
        document.getElementById('imeiModal').style.display = 'block';
    }

    function closeModal() {
        document.getElementById('imeiModal').style.display = 'none';
    }

    window.onclick = function(event) {
        var modal = document.getElementById('imeiModal');
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }
</script>