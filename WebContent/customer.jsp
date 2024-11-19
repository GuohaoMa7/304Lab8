<!DOCTYPE html>
<html>
<head>
<title>Customer Page</title>
</head>
<body>

<%@ include file="auth.jsp"%>
<%@ page import="java.text.NumberFormat, java.sql.*" %>
<%@ include file="jdbc.jsp" %>

<% 
// 修改1: 检查用户是否已登录
String userName = (String) session.getAttribute("authenticatedUser");
if (userName == null) {
    if (!response.isCommitted()) {
        response.sendRedirect("login.jsp"); // 未登录用户将被重定向到 login.jsp
    }
    return;
}
%>

<h3>Welcome, <%= userName %>!</h3>

<%
// 修改2: 从数据库中查询并显示客户信息
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String user = "sa", password = "304#sa#pw";

try (Connection con = DriverManager.getConnection(url, user, password);
     PreparedStatement stmt = con.prepareStatement(
        "SELECT customerId, firstName, lastName, email " +
        "FROM customer WHERE userid = ?"
     )) {

    stmt.setString(1, userName);
    try (ResultSet rst = stmt.executeQuery()) {
        if (rst.next()) {
            out.println("<p>Customer ID: " + rst.getInt("customerId") + "</p>");
            out.println("<p>Customer Name: " + rst.getString("firstName") + " " + rst.getString("lastName") + "</p>");
            out.println("<p>Email: " + rst.getString("email") + "</p>");
        } else {
            out.println("<h4>No customer information found.</h4>");
        }
    }
} catch (SQLException ex) {
    out.println("<h4>Error: " + ex.getMessage() + "</h4>");
}

%>

</body>
</html>
