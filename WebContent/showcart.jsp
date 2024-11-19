<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Your Shopping Cart</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 20px;
        }
        h1 {
            color: #008080;
            text-align: left;
        }
        table {
            width: 80%;
            margin: 20px auto;
            border-collapse: collapse;
            background-color: #ffffff;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #008080;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #ddd;
        }
        .total-row {
            font-weight: bold;
            background-color: #f2f2f2;
        }
        .footer-links {
            text-align: center;
            margin-top: 20px;
        }
        .footer-links a {
            color: #008080;
            text-decoration: none;
            font-size: 16px;
        }
        .footer-links a:hover {
            text-decoration: underline;
        }
        .error-message {
            color: #008080;
            text-align: left;
        }
    </style>
</head>
<body>

<%
    // 获取当前会话
    HttpSession httpSession = request.getSession(false);
    if (httpSession == null || httpSession.getAttribute("authenticatedUser") == null) {
        response.sendRedirect("login.jsp"); // 如果用户未登录，则重定向到登录页面
        return;
    }

    // 获取当前用户的购物车
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) httpSession.getAttribute("productList");

    if (productList == null || productList.isEmpty()) { 
        out.println("<h1 class='error-message'>Your shopping cart is empty!</h1>");
    } else {
        NumberFormat currFormat = NumberFormat.getCurrencyInstance();
        double total = 0;

        out.println("<h1>Your Shopping Cart</h1>");
        out.println("<form action='updatecart.jsp' method='post'>");
        out.print("<table><tr><th>Product Id</th><th>Product Name</th><th>Quantity</th>");
        out.println("<th>Price</th><th>Subtotal</th><th>Actions</th></tr>");

        for (Map.Entry<String, ArrayList<Object>> entry : productList.entrySet()) {
            ArrayList<Object> product = entry.getValue();
            String productId = entry.getKey();
            String productName = (String) product.get(1);
            double price = Double.parseDouble(product.get(2).toString());
            int quantity = Integer.parseInt(product.get(3).toString());

            double subtotal = price * quantity;
            total += subtotal;

            out.print("<tr>");
            out.print("<td>" + productId + "</td>");
            out.print("<td>" + productName + "</td>");
            out.print("<td><input type='number' name='quantity_" + productId + "' value='" + quantity + "' min='1'></td>");
            out.print("<td align='right'>" + currFormat.format(price) + "</td>");
            out.print("<td align='right'>" + currFormat.format(subtotal) + "</td>");
            out.print("<td><button type='submit' name='remove' value='" + productId + "'>Remove</button></td>");
            out.print("</tr>");
        }

        out.println("<tr class='total-row'><td colspan='4' align='right'><b>Order Total</b></td>"
                + "<td align='right'>" + currFormat.format(total) + "</td></tr>");
        out.println("</table>");

        out.println("<div style='text-align:center;'><input type='submit' name='update' value='Update Cart'></div>");
        out.println("</form>");

        out.println("<div class='footer-links'><h2><a href='checkout.jsp'>Check Out</a></h2></div>");
    }
%>

<div class="footer-links">
    <h2><a href="listprod.jsp">Continue Shopping</a></h2>
</div>

</body>
</html>
