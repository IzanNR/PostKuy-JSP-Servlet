<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PostKuy! - Home</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="icon" type="image/x-icon" href="img/favicon.ico">

</head>
<body>
    <%@ include file="navbar.jsp" %>

    <div class="container content">
        <!-- Welcome Section -->
        <div class="card mt-4">
            <div class="card-body text-center">
                <h1>PostKuy!</h1>
                <p>What do others think?</p>
                <%
                    boolean isLoggedIn = session.getAttribute("userId") != null;
                    Integer loggedInUserId = (Integer) session.getAttribute("userId");
                %>
                <% if (isLoggedIn) { %>
                    <p>Welcome, <%= session.getAttribute("username") %>! Ready to share your thoughts?</p>
                    <div>
                        <a href="postCreate.jsp" class="btn btn-success">PostKuy!</a>
                        <a href="index.jsp" class="btn btn-primary">View Posts</a>
                    </div>
                <% } else { %>
                    <div>
                        <a href="login.jsp" class="btn btn-success">PostKuy!</a>
                        <p class="mt-3">Don't have an account yet?</p>
                        <a href="register.jsp" class="btn btn-primary">Register</a>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Trending Posts Section -->
        <% if (isLoggedIn) { %>
        <div class="mt-4">
            <h3 class="text-center">Trending this Week</h3>
            <%
                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;
                try {
                    conn = com.postkuy.util.DBConnector.getConnection();

                    // Query untuk mendapatkan 5 post terakhir dalam 7 hari dengan jumlah vote terbanyak
                    String query = "SELECT posts.id, posts.title, posts.body, users.id AS author_id, users.name AS author_name, " +
                                   "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id AND vote_type = 'upvote') AS upvotes, " +
                                   "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id AND vote_type = 'downvote') AS downvotes, " +
                                   "(SELECT vote_type FROM votes WHERE post_id = posts.id AND user_id = ?) AS user_vote, " +
                                   "(SELECT COUNT(*) FROM votes WHERE post_id = posts.id) AS total_votes " +
                                   "FROM posts " +
                                   "JOIN users ON posts.user_id = users.id " +
                                   "WHERE posts.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
                                   "ORDER BY total_votes DESC, posts.created_at DESC " +
                                   "LIMIT 5";
                    stmt = conn.prepareStatement(query);
                    stmt.setInt(1, loggedInUserId);
                    rs = stmt.executeQuery();

                    while (rs.next()) {
                        String userVote = rs.getString("user_vote"); // Nilai vote user saat ini
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
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                }
            %>
        </div>
        <% } %>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="js/script.js"></script>
</body>
</html>
