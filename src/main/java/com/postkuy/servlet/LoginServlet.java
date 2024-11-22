package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import com.postkuy.util.DBConnector;
import org.mindrot.jbcrypt.BCrypt;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnector.getConnection(); // Gunakan DBConnector untuk koneksi database
            String query = "SELECT * FROM users WHERE username = ?";
            stmt = conn.prepareStatement(query);
            stmt.setString(1, username);
            rs = stmt.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("password");

                // Periksa apakah password disimpan dalam bentuk hash (BCrypt)
                boolean isPasswordValid;
                if (storedPassword.startsWith("$2a$")) {
                    // Hash BCrypt
                    isPasswordValid = BCrypt.checkpw(password, storedPassword);
                } else {
                    // Teks biasa
                    isPasswordValid = password.equals(storedPassword);
                }

                if (isPasswordValid) {
                    // Login berhasil
                    HttpSession session = request.getSession();
                    session.setAttribute("userId", rs.getInt("id"));
                    session.setAttribute("username", rs.getString("username"));

                    // Perbarui kolom `updated_at` untuk mencatat waktu login terakhir
                    String updateQuery = "UPDATE users SET updated_at = NOW() WHERE id = ?";
                    PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
                    updateStmt.setInt(1, rs.getInt("id"));
                    updateStmt.executeUpdate();

                    response.sendRedirect("home.jsp");
                } else {
                    // Password salah
                    request.setAttribute("error", "Invalid username or password.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                // Username tidak ditemukan
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
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
        // Menampilkan halaman login
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
