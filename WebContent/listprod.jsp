<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ page import="java.util.Locale" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doujiao Market</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            color: #333;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #008080;
            color: #fff;
            padding: 20px;
            text-align: center;
        }
        h1 { font-size: 2.5rem; margin: 0; }
        h2 { color: #444; text-align: center; margin-top: 20px; }
        form {
            display: flex;
            justify-content: left;
            margin: 20px 0;
        }
        form select, form input[type="text"], form input[type="submit"], form input[type="reset"] {
            font-size: 16px;
            padding: 10px;
            margin: 0 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        form input[type="submit"], form input[type="reset"] {
            background-color: #008080;
            color: #fff;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        table {
            width: 100%;
            margin: 60px auto;
            border-collapse: collapse;
        }
        table th, table td {
            padding: 15px;
            border: 1px solid #ddd;
            text-align: left;
        }
        table th { background-color: #008080; color: white; font-size: 1.2rem; }
        table tr:nth-child(even) { background-color: #f9f9f9; }
        .add-to-cart { color: #008080; text-decoration: none; }
    </style>
</head>
<body>

<header>
    <h1><i>Doujiao Grocery</i></h1>
</header>

<h2>Browse Products by Category and Search by Product Name:</h2>
<%
    // 获取当前会话以检查用户是否已登录
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("authenticatedUser") == null) {
        response.sendRedirect("login.jsp"); // 如果用户未登录，重定向到登录页面
        return;
    }
%>

<form method="get" action="listprod.jsp">
    <select name="categoryName">
        <option value="All">All</option>
        <option value="Beverages">Beverages</option>
        <option value="Condiments">Condiments</option>
        <option value="Dairy Products">Dairy Products</option>
        <option value="Produce">Produce</option>
        <option value="Meat/Poultry">Meat/Poultry</option>
        <option value="Seafood">Seafood</option>
        <option value="Confections">Confections</option>
        <option value="Grains/Cereals">Grains/Cereals</option>
    </select>
    <input type="text" name="productName" size="50" placeholder="Enter product name...">
    <input type="submit" value="Search">
    <input type="reset" value="Reset">
</form>

<% 
    String productName = request.getParameter("productName");
    String categoryName = request.getParameter("categoryName");
    
    String dbUrl = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String dbUser = "sa";
    String dbPassword = "304#sa#pw";
    
    String query;
    boolean isSpecificCategory = categoryName != null && !categoryName.equals("All");

    if (isSpecificCategory) {
        query = "SELECT P.productName, P.productPrice, P.productId, C.categoryName FROM product P " +
                "JOIN category C ON P.categoryId = C.categoryId " +
                "WHERE C.categoryName = ? AND P.productName LIKE ?";
    } else {
        query = "SELECT P.productName, P.productPrice, P.productId, C.categoryName FROM product P " +
                "JOIN category C ON P.categoryId = C.categoryId " +
                "WHERE P.productName LIKE ?";
    }

    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        try (Connection connection = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement statement = connection.prepareStatement(query)) {
            
            // Set prepared statement parameters
            if (isSpecificCategory) {
                statement.setString(1, categoryName);
                statement.setString(2, "%" + (productName != null ? productName : "") + "%");
            } else {
                statement.setString(1, "%" + (productName != null ? productName : "") + "%");
            }

            // Execute query and display results
            ResultSet results = statement.executeQuery();
            NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(Locale.US);

            out.println("<table><tr><th> </th><th>Product Name</th><th>Price</th><th>Category</th></tr>");
            while (results.next()) {
                String name = results.getString("productName");
                double price = results.getDouble("productPrice");
                int id = results.getInt("productId");
                String category = results.getString("categoryName");

                String addToCartUrl = "addcart.jsp?id=" + id + "&name=" + URLEncoder.encode(name, "UTF-8") + "&price=" + price;

                out.println("<tr>");
                out.println("<td><a class='add-to-cart' href='" + addToCartUrl + "'>Add to Cart</a></td>");
                out.println("<td><a href='product.jsp?id=" + id + "'>" + name + "</a></td>");
                out.println("<td>" + currencyFormat.format(price) + "</td>");
                out.println("<td>" + category + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
        }
    } catch (ClassNotFoundException e) {
        out.println("<p>Error loading database driver: " + e.getMessage() + "</p>");
    } catch (SQLException e) {
        out.println("<p>Database error: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>
