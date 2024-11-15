<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.io.IOException" %>
<%@ include file="header.jsp" %>
<%@ include file="jdbc.jsp" %>

<%
   
   
    String prodId = request.getParameter("id");
   Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rst = null;

    try {
        int productId = Integer.parseInt(prodId);

        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True;";
        String uid = "sa";
        String pw = "304#sa#pw";

        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        con = DriverManager.getConnection(url, uid, pw);

        String sql = "SELECT productName, productImageURL, productImage, productPrice, productDesc FROM Product WHERE productId = ?";
        pstmt = con.prepareStatement(sql);
        pstmt.setInt(1, productId);
        rst = pstmt.executeQuery();

        
        if (rst.next()) {
            String productName = rst.getString("productName");
            out.println("<h2>" + (productName != null ? productName : "Product name not available") + "</h2>");

            String imageUrl = rst.getString("productImageURL");
            if (imageUrl != null) {
                out.println("<p><img src=\"" + imageUrl + "\"></p>");
            }
             
             String imageBinary = rst.getString("productImage");
            if (imageBinary != null) {
                out.println("<img src=\"displayImage.jsp?id=" + productId + "\">");
                
            }

            out.println("<h4><b>id</b> " + productId + "</h4>");
            out.println("<h4><b>Price</b>$" + rst.getDouble("productPrice") + "</h4>");
            out.println("<h3><a href='addcart.jsp?id=" + productId + "&name=" + URLEncoder.encode(productName, "UTF-8") + "&price=" + rst.getDouble("productPrice") + "&newqty=1'>Add to cart</a></h3>");
            out.println("<h3><a href='listprod.jsp'>Continue Shopping</a></h3>");
        } else {
            out.println("<p>Product not found.</p>");
        }

    } catch (NumberFormatException e) {
        out.println("<p>Invalid product ID format.</p>");
    } catch (SQLException e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } catch (ClassNotFoundException e) {
        out.println("<p>Database driver not found.</p>");
    } finally {
        try {
            if (rst != null) rst.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            out.println("<p>Database close error: " + e.getMessage() + "</p>");
        }
    }
%>
