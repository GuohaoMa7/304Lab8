<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ include file="jdbc.jsp" %>
<%
    String authenticatedUser = null;
    session = request.getSession(true);

    try {
        authenticatedUser = validateLogin(out, request, session);
    } catch (IOException e) {
        System.err.println(e);
    }

    if (authenticatedUser != null) {
        response.sendRedirect("index.jsp"); // Successful login
    } else {
        response.sendRedirect("login.jsp"); // Failed login - redirect back to login page with a message 
    }
%>

<%!
    String validateLogin(JspWriter out, HttpServletRequest request, HttpSession session) throws IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String retStr = null;

        if (username == null || password == null) return null;
        if (username.length() == 0 || password.length() == 0) return null;

        try {
            getConnection();
            
            // Check if userId and password match some customer account
            String SQL = "SELECT customerId FROM customer WHERE userid=? AND password=?";
            PreparedStatement pstmt = con.prepareStatement(SQL);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                retStr = rs.getString("customerId"); // If user exists, set retStr to customerId
            }
        } catch (SQLException ex) {
            out.println("<h4>Error: " + ex.getMessage() + "</h4>");
        } finally {
            closeConnection();
        }

        if (retStr != null) {
            session.removeAttribute("loginMessage");
            session.setAttribute("authenticatedUser", retStr); // Store customerId instead of username
        } else {
            session.setAttribute("loginMessage", "Could not connect to the system using that username/password.");
        }

        return retStr;
    }
%>
