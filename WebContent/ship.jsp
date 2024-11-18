<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.*" %>
<%@ include file="jdbc.jsp" %>

<html>
<head>
    <title> Doujiao Grocery Shipment Processing</title>
</head>

<%@ include file="header.jsp" %>

<body>
<%
int orderId = Integer.parseInt(request.getParameter("orderId"));

// Database credentials
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String user = "sa";
String password = "304#sa#pw";

try (Connection con = DriverManager.getConnection(url, user, password)) {
    con.setAutoCommit(false);

    String checkOrderSql = "SELECT COUNT(*) FROM orderproduct WHERE orderId = ?";
    try (PreparedStatement checkOrderStmt = con.prepareStatement(checkOrderSql)) {
        checkOrderStmt.setInt(1, orderId);
        ResultSet rs = checkOrderStmt.executeQuery();
        rs.next();

        if (rs.getInt(1) == 0) {
            out.println("<h2>The Order id not exist.</h2>");
            return;
        }
    }

    String fetchOrderSql = "SELECT O.productId, O.quantity AS orderedQty, P.quantity AS inventoryQty " +
                           "FROM orderproduct O " +
                           "JOIN productinventory P ON O.productId = P.productId " +
                           "WHERE O.orderId = ? AND P.warehouseID = 1";
    try (PreparedStatement fetchOrderStmt = con.prepareStatement(fetchOrderSql)) {
        fetchOrderStmt.setInt(1, orderId);
        ResultSet rs = fetchOrderStmt.executeQuery();

        boolean canProcessShipment = true;
        List<Integer> insufficientProducts = new ArrayList<>();
        Map<Integer, Integer> updatedInventory = new HashMap<>();

        while (rs.next()) {
            int productId = rs.getInt("productId");
            int orderedQty = rs.getInt("orderedQty");
            int inventoryQty = rs.getInt("inventoryQty");

            int newInventoryQty = inventoryQty - orderedQty;
            if (newInventoryQty < 0) {
                canProcessShipment = false;
                insufficientProducts.add(productId);
            } else {
                updatedInventory.put(productId, newInventoryQty);
                out.println(String.format("<h2>Product ID: %d   Ordered Qty: %d   Old Inventory: %d    New Inventory: %d</h2>",
                    productId, orderedQty, inventoryQty, newInventoryQty));
            }
        }

        if (!canProcessShipment) {
            out.println("<h2>Shipment not processed. Insufficient inventory for products: " +
                        insufficientProducts + "</h2>");
            con.rollback();
        } else {
            
            String createShipmentSql = "INSERT INTO shipment DEFAULT VALUES";
            try (PreparedStatement createShipmentStmt = con.prepareStatement(createShipmentSql, Statement.RETURN_GENERATED_KEYS)) {
                createShipmentStmt.executeUpdate();
                ResultSet generatedKeys = createShipmentStmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int shipmentId = generatedKeys.getInt(1);
                  
                }
            }

            
            String updateInventorySql = "UPDATE productinventory SET quantity = ? WHERE productId = ?";
            try (PreparedStatement updateInventoryStmt = con.prepareStatement(updateInventorySql)) {
                for (Map.Entry<Integer, Integer> entry : updatedInventory.entrySet()) {
                    updateInventoryStmt.setInt(1, entry.getValue());
                    updateInventoryStmt.setInt(2, entry.getKey());
                    updateInventoryStmt.executeUpdate();
                }
            }

            con.commit();
            out.println("<h2>Shipment successfully processed.</h2>");
        }
    }
} catch (SQLException e) {
    out.println("<p>SQL Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>

<h2><a href="shop.html">Back to Main Page</a></h2>

</body>
</html>
