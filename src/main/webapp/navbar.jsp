<nav class="navbar navbar-expand-lg fixed-top">
    <!-- Logo -->
    <a class="navbar-brand" href="home.jsp">
        <img src="img/android-chrome-512x512.png" alt="Logo" width="40" height="40">
    </a>

    <!-- Toggle Switch for Dark Mode -->
    <div class="theme-switch ml-3">
        <label>
            <input type="checkbox" id="theme-toggle">
            <span class="slider"></span>
        </label>
    </div>

    <!-- Navbar Toggler for Small Screens -->
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>

    <!-- Navbar Links -->
    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mr-auto">
            <!-- Home Link -->
            <li class="nav-item"><a class="nav-link" href="home.jsp">Home</a></li>
            <!-- Posts Link -->
            <li class="nav-item"><a class="nav-link" href="index.jsp">Posts</a></li>

            <% 
                // Periksa apakah user telah login
                String username = (String) session.getAttribute("username");
                if (username != null) { 
            %>
                <!-- Profile Link -->
                <li class="nav-item">
                    <a class="nav-link" href="userProfile.jsp?id=<%= (Integer) session.getAttribute("userId") %>">Profile (<%= username %>)</a>
                </li>
                <!-- Logout Button -->
                <li class="nav-item">
                    <form action="logout" method="POST" class="form-inline">
                        <button class="nav-link btn btn-link" type="submit" style="cursor: pointer;">Logout</button>
                    </form>
                </li>
            <% } else { %>
                <!-- Login and Register Links -->
                <li class="nav-item"><a class="nav-link" href="login.jsp">Login</a></li>
                <li class="nav-item"><a class="nav-link" href="register.jsp">Register</a></li>
            <% } %>
        </ul>

        <!-- Search Bar -->
        <form method="GET" action="index.jsp" class="navbar-search form-inline">
            <input type="text" name="search" class="form-control mr-2" placeholder="Search">
            <button type="submit" class="btn btn-outline-primary">Search</button>
        </form>
        
    </div>
</nav>
