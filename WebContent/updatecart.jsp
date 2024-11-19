<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Cart</title>
</head>
<body>

<%
    // 获取当前会话以检查用户是否已登录
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("authenticatedUser") == null) {
        response.sendRedirect("login.jsp"); // 如果用户未登录，重定向到登录页面
        return;
    }

    // 获取购物车列表
    @SuppressWarnings("unchecked")
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    if (productList == null) {
        out.println("<h1>Your cart is empty!</h1>");
    } else {
        // 更新购物车中的商品数量
        for (String key : request.getParameterMap().keySet()) {
            if (key.startsWith("quantity_")) {
                String productId = key.substring(9); // 提取产品ID
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

        // 处理移除购物车中的产品
        String removeProductId = request.getParameter("remove");
        if (removeProductId != null) {
            productList.remove(removeProductId); 
        }

        // 将更新后的购物车存回会话
        session.setAttribute("productList", productList);
    }
    
    // 重定向到显示购物车的页面
    response.sendRedirect("showcart.jsp");
%>

</body>
</html>
