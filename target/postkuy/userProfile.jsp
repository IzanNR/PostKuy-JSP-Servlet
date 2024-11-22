<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PostKuy! - User Profile</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="icon" type="image/x-icon" href="img/favicon.ico">
</head>
<body>
    <%@ include file="navbar.jsp" %>

    <div class="container content mt-5">
        <%
            int userId = Integer.parseInt(request.getParameter("id"));
            Connection conn = null;
            PreparedStatement userStmt = null;
            PreparedStatement postStmt = null;
            ResultSet userRs = null;
            ResultSet postRs = null;

            boolean isLoggedIn = session.getAttribute("userId") != null;
            Integer loggedInUserId = isLoggedIn ? (Integer) session.getAttribute("userId") : null;

            try {
                conn = com.postkuy.util.DBConnector.getConnection();

                // Query untuk mendapatkan detail user
                String userQuery = "SELECT id, name, username, email FROM users WHERE id = ?";
                userStmt = conn.prepareStatement(userQuery);
                userStmt.setInt(1, userId);
                userRs = userStmt.executeQuery();

                if (userRs.next()) {
        %>
        <div class="card profile-card" style="margin-top: 90px;">
            <div class="card-body">
                <h3 class="card-title"><%= userRs.getString("name") %></h3>
                <p class="card-text"><strong>ID:</strong> <%= userRs.getInt("id") %></p>
                <p class="card-text"><strong>Username:</strong> <%= userRs.getString("username") %></p>
                <p class="card-text"><strong>Email:</strong> <%= userRs.getString("email") %></p>
            </div>
        </div>

        <h4>User's Posts:</h4>
        <%
                    // Query untuk mendapatkan semua post user
                    String postQuery = "SELECT posts.id, posts.title, posts.body, " +
                                       "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id AND vote_type = 'upvote') AS upvotes, " +
                                       "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id AND vote_type = 'downvote') AS downvotes, " +
                                       "(SELECT vote_type FROM votes WHERE post_id = posts.id AND user_id = ?) AS user_vote " +
                                       "FROM posts WHERE user_id = ? ORDER BY posts.created_at DESC";
                    postStmt = conn.prepareStatement(postQuery);
                    postStmt.setInt(1, loggedInUserId != null ? loggedInUserId : -1);
                    postStmt.setInt(2, userId);
                    postRs = postStmt.executeQuery();

                    while (postRs.next()) {
                        String userVote = postRs.getString("user_vote");
        %>
        <div class="card post-card mt-3" id="post-<%= postRs.getInt("id") %>">
            <div class="card-body">
                <h5 class="card-title">
                    <a href="viewPost.jsp?id=<%= postRs.getInt("id") %>" class="post-title"><%= postRs.getString("title") %></a>
                </h5>
                <p class="card-text"><%= postRs.getString("body") %></p>
                <p class="card-text">
                    <small class="text-muted">
                        by <a href="userProfile.jsp?id=<%= userId %>"><%= userRs.getString("name") %></a>
                    </small>
                </p>
                
                <div class="vote-buttons">
                    <form action="vote" method="POST" style="display:inline;">
                        <input type="hidden" name="post_id" value="<%= postRs.getInt("id") %>">
                        <input type="hidden" name="vote_type" value="upvote">
                        <button type="submit" class="btn btn-sm vote-button upvote <%= "upvote".equals(userVote) ? "voted" : "" %>">
                            <i class="fas fa-thumbs-up"></i> <span class="upvote-count"><%= postRs.getInt("upvotes") %></span>
                        </button>
                    </form>
                    <form action="vote" method="POST" style="display:inline;">
                        <input type="hidden" name="post_id" value="<%= postRs.getInt("id") %>">
                        <input type="hidden" name="vote_type" value="downvote">
                        <button type="submit" class="btn btn-sm vote-button downvote <%= "downvote".equals(userVote) ? "voted" : "" %>">
                            <i class="fas fa-thumbs-down"></i> <span class="downvote-count"><%= postRs.getInt("downvotes") %></span>
                        </button>
                    </form>
                </div>

                <a href="viewPost.jsp?id=<%= postRs.getInt("id") %>" class="btn btn-primary mt-3">View</a>

                <% if (isLoggedIn && loggedInUserId.equals(userId)) { %>
                <button type="button" class="btn btn-danger mt-3" 
                        data-toggle="modal" data-target="#deleteModal" 
                        onclick="setDeleteAction('postDelete', <%= postRs.getInt("id") %>, null)">
                    Delete
                </button>
                <% } %>
            </div>
        </div>
        <%
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (userRs != null) userRs.close();
                if (postRs != null) postRs.close();
                if (userStmt != null) userStmt.close();
                if (postStmt != null) postStmt.close();
                if (conn != null) conn.close();
            }
        %>
    </div>

    <%-- Fixed Button for Posting --%>
    <% if (loggedInUserId != null) { %>
        <a href="postCreate.jsp" class="btn btn-success fixed-button">Post!</a>
    <% } %>

    <%@ include file="deleteModal.jsp" %>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        function setDeleteAction(action, postId, commentId) {
            const form = document.getElementById('deleteForm');
            const deletePostId = document.getElementById('deletePostId');
            const deleteCommentId = document.getElementById('deleteCommentId');

            form.action = action;
            deletePostId.value = postId || '';
            deleteCommentId.value = commentId || '';
        }
    </script>
    <script src="js/script.js"></script>
</body>
</html>
