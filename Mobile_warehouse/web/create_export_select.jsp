<%-- 
    Document   : create_export_select
    Created on : Feb 12, 2026, 1:16:16 PM
    Author     : Admin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  :root{ --line:#2e3f95; --bg:#f4f4f4; }
  *{ box-sizing:border-box; }
  .wrap{ padding:10px; background:var(--bg); font-family:Arial, Helvetica, sans-serif; }
  .frame{ border:2px solid var(--line); background:#fff; padding:14px; }
  .topbar{ display:flex; align-items:center; justify-content:space-between; margin-bottom:12px; gap:10px; }
  .title{ font-size:18px; font-weight:700; }
  .btn{ padding:10px 16px; border:1px solid #333; background:#f6f6f6; text-decoration:none; color:#111; cursor:pointer; display:inline-block; }
  .btn.primary{ background:#e9f0ff; }
  .btn.danger{ background:#ffecec; border-color:#c33; }
  .hint{ color:#666; font-size:12px; margin-top:6px; line-height:1.35; }
  .cards{ display:grid; grid-template-columns:repeat(2, minmax(260px, 1fr)); gap:14px; margin-top:12px; }
  .card{ border:1px solid #bbb; border-radius:8px; padding:14px; background:#fff; }
  .card h4{ margin:0 0 6px 0; font-size:16px; }
  .card p{ margin:0; font-size:13px; color:#444; line-height:1.45; }
  .actions{ display:flex; gap:10px; margin-top:14px; flex-wrap:wrap; }
  @media(max-width:900px){ .cards{ grid-template-columns:1fr; } }
</style>

<div class="wrap">
  <div class="frame">
    <div class="topbar">
      <div class="title">Create Export Receipt - Choose Method (Sale)</div>
      <div style="display:flex; gap:10px; flex-wrap:wrap;">
        <a class="btn" href="${ctx}/home?p=dashboard">Back</a>
      </div>
    </div>

    <div class="hint">
      Sale creates export receipt directly (no manager approval). After created, warehouse staff can see it immediately.
    </div>

    <div class="cards">
      <div class="card">
        <h4>Manual Entry</h4>
        <p>Add export lines manually. Best for small quantity / quick adjustments.</p>
        <div class="actions">
          <a class="btn primary" href="${ctx}/home?p=create-export-receipt">Go Manual</a>
        </div>
      </div>

      <div class="card">
        <h4>Upload Excel (.xlsx)</h4>
        <p>Upload IMEI list (or Qty). Best for bulk export and faster input.</p>
        <div class="actions">
          <a class="btn primary" href="${ctx}/home?p=upload-export-imeis">Go Upload</a>
        </div>
      </div>
    </div>

    <div class="actions">
      <a class="btn danger" href="${ctx}/home?p=dashboard">Cancel</a>
    </div>
  </div>
</div>
