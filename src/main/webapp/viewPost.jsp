<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PostKuy! - View Post</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="icon" type="image/x-icon" href="img/favicon.ico">
</head>
<body>
    <%@ include file="navbar.jsp" %>

    <div class="container post-detail mt-5">
        <a href="index.jsp" class="btn btn-primary mb-4" style="margin-top: 50px;">Back to Posts List</a>

        <%
            int postId = Integer.parseInt(request.getParameter("id"));
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            ResultSet commentsRs = null;
            boolean isLoggedIn = session.getAttribute("userId") != null;
            Integer loggedInUserId = isLoggedIn ? (Integer) session.getAttribute("userId") : null;

            try {
                conn = com.postkuy.util.DBConnector.getConnection();
                
                String postQuery = "SELECT posts.id, posts.title, posts.body, users.name AS author_name, users.id AS author_id, " +
                                   "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id AND vote_type = 'upvote') AS upvotes, " +
                                   "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id AND vote_type = 'downvote') AS downvotes, " +
                                   "(SELECT vote_type FROM votes WHERE post_id = posts.id AND user_id = ?) AS user_vote " +
                                   "FROM posts " +
                                   "JOIN users ON posts.user_id = users.id " +
                                   "WHERE posts.id = ?";
                stmt = conn.prepareStatement(postQuery);
                stmt.setInt(1, loggedInUserId != null ? loggedInUserId : -1);
                stmt.setInt(2, postId);
                rs = stmt.executeQuery();

                if (rs.next()) {
                    String userVote = rs.getString("user_vote");
        %>
        <div class="card">
            <div class="card-body">
                <h2 class="card-title"><%= rs.getString("title") %></h2>
                <p class="card-text"><%= rs.getString("body") %></p>
                <p class="card-text">
                    <small class="text-muted">
                        by <a href="userProfile.jsp?id=<%= rs.getInt("author_id") %>"><%= rs.getString("author_name") %></a>
                    </small>
                </p>

                <div class="vote-buttons" id="post-<%= postId %>">
                    <button class="btn btn-sm vote-button upvote <%= "upvote".equals(userVote) ? "voted" : "" %>" data-post-id="<%= postId %>" data-vote-type="upvote">
                        <i class="fas fa-thumbs-up"></i> <span class="upvote-count"><%= rs.getInt("upvotes") %></span>
                    </button>
                    <button class="btn btn-sm vote-button downvote <%= "downvote".equals(userVote) ? "voted" : "" %>" data-post-id="<%= postId %>" data-vote-type="downvote">
                        <i class="fas fa-thumbs-down"></i> <span class="downvote-count"><%= rs.getInt("downvotes") %></span>
                    </button>
                </div>
                
                <% if (isLoggedIn && loggedInUserId.equals(rs.getInt("author_id"))) { %>
                <button type="button" class="btn btn-danger mt-3" 
                        data-toggle="modal" data-target="#deleteModal" 
                        onclick="setDeleteAction('postDelete', <%= postId %>, null)">
                    Delete Post
                </button>
                <% } %>

                <div class="comments mt-4">
                    <h4>Comments</h4>
                    <%
                        String commentsQuery = "SELECT comments.id, comments.body, users.name AS commenter_name, users.id AS commenter_id " +
                                               "FROM comments " +
                                               "JOIN users ON comments.user_id = users.id " +
                                               "WHERE comments.post_id = ? ORDER BY comments.created_at ASC";
                        PreparedStatement commentsStmt = conn.prepareStatement(commentsQuery);
                        commentsStmt.setInt(1, postId);
                        commentsRs = commentsStmt.executeQuery();
                        while (commentsRs.next()) {
                    %>
                    <div class="comment">
                        <p><strong><a href="userProfile.jsp?id=<%= commentsRs.getInt("commenter_id") %>"><%= commentsRs.getString("commenter_name") %></a>:</strong></p>
                        <p class="comment-text"><%= commentsRs.getString("body") %></p>
                        <% if (isLoggedIn && loggedInUserId.equals(commentsRs.getInt("commenter_id"))) { %>
                        <button type="button" class="btn btn-danger btn-sm mt-2" 
                                data-toggle="modal" data-target="#deleteModal" 
                                onclick="setDeleteAction('commentDelete', null, <%= commentsRs.getInt("id") %>)">
                            Delete
                        </button>
                        <% } %>
                    </div>
                    <% } %>
                </div>

                <% if (isLoggedIn) { %>
                <div class="mt-4">
                    <h4>Add a Comment</h4>
                    <form action="commentCreate" method="POST">
                        <input type="hidden" name="post_id" value="<%= postId %>">
                        <input type="hidden" name="user_id" value="<%= loggedInUserId %>">
                        <div class="form-group">
                            <label for="body">Comment</label>
                            <textarea name="body" id="body" class="form-control" required></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary">Submit</button>
                    </form>
                </div>
                <% } %>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (commentsRs != null) commentsRs.close();
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
