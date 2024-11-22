package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.postkuy.util.DBConnector;

public class CommentCreateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get parameters
        String body = request.getParameter("body");
        int userId = Integer.parseInt(request.getParameter("user_id"));
        int postId = Integer.parseInt(request.getParameter("post_id"));

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnector.getConnection();
            String query = "INSERT INTO comments (post_id, user_id, body, created_at) VALUES (?, ?, ?, NOW())";
            stmt = conn.prepareStatement(query);
            stmt.setInt(1, postId);
            stmt.setInt(2, userId);
            stmt.setString(3, body);
            stmt.executeUpdate();

            response.sendRedirect("viewPost.jsp?id=" + postId);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("viewPost.jsp?id=" + postId + "&error=Unable to add comment");
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
