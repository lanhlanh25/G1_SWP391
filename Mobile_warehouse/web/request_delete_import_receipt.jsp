<%-- 
    Document   : request_delete_import_receipt
    Created on : Feb 15, 2026, 5:15:39 PM
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
  <title>Request Delete Import Receipt</title>
  
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
      max-width: 800px;
      margin: 0 auto;
      background: #fff;
      border: 2px solid var(--line);
      border-radius: 8px;
      padding: 20px;
    }
    
    .header {
      background: #f0f0f0;
      padding: 10px 15px;
      border-bottom: 2px solid var(--line);
      margin: -20px -20px 20px -20px;
      border-radius: 6px 6px 0 0;
    }
    
    .header h2 {
      margin: 0;
      font-size: 18px;
    }
    
    .user-info {
      font-size: 13px;
      color: #666;
      margin-top: 5px;
    }
    
    .form-group {
      margin-bottom: 15px;
    }
    
    .form-group label {
      display: block;
      font-weight: 700;
      margin-bottom: 5px;
      font-size: 13px;
    }
    
    .form-group input[type="text"],
    .form-group textarea {
      width: 100%;
      padding: 8px;
      border: 1px solid #333;
      box-sizing: border-box;
      font-size: 13px;
    }
    
    .form-group textarea {
      min-height: 120px;
      resize: vertical;
    }
    
    .form-group input[readonly] {
      background: #f0f0f0;
      color: #666;
    }
    
    .btn-group {
      display: flex;
      gap: 10px;
      margin-top: 20px;
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
    
    .btn-primary {
      background: #1f6feb;
      color: #fff;
      border-color: #1f6feb;
    }
    
    .err {
      background: #ffe9ee;
      border: 1px solid #b00020;
      color: #b00020;
      padding: 10px;
      margin-bottom: 15px;
      border-radius: 4px;
      font-size: 13px;
    }
  </style>
</head>
<body>

<div class="container">
  <div class="header">
    <h2>Request Delete Import Receipt</h2>
    <div class="user-info">
      Role: <strong>${fn:escapeXml(role)}</strong> | 
      User: <strong>${fn:escapeXml(username)}</strong>
    </div>
  </div>
  
  <c:if test="${not empty param.err}">
    <div class="err">${fn:escapeXml(param.err)}</div>
  </c:if>
  
  <form method="post" action="${ctx}/request-delete-import-receipt">
    <input type="hidden" name="importId" value="${importInfo.importId}"/>
    <input type="hidden" name="importCode" value="${fn:escapeXml(importInfo.importCode)}"/>
    
    <div class="form-group">
      <label>Import Code</label>
      <input type="text" value="${fn:escapeXml(importInfo.importCode)}" readonly/>
    </div>
    
    <div class="form-group">
      <label>Transaction time</label>
      <input type="text" value="<fmt:formatDate value="${importInfo.transactionTime}" pattern="MM/dd/yyyy h:mm a"/>" readonly/>
    </div>
    
    <div class="form-group">
      <label>Create By</label>
      <input type="text" value="${fn:escapeXml(currentUser)}" readonly/>
    </div>
    
    <div class="form-group">
      <label>Note <span style="color:red;">*</span></label>
      <textarea name="note" placeholder="Write reason you want to send request delete import receipt." required></textarea>
      <div style="font-size:12px; color:#666; margin-top:3px;">
        Example: Wrong product entered, duplicate entry, incorrect IMEI, etc.
      </div>
    </div>
    
    <div class="btn-group">
      <button type="submit" class="btn btn-primary">Send Request</button>
      <a href="${ctx}/import-receipt-list" class="btn">Cancel</a>
    </div>
  </form>
</div>

</body>
</html>
