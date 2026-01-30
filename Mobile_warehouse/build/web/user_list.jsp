<%-- 
    Document   : user_list
    Created on : Jan 14, 2026, 12:46:01 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>User List</title>
        <style>
            body {
                font-family: Arial;
                background:#f2f2f2;
                margin:0;
            }
            .topbar {
                padding:10px;
            }
            .btn {
                display:inline-block;
                padding:6px 14px;
                border:2px solid #1f4aa8;
                background:#4a86d4;
                color:#000;
                text-decoration:none;
                font-weight:600;
                margin-right:8px;
            }
            .btn:hover {
                opacity:0.9;
            }

            .wrap {
                padding: 30px 60px;
            }
            h3 {
                margin:0 0 10px;
            }

            table {
                border-collapse:collapse;
                width: 820px;
                background:#fff;
            }
            th, td {
                border:1px solid #000;
                padding:10px;
                text-align:center;
            }
            th {
                background:#fff;
                font-weight:700;
            }

            .actions {
                text-align:right;
                margin-bottom:8px;
                width:820px;
            }
            .link {
                color: #1a54ff;
                text-decoration: underline;
                cursor:pointer;
            }
        </style>
    </head>
    <body>

        <!-- Back button -->
        <div class="topbar">
            <a class="btn" href="<%=request.getContextPath()%>/home">Back</a>
        </div>
        <form action="<%=request.getContextPath()%>/home" method="get">
            <input type="hidden" name="p" value="user-list"/>
            <input type="hidden" name="page" value="1"/>
            Search User:
            <input type="text" name="q"
                   value="<%= request.getAttribute("q") != null ? request.getAttribute("q") : "" %>"
                   placeholder="e.g. duc, email, username...">

            Status:
            <select name="status">
                <%
                    String status = (String) request.getAttribute("status");
                %>
                <option value="" <%= (status == null || status.isEmpty()) ? "selected" : "" %>>All</option>
                <option value="1" <%= "1".equals(status) ? "selected" : "" %>>Active</option>
                <option value="0" <%= "0".equals(status) ? "selected" : "" %>>Inactive</option>
            </select>

            <button type="submit">Filter</button>
        </form>



        <br>
        <div class="wrap">
            <div class="actions">
                <!-- nút Active (lọc status=1) -->
                <%--<a class="btn" href="${pageContext.request.contextPath}/admin/users/active-page">Active/Deactive</a>
                
                <!-- nút Add User -->
                <a class="btn" href="${pageContext.request.contextPath}/admin/user-add">Add User</a>--%>
                <a class="btn" href="${pageContext.request.contextPath}/home?p=user-toggle">Active/Deactive</a>
                <a class="btn" href="${pageContext.request.contextPath}/home?p=user-add">Add User</a>

            </div>

            <h3>User List</h3>

            <table>
                <thead>
                    <tr>
                        <th style="width:80px;">ID</th>
                        <th style="width:200px;">Username</th>
                        <th style="width:260px;">Action</th>
                        <th style="width:280px;">Status</th>
                    </tr>
                </thead>

                <tbody>
                    <c:if test="${empty users}">
                        <tr>
                            <td colspan="4">No users found.</td>
                        </tr>
                    </c:if>

                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>${u.userId}</td>
                            <td>${u.username}</td>

                            <td>
                                <!-- View/Update: bạn có thể trỏ sang servlet update sau này -->
                                <a class="link" href="${pageContext.request.contextPath}/admin/user/view?id=${u.userId}">
                                    View/Update
                                </a>




                            </td>

                            <td>
                                <c:choose>
                                    <c:when test="${u.status == 1}">Active</c:when>
                                    <c:otherwise>Deactive</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
            <%
                Integer pageObj = (Integer) request.getAttribute("page");
                Integer totalPagesObj = (Integer) request.getAttribute("totalPages");

                int curPage = (pageObj == null) ? 1 : pageObj;
                int totalPages = (totalPagesObj == null) ? 1 : totalPagesObj;

                String q = (String) request.getAttribute("q");
                String st = (String) request.getAttribute("status");

                String base = request.getContextPath() + "/home?p=user-list"
                        + (q != null && !q.isEmpty() ? "&q=" + java.net.URLEncoder.encode(q, "UTF-8") : "")
                        + (st != null && !st.isEmpty() ? "&status=" + st : "");
            %>

            <div class="pager">
                <% if (curPage > 1) { %>
                <a class="btn" href="<%= base %>&page=<%= (curPage - 1) %>">Prev</a>
                <% } else { %>
                <span class="page-current">Prev</span>
                <% } %>

                <% for (int i = 1; i <= totalPages; i++) { %>
                <% if (i == curPage) { %>
                <span class="page-current"><%= i %></span>
                <% } else { %>
                <a class="btn" href="<%= base %>&page=<%= i %>"><%= i %></a>
                <% } %>
                <% } %>

                <% if (curPage < totalPages) { %>
                <a class="btn" href="<%= base %>&page=<%= (curPage + 1) %>">Next</a>
                <% } else { %>
                <span class="page-current">Next</span>
                <% } %>
            </div>



        </div>

    </body>
</html>
