package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.postkuy.util.DBConnector;

public class PostDeleteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int postId = Integer.parseInt(request.getParameter("post_id"));

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnector.getConnection();

            // Check if the post belongs to the logged-in user
            String checkQuery = "SELECT user_id FROM posts WHERE id = ?";
            stmt = conn.prepareStatement(checkQuery);
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next() && rs.getInt("user_id") == userId) {
                // Delete comments associated with the post
                String deleteCommentsQuery = "DELETE FROM comments WHERE post_id = ?";
                stmt = conn.prepareStatement(deleteCommentsQuery);
                stmt.setInt(1, postId);
                stmt.executeUpdate();

                // Delete the post itself
                String deletePostQuery = "DELETE FROM posts WHERE id = ?";
                stmt = conn.prepareStatement(deletePostQuery);
                stmt.setInt(1, postId);
                stmt.executeUpdate();
            }

            response.sendRedirect("index.jsp"); // Redirect to the post list
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
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
