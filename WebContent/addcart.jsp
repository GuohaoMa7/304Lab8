<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="javax.servlet.http.HttpSession" %>

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

if (productList == null) {
    // 如果当前没有购物车，创建一个新的
    productList = new HashMap<String, ArrayList<Object>>();
}

// 获取产品信息
String id = request.getParameter("id");
String name = request.getParameter("name");
String price = request.getParameter("price");
Integer quantity = 1; // 默认数量为 1

// 创建产品信息的 ArrayList
ArrayList<Object> product = new ArrayList<Object>();
product.add(id);
product.add(name);
product.add(price);
product.add(quantity);

// 如果购物车中已经有相同的产品，更新数量
if (productList.containsKey(id)) {
    product = productList.get(id);
    int curAmount = ((Integer) product.get(3)).intValue();
    product.set(3, curAmount + 1);
} else {
    productList.put(id, product);
}

// 更新会话中的购物车
httpSession.setAttribute("productList", productList);

// 跳转到显示购物车的页面
%>
<jsp:forward page="showcart.jsp" />
