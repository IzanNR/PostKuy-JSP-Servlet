<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PostKuy! - Create Post</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="icon" type="image/x-icon" href="img/favicon.ico">

</head>
<body>
    <%@ include file="navbar.jsp" %>

    <div class="container content mt-5">
        <div class="card form-card" style="margin-top: 90px;">
            <div class="card-body">
                <h2 class="card-title">Create a New Post</h2>

                <% 
                    // Check if user is logged in
                    if (session.getAttribute("userId") == null) {
                        response.sendRedirect("login.jsp");
                        return;
                    }

                    // Display error message if exists
                    String errorMessage = (String) request.getAttribute("errorMessage");
                    if (errorMessage != null) { 
                %>
                    <div class="alert alert-danger">
                        <%= errorMessage %>
                    </div>
                <% } %>

                <form action="postCreate" method="POST">
                    <div class="form-group">
                        <label for="title">Title</label>
                        <input type="text" name="title" id="title" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label for="body">Body</label>
                        <textarea name="body" id="body" class="form-control" rows="5" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">Create Post</button>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="js/script.js"></script>
</body>
</html>
