package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.postkuy.util.DBConnector;

public class PostCreateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get form data
        String title = request.getParameter("title");
        String body = request.getParameter("body");
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        // Validate user
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnector.getConnection();

            // Insert post into database
            String query = "INSERT INTO posts (user_id, title, body, created_at, updated_at) VALUES (?, ?, ?, NOW(), NOW())";
            stmt = conn.prepareStatement(query);
            stmt.setInt(1, userId);
            stmt.setString(2, title);
            stmt.setString(3, body);
            stmt.executeUpdate();

            // Redirect to posts list after successful creation
            response.sendRedirect("index.jsp");

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred while creating the post.");
            request.getRequestDispatcher("postCreate.jsp").forward(request, response);
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
