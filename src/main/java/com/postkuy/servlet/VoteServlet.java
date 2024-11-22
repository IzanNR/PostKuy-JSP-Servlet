package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.postkuy.util.DBConnector;
import org.json.JSONObject;

public class VoteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        // Jika user belum login, kembalikan status error
        if (userId == null) {
            response.setContentType("application/json");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false, \"message\": \"User not logged in.\"}");
            return;
        }

        int postId = Integer.parseInt(request.getParameter("post_id"));
        String voteType = request.getParameter("vote_type"); // 'upvote' atau 'downvote'

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnector.getConnection();

            // Cek apakah user sudah pernah vote sebelumnya
            String checkQuery = "SELECT vote_type FROM votes WHERE user_id = ? AND post_id = ?";
            stmt = conn.prepareStatement(checkQuery);
            stmt.setInt(1, userId);
            stmt.setInt(2, postId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String existingVote = rs.getString("vote_type");
                if (existingVote.equals(voteType)) {
                    // Jika vote sama, hapus vote (toggle)
                    String deleteQuery = "DELETE FROM votes WHERE user_id = ? AND post_id = ?";
                    stmt = conn.prepareStatement(deleteQuery);
                    stmt.setInt(1, userId);
                    stmt.setInt(2, postId);
                    stmt.executeUpdate();
                } else {
                    // Jika vote berbeda, update vote
                    String updateQuery = "UPDATE votes SET vote_type = ? WHERE user_id = ? AND post_id = ?";
                    stmt = conn.prepareStatement(updateQuery);
                    stmt.setString(1, voteType);
                    stmt.setInt(2, userId);
                    stmt.setInt(3, postId);
                    stmt.executeUpdate();
                }
            } else {
                // Jika belum pernah vote, tambahkan vote baru
                String insertQuery = "INSERT INTO votes (user_id, post_id, vote_type) VALUES (?, ?, ?)";
                stmt = conn.prepareStatement(insertQuery);
                stmt.setInt(1, userId);
                stmt.setInt(2, postId);
                stmt.setString(3, voteType);
                stmt.executeUpdate();
            }

            // Hitung ulang jumlah upvote dan downvote
            String countQuery = "SELECT " +
                    "(SELECT COUNT(*) FROM votes WHERE post_id = ? AND vote_type = 'upvote') AS upvotes, " +
                    "(SELECT COUNT(*) FROM votes WHERE post_id = ? AND vote_type = 'downvote') AS downvotes";
            stmt = conn.prepareStatement(countQuery);
            stmt.setInt(1, postId);
            stmt.setInt(2, postId);
            rs = stmt.executeQuery();

            int upvotes = 0, downvotes = 0;
            if (rs.next()) {
                upvotes = rs.getInt("upvotes");
                downvotes = rs.getInt("downvotes");
            }

            // Kirimkan response JSON
            JSONObject jsonResponse = new JSONObject();
            jsonResponse.put("success", true);
            jsonResponse.put("upvotes", upvotes);
            jsonResponse.put("downvotes", downvotes);

            response.setContentType("application/json");
            response.getWriter().write(jsonResponse.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Error processing vote.\"}");
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
