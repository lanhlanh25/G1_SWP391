<%-- 
    Document   : product_detail
    Created on : Feb 6, 2026, 3:54:02 PM
    Author     : Lanhlanh
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
    <head>
        <title>Product Detail</title>
        <style>
            table {
                border-collapse: collapse;
                width: 80%;
                margin-bottom: 30px;
            }
            th, td {
                border: 1px solid #333;
                padding: 8px 12px;
                text-align: left;
            }
            th {
                background-color: #f2f2f2;
            }
            h2 {
                margin-top: 30px;
            }
        </style>
    </head>
    <body>

        <h1>Product Detail</h1>

        <c:if test="${product == null}">
            <p style="color:red;">Product not found</p>
        </c:if>

        <c:if test="${product != null}">
            <table>
                <tr>
                    <th>Product Code</th>
                    <td>${product.productCode}</td>
                </tr>
                <tr>
                    <th>Product Name</th>
                    <td>${product.productName}</td>
                </tr>
                <tr>
                    <th>Brand</th>
                    <td>${product.brandName}</td>
                </tr>
                <tr>
                    <th>Model</th>
                    <td>${product.model}</td>
                </tr>
                <tr>
                    <th>Status</th>
                    <td>${product.status}</td>
                </tr>
                <tr>
                    <th>Description</th>
                    <td>${product.description}</td>
                </tr>
            </table>

            <h2>SKU List</h2>

            <table>
                <tr>
                    <th>SKU Code</th>
                    <th>Color</th>
                    <th>RAM (GB)</th>
                    <th>Storage (GB)</th>
                    <th>Price</th>
                    <th>Status</th>
                </tr>

                <c:if test="${empty skuList}">
                    <tr>
                        <td colspan="6" style="text-align:center;">No SKU found</td>
                    </tr>
                </c:if>

                <c:forEach items="${skuList}" var="s">
                    <tr>
                        <td>${s.skuCode}</td>
                        <td>${s.color}</td>
                        <td>${s.ramGb}</td>
                        <td>${s.storageGb}</td>
                        <td>${s.price}</td>
                        <td>${s.status}</td>
                    </tr>
                </c:forEach>
            </table>
        </c:if>

        <a href="home?p=product-list">Back to Product List</a>

    </body>
</html>