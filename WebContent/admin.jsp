<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale" %>
<%@ include file="auth.jsp" %>  
<%@ include file="jdbc.jsp" %>  
<!DOCTYPE html>
<html>
<head>
    <title>Administrator Page</title>
</head>
<body>
    <% 
    // 修改1: 检查用户是否已登录，并在未登录时重定向
    String userName = (String) session.getAttribute("authenticatedUser");
    if (userName == null) {
        if (!response.isCommitted()) {
            response.sendRedirect("login.jsp"); // 未登录用户将被重定向到 login.jsp
        }
        return;
    }
    %>
    <header>
        <nav>
            <ul>
                <!-- 修改2: 显示当前登录用户 -->
                <li><a href='customer.jsp'><%= userName %></a></li>
                <li><a href='logout.jsp'>Sign Out</a></li>
            </ul>
        </nav>
    </header>

    <h3>Administrator Sales Report by Day</h3>
    <div>
        <% 
        // 修改3: 使用 SQL 查询显示每日销售报告
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        String user = "sa", password = "304#sa#pw";

        try (Connection con = DriverManager.getConnection(url, user, password);
             Statement stmt = con.createStatement();
             ResultSet rst = stmt.executeQuery(
                "SELECT YEAR(orderDate) AS Year, " +
                "MONTH(orderDate) AS Month, " +
                "DAY(orderDate) AS Day, " +
                "SUM(totalAmount) AS Total " +
                "FROM ordersummary " +
                "GROUP BY YEAR(orderDate), MONTH(orderDate), DAY(orderDate) " +
                "ORDER BY Year, Month, Day"
             )) {

            out.println("<table border='1'>");
            out.println("<tr><th>Order Date</th><th>Total Order Amount</th></tr>");

            while (rst.next()) {
                String date = rst.getInt("Year") + "-" + rst.getInt("Month") + "-" + rst.getInt("Day");
                double totalSales = rst.getDouble("Total");
                out.println("<tr><td>" + date + "</td><td>" + NumberFormat.getCurrencyInstance(Locale.US).format(totalSales) + "</td></tr>");
            }
            out.println("</table>");
        } catch (SQLException ex) {
            out.println("<h4>Error: " + ex.getMessage() + "</h4>");
        }
        %>
    </div>
</body>
</html>
