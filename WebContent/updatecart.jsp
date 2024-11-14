<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title> Cart</title>
</head>
<body>

<%
    
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
    
    if (productList == null) {
        out.println("<h1>Your cart is empty!</h1>");
    } else {
        // update
        for (String key : request.getParameterMap().keySet()) {
            if (key.startsWith("quantity_")) {
                String productId = key.substring(9); // Extract the productId
                String quantityStr = request.getParameter(key);
                try {
                    int quantity = Integer.parseInt(quantityStr);
                    if (quantity < 1) {
                        quantity = 1; 
                    }
                    ArrayList<Object> product = productList.get(productId);
                    if (product != null) {
                        product.set(3, quantity); 
                    }
                } catch (NumberFormatException e) {
                    out.println("<h1>Error: Invalid quantity for product " + productId + "</h1>");
                }
            }
        }
        
       
        String removeProductId = request.getParameter("remove");
        if (removeProductId != null) {
            productList.remove(removeProductId); 
        }
        
        session.setAttribute("productList", productList);
    }
    
    response.sendRedirect("showcart.jsp");
%>

</body>
</html>
