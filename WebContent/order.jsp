<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Pet Shop Order Processing</title>
    <style>
        body {
            font-family: Arial, sans-serif;
        }
        table {
            width: 70%;
            margin: auto;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid #333;
            padding: 8px;
            text-align: center;
        }
        th {
            background-color: #008080;
            color: white;
        }
        .header, .footer {
            text-align: center;
            margin: 20px;
        }
        a {
            text-decoration: none;
            color: #008080;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Order Processing Summary</h1>
    </div>
    <%
        // Load SQL Server JDBC driver
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            out.println("ClassNotFoundException: " + e);
            return;
        }

        // Connection details
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        String user = "sa";
        String password = "304#sa#pw";

        // Retrieve session to check if the user is logged in
        HttpSession httpSession = request.getSession(false);
        String authenticatedUser = (String) httpSession.getAttribute("authenticatedUser");

        // Check if user is authenticated
        if (authenticatedUser == null) {
            response.sendRedirect("login.jsp"); // Redirect to login page if not authenticated
            return;
        }

        // Retrieve the shopping cart from session
        @SuppressWarnings({"unchecked"})
        HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) httpSession.getAttribute("productList");
        if (productList == null || productList.isEmpty()) {
            out.println("<p>Error: Your shopping cart is empty. Please add items before checking out.</p>");
            return;
        }

        // Establish connection to the database
        try (Connection con = DriverManager.getConnection(url, user, password)) {

            // Insert order into OrderSummary table and retrieve generated order ID
            String insertOrderQuery = "INSERT INTO OrderSummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), 0.0)";
            try (PreparedStatement orderStmt = con.prepareStatement(insertOrderQuery, Statement.RETURN_GENERATED_KEYS)) {
                // Use authenticatedUser (customerId) from session
                String custId = authenticatedUser;
                orderStmt.setString(1, custId);
                orderStmt.executeUpdate();

                // Retrieve generated order ID
                ResultSet keys = orderStmt.getGeneratedKeys();
                keys.next();
                int orderId = keys.getInt(1);

                // Insert each product into OrderProduct table
                String insertProductQuery = "INSERT INTO OrderProduct (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
                try (PreparedStatement productStmt = con.prepareStatement(insertProductQuery)) {
                    Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
                    double totalAmount = 0.0;

                    while (iterator.hasNext()) {
                        Map.Entry<String, ArrayList<Object>> entry = iterator.next();
                        ArrayList<Object> product = entry.getValue();
                        String productId = product.get(0).toString();

                        // Ensure productId is an integer
                        if (productId.contains(".")) {
                            productId = productId.substring(0, productId.indexOf('.'));
                        }
                        int productIdInt = Integer.parseInt(productId);

                        int quantity = Integer.parseInt(product.get(3).toString());
                        double price = Double.parseDouble(product.get(2).toString());

                        // Insert product details into OrderProduct table
                        productStmt.setInt(1, orderId);
                        productStmt.setInt(2, productIdInt);
                        productStmt.setInt(3, quantity);
                        productStmt.setDouble(4, price);
                        productStmt.executeUpdate();

                        // Calculate total amount for the order
                        totalAmount += quantity * price;
                    }

                    // Update total amount in OrderSummary table
                    String updateOrderQuery = "UPDATE OrderSummary SET totalAmount = ? WHERE orderId = ?";
                    try (PreparedStatement updateStmt = con.prepareStatement(updateOrderQuery)) {
                        updateStmt.setDouble(1, totalAmount);
                        updateStmt.setInt(2, orderId);
                        updateStmt.executeUpdate();
                    }

                    // Display order summary
                    out.println("<h2>Order Summary</h2>");
                    out.println("<p>Order ID: " + orderId + "</p>");
                    out.println("<p>Customer ID: " + custId + "</p>");
                    out.println("<p>Total Amount: " + NumberFormat.getCurrencyInstance().format(totalAmount) + "</p>");
                    out.println("<h3>Ordered Products:</h3>");
                    out.println("<table><tr><th>Product ID</th><th>Product Name</th><th>Quantity</th><th>Price</th></tr>");

                    // Iterate through the products to display ordered items
                    iterator = productList.entrySet().iterator();
                    while (iterator.hasNext()) {
                        Map.Entry<String, ArrayList<Object>> entry = iterator.next();
                        ArrayList<Object> product = entry.getValue();
                        String productIdDisplay = product.get(0).toString();
                        String productName = (String) product.get(1);
                        int quantityDisplay = Integer.parseInt(product.get(3).toString());
                        double priceDisplay = Double.parseDouble(product.get(2).toString());

                        out.println("<tr><td>" + productIdDisplay + "</td><td>" + productName + "</td><td>" + quantityDisplay + "</td><td>" + NumberFormat.getCurrencyInstance().format(priceDisplay) + "</td></tr>");
                    }
                    out.println("</table>");

                    // Clear the shopping cart after successful order placement
                    httpSession.removeAttribute("productList");
                }
            }
        } catch (SQLException e) {
            out.println("SQLException: " + e.getMessage());
        }
    %>

    <div class="footer">
        <a href="listprod.jsp">go to Homepage</a>
    </div>
</body>
</html>
