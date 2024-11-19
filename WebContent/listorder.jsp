<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Doujiao Grocery Order History</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            margin: 0;
            text-align: center;
        }
        h1 {
            color: #008080;
            font-size: 2em;
            margin-bottom: 20px;
        }
        table {
            width: 80%;
            margin: 20px auto;
            border-collapse: collapse;
            background-color: #ffffff;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #008080;
            color: white;
            font-weight: bold;
            font-size: 0.85em;
        }
        .order-header {
            background-color: #f2f8ff;
        }
        .total-row {
            background-color: #e2e9f3;
            font-weight: bold;
        }
        .product-table {
            width: 100%;
            margin-top: 10px;
            border-top: 1px solid #ccc;
            color: #555;
        }
        .product-table th, .product-table td {
            padding: 8px;
            text-align: left;
            font-size: 0.85em;
        }
    </style>
</head>
<body>
<h1>Doujiao Grocery Order</h1>
<%
    // 获取当前会话以检查用户是否已登录
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("authenticatedUser") == null) {
        response.sendRedirect("login.jsp"); // 如果用户未登录，重定向到登录页面
        return;
    }

    String authenticatedUser = (String) session.getAttribute("authenticatedUser");

    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    } catch (ClassNotFoundException e) {
        out.println("Driver not found: " + e.getMessage());
        return;
    }

    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String user = "sa", password = "304#sa#pw";
    NumberFormat currency = NumberFormat.getCurrencyInstance(Locale.US);

    try (Connection con = DriverManager.getConnection(url, user, password);
         Statement stmt = con.createStatement()) {

        String orderQuery = "SELECT O.orderId, O.orderDate, C.customerId, C.firstName, C.lastname, O.totalAmount " +
                            "FROM ordersummary AS O INNER JOIN customer AS C ON O.customerId = C.customerId " +
                            "WHERE C.customerId = ?";
        PreparedStatement orderStmt = con.prepareStatement(orderQuery);
        orderStmt.setString(1, authenticatedUser);
        ResultSet orders = orderStmt.executeQuery();

        PreparedStatement productStmt = con.prepareStatement(
            "SELECT productId, quantity, price FROM orderproduct WHERE orderId = ?");

        out.println("<table><thead><tr><th>Order ID</th><th>Date</th><th>Customer ID</th><th>Customer Name</th><th>Total Amount</th></tr></thead><tbody>");

        while (orders.next()) {
            int orderId = orders.getInt("orderId");
            String orderDate = orders.getString("orderDate");
            int customerId = orders.getInt("customerId");
            String customerName = orders.getString("firstName") + " " + orders.getString("lastname");
            double totalAmount = orders.getDouble("totalAmount");

            out.println("<tr class='order-header'><td>" + orderId + "</td><td>" + orderDate + "</td><td>" + customerId + "</td><td>" + customerName + "</td><td>" + currency.format(totalAmount) + "</td></tr>");

            productStmt.setInt(1, orderId);
            ResultSet products = productStmt.executeQuery();
            int totalQuantity = 0;
            double orderTotal = 0;

            if (products.isBeforeFirst()) {
                out.println("<tr><td colspan='5'><table class='product-table'><thead><tr><th>Product ID</th><th>Quantity</th><th>Price</th></tr></thead><tbody>");
                while (products.next()) {
                    int productId = products.getInt("productId");
                    int quantity = products.getInt("quantity");
                    double price = products.getDouble("price");

                    out.println("<tr><td>" + productId + "</td><td>" + quantity + "</td><td>" + currency.format(price) + "</td></tr>");

                    totalQuantity += quantity;
                    orderTotal += quantity * price;
                }
                out.println("<tr class='total-row'><td>Total</td><td>" + totalQuantity + "</td><td>" + currency.format(orderTotal) + "</td></tr>");
                out.println("</tbody></table></td></tr>");
            }
            products.close();
        }

        out.println("</tbody></table>");
        orders.close();
        productStmt.close();

    } catch (SQLException ex) {
        out.println("SQL Error: " + ex.getMessage());
    }
%>
</body>
</html>
