<%-- 
    Document   : view_user_information
    Created on : Jan 15, 2026, 1:17:31 AM
    Author     : Admin
--%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>View User Information</title>

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

            .form-box{
                width: 900px;
                background:#f4f1ea;
                padding: 18px 22px;
                border-radius: 2px;
                box-sizing: border-box;
            }

            .row {
                display:flex;
                gap:40px;
                margin: 10px 0;
                align-items:center;
                flex-wrap:wrap;
            }
            .col {
                display:flex;
                align-items:center;
                gap:10px;
                min-width: 380px;
            }

            .label {
                width: 90px;
                font-size: 13px;
            }
            .input {
                width: 250px;
                height: 26px;
                border: 1px solid #333;
                background: #fff;
                padding: 2px 8px;
                box-sizing: border-box;
            }

            .actions {
                margin-top: 18px;
                text-align:center;
            }
            .btn-update {
                padding:6px 22px;
                border:2px solid #1f4aa8;
                background:#4a86d4;
                font-weight:700;
                cursor:pointer;
                text-decoration:none;
                color:#000;
                display:inline-block;
            }
            .btn-update:hover {
                opacity:0.9;
            }
        </style>
    </head>
    <body>

        <div class="topbar">
            <a class="btn" href="<%=request.getContextPath()%>/home?p=user-list">Back</a>

            <a class="btn" href="<%=request.getContextPath()%>/home">Home</a>
        </div>

        <div class="wrap">
            <h3>View User Information</h3>

          

            <div class="form-box">
                <div class="row">
                    <div class="col">
                        <div class="label">Avatar :</div>
                        <img src="${pageContext.request.contextPath}/${empty user.avatar ? 'assets/default-avatar.jpg' : user.avatar}?v=<fmt:formatDate value='${now}' pattern='yyyyMMddHHmmssSSS'/>"
                             style="width:70px;height:70px;object-fit:cover;border:1px solid #aaa;border-radius:6px;">


                    </div>
                    <div class="col">

                    </div>
                </div>
                <div class="row">

                    <div class="col">
                        <div class="label">User ID :</div>
                        <input class="input" type="text" name="user_id" value="${user.userId}" readonly>
                    </div>

                    <div class="col">
                        <div class="label">Username :</div>
                        <input class="input" type="text" name="username" value="${user.username}" readonly>
                    </div>
                </div>

                <div class="row">
                    <div class="col">
                        <div class="label">Full Name :</div>
                        <input class="input" type="text" name="full_name" value="${user.fullName}" readonly>
                    </div>

                    <div class="col">
                        <div class="label">Phone :</div>
                        <input class="input" type="text" name="phone" value="${user.phone}" readonly>
                    </div>
                </div>
                <div class="row">
                    <div class="col">
                        <div class="label">Address :</div>
                        <input class="input" type="text" value="${user.address}" readonly>
                    </div>
                </div>

                <div class="row">
                    <div class="col">
                        <div class="label">Email :</div>
                        <input class="input" type="text" name="email" value="${user.email}" readonly>
                    </div>

                    <div class="col">
                        <div class="label">Role :</div>
                        <input class="input" type="text" name="role" value="${roleName}" readonly>
                    </div>
                </div>

                <div class="row">
                    <div class="col">
                        <div class="label">Status :</div>
                        <input class="input" type="text" name="status"
                               value="${user.status == 1 ? 'Active' : 'Deactive'}" readonly>
                    </div>
                </div>

                <div class="actions">
                    <%-- nút Update: chuyển sang trang update (nếu bạn đã làm controller) --%>
                    <a class="btn-update"
                       href="${pageContext.request.contextPath}/admin/user/update?id=${user.userId}">
                        Update
                    </a>
                </div>

            </div>
        </div>

    </body>
</html>
