package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.postkuy.util.DBConnector;
import org.mindrot.jbcrypt.BCrypt;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String name = request.getParameter("name");
        String email = request.getParameter("email");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnector.getConnection(); // Menggunakan DBConnector untuk koneksi database
            
            // Periksa apakah username atau email sudah terdaftar
            String checkQuery = "SELECT COUNT(*) FROM users WHERE username = ? OR email = ?";
            stmt = conn.prepareStatement(checkQuery);
            stmt.setString(1, username);
            stmt.setString(2, email);
            rs = stmt.executeQuery();
            rs.next();

            if (rs.getInt(1) > 0) {
                // Jika username atau email sudah ada, kembali ke halaman registrasi dengan pesan error
                request.setAttribute("error", "Username or email already exists.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // Jika tidak ada duplikasi, hash password menggunakan BCrypt
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
            // Catat waktu registrasi dan update
            String currentTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

            // Simpan data pengguna ke database
            String query = "INSERT INTO users (username, password, name, email, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, username);
            stmt.setString(2, hashedPassword);
            stmt.setString(3, name);
            stmt.setString(4, email);
            stmt.setString(5, currentTime); // created_at
            stmt.setString(6, currentTime); // updated_at
            stmt.executeUpdate();

            // Ambil ID pengguna yang baru saja dibuat
            rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                int userId = rs.getInt(1);

                // Buat sesi login otomatis
                HttpSession session = request.getSession();
                session.setAttribute("userId", userId);
                session.setAttribute("username", username);

                // Redirect ke halaman utama (home.jsp)
                response.sendRedirect("home.jsp");
                return;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            // Jika terjadi error, tetap redirect ke halaman registrasi dengan pesan error
            request.setAttribute("error", "An error occurred during registration. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);

        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Menampilkan halaman registrasi
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
}
