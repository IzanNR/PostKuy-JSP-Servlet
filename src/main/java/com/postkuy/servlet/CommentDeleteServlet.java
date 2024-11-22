package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.postkuy.util.DBConnector;

public class CommentDeleteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int commentId = Integer.parseInt(request.getParameter("comment_id"));

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnector.getConnection();

            // Check if the comment belongs to the logged-in user
            String checkQuery = "SELECT user_id FROM comments WHERE id = ?";
            stmt = conn.prepareStatement(checkQuery);
            stmt.setInt(1, commentId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next() && rs.getInt("user_id") == userId) {
                String deleteQuery = "DELETE FROM comments WHERE id = ?";
                stmt = conn.prepareStatement(deleteQuery);
                stmt.setInt(1, commentId);
                stmt.executeUpdate();
            }

            response.sendRedirect(request.getHeader("Referer")); // Redirect back to the post page
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
