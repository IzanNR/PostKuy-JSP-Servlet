package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.postkuy.util.DBConnector;

public class UserProfileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("id"));
        Connection conn = null;
        PreparedStatement userStmt = null;
        PreparedStatement postStmt = null;
        ResultSet userRs = null;
        ResultSet postRs = null;

        try {
            conn = DBConnector.getConnection();

            // Query user details
            String userQuery = "SELECT id, name, username, email FROM users WHERE id = ?";
            userStmt = conn.prepareStatement(userQuery);
            userStmt.setInt(1, userId);
            userRs = userStmt.executeQuery();

            if (userRs.next()) {
                request.setAttribute("userId", userRs.getInt("id"));
                request.setAttribute("name", userRs.getString("name"));
                request.setAttribute("username", userRs.getString("username"));
                request.setAttribute("email", userRs.getString("email"));

                // Query user posts
                String postQuery = "SELECT id, title, body FROM posts WHERE user_id = ? ORDER BY created_at DESC";
                postStmt = conn.prepareStatement(postQuery);
                postStmt.setInt(1, userId);
                postRs = postStmt.executeQuery();

                request.setAttribute("posts", postRs);
                RequestDispatcher dispatcher = request.getRequestDispatcher("userProfile.jsp");
                dispatcher.forward(request, response);
            } else {
                response.sendRedirect("error.jsp");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (userRs != null) userRs.close();
                if (postRs != null) postRs.close();
                if (userStmt != null) userStmt.close();
                if (postStmt != null) postStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
