<%-- 
    Document   : request_delete_import_receipt_list
    Created on : Feb 15, 2026, 5:16:34 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Request Delete Import Receipt List</title>
  
  <style>
    :root {
      --blue: #3a7bd5;
      --line: #2e3f95;
      --bg: #f4f4f4;
    }
    
    body {
      font-family: Arial, Helvetica, sans-serif;
      background: var(--bg);
      margin: 0;
      padding: 20px;
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      background: #fff;
      border: 2px solid var(--line);
      border-radius: 8px;
      padding: 20px;
    }
    
    .topbar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }
    
    .title {
      font-size: 22px;
      font-weight: 700;
    }
    
    .btn {
      padding: 8px 16px;
      border: 1px solid #333;
      background: #f6f6f6;
      cursor: pointer;
      font-size: 13px;
      text-decoration: none;
      color: #111;
      display: inline-block;
    }
    
    .search-bar {
      display: flex;
      gap: 10px;
      margin-bottom: 20px;
      align-items: center;
    }
    
    .search-bar input[type="text"],
    .search-bar input[type="date"] {
      padding: 8px;
      border: 1px solid #333;
      font-size: 13px;
    }
    
    .search-bar input[type="text"] {
      width: 250px;
    }
    
    table {
      width: 100%;
      border-collapse: collapse;
    }
    
    th, td {
      border: 1px solid #cfcfcf;
      padding: 8px;
      font-size: 13px;
      vertical-align: top;
    }
    
    th {
      background: #efefef;
      text-align: left;
    }
    
    .center {
      text-align: center;
    }
    
    .pager {
      display: flex;
      justify-content: center;
      gap: 6px;
      margin-top: 15px;
      align-items: center;
    }
    
    .pill {
      display: inline-block;
      min-width: 26px;
      text-align: center;
      padding: 4px 8px;
      border: 1px solid #aaa;
      background: #f6f6f6;
    }
    
    .pill.active {
      background: var(--blue);
      color: #fff;
      border-color: var(--blue);
    }
  </style>
</head>
<body>

<div class="container">
  <div class="topbar">
    <div class="title">Request Delete Import Receipt List</div>
    <a href="${ctx}/import-receipt-list" class="btn">← Back</a>
  </div>
  
  <form method="get" action="${ctx}/request-delete-import-receipt-list" class="search-bar">
    <input type="text" name="q" value="${fn:escapeXml(q)}" placeholder="Search by import code"/>
    <input type="date" name="transactionTime" value="${fn:escapeXml(transactionTime)}" placeholder="mm/dd/yyyy"/>
    <button type="submit" class="btn">Search</button>
    <a href="${ctx}/request-delete-import-receipt-list" class="btn">Reset</a>
  </form>
  
  <table>
    <thead>
      <tr>
        <th style="width:60px;" class="center">#</th>
        <th style="width:150px;">Import Code</th>
        <th>Note</th>
        <th style="width:130px;">Create By</th>
        <th style="width:160px;">Transaction time</th>
      </tr>
    </thead>
    <tbody>
      <c:choose>
        <c:when test="${empty requests}">
          <tr>
            <td colspan="5" class="center" style="color:#999;">No pending delete requests</td>
          </tr>
        </c:when>
        <c:otherwise>
          <c:forEach var="req" items="${requests}" varStatus="st">
            <tr>
              <td class="center">${st.index + 1}</td>
              <td>${fn:escapeXml(req.importCode)}</td>
              <td>${fn:escapeXml(req.note)}</td>
              <td>${fn:escapeXml(req.requestedByName)}</td>
              <td>
                <fmt:formatDate value="${req.transactionTime}" pattern="MM/dd/yyyy h:mm a"/>
              </td>
            </tr>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </tbody>
  </table>
  
  <c:if test="${totalPages > 1}">
    <div class="pager">
      <c:choose>
        <c:when test="${page <= 1}">
          <span class="btn" style="opacity:.5; pointer-events:none;">Prev</span>
        </c:when>
        <c:otherwise>
          <a class="btn" href="${ctx}/request-delete-import-receipt-list?page=${page-1}&q=${fn:escapeXml(q)}&transactionTime=${fn:escapeXml(transactionTime)}">Prev</a>
        </c:otherwise>
      </c:choose>
      
      <span class="pill active">${page}</span>
      
      <c:choose>
        <c:when test="${page >= totalPages}">
          <span class="btn" style="opacity:.5; pointer-events:none;">Next</span>
        </c:when>
        <c:otherwise>
          <a class="btn" href="${ctx}/request-delete-import-receipt-list?page=${page+1}&q=${fn:escapeXml(q)}&transactionTime=${fn:escapeXml(transactionTime)}">Next</a>
        </c:otherwise>
      </c:choose>
    </div>
  </c:if>
</div>

</body>
</html>

