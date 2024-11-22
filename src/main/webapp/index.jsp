<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PostKuy! - Posts</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="icon" type="image/x-icon" href="img/favicon.ico">

</head>
<body>
    <%@ include file="navbar.jsp" %>

    <div class="container content">
        <div style="margin-bottom: 20px;"></div>

        <%
            // Ambil parameter pencarian dari request
            String searchQuery = request.getParameter("search");
            String userIdQuery = request.getParameter("id");

            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            Integer loggedInUserId = (Integer) session.getAttribute("userId");

            try {
                conn = com.postkuy.util.DBConnector.getConnection();

                // Query pencarian dengan parameter
                String query = "SELECT posts.id, posts.title, posts.body, users.id AS author_id, users.name AS author_name, " +
                               "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id AND vote_type = 'upvote') AS upvotes, " +
                               "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id AND vote_type = 'downvote') AS downvotes, " +
                               "(SELECT vote_type FROM votes WHERE post_id = posts.id AND user_id = ?) AS user_vote " +
                               "FROM posts " +
                               "JOIN users ON posts.user_id = users.id " +
                               "WHERE (posts.title LIKE ? OR users.id = ?) " +
                               "ORDER BY posts.created_at DESC";

                stmt = conn.prepareStatement(query);
                stmt.setInt(1, loggedInUserId != null ? loggedInUserId : -1); // Parameter untuk user_vote
                stmt.setString(2, "%" + (searchQuery != null ? searchQuery : "") + "%"); // Pencarian judul
                if (userIdQuery != null && !userIdQuery.isEmpty()) {
                    stmt.setInt(3, Integer.parseInt(userIdQuery)); // Pencarian berdasarkan ID user
                } else {
                    stmt.setNull(3, java.sql.Types.INTEGER); // Null jika tidak ada parameter ID
                }

                rs = stmt.executeQuery();

                if (!rs.isBeforeFirst()) {
        %>
            <p>No posts found matching your criteria.</p>
        <%
                } else {
                    while (rs.next()) {
                        String userVote = rs.getString("user_vote");
        %>
            <div class="card post-card mt-3" id="post-<%= rs.getInt("id") %>">
                <div class="card-body">
                    <h5 class="card-title">
                        <a href="viewPost.jsp?id=<%= rs.getInt("id") %>" class="post-title"><%= rs.getString("title") %></a>
                    </h5>
                    <p class="card-text"><%= rs.getString("body") %></p>
                    <p class="card-text">
                        <small class="text-muted">
                            by <a href="userProfile.jsp?id=<%= rs.getInt("author_id") %>"><%= rs.getString("author_name") %></a>
                        </small>
                    </p>
                    
                    <div class="vote-buttons">
                        <form action="vote" method="POST" style="display:inline;">
                            <input type="hidden" name="post_id" value="<%= rs.getInt("id") %>">
                            <input type="hidden" name="vote_type" value="upvote">
                            <button type="submit" class="btn btn-sm vote-button upvote <%= "upvote".equals(userVote) ? "voted" : "" %>">
                                <i class="fas fa-thumbs-up"></i> <span class="upvote-count"><%= rs.getInt("upvotes") %></span>
                            </button>
                        </form>
                        <form action="vote" method="POST" style="display:inline;">
                            <input type="hidden" name="post_id" value="<%= rs.getInt("id") %>">
                            <input type="hidden" name="vote_type" value="downvote">
                            <button type="submit" class="btn btn-sm vote-button downvote <%= "downvote".equals(userVote) ? "voted" : "" %>">
                                <i class="fas fa-thumbs-down"></i> <span class="downvote-count"><%= rs.getInt("downvotes") %></span>
                            </button>
                        </form>
                    </div>

                    <a href="viewPost.jsp?id=<%= rs.getInt("id") %>" class="btn btn-primary mt-3">View</a>
                </div>
            </div>
        <%
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
        %>

    </div>

    <%-- Fixed Button for Posting --%>
    <% if (loggedInUserId != null) { %>
        <a href="postCreate.jsp" class="btn btn-success fixed-button">Post!</a>
    <% } %>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="js/script.js"></script>
</body>
</html>
