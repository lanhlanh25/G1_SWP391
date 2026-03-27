<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page import="model.User"%>
<%
    User u = (User) session.getAttribute("authUser");
    if (u == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String ctx = request.getContextPath();
    String sidebarPage = (String) request.getAttribute("sidebarPage");
    String contentPage = (String) request.getAttribute("contentPage");
    String currentPage = (String) request.getAttribute("currentPage");
    String roleName = (String) session.getAttribute("roleName");
    if (roleName == null) roleName = "";
    if (sidebarPage == null || sidebarPage.isBlank()) sidebarPage = "sidebar_staff.jsp";
    if (contentPage == null || contentPage.isBlank()) contentPage = "content.jsp";
    if (currentPage == null || currentPage.isBlank()) currentPage = "dashboard";
    if (sidebarPage.startsWith("/")) sidebarPage = sidebarPage.substring(1);
    if (contentPage.startsWith("/")) contentPage = contentPage.substring(1);

    String avatarPath = (u.getAvatar() == null) ? "" : u.getAvatar().trim();
    String avatarUrl = avatarPath.isBlank()
            ? (ctx + "/assets/img/avatars/1.png")
            : (ctx + "/" + avatarPath);
    String fullName = u.getFullName() == null ? "User" : u.getFullName().trim();
%>
<!DOCTYPE html>
<html lang="en" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="<%=ctx%>/assets/" data-template="vertical-menu-template-free">
<head>
    <meta charset="utf-8" />
    <title>DTLA Mobile WMS</title>
    <%@ include file="/WEB-INF/jspf/common_head.jspf" %>
    <script>
        const ctx = '<%=ctx%>';
    </script>
</head>
<body>
    <div class="layout-wrapper layout-content-navbar">
        <div class="layout-container">
            <!-- Menu -->
            <aside id="layout-menu" class="layout-menu menu-vertical menu bg-dark">
                <div class="app-brand demo">
                    <a href="<%=ctx%>/home?p=dashboard" class="app-brand-link">
                        <span class="app-brand-text demo menu-text fw-bolder ms-2" style="text-transform: capitalize;">DTLA WMS</span>
                    </a>
                    <a href="javascript:void(0);" class="layout-menu-toggle menu-link text-large ms-auto d-block d-xl-none">
                        <i class="bx bx-chevron-left bx-sm align-middle"></i>
                    </a>
                </div>
                <div class="menu-inner-shadow"></div>
                <ul class="menu-inner py-1">
                    <jsp:include page="<%= sidebarPage %>" />
                </ul>
            </aside>
            <!-- / Menu -->

            <!-- Layout container -->
            <div class="layout-page">
                <!-- Navbar -->
                <nav class="layout-navbar container-xxl navbar navbar-expand-xl navbar-detached align-items-center bg-navbar-theme" id="layout-navbar">
                    <div class="layout-menu-toggle navbar-nav align-items-xl-center me-3 me-xl-0 d-xl-none">
                        <a class="nav-item nav-link px-0 me-xl-4" href="javascript:void(0)">
                            <i class="bx bx-menu bx-sm"></i>
                        </a>
                    </div>

                    <div class="navbar-nav-right d-flex align-items-center" id="navbar-collapse">
                        <!-- Search -->
                        <div class="navbar-nav align-items-center">
                            <form action="<%=ctx%>/home" method="get" class="nav-item d-flex align-items-center" id="navbar-search-form" style="position: relative; width: 400px;">
                                <input type="hidden" name="p" value="product-list" />
                                <div class="search-input-wrapper w-100 d-flex align-items-center bg-light rounded-pill px-3 py-1 border transition-all" id="search-container">
                                    <i class="bx bx-search fs-5 text-muted"></i>
                                    <input type="text" name="q" id="navbar-search-input" class="form-control border-0 bg-transparent shadow-none ms-1 py-1" placeholder="Search pages or products..." aria-label="Search..." autocomplete="off" value="${fn:escapeXml(param.q)}" />
                                </div>
                                <button type="submit" style="display: none;"></button>
                                
                                <%-- Search Results Dropdown --%>
                                <div id="navbar-search-results" class="dropdown-menu border-0 shadow-lg mt-2 py-2 overflow-hidden" style="display: none; position: absolute; top: 100%; left: 0; right: 0; min-width: 400px; max-height: 450px; overflow-y: auto; z-index: 1070; border-radius: 12px; background: rgba(255, 255, 255, 0.98); backdrop-filter: blur(10px);">
                                </div>
                            </form>
                        </div>
                        <!-- /Search -->

                        <style>
                            .search-input-wrapper {
                                border-color: rgba(67, 89, 113, 0.2);
                                transition: all 0.2s ease;
                                background-color: #f5f7f9 !important;
                            }
                            .search-input-wrapper:focus-within {
                                border-color: #696cff;
                                background-color: #fff !important;
                                box-shadow: 0 0 0 0.2rem rgba(105, 108, 255, 0.1);
                            }
                            #navbar-search-results .dropdown-item {
                                border-radius: 8px;
                                margin: 0 8px;
                                width: calc(100% - 16px);
                            }
                            #navbar-search-results .dropdown-item.active, 
                            #navbar-search-results .dropdown-item:hover {
                                background-color: #f0f1ff;
                                color: #696cff;
                            }
                            #navbar-search-results .icon-badge {
                                width: 32px;
                                height: 32px;
                                background: #f8f9fa;
                                border-radius: 6px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                            }
                            #navbar-search-results .dropdown-item:hover .icon-badge {
                                background: #fff;
                            }
                        </style>

                        <script>
                            document.addEventListener('DOMContentLoaded', function() {
                                const searchInput = document.getElementById('navbar-search-input');
                                const resultsDiv = document.getElementById('navbar-search-results');
                                
                                // Define searchable pages with icons
                                const pages = [
                                    { name: 'Dashboard', url: ctx + '/home?p=dashboard', icon: 'bx-home-circle', color: 'primary', keywords: 'tong quan, bieu do, stats, home' },
                                    { name: 'Inventory Management', url: ctx + '/inventory', icon: 'bx-package', color: 'info', keywords: 'ton kho, kho, inventory, quan ly kho' },
                                    { name: 'Inventory Report', url: ctx + '/inventory-report', icon: 'bx-bar-chart-alt-2', color: 'warning', keywords: 'bao cao ton kho, inventory report' },
                                    { name: 'Inventory Count', url: ctx + '/inventory-count', icon: 'bx-check-double', color: 'success', keywords: 'kiem ke, count, kiem kho' },
                                    { name: 'Variant Matrix', url: ctx + '/home?p=variant-matrix', icon: 'bx-grid-alt', color: 'secondary', keywords: 'bien the, variant, matrix' },
                                    
                                    { name: 'Import Requests', url: ctx + '/home?p=import-request-list', icon: 'bx-download', color: 'primary', keywords: 'yeu cau nhap, import request, request list' },
                                    { name: 'Export Requests', url: ctx + '/home?p=export-request-list', icon: 'bx-upload', color: 'danger', keywords: 'yeu cau xuat, export request, request list' },
                                    
                                    { name: 'Import Receipt List', url: ctx + '/home?p=import-receipt-list', icon: 'bx-file', color: 'info', keywords: 'bien ban nhap, receipt, phieu nhap, receipt list' },
                                    { name: 'Export Receipt List', url: ctx + '/home?p=export-receipt-list', icon: 'bx-file', color: 'warning', keywords: 'bien ban xuat, receipt, phieu xuat, receipt list' },
                                    
                                    { name: 'Product List', url: ctx + '/home?p=product-list', icon: 'bx-list-ul', color: 'primary', keywords: 'san pham, products, product list, ds san pham' },
                                    { name: 'Add Product', url: ctx + '/home?p=product-add', icon: 'bx-plus-circle', color: 'success', keywords: 'them san pham, new product' },
                                    { name: 'Add SKU', url: ctx + '/home?p=sku-add', icon: 'bx-plus-circle', color: 'info', keywords: 'them sku, new sku, variant' },
                                    
                                    { name: 'Brand List', url: ctx + '/home?p=brand-list', icon: 'bx-bookmark', color: 'primary', keywords: 'thuong hieu, nhan hieu, brand' },
                                    { name: 'Add Brand', url: ctx + '/home?p=brand-add', icon: 'bx-plus-circle', color: 'success', keywords: 'them thuong hieu, new brand' },
                                    { name: 'Brand Statistics', url: ctx + '/home?p=brand-stats', icon: 'bx-line-chart', color: 'warning', keywords: 'thong ke thuong hieu, brand stats' },
                                    
                                    { name: 'Supplier List', url: ctx + '/home?p=view_supplier', icon: 'bx-buildings', color: 'primary', keywords: 'nha cung cap, ncc, supplier list' },
                                    { name: 'Add Supplier', url: ctx + '/home?p=add_supplier', icon: 'bx-plus-circle', color: 'success', keywords: 'them nha cung cap, new supplier' },
                                    
                                    { name: 'Export Center', url: ctx + '/home?p=export-center', icon: 'bx-spreadsheet', color: 'info', keywords: 'trung tam xuat, export center' },
                                    { name: 'Low Stock Report', url: ctx + '/home?p=low-stock-report', icon: 'bx-error-circle', color: 'danger', keywords: 'bao cao sap het hang, low stock' },
                                    { name: 'Best-selling Statistics', url: ctx + '/home?p=best-selling-product-statistics', icon: 'bx-trending-up', color: 'success', keywords: 'san pham ban chay, best selling' },
                                    { name: 'Stock Movement', url: ctx + '/home?p=stock-movement-history', icon: 'bx-history', color: 'secondary', keywords: 'lich su kho, stock movement, history' },
                                    
                                    { name: 'My Profile', url: ctx + '/home?p=my-profile', icon: 'bx-user', color: 'primary', keywords: 'ca nhan, ho so, profile' }
                                ];

                                searchInput.addEventListener('input', function() {
                                    const val = this.value.toLowerCase().trim();
                                    if (!val) {
                                        resultsDiv.style.display = 'none';
                                        return;
                                    }

                                    const matches = pages.filter(p => 
                                        p.name.toLowerCase().includes(val) || 
                                        p.keywords.toLowerCase().includes(val)
                                    ).slice(0, 10);

                                    if (matches.length > 0) {
                                        resultsDiv.innerHTML = `
                                            <div class="dropdown-header small text-uppercase text-muted py-2 px-3">Quick Navigation</div>
                                            ` + matches.map((m, index) => `
                                            <a href="${m.url}" class="dropdown-item d-flex align-items-center py-2" data-index="${index}">
                                                <div class="icon-badge me-3">
                                                    <i class="bx ${m.icon} text-${m.color} fs-5"></i>
                                                </div>
                                                <div class="d-flex flex-column">
                                                    <span class="fw-semibold small">${m.name}</span>
                                                    <small class="text-muted" style="font-size: 0.7rem;">Go to page</small>
                                                </div>
                                            </a>
                                        `).join('');
                                        resultsDiv.style.display = 'block';
                                    } else {
                                        resultsDiv.innerHTML = `
                                            <div class="p-3 text-center">
                                                <i class="bx bx-search-alt-2 fs-2 text-muted mb-2"></i>
                                                <p class="text-muted mb-0 small">No matching page found.</p>
                                                <p class="text-primary mt-1 small">Press Enter to search for products instead</p>
                                            </div>`;
                                        resultsDiv.style.display = 'block';
                                    }
                                });

                                // Hide results on blur, but delay to allow clicks
                                searchInput.addEventListener('blur', () => {
                                    setTimeout(() => { resultsDiv.style.display = 'none'; }, 200);
                                });

                                // Handle keyboard navigation
                                searchInput.addEventListener('keydown', function(e) {
                                    if (resultsDiv.style.display === 'none') return;
                                    
                                    const items = resultsDiv.querySelectorAll('.dropdown-item');
                                    let activeIndex = Array.from(items).findIndex(i => i.classList.contains('active'));

                                    if (e.key === 'ArrowDown') {
                                        e.preventDefault();
                                        if (activeIndex < items.length - 1) {
                                            if (activeIndex >= 0) items[activeIndex].classList.remove('active');
                                            items[++activeIndex].classList.add('active');
                                            items[activeIndex].scrollIntoView({ block: 'nearest' });
                                        }
                                    } else if (e.key === 'ArrowUp') {
                                        e.preventDefault();
                                        if (activeIndex > 0) {
                                            items[activeIndex].classList.remove('active');
                                            items[--activeIndex].classList.add('active');
                                            items[activeIndex].scrollIntoView({ block: 'nearest' });
                                        }
                                    } else if (e.key === 'Enter') {
                                        if (activeIndex >= 0) {
                                            e.preventDefault();
                                            window.location.href = items[activeIndex].href;
                                        }
                                    }
                                });
                            });
                        </script>

                        <ul class="navbar-nav flex-row align-items-center ms-auto">
                            <!-- User -->
                            <li class="nav-item navbar-dropdown dropdown-user dropdown">
                                <a class="nav-link dropdown-toggle hide-arrow" href="javascript:void(0);" data-bs-toggle="dropdown">
                                    <div class="avatar avatar-online">
                                        <img src="<%=avatarUrl%>" alt class="w-px-40 h-auto rounded-circle" onerror="this.src='<%=ctx%>/assets/img/avatars/1.png'"/>
                                    </div>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li>
                                        <a class="dropdown-item" href="#">
                                            <div class="d-flex">
                                                <div class="flex-shrink-0 me-3">
                                                    <div class="avatar avatar-online">
                                                        <img src="<%=avatarUrl%>" alt class="w-px-40 h-auto rounded-circle" onerror="this.src='<%=ctx%>/assets/img/avatars/1.png'"/>
                                                    </div>
                                                </div>
                                                <div class="flex-grow-1">
                                                    <span class="fw-semibold d-block text-truncate" style="max-width: 120px;"><%= fullName %></span>
                                                    <small class="text-muted"><%= roleName %></small>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                    <li><div class="dropdown-divider"></div></li>
                                    <li>
                                        <a class="dropdown-item" href="<%=ctx%>/home?p=my-profile">
                                            <i class="bx bx-user me-2"></i>
                                            <span class="align-middle">My Profile</span>
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="<%=ctx%>/home?p=change-password">
                                            <i class="bx bx-lock-alt me-2"></i>
                                            <span class="align-middle">Change Password</span>
                                        </a>
                                    </li>
                                    <li><div class="dropdown-divider"></div></li>
                                    <li>
                                        <a class="dropdown-item text-danger" href="<%=ctx%>/logout" onclick="return confirm('Are you sure you want to log out?');">
                                            <i class="bx bx-power-off me-2"></i>
                                            <span class="align-middle">Log Out</span>
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <!--/ User -->
                        </ul>
                    </div>
                </nav>
                <!-- / Navbar -->

                <!-- Content wrapper -->
                <div class="content-wrapper">
                    <div class="container-xxl flex-grow-1 container-p-y">
                        <jsp:include page="<%= contentPage %>" />
                    </div>
                    <!-- Footer -->
                    <%@ include file="/WEB-INF/jspf/footer.jspf" %>
                    <div class="content-backdrop fade"></div>
                </div>
                <!-- Content wrapper -->
            </div>
            <!-- / Layout page -->
        </div>
        <!-- Overlay -->
        <div class="layout-overlay layout-menu-toggle"></div>
    </div>
    <!-- / Layout wrapper -->

    <!-- Toast Notification Container -->
    <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 9999">
        <%-- Success Toast --%>
        <c:if test="${not empty sessionScope.msg}">
            <div id="successToast" class="toast show animate__animated animate__fadeInUp" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header bg-success text-white py-2">
                    <i class="bx bx-check-circle me-2 fs-5"></i>
                    <strong class="me-auto">Notification</strong>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div class="toast-body border-start border-success border-3">
                    ${sessionScope.msg}
                </div>
            </div>
            <c:remove var="msg" scope="session" />
        </c:if>

        <%-- Error Toast --%>
        <c:if test="${not empty sessionScope.msgErr}">
            <div id="errorToast" class="toast show animate__animated animate__fadeInUp" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header bg-danger text-white py-2">
                    <i class="bx bx-error-circle me-2 fs-5"></i>
                    <strong class="me-auto">Alert</strong>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div class="toast-body border-start border-danger border-3">
                    ${sessionScope.msgErr}
                </div>
            </div>
            <c:remove var="msgErr" scope="session" />
        </c:if>
    </div>

    <style>
        .toast {
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            margin-bottom: 1rem;
            min-width: 300px;
        }
    </style>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Auto-hide toasts after 5 seconds
            const toasts = document.querySelectorAll('.toast');
            toasts.forEach(toast => {
                setTimeout(() => {
                    const bsToast = new bootstrap.Toast(toast);
                    bsToast.hide();
                }, 5000);
            });
        });
    </script>

    <%@ include file="/WEB-INF/jspf/common_scripts.jspf" %>
</body>
</html>

