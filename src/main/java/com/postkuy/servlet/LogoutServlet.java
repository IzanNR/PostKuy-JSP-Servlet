package com.postkuy.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;

public class LogoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Hapus session
        HttpSession session = request.getSession(false); // Ambil session jika ada
        if (session != null) {
            session.invalidate(); // Hapus session
        }

        // Redirect ke halaman login atau home
        response.sendRedirect("home.jsp");
    }
}
